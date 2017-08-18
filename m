From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH 2/2] netfilter/libxt_hashlimit: new feature/algorithm for xt_hashlimit
Date: Fri, 18 Aug 2017 16:59:06 -0400
Message-ID: <1503089946-15996-1-git-send-email-vpai@akamai.com>
Cc: johunt@akamai.com, fw@strlen.de, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new feature to hashlimit that allows matching on the
current packet/byte rate without rate limiting. This can be enabled
with a new flag --hashlimit-rate-match. The match returns true if the
current rate of packets is above/below the user specified value.

The main difference between the existing algorithm and the new one is
that the existing algorithm rate-limits the flow whereas the new algorithm
does not. Instead it *classifies* the flow based on whether it is above or
below a certain rate. I will demonstrate this with an example below. Let
us assume this rule:

iptables -A INPUT -m hashlimit --hashlimit-above 10/s -j new_chain

If the packet rate is 15/s, the existing algorithm would ACCEPT 10 packets
every second and send 5 packets to "new_chain".

But with the new algorithm, as long as the rate of 15/s is sustained, all
packets will continue to match and every packet is sent to new_chain.

This new functionality will let us classify different flows based on their
current rate, so that further decisions can be made on them based on what
the current rate is.

This is how the new algorithm works:
We divide time into intervals of 1 (sec/min/hour) as specified by
the user. We keep track of the number of packets/bytes processed in the
current interval. After each interval we reset the counter to 0.

When we receive a packet for match, we look at the packet rate
during the current interval and the previous interval to make a decision:

if [ prev_rate < user and cur_rate < user ]
        return Below
else
        return Above

Where cur_rate is the number of packets/bytes seen in the current
interval, prev is the number of packets/bytes seen in the previous
interval and 'user' is the rate specified by the user.

We also provide flexibility to the user for choosing the time
interval using the option --hashilmit-interval. For example the user can
keep a low rate like x/hour but still keep the interval as small as 1
second.

To preserve backwards compatibility we have to add this feature in a new
revision, so I've created revision 3 for hashlimit. The two new options
we add are:

--hashlimit-rate-match
--hashlimit-rate-interval

I have updated the help text to add these new options. Also added a few
tests for the new options.

Suggested-by: Igor Lubashev <ilubashe@akamai.com>
Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 extensions/libxt_hashlimit.c           | 407 ++++++++++++++++++++++++++++++---
 extensions/libxt_hashlimit.man         |   8 +
 extensions/libxt_hashlimit.t           |   4 +
 include/linux/netfilter/xt_hashlimit.h |  36 ++-
 4 files changed, 414 insertions(+), 41 deletions(-)

diff --git a/extensions/libxt_hashlimit.c b/extensions/libxt_hashlimit.c
index 9e63e1e..e51ac1a 100644
--- a/extensions/libxt_hashlimit.c
+++ b/extensions/libxt_hashlimit.c
@@ -68,10 +68,13 @@ enum {
 	O_HTABLE_MAX,
 	O_HTABLE_GCINT,
 	O_HTABLE_EXPIRE,
+	O_RATEMATCH,
+	O_INTERVAL,
 	F_BURST         = 1 << O_BURST,
 	F_UPTO          = 1 << O_UPTO,
 	F_ABOVE         = 1 << O_ABOVE,
 	F_HTABLE_EXPIRE = 1 << O_HTABLE_EXPIRE,
+	F_RATEMATCH	= 1 << O_RATEMATCH,
 };
 
 static void hashlimit_mt_help(void)
@@ -95,6 +98,29 @@ static void hashlimit_mt_help(void)
 "\n", XT_HASHLIMIT_BURST);
 }
 
+static void hashlimit_mt_help_v3(void)
+{
+	printf(
+"hashlimit match options:\n"
+"  --hashlimit-upto <avg>           max average match rate\n"
+"                                   [Packets per second unless followed by \n"
+"                                   /sec /minute /hour /day postfixes]\n"
+"  --hashlimit-above <avg>          min average match rate\n"
+"  --hashlimit-mode <mode>          mode is a comma-separated list of\n"
+"                                   dstip,srcip,dstport,srcport (or none)\n"
+"  --hashlimit-srcmask <length>     source address grouping prefix length\n"
+"  --hashlimit-dstmask <length>     destination address grouping prefix length\n"
+"  --hashlimit-name <name>          name for /proc/net/ipt_hashlimit\n"
+"  --hashlimit-burst <num>	    number to match in a burst, default %u\n"
+"  --hashlimit-htable-size <num>    number of hashtable buckets\n"
+"  --hashlimit-htable-max <num>     number of hashtable entries\n"
+"  --hashlimit-htable-gcinterval    interval between garbage collection runs\n"
+"  --hashlimit-htable-expire        after which time are idle entries expired?\n"
+"  --hashlimit-rate-match           rate match the flow without rate-limiting it\n"
+"  --hashlimit-rate-interval        interval in seconds for hashlimit-rate-match\n"
+"\n", XT_HASHLIMIT_BURST);
+}
+
 #define s struct xt_hashlimit_info
 static const struct xt_option_entry hashlimit_opts[] = {
 	{.name = "hashlimit", .id = O_UPTO, .excl = F_ABOVE,
@@ -153,6 +179,35 @@ static const struct xt_option_entry hashlimit_mt_opts_v1[] = {
 #undef s
 
 #define s struct xt_hashlimit_mtinfo2
+static const struct xt_option_entry hashlimit_mt_opts_v2[] = {
+	{.name = "hashlimit-upto", .id = O_UPTO, .excl = F_ABOVE,
+	 .type = XTTYPE_STRING, .flags = XTOPT_INVERT},
+	{.name = "hashlimit-above", .id = O_ABOVE, .excl = F_UPTO,
+	 .type = XTTYPE_STRING, .flags = XTOPT_INVERT},
+	{.name = "hashlimit", .id = O_UPTO, .excl = F_ABOVE,
+	 .type = XTTYPE_STRING, .flags = XTOPT_INVERT}, /* old name */
+	{.name = "hashlimit-srcmask", .id = O_SRCMASK, .type = XTTYPE_PLEN},
+	{.name = "hashlimit-dstmask", .id = O_DSTMASK, .type = XTTYPE_PLEN},
+	{.name = "hashlimit-burst", .id = O_BURST, .type = XTTYPE_STRING},
+	{.name = "hashlimit-htable-size", .id = O_HTABLE_SIZE,
+	 .type = XTTYPE_UINT32, .flags = XTOPT_PUT,
+	 XTOPT_POINTER(s, cfg.size)},
+	{.name = "hashlimit-htable-max", .id = O_HTABLE_MAX,
+	 .type = XTTYPE_UINT32, .flags = XTOPT_PUT,
+	 XTOPT_POINTER(s, cfg.max)},
+	{.name = "hashlimit-htable-gcinterval", .id = O_HTABLE_GCINT,
+	 .type = XTTYPE_UINT32, .flags = XTOPT_PUT,
+	 XTOPT_POINTER(s, cfg.gc_interval)},
+	{.name = "hashlimit-htable-expire", .id = O_HTABLE_EXPIRE,
+	 .type = XTTYPE_UINT32, .flags = XTOPT_PUT,
+	 XTOPT_POINTER(s, cfg.expire)},
+	{.name = "hashlimit-mode", .id = O_MODE, .type = XTTYPE_STRING},
+	{.name = "hashlimit-name", .id = O_NAME, .type = XTTYPE_STRING,
+	 .flags = XTOPT_MAND | XTOPT_PUT, XTOPT_POINTER(s, name), .min = 1},
+};
+#undef s
+
+#define s struct xt_hashlimit_mtinfo3
 static const struct xt_option_entry hashlimit_mt_opts[] = {
 	{.name = "hashlimit-upto", .id = O_UPTO, .excl = F_ABOVE,
 	 .type = XTTYPE_STRING, .flags = XTOPT_INVERT},
@@ -178,12 +233,14 @@ static const struct xt_option_entry hashlimit_mt_opts[] = {
 	{.name = "hashlimit-mode", .id = O_MODE, .type = XTTYPE_STRING},
 	{.name = "hashlimit-name", .id = O_NAME, .type = XTTYPE_STRING,
 	 .flags = XTOPT_MAND | XTOPT_PUT, XTOPT_POINTER(s, name), .min = 1},
+	{.name = "hashlimit-rate-match", .id = O_RATEMATCH, .type = XTTYPE_NONE},
+	{.name = "hashlimit-rate-interval", .id = O_INTERVAL, .type = XTTYPE_STRING},
 	XTOPT_TABLEEND,
 };
 #undef s
 
 static int
-cfg_copy(struct hashlimit_cfg2 *to, const void *from, int revision)
+cfg_copy(struct hashlimit_cfg3 *to, const void *from, int revision)
 {
 	if (revision == 1) {
 		struct hashlimit_cfg1 *cfg = (struct hashlimit_cfg1 *)from;
@@ -198,7 +255,19 @@ cfg_copy(struct hashlimit_cfg2 *to, const void *from, int revision)
 		to->srcmask = cfg->srcmask;
 		to->dstmask = cfg->dstmask;
 	} else if (revision == 2) {
-		memcpy(to, from, sizeof(struct hashlimit_cfg2));
+		struct hashlimit_cfg2 *cfg = (struct hashlimit_cfg2 *)from;
+
+		to->mode = cfg->mode;
+		to->avg = cfg->avg;
+		to->burst = cfg->burst;
+		to->size = cfg->size;
+		to->max = cfg->max;
+		to->gc_interval = cfg->gc_interval;
+		to->expire = cfg->expire;
+		to->srcmask = cfg->srcmask;
+		to->dstmask = cfg->dstmask;
+	} else if (revision == 3) {
+		memcpy(to, from, sizeof(struct hashlimit_cfg3));
 	} else {
 		return -EINVAL;
 	}
@@ -346,6 +415,16 @@ int parse_rate(const char *rate, void *val, struct hashlimit_mt_udata *ud, int r
 	return 1;
 }
 
+static int parse_interval(const char *rate, uint32_t *val)
+{
+	int r = atoi(rate);
+	if (r <= 0)
+		return 0;
+
+	*val = r;
+	return 1;
+}
+
 static void hashlimit_init(struct xt_entry_match *m)
 {
 	struct xt_hashlimit_info *r = (struct xt_hashlimit_info *)m->data;
@@ -377,7 +456,7 @@ static void hashlimit_mt6_init_v1(struct xt_entry_match *match)
 	info->cfg.dstmask     = 128;
 }
 
-static void hashlimit_mt4_init(struct xt_entry_match *match)
+static void hashlimit_mt4_init_v2(struct xt_entry_match *match)
 {
 	struct xt_hashlimit_mtinfo2 *info = (void *)match->data;
 
@@ -388,7 +467,7 @@ static void hashlimit_mt4_init(struct xt_entry_match *match)
 	info->cfg.dstmask     = 32;
 }
 
-static void hashlimit_mt6_init(struct xt_entry_match *match)
+static void hashlimit_mt6_init_v2(struct xt_entry_match *match)
 {
 	struct xt_hashlimit_mtinfo2 *info = (void *)match->data;
 
@@ -399,6 +478,30 @@ static void hashlimit_mt6_init(struct xt_entry_match *match)
 	info->cfg.dstmask     = 128;
 }
 
+static void hashlimit_mt4_init(struct xt_entry_match *match)
+{
+	struct xt_hashlimit_mtinfo3 *info = (void *)match->data;
+
+	info->cfg.mode        = 0;
+	info->cfg.burst       = XT_HASHLIMIT_BURST;
+	info->cfg.gc_interval = XT_HASHLIMIT_GCINTERVAL;
+	info->cfg.srcmask     = 32;
+	info->cfg.dstmask     = 32;
+	info->cfg.interval    = 0;
+}
+
+static void hashlimit_mt6_init(struct xt_entry_match *match)
+{
+	struct xt_hashlimit_mtinfo3 *info = (void *)match->data;
+
+	info->cfg.mode        = 0;
+	info->cfg.burst       = XT_HASHLIMIT_BURST;
+	info->cfg.gc_interval = XT_HASHLIMIT_GCINTERVAL;
+	info->cfg.srcmask     = 128;
+	info->cfg.dstmask     = 128;
+	info->cfg.interval    = 0;
+}
+
 /* Parse a 'mode' parameter into the required bitmask */
 static int parse_mode(uint32_t *mode, const char *option_arg)
 {
@@ -488,7 +591,7 @@ static void hashlimit_mt_parse_v1(struct xt_option_call *cb)
 	}
 }
 
-static void hashlimit_mt_parse(struct xt_option_call *cb)
+static void hashlimit_mt_parse_v2(struct xt_option_call *cb)
 {
 	struct xt_hashlimit_mtinfo2 *info = cb->data;
 
@@ -529,6 +632,54 @@ static void hashlimit_mt_parse(struct xt_option_call *cb)
 	}
 }
 
+static void hashlimit_mt_parse(struct xt_option_call *cb)
+{
+	struct xt_hashlimit_mtinfo3 *info = cb->data;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_BURST:
+		info->cfg.burst = parse_burst(cb->arg, 2);
+		break;
+	case O_UPTO:
+		if (cb->invert)
+			info->cfg.mode |= XT_HASHLIMIT_INVERT;
+		if (parse_bytes(cb->arg, &info->cfg.avg, cb->udata, 2))
+			info->cfg.mode |= XT_HASHLIMIT_BYTES;
+		else if (!parse_rate(cb->arg, &info->cfg.avg, cb->udata, 2))
+			xtables_param_act(XTF_BAD_VALUE, "hashlimit",
+			          "--hashlimit-upto", cb->arg);
+		break;
+	case O_ABOVE:
+		if (!cb->invert)
+			info->cfg.mode |= XT_HASHLIMIT_INVERT;
+		if (parse_bytes(cb->arg, &info->cfg.avg, cb->udata, 2))
+			info->cfg.mode |= XT_HASHLIMIT_BYTES;
+		else if (!parse_rate(cb->arg, &info->cfg.avg, cb->udata, 2))
+			xtables_param_act(XTF_BAD_VALUE, "hashlimit",
+			          "--hashlimit-above", cb->arg);
+		break;
+	case O_MODE:
+		if (parse_mode(&info->cfg.mode, cb->arg) < 0)
+			xtables_param_act(XTF_BAD_VALUE, "hashlimit",
+			          "--hashlimit-mode", cb->arg);
+		break;
+	case O_SRCMASK:
+		info->cfg.srcmask = cb->val.hlen;
+		break;
+	case O_DSTMASK:
+		info->cfg.dstmask = cb->val.hlen;
+		break;
+	case O_RATEMATCH:
+		info->cfg.mode |= XT_HASHLIMIT_RATE_MATCH;
+		break;
+	case O_INTERVAL:
+		if (!parse_interval(cb->arg, &info->cfg.interval))
+			xtables_param_act(XTF_BAD_VALUE, "hashlimit",
+				"--hashlimit-rate-interval", cb->arg);
+	}
+}
+
 static void hashlimit_check(struct xt_fcheck_call *cb)
 {
 	const struct hashlimit_mt_udata *udata = cb->udata;
@@ -572,7 +723,7 @@ static void hashlimit_mt_check_v1(struct xt_fcheck_call *cb)
 		burst_error_v1();
 }
 
-static void hashlimit_mt_check(struct xt_fcheck_call *cb)
+static void hashlimit_mt_check_v2(struct xt_fcheck_call *cb)
 {
 	const struct hashlimit_mt_udata *udata = cb->udata;
 	struct xt_hashlimit_mtinfo2 *info = cb->data;
@@ -603,6 +754,48 @@ static void hashlimit_mt_check(struct xt_fcheck_call *cb)
 		burst_error();
 }
 
+static void hashlimit_mt_check(struct xt_fcheck_call *cb)
+{
+	const struct hashlimit_mt_udata *udata = cb->udata;
+	struct xt_hashlimit_mtinfo3 *info = cb->data;
+
+	if (!(cb->xflags & (F_UPTO | F_ABOVE)))
+		xtables_error(PARAMETER_PROBLEM,
+				"You have to specify --hashlimit");
+	if (!(cb->xflags & F_HTABLE_EXPIRE))
+		info->cfg.expire = udata->mult * 1000; /* from s to msec */
+
+	if (info->cfg.mode & XT_HASHLIMIT_BYTES) {
+		uint32_t burst = 0;
+		if (cb->xflags & F_BURST) {
+			if (info->cfg.burst < cost_to_bytes(info->cfg.avg))
+				xtables_error(PARAMETER_PROBLEM,
+					"burst cannot be smaller than %lub", cost_to_bytes(info->cfg.avg));
+
+			burst = info->cfg.burst;
+			burst /= cost_to_bytes(info->cfg.avg);
+			if (info->cfg.burst % cost_to_bytes(info->cfg.avg))
+				burst++;
+			if (!(cb->xflags & F_HTABLE_EXPIRE))
+				info->cfg.expire = XT_HASHLIMIT_BYTE_EXPIRE_BURST * 1000;
+		}
+		info->cfg.burst = burst;
+	} else if (info->cfg.burst > XT_HASHLIMIT_BURST_MAX)
+		burst_error();
+
+	if (cb->xflags & F_RATEMATCH) {
+		if (!(info->cfg.mode & XT_HASHLIMIT_BYTES))
+			info->cfg.avg /= udata->mult;
+
+		if (info->cfg.interval == 0) {
+			if (info->cfg.mode & XT_HASHLIMIT_BYTES)
+				info->cfg.interval = 1;
+			else
+				info->cfg.interval = udata->mult;
+		}
+	}
+}
+
 struct rates {
 	const char *name;
 	uint64_t mult;
@@ -617,7 +810,7 @@ static const struct rates rates[] = {
 	{ "min", XT_HASHLIMIT_SCALE_v2*60 },
 	{ "sec", XT_HASHLIMIT_SCALE_v2 } };
 
-static uint32_t print_rate(uint32_t period, int revision)
+static uint32_t print_rate(uint64_t period, int revision)
 {
 	unsigned int i;
 	const struct rates *_rates = (revision == 1) ? rates_v1 : rates;
@@ -723,9 +916,10 @@ static void hashlimit_print(const void *ip,
 }
 
 static void
-hashlimit_mt_print(const struct hashlimit_cfg2 *cfg, unsigned int dmask, int revision)
+hashlimit_mt_print(const struct hashlimit_cfg3 *cfg, unsigned int dmask, int revision)
 {
-	uint32_t quantum;
+	uint64_t quantum;
+	uint64_t period;
 
 	if (cfg->mode & XT_HASHLIMIT_INVERT)
 		fputs(" limit: above", stdout);
@@ -735,7 +929,15 @@ hashlimit_mt_print(const struct hashlimit_cfg2 *cfg, unsigned int dmask, int rev
 	if (cfg->mode & XT_HASHLIMIT_BYTES) {
 		quantum = print_bytes(cfg->avg, cfg->burst, "");
 	} else {
-		quantum = print_rate(cfg->avg, revision);
+		if (revision == 3) {
+			period = cfg->avg;
+			if (cfg->interval != 0)
+				period *= cfg->interval;
+
+			quantum = print_rate(period, revision);
+		} else {
+			quantum = print_rate(cfg->avg, revision);
+		}
 		printf(" burst %llu", cfg->burst);
 	}
 	if (cfg->mode & (XT_HASHLIMIT_HASH_SIP | XT_HASHLIMIT_HASH_SPT |
@@ -756,6 +958,13 @@ hashlimit_mt_print(const struct hashlimit_cfg2 *cfg, unsigned int dmask, int rev
 		printf(" srcmask %u", cfg->srcmask);
 	if (cfg->dstmask != dmask)
 		printf(" dstmask %u", cfg->dstmask);
+
+	if ((revision == 3) && (cfg->mode & XT_HASHLIMIT_RATE_MATCH))
+		printf(" rate-match");
+
+	if ((revision == 3) && (cfg->mode & XT_HASHLIMIT_RATE_MATCH))
+		if (cfg->interval != 1)
+			printf(" rate-interval %u", cfg->interval);
 }
 
 static void
@@ -763,7 +972,7 @@ hashlimit_mt4_print_v1(const void *ip, const struct xt_entry_match *match,
                    int numeric)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg3 cfg;
 	int ret;
 
 	ret = cfg_copy(&cfg, (const void *)&info->cfg, 1);
@@ -779,7 +988,7 @@ hashlimit_mt6_print_v1(const void *ip, const struct xt_entry_match *match,
                    int numeric)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg3 cfg;
 	int ret;
 
 	ret = cfg_copy(&cfg, (const void *)&info->cfg, 1);
@@ -791,21 +1000,52 @@ hashlimit_mt6_print_v1(const void *ip, const struct xt_entry_match *match,
 }
 
 static void
-hashlimit_mt4_print(const void *ip, const struct xt_entry_match *match,
+hashlimit_mt4_print_v2(const void *ip, const struct xt_entry_match *match,
                    int numeric)
 {
 	const struct xt_hashlimit_mtinfo2 *info = (const void *)match->data;
+	struct hashlimit_cfg3 cfg;
+	int ret;
+
+	ret = cfg_copy(&cfg, (const void *)&info->cfg, 2);
 
-	hashlimit_mt_print(&info->cfg, 32, 2);
+	if (ret)
+		xtables_error(OTHER_PROBLEM, "unknown revision");
+
+	hashlimit_mt_print(&cfg, 32, 2);
 }
 
 static void
-hashlimit_mt6_print(const void *ip, const struct xt_entry_match *match,
+hashlimit_mt6_print_v2(const void *ip, const struct xt_entry_match *match,
                    int numeric)
 {
 	const struct xt_hashlimit_mtinfo2 *info = (const void *)match->data;
+	struct hashlimit_cfg3 cfg;
+	int ret;
+
+	ret = cfg_copy(&cfg, (const void *)&info->cfg, 2);
+
+	if (ret)
+		xtables_error(OTHER_PROBLEM, "unknown revision");
+
+	hashlimit_mt_print(&cfg, 128, 2);
+}
+static void
+hashlimit_mt4_print(const void *ip, const struct xt_entry_match *match,
+                   int numeric)
+{
+	const struct xt_hashlimit_mtinfo3 *info = (const void *)match->data;
+
+	hashlimit_mt_print(&info->cfg, 32, 3);
+}
+
+static void
+hashlimit_mt6_print(const void *ip, const struct xt_entry_match *match,
+                   int numeric)
+{
+	const struct xt_hashlimit_mtinfo3 *info = (const void *)match->data;
 
-	hashlimit_mt_print(&info->cfg, 128, 2);
+	hashlimit_mt_print(&info->cfg, 128, 3);
 }
 
 static void hashlimit_save(const void *ip, const struct xt_entry_match *match)
@@ -833,7 +1073,7 @@ static void hashlimit_save(const void *ip, const struct xt_entry_match *match)
 }
 
 static void
-hashlimit_mt_save(const struct hashlimit_cfg2 *cfg, const char* name, unsigned int dmask, int revision)
+hashlimit_mt_save(const struct hashlimit_cfg3 *cfg, const char* name, unsigned int dmask, int revision)
 {
 	uint32_t quantum;
 
@@ -870,13 +1110,20 @@ hashlimit_mt_save(const struct hashlimit_cfg2 *cfg, const char* name, unsigned i
 		printf(" --hashlimit-srcmask %u", cfg->srcmask);
 	if (cfg->dstmask != dmask)
 		printf(" --hashlimit-dstmask %u", cfg->dstmask);
+
+	if ((revision == 3) && (cfg->mode & XT_HASHLIMIT_RATE_MATCH))
+		printf(" --hashlimit-rate-match");
+
+	if ((revision == 3) && (cfg->mode & XT_HASHLIMIT_RATE_MATCH))
+		if (cfg->interval != 1)
+			printf(" --hashlimit-rate-interval %u", cfg->interval);
 }
 
 static void
 hashlimit_mt4_save_v1(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg3 cfg;
 	int ret;
 
 	ret = cfg_copy(&cfg, (const void *)&info->cfg, 1);
@@ -891,7 +1138,7 @@ static void
 hashlimit_mt6_save_v1(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg3 cfg;
 	int ret;
 
 	ret = cfg_copy(&cfg, (const void *)&info->cfg, 1);
@@ -903,19 +1150,49 @@ hashlimit_mt6_save_v1(const void *ip, const struct xt_entry_match *match)
 }
 
 static void
-hashlimit_mt4_save(const void *ip, const struct xt_entry_match *match)
+hashlimit_mt4_save_v2(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_hashlimit_mtinfo2 *info = (const void *)match->data;
+	struct hashlimit_cfg3 cfg;
+	int ret;
+
+	ret = cfg_copy(&cfg, (const void *)&info->cfg, 2);
+
+	if (ret)
+		xtables_error(OTHER_PROBLEM, "unknown revision");
 
-	hashlimit_mt_save(&info->cfg, info->name, 32, 2);
+	hashlimit_mt_save(&cfg, info->name, 32, 2);
 }
 
 static void
-hashlimit_mt6_save(const void *ip, const struct xt_entry_match *match)
+hashlimit_mt6_save_v2(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_hashlimit_mtinfo2 *info = (const void *)match->data;
+	struct hashlimit_cfg3 cfg;
+	int ret;
+
+	ret = cfg_copy(&cfg, (const void *)&info->cfg, 2);
+
+	if (ret)
+		xtables_error(OTHER_PROBLEM, "unknown revision");
+
+	hashlimit_mt_save(&cfg, info->name, 128, 2);
+}
+
+static void
+hashlimit_mt4_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_hashlimit_mtinfo3 *info = (const void *)match->data;
+
+	hashlimit_mt_save(&info->cfg, info->name, 32, 3);
+}
+
+static void
+hashlimit_mt6_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_hashlimit_mtinfo3 *info = (const void *)match->data;
 
-	hashlimit_mt_save(&info->cfg, info->name, 128, 2);
+	hashlimit_mt_save(&info->cfg, info->name, 128, 3);
 }
 
 static const struct rates rates_v1_xlate[] = {
@@ -947,7 +1224,7 @@ static void print_packets_rate_xlate(struct xt_xlate *xl, uint64_t avg,
 }
 
 static void print_bytes_rate_xlate(struct xt_xlate *xl,
-				   const struct hashlimit_cfg2 *cfg)
+				   const struct hashlimit_cfg3 *cfg)
 {
 	unsigned int i;
 	unsigned long long r;
@@ -1055,7 +1332,7 @@ static int hashlimit_mode_xlate(struct xt_xlate *xl,
 }
 
 static int hashlimit_mt_xlate(struct xt_xlate *xl, const char *name,
-			      const struct hashlimit_cfg2 *cfg,
+			      const struct hashlimit_cfg3 *cfg,
 			      int revision, int family)
 {
 	int ret = 1;
@@ -1098,7 +1375,7 @@ static int hashlimit_mt4_xlate_v1(struct xt_xlate *xl,
 {
 	const struct xt_hashlimit_mtinfo1 *info =
 		(const void *)params->match->data;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg3 cfg;
 
 	if (cfg_copy(&cfg, (const void *)&info->cfg, 1))
 		xtables_error(OTHER_PROBLEM, "unknown revision");
@@ -1111,7 +1388,7 @@ static int hashlimit_mt6_xlate_v1(struct xt_xlate *xl,
 {
 	const struct xt_hashlimit_mtinfo1 *info =
 		(const void *)params->match->data;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg3 cfg;
 
 	if (cfg_copy(&cfg, (const void *)&info->cfg, 1))
 		xtables_error(OTHER_PROBLEM, "unknown revision");
@@ -1119,22 +1396,48 @@ static int hashlimit_mt6_xlate_v1(struct xt_xlate *xl,
 	return hashlimit_mt_xlate(xl, info->name, &cfg, 1, NFPROTO_IPV6);
 }
 
+static int hashlimit_mt4_xlate_v2(struct xt_xlate *xl,
+				  const struct xt_xlate_mt_params *params)
+{
+	const struct xt_hashlimit_mtinfo2 *info =
+		(const void *)params->match->data;
+	struct hashlimit_cfg3 cfg;
+
+	if (cfg_copy(&cfg, (const void *)&info->cfg, 2))
+		xtables_error(OTHER_PROBLEM, "unknown revision");
+
+	return hashlimit_mt_xlate(xl, info->name, &cfg, 2, NFPROTO_IPV4);
+}
+
+static int hashlimit_mt6_xlate_v2(struct xt_xlate *xl,
+				  const struct xt_xlate_mt_params *params)
+{
+	const struct xt_hashlimit_mtinfo2 *info =
+		(const void *)params->match->data;
+	struct hashlimit_cfg3 cfg;
+
+	if (cfg_copy(&cfg, (const void *)&info->cfg, 2))
+		xtables_error(OTHER_PROBLEM, "unknown revision");
+
+	return hashlimit_mt_xlate(xl, info->name, &cfg, 2, NFPROTO_IPV6);
+}
+
 static int hashlimit_mt4_xlate(struct xt_xlate *xl,
 			       const struct xt_xlate_mt_params *params)
 {
-	const struct xt_hashlimit_mtinfo2 *info =
+	const struct xt_hashlimit_mtinfo3 *info =
 		(const void *)params->match->data;
 
-	return hashlimit_mt_xlate(xl, info->name, &info->cfg, 2, NFPROTO_IPV4);
+	return hashlimit_mt_xlate(xl, info->name, &info->cfg, 3, NFPROTO_IPV4);
 }
 
 static int hashlimit_mt6_xlate(struct xt_xlate *xl,
 			       const struct xt_xlate_mt_params *params)
 {
-	const struct xt_hashlimit_mtinfo2 *info =
+	const struct xt_hashlimit_mtinfo3 *info =
 		(const void *)params->match->data;
 
-	return hashlimit_mt_xlate(xl, info->name, &info->cfg, 2, NFPROTO_IPV6);
+	return hashlimit_mt_xlate(xl, info->name, &info->cfg, 3, NFPROTO_IPV6);
 }
 
 static struct xtables_match hashlimit_mt_reg[] = {
@@ -1197,6 +1500,40 @@ static struct xtables_match hashlimit_mt_reg[] = {
 		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo2)),
 		.userspacesize = offsetof(struct xt_hashlimit_mtinfo2, hinfo),
 		.help          = hashlimit_mt_help,
+		.init          = hashlimit_mt4_init_v2,
+		.x6_parse      = hashlimit_mt_parse_v2,
+		.x6_fcheck     = hashlimit_mt_check_v2,
+		.print         = hashlimit_mt4_print_v2,
+		.save          = hashlimit_mt4_save_v2,
+		.x6_options    = hashlimit_mt_opts_v2,
+		.udata_size    = sizeof(struct hashlimit_mt_udata),
+		.xlate         = hashlimit_mt4_xlate_v2,
+	},
+	{
+		.version       = XTABLES_VERSION,
+		.name          = "hashlimit",
+		.revision      = 2,
+		.family        = NFPROTO_IPV6,
+		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo2)),
+		.userspacesize = offsetof(struct xt_hashlimit_mtinfo2, hinfo),
+		.help          = hashlimit_mt_help,
+		.init          = hashlimit_mt6_init_v2,
+		.x6_parse      = hashlimit_mt_parse_v2,
+		.x6_fcheck     = hashlimit_mt_check_v2,
+		.print         = hashlimit_mt6_print_v2,
+		.save          = hashlimit_mt6_save_v2,
+		.x6_options    = hashlimit_mt_opts_v2,
+		.udata_size    = sizeof(struct hashlimit_mt_udata),
+		.xlate         = hashlimit_mt6_xlate_v2,
+	},
+	{
+		.version       = XTABLES_VERSION,
+		.name          = "hashlimit",
+		.revision      = 3,
+		.family        = NFPROTO_IPV4,
+		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo3)),
+		.userspacesize = offsetof(struct xt_hashlimit_mtinfo3, hinfo),
+		.help          = hashlimit_mt_help_v3,
 		.init          = hashlimit_mt4_init,
 		.x6_parse      = hashlimit_mt_parse,
 		.x6_fcheck     = hashlimit_mt_check,
@@ -1209,11 +1546,11 @@ static struct xtables_match hashlimit_mt_reg[] = {
 	{
 		.version       = XTABLES_VERSION,
 		.name          = "hashlimit",
-		.revision      = 2,
+		.revision      = 3,
 		.family        = NFPROTO_IPV6,
-		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo2)),
-		.userspacesize = offsetof(struct xt_hashlimit_mtinfo2, hinfo),
-		.help          = hashlimit_mt_help,
+		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo3)),
+		.userspacesize = offsetof(struct xt_hashlimit_mtinfo3, hinfo),
+		.help          = hashlimit_mt_help_v3,
 		.init          = hashlimit_mt6_init,
 		.x6_parse      = hashlimit_mt_parse,
 		.x6_fcheck     = hashlimit_mt_check,
diff --git a/extensions/libxt_hashlimit.man b/extensions/libxt_hashlimit.man
index 6aac3f2..5dbb327 100644
--- a/extensions/libxt_hashlimit.man
+++ b/extensions/libxt_hashlimit.man
@@ -51,6 +51,14 @@ After how many milliseconds do hash entries expire.
 .TP
 \fB\-\-hashlimit\-htable\-gcinterval\fP \fImsec\fP
 How many milliseconds between garbage collection intervals.
+.TP
+\fB\-\-hashlimit\-rate\-match\fP
+Classify the flow instead of rate-limiting it. This acts like a
+true/flase match on whether the rate is above/below a certain number
+.TP
+\fB\-\-hashlimit\-rate\-interval\fP \fIsec\fP
+Can be used with \-\-hashlimit\-rate\-match to specify the interval
+at which the rate should be sampled
 .PP
 Examples:
 .TP
diff --git a/extensions/libxt_hashlimit.t b/extensions/libxt_hashlimit.t
index a163fdf..ccd0d1e 100644
--- a/extensions/libxt_hashlimit.t
+++ b/extensions/libxt_hashlimit.t
@@ -27,3 +27,7 @@
 -m hashlimit --hashlimit-upto 1/sec;;FAIL
 -m hashlimit;;FAIL
 -m hashlimit --hashlimit-upto 40/sec --hashlimit-burst 20 --hashlimit-mode srcip --hashlimit-name syn-flood;=;OK
+-m hashlimit --hashlimit-upto 40/sec --hashlimit-burst 20 --hashlimit-mode srcip --hashlimit-name rate1 --hashlimit-rate-match;=;OK
+-m hashlimit --hashlimit-upto 40mb/s --hashlimit-mode srcip --hashlimit-name rate2 --hashlimit-rate-match;=;OK
+-m hashlimit --hashlimit-upto 40/sec --hashlimit-burst 20 --hashlimit-mode srcip --hashlimit-name rate3 --hashlimit-rate-match --hashlimit-rate-interval 10;=;OK
+-m hashlimit --hashlimit-upto 40mb/s --hashlimit-mode srcip --hashlimit-name rate4 --hashlimit-rate-match --hashlimit-rate-interval 10;=;OK
diff --git a/include/linux/netfilter/xt_hashlimit.h b/include/linux/netfilter/xt_hashlimit.h
index d9808b5..ade33f6 100644
--- a/include/linux/netfilter/xt_hashlimit.h
+++ b/include/linux/netfilter/xt_hashlimit.h
@@ -17,12 +17,13 @@
 struct xt_hashlimit_htable;
 
 enum {
-	XT_HASHLIMIT_HASH_DIP = 1 << 0,
-	XT_HASHLIMIT_HASH_DPT = 1 << 1,
-	XT_HASHLIMIT_HASH_SIP = 1 << 2,
-	XT_HASHLIMIT_HASH_SPT = 1 << 3,
-	XT_HASHLIMIT_INVERT   = 1 << 4,
-	XT_HASHLIMIT_BYTES    = 1 << 5,
+	XT_HASHLIMIT_HASH_DIP	= 1 << 0,
+	XT_HASHLIMIT_HASH_DPT	= 1 << 1,
+	XT_HASHLIMIT_HASH_SIP	= 1 << 2,
+	XT_HASHLIMIT_HASH_SPT	= 1 << 3,
+	XT_HASHLIMIT_INVERT	= 1 << 4,
+	XT_HASHLIMIT_BYTES	= 1 << 5,
+	XT_HASHLIMIT_RATE_MATCH	= 1 << 6,
 };
 
 struct hashlimit_cfg {
@@ -77,6 +78,21 @@ struct hashlimit_cfg2 {
 	__u8 srcmask, dstmask;
 };
 
+struct hashlimit_cfg3 {
+	__u64 avg;		/* Average secs between packets * scale */
+	__u64 burst;		/* Period multiplier for upper limit. */
+	__u32 mode;		/* bitmask of XT_HASHLIMIT_HASH_* */
+
+	/* user specified */
+	__u32 size;		/* how many buckets */
+	__u32 max;		/* max number of entries */
+	__u32 gc_interval;	/* gc interval */
+	__u32 expire;		/* when do entries expire? */
+
+	__u32 interval;		/* in seconds*/
+	__u8 srcmask, dstmask;
+};
+
 struct xt_hashlimit_mtinfo1 {
 	char name[IFNAMSIZ];
 	struct hashlimit_cfg1 cfg;
@@ -93,4 +109,12 @@ struct xt_hashlimit_mtinfo2 {
 	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
 };
 
+struct xt_hashlimit_mtinfo3 {
+	char name[NAME_MAX];
+	struct hashlimit_cfg3 cfg;
+
+	/* Used internally by the kernel */
+	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
+};
+
 #endif /*_XT_HASHLIMIT_H*/
-- 
1.9.1

