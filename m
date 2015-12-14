From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC radvd 2/2] radvd: rework 6CO handling
Date: Mon, 14 Dec 2015 15:07:36 +0100
Message-ID: <1450102056-23107-3-git-send-email-alex.aring@gmail.com>
References: <1450102056-23107-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	martin.gergeleit-6wGqcYweBVc@public.gmane.org, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450102056-23107-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Current issues with the 6CO handling:
 - Doesn't work on little endian at my side because forgotten
   byteordering handling at bitfields.
 - There can be multiple 6CO options. Up to 16 6CO options at maximum.
 - It doesn't work as it should. Maybe for some use-case somebody need
   that, but 6CO contains information for header parsing and this need
   functionality to tell it the kernel. Currently we have a debugfs entry
   for that.

As an example, RFC6775 describes the 6LBR should be configurated and
managed the context entries of RFC6282.

interface lowpan0
{
        Adv6LBR on;
        AdvSendAdvert on;
        UnicastOnly on;
        AdvCurHopLimit 255;

        prefix 2001::/64 {
                AdvOnLink on;
                AdvAutonomous on;
                AdvRouterAddr on;
        };

        lowpanco {
                ctx 0 {
                        AdvContextCompressionFlag on;
                        AdvContextLength 64;
                        AdvContextPrefix 2001::;
                        AdvLifeTime 1000;
                };
        };
};

If we set "Adv6LBR" to on, then the "lowpanco" contexts will be setup
during startup of radvd, otherwise all contexts are empty (non active).

I changed the parsing of contexts:
 - lowpanco contains up-to 16 contexts with _unique_ id's.
 - The id is after "ctx" specified.

What doesn't work:
 - Lifetime handling.
 - AdvContextCompressionFlag should be 0 at first to propagate "safety"
   the context inside the context. RFC6775 says here:

   New context information SHOULD be introduced into the LoWPAN with C=0,
   to ensure that it is known by all nodes that may have to perform header
   decompression based on this context information. Only when it is
   reasonable to assume that this information was successfully
   disseminated SHOULD an option with C=1 be sent, enabling the actual
   use of the context information for compression

   I know what this means, but then don't know "when" we can do "C=1",
   maybe this is out-of-scope in RFC6775.

Note:
 I ignore the ABRO for now. The ABRO need to be included and the version
 fields indicates if new context or old context information. This is
 just to begin with something to handle 6CO.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 defaults.h      |  3 +++
 device-bsd44.c  |  6 ++++++
 device-linux.c  | 35 +++++++++++++++++++++++++++++++++++
 gram.y          | 55 ++++++++++++++++++++++++++++++++++++++++++++++---------
 pathnames.h     |  1 +
 privsep-linux.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 process.c       | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 radvd.c         |  6 ++++++
 radvd.h         | 21 +++++++++++++++++++--
 scanner.l       |  4 +++-
 send.c          | 33 ++++++++++++++++++++++++---------
 11 files changed, 245 insertions(+), 22 deletions(-)

diff --git a/defaults.h b/defaults.h
index fedd546..a328793 100644
--- a/defaults.h
+++ b/defaults.h
@@ -125,6 +125,9 @@
 
 #define MAX_PrefixLen			128
 
+/* RFC6282 Constraints */
+#define MAX_CIDLen			16
+
 /* SLAAC (RFC4862) Constants and Derived Values */
 #define MIN_AdvValidLifetime		7200	/* 2 hours in secs */
 
diff --git a/device-bsd44.c b/device-bsd44.c
index f1aacca..6d4d838 100644
--- a/device-bsd44.c
+++ b/device-bsd44.c
@@ -143,6 +143,12 @@ int set_interface_retranstimer(const char *iface, uint32_t rettimer)
 	return -1;
 }
 
+int set_interface_6ctx(const struct Interface *iface, struct AdvLowpanCtx ctx)
+{
+	dlog(LOG_DEBUG, 4, "update 6LoWPAN context not supported");
+	return 0;
+}
+
 int check_ip6_forwarding(void)
 {
 	dlog(LOG_DEBUG, 4, "checking ipv6 forwarding not supported");
diff --git a/device-linux.c b/device-linux.c
index 7301927..c9b516f 100644
--- a/device-linux.c
+++ b/device-linux.c
@@ -86,6 +86,30 @@ int update_device_info(int sock, struct Interface *iface)
 	case ARPHRD_6LOWPAN:
 		iface->sllao.if_hwaddr_len = 64;
 		iface->sllao.if_prefix_len = 64;
+
+		if (iface->state_info.configured)
+			break;
+
+		/* if nothing specified use a empy AdvLowpanCoList as default */
+		if (!iface->AdvLowpanCoList) {
+			iface->AdvLowpanCoList = malloc(sizeof(struct AdvLowpanCo));
+			if (iface->AdvLowpanCoList == NULL) {
+				flog(LOG_ERR, "AdvLowpanCo allocation failed");
+				return -2;
+			}
+
+			memset(iface->AdvLowpanCoList, 0, sizeof(struct AdvLowpanCo));
+		} else {
+			/* If the LoWPAN uses header compression [RFC6282] with context, then
+			 * the 6LBR must be configured with context information and related
+			 * CIDs. Zero all if non 6LBR.
+			 */
+			if (!iface->Adv6LBR)
+				memset(iface->AdvLowpanCoList, 0, sizeof(struct AdvLowpanCo));
+		}
+
+		for (int i = 0; i < MAX_CIDLen - 1; i++)
+			iface->AdvLowpanCoList->table[i].AdvContextID = i;
 		break;
 	default:
 		iface->sllao.if_hwaddr_len = -1;
@@ -147,6 +171,17 @@ int setup_allrouters_membership(int sock, struct Interface *iface)
 	return 0;
 }
 
+int set_interface_6ctx(const struct Interface *iface, struct AdvLowpanCtx ctx)
+{
+	int ret;
+
+	ret = privsep_interface_6ctx(iface->props.name, ctx);
+	if (ret == 0)
+		iface->AdvLowpanCoList->table[ctx.AdvContextID] = ctx;
+
+	return ret;
+}
+
 int set_interface_linkmtu(const char *iface, uint32_t mtu)
 {
 	return privsep_interface_linkmtu(iface, mtu);
diff --git a/gram.y b/gram.y
index fdab34d..33e6e33 100644
--- a/gram.y
+++ b/gram.y
@@ -53,6 +53,7 @@ static struct in6_addr get_prefix6(struct in6_addr const *addr, struct in6_addr
 %token		T_DNSSL
 %token		T_CLIENTS
 %token		T_LOWPANCO
+%token		T_CTX
 %token		T_ABRO
 
 %token	<str>	STRING
@@ -111,9 +112,10 @@ static struct in6_addr get_prefix6(struct in6_addr const *addr, struct in6_addr
 
 %token		T_AdvMobRtrSupportFlag
 
+%token		T_Adv6LBR;
+
 %token		T_AdvContextLength
 %token		T_AdvContextCompressionFlag
-%token		T_AdvContextID
 %token		T_AdvLifeTime
 %token		T_AdvContextPrefix
 
@@ -159,6 +161,7 @@ static struct AdvRoute *route;
 static struct AdvRDNSS *rdnss;
 static struct AdvDNSSL *dnssl;
 static struct AdvLowpanCo *lowpanco;
+static struct AdvLowpanCtx *lowpanctx;
 static struct AdvAbro  *abro;
 static void cleanup(void);
 #define ABORT	do { cleanup(); YYABORT; } while (0);
@@ -228,7 +231,7 @@ ifaceparam 	: ifaceval
 		| routedef 	{ ADD_TO_LL(struct AdvRoute, AdvRouteList, $1); }
 		| rdnssdef 	{ ADD_TO_LL(struct AdvRDNSS, AdvRDNSSList, $1); }
 		| dnssldef 	{ ADD_TO_LL(struct AdvDNSSL, AdvDNSSLList, $1); }
-		| lowpancodef   { ADD_TO_LL(struct AdvLowpanCo, AdvLowpanCoList, $1); }
+		| lowpancodef	{ ADD_TO_LL(struct AdvLowpanCo, AdvLowpanCoList, $1); }
 		| abrodef       { ADD_TO_LL(struct AdvAbro, AdvAbroList, $1); }
 		;
 
@@ -328,6 +331,10 @@ ifaceval	: T_MinRtrAdvInterval NUMBER ';'
 		{
 			iface->mipv6.AdvMobRtrSupportFlag = $2;
 		}
+		| T_Adv6LBR SWITCH ';'
+		{
+			iface->Adv6LBR = $2;
+		}
 		;
 
 clientslist	: T_CLIENTS '{' v6addrlist '}' ';'
@@ -913,7 +920,7 @@ dnsslparms	: T_AdvDNSSLLifetime number_or_infinity ';'
 		}
 		;
 
-lowpancodef 	: lowpancohead  '{' optional_lowpancoplist '}' ';'
+lowpancodef 	: lowpancohead '{' ctxlist '}' ';'
 		{
 			$$ = lowpanco;
 			lowpanco = NULL;
@@ -933,6 +940,30 @@ lowpancohead	: T_LOWPANCO
 		}
 		;
 
+ctxlist		: ctxhead '{' optional_lowpancoplist '}' ';'
+		| ctxlist ctxhead '{' optional_lowpancoplist '}' ';'
+		;
+
+ctxhead		: T_CTX NUMBER
+		{
+			if ($2 > MAX_CIDLen - 1)
+			{
+				flog(LOG_ERR, "invalid context id %d in %s, line %d", $2, filename, num_lines);
+				ABORT;
+			}
+
+			lowpanctx = &lowpanco->table[$2];
+
+			if (lowpanctx->active) {
+				flog(LOG_ERR, "context id %d already exists in %s, line %d", $2, filename, num_lines);
+				ABORT;
+			}
+
+			lowpanctx->AdvContextID = $2;
+			lowpanctx->active = 1;
+		}
+		;
+
 optional_lowpancoplist:
 		| lowpancoplist
 		;
@@ -943,19 +974,25 @@ lowpancoplist	: lowpancoplist lowpancoparms
 
 lowpancoparms 	: T_AdvContextLength NUMBER ';'
 		{
-			lowpanco->ContextLength = $2;
+			if ($2 > MAX_PrefixLen)
+			{
+				flog(LOG_ERR, "invalid context prefix length in %s, line %d", filename, num_lines);
+				ABORT;
+			}
+
+			lowpanctx->ContextLength = $2;
 		}
 		| T_AdvContextCompressionFlag SWITCH ';'
 		{
-			lowpanco->ContextCompressionFlag = $2;
+			lowpanctx->ContextCompressionFlag = $2;
 		}
-		| T_AdvContextID NUMBER ';'
+		| T_AdvLifeTime NUMBER ';'
 		{
-			lowpanco->AdvContextID = $2;
+			lowpanctx->AdvLifeTime = $2;
 		}
-		| T_AdvLifeTime NUMBER ';'
+		| T_AdvContextPrefix IPV6ADDR ';'
 		{
-			lowpanco->AdvLifeTime = $2;
+			memcpy(&lowpanctx->AdvContextPrefix, $2, sizeof(struct in6_addr));
 		}
 		;
 
diff --git a/pathnames.h b/pathnames.h
index 580e2b2..6246e49 100644
--- a/pathnames.h
+++ b/pathnames.h
@@ -40,6 +40,7 @@
 #define PROC_SYS_IP6_BASEREACHTIME "/proc/sys/net/ipv6/neigh/%s/base_reachable_time"
 #define PROC_SYS_IP6_RETRANSTIMER_MS "/proc/sys/net/ipv6/neigh/%s/retrans_time_ms"
 #define PROC_SYS_IP6_RETRANSTIMER "/proc/sys/net/ipv6/neigh/%s/retrans_time"
+#define DEBUGFS_6LOWPAN_CTX_TABLE "/sys/kernel/debug/6lowpan/%s/ctx_table"
 #else				/* BSD */
 #define SYSCTL_IP6_FORWARDING CTL_NET, PF_INET6, IPPROTO_IPV6, IPV6CTL_FORWARDING
 #endif
diff --git a/privsep-linux.c b/privsep-linux.c
index a48f52a..7adb92e 100644
--- a/privsep-linux.c
+++ b/privsep-linux.c
@@ -36,15 +36,50 @@ enum privsep_type {
 	SET_INTERFACE_CURHLIM,
 	SET_INTERFACE_REACHTIME,
 	SET_INTERFACE_RETRANSTIMER,
+	SET_INTERFACE_6CO,
 };
 
 /* Command sent over pipe is a fixed size binary structure. */
 struct privsep_command {
 	int type;
 	char iface[IFNAMSIZ];
-	uint32_t val;
+	union {
+		uint32_t val;
+		struct AdvLowpanCtx ctx;
+	};
 };
 
+static void __set_interface_6ctx(const char *iface, const struct AdvLowpanCtx *ctx)
+{
+	char path[PATH_MAX + 1] = {};
+	FILE *ctx_table;
+	uint32_t flags = 0;
+	int ret;
+
+	sprintf(path, DEBUGFS_6LOWPAN_CTX_TABLE, iface);
+	ctx_table = fopen(path, "w");
+	if (!ctx_table) {
+		flog(LOG_ERR, "fopen for %s failed on %s: %s. Context table is invalid now.", path, iface, strerror(errno));
+		return;
+	}
+
+	if (ctx->active)
+		flags |= 0x1;
+	if (ctx->ContextCompressionFlag)
+		flags |= 0x2;
+
+	ret = fprintf(ctx_table, "%d %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x/%d %x", ctx->AdvContextID,
+		      be16toh(ctx->AdvContextPrefix.s6_addr16[0]), be16toh(ctx->AdvContextPrefix.s6_addr16[1]),
+		      be16toh(ctx->AdvContextPrefix.s6_addr16[2]), be16toh(ctx->AdvContextPrefix.s6_addr16[3]),
+		      be16toh(ctx->AdvContextPrefix.s6_addr16[4]), be16toh(ctx->AdvContextPrefix.s6_addr16[5]),
+		      be16toh(ctx->AdvContextPrefix.s6_addr16[6]), be16toh(ctx->AdvContextPrefix.s6_addr16[7]),
+		      ctx->ContextLength, flags);
+	if (ret < 0)
+		flog(LOG_ERR, "Error while setting context table and is invalid now, error: %s", strerror(errno));
+
+	fclose(ctx_table);
+}
+
 /* Privileged read loop */
 static void privsep_read_loop(void)
 {
@@ -112,6 +147,13 @@ static void privsep_read_loop(void)
 			set_interface_var(cmd.iface, PROC_SYS_IP6_RETRANSTIMER, "RetransTimer", cmd.val / 1000 * USER_HZ);	/* XXX user_hz */
 			break;
 
+		case SET_INTERFACE_6CO:
+			if (cmd.ctx.AdvContextID > MAX_CIDLen - 1)
+				break;
+
+			__set_interface_6ctx(cmd.iface, &cmd.ctx);
+			break;
+
 		default:
 			/* Bad command */
 			break;
@@ -174,6 +216,17 @@ int privsep_interface_retranstimer(const char *iface, uint32_t rettimer)
 	return 0;
 }
 
+int privsep_interface_6ctx(const char *iface, struct AdvLowpanCtx ctx)
+{
+	struct privsep_command cmd;
+	cmd.type = SET_INTERFACE_6CO;
+	strncpy(cmd.iface, iface, sizeof(cmd.iface));
+	cmd.ctx = ctx;
+	if (writen(pfd, &cmd, sizeof(cmd)) != sizeof(cmd))
+		return -1;
+	return 0;
+}
+
 /* note: also called from the root context */
 static int set_interface_var(const char *iface, const char *var, const char *name, uint32_t val)
 {
diff --git a/process.c b/process.c
index a6050ad..7176d7d 100644
--- a/process.c
+++ b/process.c
@@ -385,6 +385,54 @@ static void process_ra(struct Interface *iface, unsigned char *msg, int len, str
 				}
 				break;
 			}
+		case ND_OPT_6CO: {
+				struct nd_opt_6co *ctxinfo = (struct nd_opt_6co *)opt_str;
+				struct AdvLowpanCtx ctx = {};
+
+				/* filter 6CO if we don't managed context table */
+				if (!iface->AdvLowpanCoList)
+					return;
+
+				/* TODO really necessary? */
+				if (iface->Adv6LBR)
+					return;
+
+				/* check if we can evaluate the len field */
+				if (len < 2)
+					return;
+
+				switch (ctxinfo->nd_opt_6co_len) {
+				case 2:
+					if (len < (sizeof(*ctxinfo) - 8))
+						return;
+
+					memcpy(&ctx.AdvContextPrefix, &ctxinfo->nd_opt_6co_con_prefix, 8);
+					break;
+				case 3:
+					if (len < (sizeof(*ctxinfo)))
+						return;
+
+					memcpy(&ctx.AdvContextPrefix, &ctxinfo->nd_opt_6co_con_prefix, 16);
+					break;
+				default:
+					return;
+				}
+
+				if (ctxinfo->nd_opt_6co_cid > MAX_CIDLen - 1)
+					return;
+
+				ctx.ContextCompressionFlag = ctxinfo->nd_opt_6co_c;
+				ctx.AdvContextID = ctxinfo->nd_opt_6co_cid;
+				ctx.AdvLifeTime = ctxinfo->nd_opt_6co_valid_lifetime;
+				ctx.ContextLength = ctxinfo->nd_opt_6co_context_len;
+
+				/* If the Valid Lifetime field in the 6CO is zero, then the entry is immediately deleted. */
+				if (ctx.AdvLifeTime)
+					ctx.active = 1;
+
+				set_interface_6ctx(iface, ctx);
+				break;
+			}
 		default:
 			dlog(LOG_DEBUG, 1, "unknown option %d in RA on %s from %s", (int)*opt_str, iface->props.name, addr_str);
 			break;
diff --git a/radvd.c b/radvd.c
index 140cbff..380fc05 100644
--- a/radvd.c
+++ b/radvd.c
@@ -710,6 +710,12 @@ static void config_interface(struct Interface *iface)
 		set_interface_reachtime(iface->props.name, iface->ra_header_info.AdvReachableTime);
 	if (iface->ra_header_info.AdvRetransTimer)
 		set_interface_retranstimer(iface->props.name, iface->ra_header_info.AdvRetransTimer);
+	if (iface->AdvLowpanCoList) {
+		for (int i = 0; i < MAX_CIDLen - 1; i++)
+			set_interface_6ctx(iface, iface->AdvLowpanCoList->table[i]);
+	}
+
+	iface->state_info.configured = 1;
 }
 
 /*
diff --git a/radvd.h b/radvd.h
index f557bf3..f68d527 100644
--- a/radvd.h
+++ b/radvd.h
@@ -60,6 +60,7 @@ struct Interface {
 		int ready;	/* Info whether this interface has been initialized successfully */
 		int changed;	/* Info whether this interface's settings have changed */
 		int cease_adv;
+		int configured;
 		uint32_t racount;
 	} state_info;
 
@@ -112,6 +113,7 @@ struct Interface {
 		int AdvMobRtrSupportFlag;
 	} mipv6;
 
+	int Adv6LBR;
 	struct AdvLowpanCo *AdvLowpanCoList;
 	struct AdvAbro *AdvAbroList;
 
@@ -187,15 +189,20 @@ struct AdvDNSSL {
 	struct AdvDNSSL *next;
 };
 
-/* Options for 6lopan configuration */
+/* Options for 6lowpan configuration */
 
-struct AdvLowpanCo {
+struct AdvLowpanCtx {
 	uint8_t ContextLength;
 	uint8_t ContextCompressionFlag;
 	uint8_t AdvContextID;
 	uint16_t AdvLifeTime;
 	struct in6_addr AdvContextPrefix;
 
+	int active;
+};
+
+struct AdvLowpanCo {
+	struct AdvLowpanCtx table[MAX_CIDLen];
 	struct AdvLowpanCo *next;
 };
 
@@ -242,9 +249,17 @@ struct nd_opt_6co {
 	uint8_t nd_opt_6co_type;
 	uint8_t nd_opt_6co_len;
 	uint8_t nd_opt_6co_context_len;
+#if __BYTE_ORDER == __LITTLE_ENDIAN
+	uint8_t nd_opt_6co_cid:4;
+	uint8_t nd_opt_6co_c:1;
+	uint8_t nd_opt_6co_res:3;
+#elif __BYTE_ORDER == __BIG_ENDIAN
 	uint8_t nd_opt_6co_res:3;
 	uint8_t nd_opt_6co_c:1;
 	uint8_t nd_opt_6co_cid:4;
+#else
+#error "no byte order specified!"
+#endif
 	uint16_t nd_opt_6co_reserved;
 	uint16_t nd_opt_6co_valid_lifetime;
 	struct in6_addr nd_opt_6co_con_prefix;
@@ -269,6 +284,7 @@ int set_interface_curhlim(const char *, uint8_t);
 int set_interface_linkmtu(const char *, uint32_t);
 int set_interface_reachtime(const char *, uint32_t);
 int set_interface_retranstimer(const char *, uint32_t);
+int set_interface_6ctx(const struct Interface *iface, struct AdvLowpanCtx ctx);
 int setup_allrouters_membership(int sock, struct Interface *);
 int setup_linklocal_addr(struct Interface *);
 int setup_linklocal_addr(struct Interface *iface);
@@ -321,6 +337,7 @@ int privsep_interface_curhlim(const char *iface, uint32_t hlim);
 int privsep_interface_linkmtu(const char *iface, uint32_t mtu);
 int privsep_interface_reachtime(const char *iface, uint32_t rtime);
 int privsep_interface_retranstimer(const char *iface, uint32_t rettimer);
+int privsep_interface_6ctx(const char *iface, struct AdvLowpanCtx ctx);
 void privsep_init(int);
 void privsep_set_write_fd(int);
 
diff --git a/scanner.l b/scanner.l
index 164a834..d0fc324 100644
--- a/scanner.l
+++ b/scanner.l
@@ -49,6 +49,7 @@ RDNSS			{ return T_RDNSS; }
 DNSSL			{ return T_DNSSL; }
 clients			{ return T_CLIENTS; }
 lowpanco		{ return T_LOWPANCO; }
+ctx			{ return T_CTX; }
 abro			{ return T_ABRO; }
 
 IgnoreIfMissing		{ return T_IgnoreIfMissing; }
@@ -100,9 +101,10 @@ MinDelayBetweenRAs      { return T_MinDelayBetweenRAs; }
 
 AdvMobRtrSupportFlag	{ return T_AdvMobRtrSupportFlag; }
 
+Adv6LBR			{ return T_Adv6LBR; }
+
 AdvContextLength	{ return T_AdvContextLength; }
 AdvContextCompressionFlag { return T_AdvContextCompressionFlag; }
-AdvContextID		{ return T_AdvContextID; }
 AdvLifeTime		{ return T_AdvLifeTime; }
 AdvContextPrefix	{ return T_AdvContextPrefix; }
 
diff --git a/send.c b/send.c
index 96ded05..61c0afc 100644
--- a/send.c
+++ b/send.c
@@ -543,18 +543,33 @@ static void add_mipv6_home_agent_info(struct safe_buffer * sb, struct mipv6 cons
 static void add_lowpanco(struct safe_buffer * sb, struct AdvLowpanCo const *lowpanco)
 {
 	struct nd_opt_6co co;
+	size_t nd_opt_6co_size;
 
-	memset(&co, 0, sizeof(co));
+	for (int i = 0; i < MAX_CIDLen; i++) {
+		struct AdvLowpanCtx const *ctx = &lowpanco->table[i];
 
-	co.nd_opt_6co_type = ND_OPT_6CO;
-	co.nd_opt_6co_len = 3;
-	co.nd_opt_6co_context_len = lowpanco->ContextLength;
-	co.nd_opt_6co_c = lowpanco->ContextCompressionFlag;
-	co.nd_opt_6co_cid = lowpanco->AdvContextID;
-	co.nd_opt_6co_valid_lifetime = lowpanco->AdvLifeTime;
-	co.nd_opt_6co_con_prefix = lowpanco->AdvContextPrefix;
+		if (!ctx->active)
+			continue;
+
+		memset(&co, 0, sizeof(co));
 
-	safe_buffer_append(sb, &co, sizeof(co));
+		co.nd_opt_6co_type = ND_OPT_6CO;
+		co.nd_opt_6co_context_len = ctx->ContextLength;
+		if (co.nd_opt_6co_context_len > 64) {
+			co.nd_opt_6co_len = 3;
+			nd_opt_6co_size = sizeof(co);
+		} else {
+			co.nd_opt_6co_len = 2;
+			nd_opt_6co_size = sizeof(co) - 8;
+		}
+		co.nd_opt_6co_c = ctx->ContextCompressionFlag;
+		co.nd_opt_6co_cid = ctx->AdvContextID;
+		co.nd_opt_6co_valid_lifetime = ctx->AdvLifeTime;
+		co.nd_opt_6co_con_prefix = ctx->AdvContextPrefix;
+
+		safe_buffer_append(sb, &co, nd_opt_6co_size);
+
+	}
 }
 
 static void add_abro(struct safe_buffer * sb, struct AdvAbro const *abroo)
-- 
2.6.1
