From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 3/3] ss: Filtering logic changing, with fixes
Date: Sun,  4 Jan 2015 19:20:55 +0200
Message-ID: <1420392055-4754-4-git-send-email-vadim4j@gmail.com>
References: <1420392055-4754-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:42628 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbbADRbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 12:31:25 -0500
Received: by mail-la0-f48.google.com with SMTP id gf13so16865792lab.21
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 09:31:23 -0800 (PST)
In-Reply-To: <1420392055-4754-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This patch fixes some filtering combinations issues which does not
work on the 'master' version:

    $ ss -4
    shows inet & unix sockets, instead of only inet sockets

    $ ss -u
    needs to specify 'state closed'

    $ ss src unix:*X11*
    needs to specify '-x' shortcut for UNIX family

    $ ss -A all
    shows only sockets with established states

There might some other issues which was not observed.

Also changed logic for calculating families, socket types and
states filtering. I think that this version is a little simpler
one. Now there are 2 predefined default tables which describes
the following maping:

    family  -> (states, dbs)
    db      -> (states, families)

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 318 ++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 207 insertions(+), 111 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 20d3f75..d64d831 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -129,6 +129,7 @@ enum
 #define PACKET_DBM ((1<<PACKET_DG_DB)|(1<<PACKET_R_DB))
 #define UNIX_DBM ((1<<UNIX_DG_DB)|(1<<UNIX_ST_DB)|(1<<UNIX_SQ_DB))
 #define ALL_DB ((1<<MAX_DB)-1)
+#define INET_DBM ((1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB)|(1<<RAW_DB))
 
 enum {
 	SS_UNKNOWN,
@@ -146,7 +147,8 @@ enum {
 	SS_MAX
 };
 
-#define SS_ALL ((1<<SS_MAX)-1)
+#define SS_ALL ((1 << SS_MAX) - 1)
+#define SS_CONN (SS_ALL & ~((1<<SS_LISTEN)|(1<<SS_CLOSE)|(1<<SS_TIME_WAIT)|(1<<SS_SYN_RECV)))
 
 #include "ssfilter.h"
 
@@ -158,13 +160,126 @@ struct filter
 	struct ssfilter *f;
 };
 
-struct filter default_filter = {
-	.dbs	=  ~0,
-	.states = SS_ALL & ~((1<<SS_LISTEN)|(1<<SS_CLOSE)|(1<<SS_TIME_WAIT)|(1<<SS_SYN_RECV)),
-	.families= (1<<AF_INET)|(1<<AF_INET6),
+const struct filter default_dbs[MAX_DB] = {
+	[TCP_DB] = {
+		.states   = SS_CONN,
+		.families = (1 << AF_INET) | (1 << AF_INET6),
+	},
+	[DCCP_DB] = {
+		.states   = SS_CONN,
+		.families = (1 << AF_INET) | (1 << AF_INET6),
+	},
+	[UDP_DB] = {
+		.states   = (1 << SS_CLOSE),
+		.families = (1 << AF_INET) | (1 << AF_INET6),
+	},
+	[RAW_DB] = {
+		.states   = (1 << SS_CLOSE),
+		.families = (1 << AF_INET) | (1 << AF_INET6),
+	},
+	[UNIX_DG_DB] = {
+		.states   = (1 << SS_CLOSE),
+		.families = (1 << AF_UNIX),
+	},
+	[UNIX_ST_DB] = {
+		.states   = SS_CONN,
+		.families = (1 << AF_UNIX),
+	},
+	[UNIX_SQ_DB] = {
+		.states   = SS_CONN,
+		.families = (1 << AF_UNIX),
+	},
+	[PACKET_DG_DB] = {
+		.states   = (1 << SS_CLOSE),
+		.families = (1 << AF_PACKET),
+	},
+	[PACKET_R_DB] = {
+		.states   = (1 << SS_CLOSE),
+		.families = (1 << AF_PACKET),
+	},
+	[NETLINK_DB] = {
+		.states   = (1 << SS_CLOSE),
+		.families = (1 << AF_NETLINK),
+	},
 };
 
-struct filter current_filter;
+const struct filter default_afs[AF_MAX] = {
+	[AF_INET] = {
+		.dbs    = INET_DBM,
+		.states = SS_CONN,
+	},
+	[AF_INET6] = {
+		.dbs    = INET_DBM,
+		.states = SS_CONN,
+	},
+	[AF_UNIX] = {
+		.dbs    = UNIX_DBM,
+		.states = SS_CONN,
+	},
+	[AF_PACKET] = {
+		.dbs    = PACKET_DBM,
+		.states = (1 << SS_CLOSE),
+	},
+	[AF_NETLINK] = {
+		.dbs    = (1 << NETLINK_DB),
+		.states = (1 << SS_CLOSE),
+	},
+};
+
+static int do_default = 1;
+static struct filter current_filter;
+
+static void filter_db_set(struct filter *f, int db)
+{
+	f->states   |= default_dbs[db].states;
+	f->families |= default_dbs[db].families;
+	f->dbs	    |= 1 << db;
+	do_default   = 0;
+}
+
+static void filter_af_set(struct filter *f, int af)
+{
+	f->dbs	    |= default_afs[af].dbs;
+	f->states   |= default_afs[af].states;
+	f->families |= 1 << af;
+	do_default   = 0;
+}
+
+static int filter_af_get(struct filter *f, int af)
+{
+	return f->families & (1 << af);
+}
+
+static void filter_default_dbs(struct filter *f)
+{
+	filter_db_set(f, UDP_DB);
+	filter_db_set(f, DCCP_DB);
+	filter_db_set(f, TCP_DB);
+	filter_db_set(f, RAW_DB);
+	filter_db_set(f, UNIX_ST_DB);
+	filter_db_set(f, UNIX_DG_DB);
+	filter_db_set(f, UNIX_SQ_DB);
+	filter_db_set(f, PACKET_R_DB);
+	filter_db_set(f, PACKET_DG_DB);
+	filter_db_set(f, NETLINK_DB);
+}
+
+static void filter_merge(struct filter *af, struct filter *dbf, int states)
+{
+	if (af->families)
+		af->families = (af->families | dbf->families) & af->families;
+	else
+		af->families = dbf->families;
+
+	if (dbf->dbs)
+		af->dbs = (af->dbs | dbf->dbs) & dbf->dbs;
+
+	if (dbf->states)
+		af->states = (af->states | dbf->states) & dbf->states;
+
+	if (states)
+		af->states = (af->states | states) & states;
+}
 
 static FILE *generic_proc_open(const char *env, const char *name)
 {
@@ -1172,12 +1287,13 @@ void *parse_hostcond(char *addr)
 	char *port = NULL;
 	struct aafilter a;
 	struct aafilter *res;
-	int fam = preferred_family;
+	int fam = 0;
+	struct filter *f = &current_filter;
 
 	memset(&a, 0, sizeof(a));
 	a.port = -1;
 
-	if (fam == AF_UNIX || strncmp(addr, "unix:", 5) == 0) {
+	if (filter_af_get(f, AF_UNIX) || strncmp(addr, "unix:", 5) == 0) {
 		char *p;
 		a.addr.family = AF_UNIX;
 		if (strncmp(addr, "unix:", 5) == 0)
@@ -1185,10 +1301,11 @@ void *parse_hostcond(char *addr)
 		p = strdup(addr);
 		a.addr.bitlen = 8*strlen(p);
 		memcpy(a.addr.data, &p, sizeof(p));
+		fam = AF_UNIX;
 		goto out;
 	}
 
-	if (fam == AF_PACKET || strncmp(addr, "link:", 5) == 0) {
+	if (filter_af_get(f, AF_PACKET) || strncmp(addr, "link:", 5) == 0) {
 		a.addr.family = AF_PACKET;
 		a.addr.bitlen = 0;
 		if (strncmp(addr, "link:", 5) == 0)
@@ -1210,10 +1327,11 @@ void *parse_hostcond(char *addr)
 				return NULL;
 			a.addr.data[0] = ntohs(tmp);
 		}
+		fam = AF_PACKET;
 		goto out;
 	}
 
-	if (fam == AF_NETLINK || strncmp(addr, "netlink:", 8) == 0) {
+	if (filter_af_get(f, AF_NETLINK) || strncmp(addr, "netlink:", 8) == 0) {
 		a.addr.family = AF_NETLINK;
 		a.addr.bitlen = 0;
 		if (strncmp(addr, "netlink:", 8) == 0)
@@ -1235,13 +1353,14 @@ void *parse_hostcond(char *addr)
 			if (nl_proto_a2n(&a.addr.data[0], addr) == -1)
 				return NULL;
 		}
+		fam = AF_NETLINK;
 		goto out;
 	}
 
-	if (strncmp(addr, "inet:", 5) == 0) {
+	if (filter_af_get(f, AF_INET) || !strncmp(addr, "inet:", 5)) {
 		addr += 5;
 		fam = AF_INET;
-	} else if (strncmp(addr, "inet6:", 6) == 0) {
+	} else if (filter_af_get(f, AF_INET6) || !strncmp(addr, "inet6:", 6)) {
 		addr += 6;
 		fam = AF_INET6;
 	}
@@ -1310,7 +1429,10 @@ void *parse_hostcond(char *addr)
 		}
 	}
 
-	out:
+out:
+	if (fam)
+		filter_af_set(f, fam);
+
 	res = malloc(sizeof(*res));
 	if (res)
 		memcpy(res, &a, sizeof(a));
@@ -2460,6 +2582,9 @@ static int unix_show(struct filter *f)
 	int  cnt;
 	struct unixstat *list = NULL;
 
+	if (!filter_af_get(f, AF_UNIX))
+		return 0;
+
 	if (!getenv("PROC_NET_UNIX") && !getenv("PROC_ROOT")
 	    && unix_show_netlink(f) == 0)
 		return 0;
@@ -2702,7 +2827,7 @@ static int packet_show(struct filter *f)
 {
 	FILE *fp;
 
-	if (preferred_family != AF_PACKET && !(f->states & (1 << SS_CLOSE)))
+	if (!filter_af_get(f, AF_PACKET) || !(f->states & (1 << SS_CLOSE)))
 		return 0;
 
 	if (!getenv("PROC_NET_PACKET") && !getenv("PROC_ROOT") &&
@@ -2870,7 +2995,7 @@ static int netlink_show(struct filter *f)
 	int rq, wq, rc;
 	unsigned long long sk, cb;
 
-	if (preferred_family != AF_NETLINK && !(f->states & (1 << SS_CLOSE)))
+	if (!filter_af_get(f, AF_NETLINK) || !(f->states & (1 << SS_CLOSE)))
 		return 0;
 
 	if (!getenv("PROC_NET_NETLINK") && !getenv("PROC_ROOT") &&
@@ -3133,7 +3258,9 @@ static int scan_state(const char *state)
 		if (strcasecmp(state, sstate_namel[i]) == 0)
 			return (1<<i);
 	}
-	return 0;
+
+	fprintf(stderr, "ss: wrong state name: %s\n", state);
+	exit(-1);
 }
 
 static const struct option long_opts[] = {
@@ -3171,17 +3298,14 @@ static const struct option long_opts[] = {
 
 int main(int argc, char *argv[])
 {
-	int do_default = 1;
 	int saw_states = 0;
 	int saw_query = 0;
 	int do_summary = 0;
 	const char *dump_tcpdiag = NULL;
 	FILE *filter_fp = NULL;
 	int ch;
-
-	memset(&current_filter, 0, sizeof(current_filter));
-
-	current_filter.states = default_filter.states;
+	struct filter dbs_filter = {};
+	int state_filter = 0;
 
 	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZ",
 				 long_opts, NULL)) != EOF) {
@@ -3214,55 +3338,51 @@ int main(int argc, char *argv[])
 			show_bpf++;
 			break;
 		case 'd':
-			current_filter.dbs |= (1<<DCCP_DB);
-			do_default = 0;
+			filter_db_set(&dbs_filter, DCCP_DB);
 			break;
 		case 't':
-			current_filter.dbs |= (1<<TCP_DB);
-			do_default = 0;
+			filter_db_set(&dbs_filter, TCP_DB);
 			break;
 		case 'u':
-			current_filter.dbs |= (1<<UDP_DB);
-			do_default = 0;
+			filter_db_set(&dbs_filter, UDP_DB);
 			break;
 		case 'w':
-			current_filter.dbs |= (1<<RAW_DB);
-			do_default = 0;
+			filter_db_set(&dbs_filter, RAW_DB);
 			break;
 		case 'x':
-			current_filter.dbs |= UNIX_DBM;
-			do_default = 0;
+			filter_af_set(&current_filter, AF_UNIX);
 			break;
 		case 'a':
-			current_filter.states = SS_ALL;
+			state_filter = SS_ALL;
 			break;
 		case 'l':
-			current_filter.states = (1<<SS_LISTEN) | (1<<SS_CLOSE);
+			state_filter = (1 << SS_LISTEN) | (1 << SS_CLOSE);
 			break;
 		case '4':
-			preferred_family = AF_INET;
+			filter_af_set(&current_filter, AF_INET);
 			break;
 		case '6':
-			preferred_family = AF_INET6;
+			filter_af_set(&current_filter, AF_INET6);
 			break;
 		case '0':
-			preferred_family = AF_PACKET;
+			filter_af_set(&current_filter, AF_PACKET);
 			break;
 		case 'f':
 			if (strcmp(optarg, "inet") == 0)
-				preferred_family = AF_INET;
+				filter_af_set(&current_filter, AF_INET);
 			else if (strcmp(optarg, "inet6") == 0)
-				preferred_family = AF_INET6;
+				filter_af_set(&current_filter, AF_INET6);
 			else if (strcmp(optarg, "link") == 0)
-				preferred_family = AF_PACKET;
+				filter_af_set(&current_filter, AF_PACKET);
 			else if (strcmp(optarg, "unix") == 0)
-				preferred_family = AF_UNIX;
+				filter_af_set(&current_filter, AF_UNIX);
 			else if (strcmp(optarg, "netlink") == 0)
-				preferred_family = AF_NETLINK;
+				filter_af_set(&current_filter, AF_NETLINK);
 			else if (strcmp(optarg, "help") == 0)
 				help();
 			else {
-				fprintf(stderr, "ss: \"%s\" is invalid family\n", optarg);
+				fprintf(stderr, "ss: \"%s\" is invalid family\n",
+						optarg);
 				usage();
 			}
 			break;
@@ -3279,38 +3399,44 @@ int main(int argc, char *argv[])
 				if ((p1 = strchr(p, ',')) != NULL)
 					*p1 = 0;
 				if (strcmp(p, "all") == 0) {
-					current_filter.dbs = ALL_DB;
+					filter_default_dbs(&dbs_filter);
 				} else if (strcmp(p, "inet") == 0) {
-					current_filter.dbs |= (1<<TCP_DB)|(1<<DCCP_DB)|(1<<UDP_DB)|(1<<RAW_DB);
+					filter_db_set(&dbs_filter, UDP_DB);
+					filter_db_set(&dbs_filter, DCCP_DB);
+					filter_db_set(&dbs_filter, TCP_DB);
+					filter_db_set(&dbs_filter, RAW_DB);
 				} else if (strcmp(p, "udp") == 0) {
-					current_filter.dbs |= (1<<UDP_DB);
+					filter_db_set(&dbs_filter, UDP_DB);
 				} else if (strcmp(p, "dccp") == 0) {
-					current_filter.dbs |= (1<<DCCP_DB);
+					filter_db_set(&dbs_filter, DCCP_DB);
 				} else if (strcmp(p, "tcp") == 0) {
-					current_filter.dbs |= (1<<TCP_DB);
+					filter_db_set(&dbs_filter, TCP_DB);
 				} else if (strcmp(p, "raw") == 0) {
-					current_filter.dbs |= (1<<RAW_DB);
+					filter_db_set(&dbs_filter, RAW_DB);
 				} else if (strcmp(p, "unix") == 0) {
-					current_filter.dbs |= UNIX_DBM;
+					filter_db_set(&dbs_filter, UNIX_ST_DB);
+					filter_db_set(&dbs_filter, UNIX_DG_DB);
+					filter_db_set(&dbs_filter, UNIX_SQ_DB);
 				} else if (strcasecmp(p, "unix_stream") == 0 ||
 					   strcmp(p, "u_str") == 0) {
-					current_filter.dbs |= (1<<UNIX_ST_DB);
+					filter_db_set(&dbs_filter, UNIX_ST_DB);
 				} else if (strcasecmp(p, "unix_dgram") == 0 ||
 					   strcmp(p, "u_dgr") == 0) {
-					current_filter.dbs |= (1<<UNIX_DG_DB);
+					filter_db_set(&dbs_filter, UNIX_DG_DB);
 				} else if (strcasecmp(p, "unix_seqpacket") == 0 ||
 					   strcmp(p, "u_seq") == 0) {
-					current_filter.dbs |= (1<<UNIX_SQ_DB);
+					filter_db_set(&dbs_filter, UNIX_SQ_DB);
 				} else if (strcmp(p, "packet") == 0) {
-					current_filter.dbs |= PACKET_DBM;
+					filter_db_set(&dbs_filter, PACKET_R_DB);
+					filter_db_set(&dbs_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "packet_raw") == 0 ||
 					   strcmp(p, "p_raw") == 0) {
-					current_filter.dbs |= (1<<PACKET_R_DB);
+					filter_db_set(&dbs_filter, PACKET_R_DB);
 				} else if (strcmp(p, "packet_dgram") == 0 ||
 					   strcmp(p, "p_dgr") == 0) {
-					current_filter.dbs |= (1<<PACKET_DG_DB);
+					filter_db_set(&dbs_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "netlink") == 0) {
-					current_filter.dbs |= (1<<NETLINK_DB);
+					filter_db_set(&dbs_filter, NETLINK_DB);
 				} else {
 					fprintf(stderr, "ss: \"%s\" is illegal socket table id\n", p);
 					usage();
@@ -3372,57 +3498,6 @@ int main(int argc, char *argv[])
 			exit(0);
 	}
 
-	if (do_default)
-		current_filter.dbs = default_filter.dbs;
-
-	if (preferred_family == AF_UNSPEC) {
-		if (!(current_filter.dbs&~UNIX_DBM))
-			preferred_family = AF_UNIX;
-		else if (!(current_filter.dbs&~PACKET_DBM))
-			preferred_family = AF_PACKET;
-		else if (!(current_filter.dbs&~(1<<NETLINK_DB)))
-			preferred_family = AF_NETLINK;
-	}
-
-	if (preferred_family != AF_UNSPEC) {
-		int mask2;
-		if (preferred_family == AF_INET ||
-		    preferred_family == AF_INET6) {
-			mask2= current_filter.dbs;
-		} else if (preferred_family == AF_PACKET) {
-			mask2 = PACKET_DBM;
-		} else if (preferred_family == AF_UNIX) {
-			mask2 = UNIX_DBM;
-		} else if (preferred_family == AF_NETLINK) {
-			mask2 = (1<<NETLINK_DB);
-		} else {
-			mask2 = 0;
-		}
-
-		if (do_default)
-			current_filter.dbs = mask2;
-		else
-			current_filter.dbs &= mask2;
-		current_filter.families = (1<<preferred_family);
-	} else {
-		if (!do_default)
-			current_filter.families = ~0;
-		else
-			current_filter.families = default_filter.families;
-	}
-	if (current_filter.dbs == 0) {
-		fprintf(stderr, "ss: no socket tables to show with such filter.\n");
-		exit(0);
-	}
-	if (current_filter.families == 0) {
-		fprintf(stderr, "ss: no families to show with such filter.\n");
-		exit(0);
-	}
-
-	if (resolve_services && resolve_hosts &&
-	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
-		init_service_resolver();
-
 	/* Now parse filter... */
 	if (argc == 0 && filter_fp) {
 		if (ssfilter_parse(&current_filter.f, 0, NULL, filter_fp))
@@ -3433,15 +3508,15 @@ int main(int argc, char *argv[])
 		if (strcmp(*argv, "state") == 0) {
 			NEXT_ARG();
 			if (!saw_states)
-				current_filter.states = 0;
-			current_filter.states |= scan_state(*argv);
+				state_filter = 0;
+			state_filter |= scan_state(*argv);
 			saw_states = 1;
 		} else if (strcmp(*argv, "exclude") == 0 ||
 			   strcmp(*argv, "excl") == 0) {
 			NEXT_ARG();
 			if (!saw_states)
-				current_filter.states = SS_ALL;
-			current_filter.states &= ~scan_state(*argv);
+				state_filter = SS_ALL;
+			state_filter &= ~scan_state(*argv);
 			saw_states = 1;
 		} else {
 			if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
@@ -3451,6 +3526,27 @@ int main(int argc, char *argv[])
 		argc--; argv++;
 	}
 
+	if (do_default) {
+		state_filter = state_filter ? state_filter : SS_CONN;
+		filter_default_dbs(&current_filter);
+		filter_merge(&current_filter, &current_filter, state_filter);
+	} else {
+		filter_merge(&current_filter, &dbs_filter, state_filter);
+	}
+
+	if (resolve_services && resolve_hosts &&
+	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
+		init_service_resolver();
+
+
+	if (current_filter.dbs == 0) {
+		fprintf(stderr, "ss: no socket tables to show with such filter.\n");
+		exit(0);
+	}
+	if (current_filter.families == 0) {
+		fprintf(stderr, "ss: no families to show with such filter.\n");
+		exit(0);
+	}
 	if (current_filter.states == 0) {
 		fprintf(stderr, "ss: no socket states to show with such filter.\n");
 		exit(0);
-- 
2.1.3
