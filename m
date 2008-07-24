From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 16:23:53 +0200
Message-ID: <20080724142353.GA400@elte.hu>
References: <20080724060448.GA10203@elte.hu> <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au> <20080724.022259.113079007.davem@davemloft.net> <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu> <20080724115957.GA25701@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>,
	Krzysztof Piotr Oledzki <ole@ans.pl>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43463 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbYGXOZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 10:25:14 -0400
Content-Disposition: inline
In-Reply-To: <20080724115957.GA25701@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> here's the full bootlog:
> 
>  http://redhat.com/~mingo/misc/crash-Thu_Jul_24_13_23_34_CEST_2008.log
> 
> kernel is latest -git, v2.6.26-6371-g338b9bb.

FYI, this was the most complex bisection i have ever done under Linux.

Firstly, automated bisection honed in on an already known bad commit, so 
i had to do another, manual bisection.

There i hit four other regression and i had to work them around at 
multiple bisection points to be able to bisect this regression. I also 
had to do a "nested" sub-bisection to fix one of the bisection points.

In case someone else has to bisect in the future in this region as well, 
here is the list:

1) I hit the mac802 hwsim NULL dereference bootup crash and 
   cherry-picked its fix, 3a33cc108d1. Alas, that didnt work - so i 
   tweaked the .config. (hoping that it would not change the crash 
   pattern - fortunately it didnt)

2) build failure:

     net/built-in.o: In function `dev_queue_xmit':
     : undefined reference to `qdisc_calculate_pkt_len'
     net/built-in.o: In function `__qdisc_destroy':
     sch_generic.c:(.text+0x22874): undefined reference to qdisc_put_stab'
     net/built-in.o: In function `ieee80211_requeue':
     : undefined reference to `qdisc_calculate_pkt_len'

   had to do a secondary, nested bisection to figure out that the 
   build at this commit point was broken by 175f9c1bba9b ("net_sched: 
   Add size table for qdiscs") and reverted it.

3) on bisection point 11ea859d64b i got a hard lockup:

   BUG: NMI Watchdog detected LOCKUP on CPU0, ip ffffffff8028ef43, registers:

   Call Trace:
    [<ffffffff8028f3c6>] slob_alloc+0x9c/0x248
    [<ffffffff8028f59d>] kmem_cache_alloc_node+0x2b/0x5e
    [<ffffffff80292e42>] get_empty_filp+0x4f/0xee
    [<ffffffff8029c635>] __path_lookup_intent_open+0x2f/0x9f
    [<ffffffff8029c719>] path_lookup_open+0xc/0xe
    [<ffffffff8029c7c8>] do_filp_open+0xad/0x7e7
    [<ffffffff80272bec>] ? trace_preempt_on+0x9/0xb
    [<ffffffff802419d9>] ? sub_preempt_count+0x2d/0x40
    [<ffffffff802903ca>] ? get_unused_fd_flags+0x110/0x128
    [<ffffffff80290433>] do_sys_open+0x51/0xd8
    [<ffffffff802904e3>] sys_open+0x1b/0x1d
    [<ffffffff802247aa>] system_call_after_swapgs+0x9a/0x9f

   This might or might not be the same regression so i picked another 
   bisection point from the middle of the range, 11ea859d64b.

4) On one of the last bisection points (c3ee841) i hit this KVM 
   regression:

      arch/x86/kvm/built-in.o:(.text.fixup+0x1): relocation truncated to fit: R_X86_64_32 against `.text'

   i cherry-picked the fix 33a37eb411d.

Thus in this second bisection i arrived to:

| ae6134bdf3197206fba95563d755d2fa50d90ddd is first bad commit
| commit ae6134bdf3197206fba95563d755d2fa50d90ddd
| Author: Micah Dowty <micah@navi.cx>
| Date:   Mon Jul 21 09:59:09 2008 -0700
|
|    hdlcdrv: Fix CRC calculation.

Ok: recent change, networking related, i had this driver enabled, looks 
plausible. Here's the bisection log:

 # bad:  [338b9bb2] Merge branch 'x86/auditsc' of git://git.kernel.org
 # good: [bce7f795] Linux 2.6.26
 # good: [bce7f795] Linux 2.6.26
 # good: [bce7f795] Linux 2.6.26
 # good: [43146521] Merge branch 'release-2.6.27' of git://git.kernel.
 # good: [906f25b3] Revert "net_sched: Add size table for qdiscs"
 # good: [72a73693] Merge branch 'x86/for-linus' of git://git.kernel.o
 # bad:  [0988c371] Merge branch 'x86-fixes-for-linus' of git://git.ke
 # bad:  [a6e2ba82] block: make /proc/diskstats only build if CONFIG_P
 # bad:  [e89970a5] Merge git://git.kernel.org/pub/scm/linux/kernel/gi
 # bad:  [ae6134bd] hdlcdrv: Fix CRC calculation.
 # good: [c3ee841b] pkt_sched: Remove unused variable skb in dev_deact
 # good: [867d79f4] net: In __netif_schedule() use WARN_ON instead of
 # good: [d3678b4b] Revert "pkt_sched: Make default qdisc nonshared-mu

[ and this bisection found a small Git buglet as well: it shows a
  small git-bisect buglet. (Those three 2.6.26 log entries are there
  because git-bisect failed to check out the target bisection point two
  times due to untracked files.) ]

So i reverted "hdlcdrv: Fix CRC calculation." (ae6134bdf) ...

... but got the same crash again. So either the crash is not 
deterministic or one of the bisection points had to be wrong. (which, 
given the multitude of other regressions, is really not a surprise)

Then i tried both suggested fix patches Patrick sent me (a suggested 
revert and an netfilter/RCU use-after-free fix), but none of them solved 
the crash.

So i looked at the failed bisection log again, and noticed that the 
'bad' commit ae6134bdf is just next to a string of netfilter commits:

 5547cd0: netfilter: nf_conntrack_sctp: fix sparse warnings
 c71529e: netfilter: nf_nat_sip: c= is optional for session
 db1a75b: netfilter: xt_TCPMSS: collapse tcpmss_reverse_mtu{4,6} into one function
 72961ec: netfilter: nfnetlink_log: send complete hardware header
 280763c: netfilter: xt_time: fix time's time_mt()'s use of do_div()
 5840157: netfilter: accounting rework: ct_extend + 64bit counters (v4)
 07a7c10: netlink: add NLA_PUT_BE64 macro
 0dbff68: netfilter: nf_nat_core: eliminate useless find_appropriate_src for IP_N
 ae6134b: hdlcdrv: Fix CRC calculation.

... and the crash was in netfilter after all.

So i cornered the bug by checking:

   5547cd0   => crash
   ae6134bdf => good

... and starting off that point again, with the third bisection.

Thus i finally arrived to:

 # good: [ae6134bd] hdlcdrv: Fix CRC calculation.
 # bad:  [5547cd0d] netfilter: nf_conntrack_sctp: fix sparse warnings
 # bad:  [280763c6] netfilter: xt_time: fix time's time_mt()'s use of
 # good: [07a7c10b] netlink: add NLA_PUT_BE64 macro
 # bad:  [58401573] netfilter: accounting rework: ct_extend + 64bit co

| 584015727a3b88b46602b20077b46cd04f8b4ab3 is first bad commit
| commit 584015727a3b88b46602b20077b46cd04f8b4ab3
| Author: Krzysztof Piotr Oledzki <ole@ans.pl>
| AuthorDate: Mon Jul 21 10:01:34 2008 -0700
| Commit:     David S. Miller <davem@davemloft.net>
| CommitDate: Mon Jul 21 10:10:58 2008 -0700
|
|    netfilter: accounting rework: ct_extend + 64bit counters (v4)
[...]
|     Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
|     Signed-off-by: Patrick McHardy <kaber@trash.net>
|     Signed-off-by: David S. Miller <davem@davemloft.net>

Which i double-checked by reverting that commit from -git as well and 
that solved the crash. Find the tested reverter patch below.

	Ingo

----------------------->
commit 548d9ef5fc65d921d20528de7b4d50e6cf0a1a15
Author: Ingo Molnar <mingo@elte.hu>
Date:   Thu Jul 24 15:16:22 2008 +0200

    Revert "netfilter: accounting rework: ct_extend + 64bit counters (v4)"
    
    This reverts commit 584015727a3b88b46602b20077b46cd04f8b4ab3.

    Signed-off-by: Ingo Molnar <mingo@elte.hu>

---
 Documentation/feature-removal-schedule.txt         |   10 --
 Documentation/kernel-parameters.txt                |    7 --
 include/linux/netfilter/nf_conntrack_common.h      |    8 ++-
 include/linux/netfilter/nfnetlink_conntrack.h      |    8 +-
 include/net/netfilter/nf_conntrack.h               |    6 +
 include/net/netfilter/nf_conntrack_acct.h          |   51 ----------
 include/net/netfilter/nf_conntrack_extend.h        |    2 -
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   18 +++-
 net/netfilter/Kconfig                              |    9 --
 net/netfilter/Makefile                             |    2 +-
 net/netfilter/nf_conntrack_acct.c                  |  104 --------------------
 net/netfilter/nf_conntrack_core.c                  |   39 +++-----
 net/netfilter/nf_conntrack_netlink.c               |   44 +++++----
 net/netfilter/nf_conntrack_standalone.c            |   18 +++-
 net/netfilter/xt_connbytes.c                       |    8 +-
 15 files changed, 86 insertions(+), 248 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 9f73587..86334b6 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -336,13 +336,3 @@ When:	After the only user (hal) has seen a release with the patches
 Why:	Over 1K .text/.data size reduction, data is available in other
 	ways (ioctls)
 Who:	Johannes Berg <johannes@sipsolutions.net>
-
----------------------------
-
-What: CONFIG_NF_CT_ACCT
-When: 2.6.29
-Why:  Accounting can now be enabled/disabled without kernel recompilation.
-      Currently used only to set a default value for a feature that is also
-      controlled by a kernel/module/sysfs/sysctl parameter.
-Who:  Krzysztof Piotr Oledzki <ole@ans.pl>
-
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 931f960..1d7e6b0 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1279,13 +1279,6 @@ and is between 256 and 4096 characters. It is defined in the file
 			This usage is only documented in each driver source
 			file if at all.
 
-	nf_conntrack.acct=
-			[NETFILTER] Enable connection tracking flow accounting
-			0 to disable accounting
-			1 to enable accounting
-			Default value depends on CONFIG_NF_CT_ACCT that is
-			going to be removed in 2.6.29.
-
 	nfsaddrs=	[NFS]
 			See Documentation/filesystems/nfsroot.txt.
 
diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 885cbe2..bad1eb7 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -122,7 +122,7 @@ enum ip_conntrack_events
 	IPCT_NATINFO_BIT = 10,
 	IPCT_NATINFO = (1 << IPCT_NATINFO_BIT),
 
-	/* Counter highest bit has been set, unused */
+	/* Counter highest bit has been set */
 	IPCT_COUNTER_FILLING_BIT = 11,
 	IPCT_COUNTER_FILLING = (1 << IPCT_COUNTER_FILLING_BIT),
 
@@ -145,6 +145,12 @@ enum ip_conntrack_expect_events {
 };
 
 #ifdef __KERNEL__
+struct ip_conntrack_counter
+{
+	u_int32_t packets;
+	u_int32_t bytes;
+};
+
 struct ip_conntrack_stat
 {
 	unsigned int searched;
diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index c19595c..759bc04 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -115,10 +115,10 @@ enum ctattr_protoinfo_sctp {
 
 enum ctattr_counters {
 	CTA_COUNTERS_UNSPEC,
-	CTA_COUNTERS_PACKETS,		/* 64bit counters */
-	CTA_COUNTERS_BYTES,		/* 64bit counters */
-	CTA_COUNTERS32_PACKETS,		/* old 32bit counters, unused */
-	CTA_COUNTERS32_BYTES,		/* old 32bit counters, unused */
+	CTA_COUNTERS_PACKETS,		/* old 64bit counters */
+	CTA_COUNTERS_BYTES,		/* old 64bit counters */
+	CTA_COUNTERS32_PACKETS,
+	CTA_COUNTERS32_BYTES,
 	__CTA_COUNTERS_MAX
 };
 #define CTA_COUNTERS_MAX (__CTA_COUNTERS_MAX - 1)
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 0741ad5..8f5b757 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -88,6 +88,7 @@ struct nf_conn_help {
 	u8 expecting[NF_CT_MAX_EXPECT_CLASSES];
 };
 
+
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
@@ -110,6 +111,11 @@ struct nf_conn
 	/* Timer function; drops refcnt when it goes off. */
 	struct timer_list timeout;
 
+#ifdef CONFIG_NF_CT_ACCT
+	/* Accounting Information (same cache line as other written members) */
+	struct ip_conntrack_counter counters[IP_CT_DIR_MAX];
+#endif
+
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	u_int32_t mark;
 #endif
diff --git a/include/net/netfilter/nf_conntrack_acct.h b/include/net/netfilter/nf_conntrack_acct.h
deleted file mode 100644
index 5d5ae55..0000000
--- a/include/net/netfilter/nf_conntrack_acct.h
+++ /dev/null
@@ -1,51 +0,0 @@
-/*
- * (C) 2008 Krzysztof Piotr Oledzki <ole@ans.pl>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _NF_CONNTRACK_ACCT_H
-#define _NF_CONNTRACK_ACCT_H
-#include <linux/netfilter/nf_conntrack_common.h>
-#include <linux/netfilter/nf_conntrack_tuple_common.h>
-#include <net/netfilter/nf_conntrack.h>
-#include <net/netfilter/nf_conntrack_extend.h>
-
-struct nf_conn_counter {
-	u_int64_t packets;
-	u_int64_t bytes;
-};
-
-extern int nf_ct_acct;
-
-static inline
-struct nf_conn_counter *nf_conn_acct_find(const struct nf_conn *ct)
-{
-	return nf_ct_ext_find(ct, NF_CT_EXT_ACCT);
-}
-
-static inline
-struct nf_conn_counter *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
-{
-	struct nf_conn_counter *acct;
-
-	if (!nf_ct_acct)
-		return NULL;
-
-	acct = nf_ct_ext_add(ct, NF_CT_EXT_ACCT, gfp);
-	if (!acct)
-		pr_debug("failed to add accounting extension area");
-
-
-	return acct;
-};
-
-extern unsigned int
-seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir);
-
-extern int nf_conntrack_acct_init(void);
-extern void nf_conntrack_acct_fini(void);
-
-#endif /* _NF_CONNTRACK_ACCT_H */
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index da8ee52..f80c0ed 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -7,13 +7,11 @@ enum nf_ct_ext_id
 {
 	NF_CT_EXT_HELPER,
 	NF_CT_EXT_NAT,
-	NF_CT_EXT_ACCT,
 	NF_CT_EXT_NUM,
 };
 
 #define NF_CT_EXT_HELPER_TYPE struct nf_conn_help
 #define NF_CT_EXT_NAT_TYPE struct nf_conn_nat
-#define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 3a02072..40a46d4 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -18,7 +18,19 @@
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_expect.h>
-#include <net/netfilter/nf_conntrack_acct.h>
+
+#ifdef CONFIG_NF_CT_ACCT
+static unsigned int
+seq_print_counters(struct seq_file *s,
+		   const struct ip_conntrack_counter *counter)
+{
+	return seq_printf(s, "packets=%llu bytes=%llu ",
+			  (unsigned long long)counter->packets,
+			  (unsigned long long)counter->bytes);
+}
+#else
+#define seq_print_counters(x, y)	0
+#endif
 
 struct ct_iter_state {
 	unsigned int bucket;
@@ -115,7 +127,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 			l3proto, l4proto))
 		return -ENOSPC;
 
-	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
+	if (seq_print_counters(s, &ct->counters[IP_CT_DIR_ORIGINAL]))
 		return -ENOSPC;
 
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
@@ -126,7 +138,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 			l3proto, l4proto))
 		return -ENOSPC;
 
-	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
+	if (seq_print_counters(s, &ct->counters[IP_CT_DIR_REPLY]))
 		return -ENOSPC;
 
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ee898e7..316c7af 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -49,15 +49,6 @@ config NF_CT_ACCT
 	  Those counters can be used for flow-based accounting or the
 	  `connbytes' match.
 
-	  Please note that currently this option only sets a default state.
-	  You may change it at boot time with nf_conntrack.acct=0/1 kernel
-	  paramater or by loading the nf_conntrack module with acct=0/1.
-
-	  You may also disable/enable it on a running system with:
-	   sysctl net.netfilter.nf_conntrack_acct=0/1
-
-	  This option will be removed in 2.6.29.
-
 	  If unsure, say `N'.
 
 config NF_CONNTRACK_MARK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 3bd2cc5..5c4b183 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,6 +1,6 @@
 netfilter-objs := core.o nf_log.o nf_queue.o nf_sockopt.o
 
-nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o nf_conntrack_acct.o
+nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
deleted file mode 100644
index 59bd8b9..0000000
--- a/net/netfilter/nf_conntrack_acct.c
+++ /dev/null
@@ -1,104 +0,0 @@
-/* Accouting handling for netfilter. */
-
-/*
- * (C) 2008 Krzysztof Piotr Oledzki <ole@ans.pl>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/netfilter.h>
-#include <linux/kernel.h>
-#include <linux/moduleparam.h>
-
-#include <net/netfilter/nf_conntrack.h>
-#include <net/netfilter/nf_conntrack_extend.h>
-#include <net/netfilter/nf_conntrack_acct.h>
-
-#ifdef CONFIG_NF_CT_ACCT
-#define NF_CT_ACCT_DEFAULT 1
-#else
-#define NF_CT_ACCT_DEFAULT 0
-#endif
-
-int nf_ct_acct __read_mostly = NF_CT_ACCT_DEFAULT;
-EXPORT_SYMBOL_GPL(nf_ct_acct);
-
-module_param_named(acct, nf_ct_acct, bool, 0644);
-MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
-
-#ifdef CONFIG_SYSCTL
-static struct ctl_table_header *acct_sysctl_header;
-static struct ctl_table acct_sysctl_table[] = {
-	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "nf_conntrack_acct",
-		.data		= &nf_ct_acct,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{}
-};
-#endif /* CONFIG_SYSCTL */
-
-unsigned int
-seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
-{
-	struct nf_conn_counter *acct;
-
-	acct = nf_conn_acct_find(ct);
-	if (!acct)
-		return 0;
-
-	return seq_printf(s, "packets=%llu bytes=%llu ",
-			  (unsigned long long)acct[dir].packets,
-			  (unsigned long long)acct[dir].bytes);
-};
-EXPORT_SYMBOL_GPL(seq_print_acct);
-
-static struct nf_ct_ext_type acct_extend __read_mostly = {
-	.len	= sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]),
-	.align	= __alignof__(struct nf_conn_counter[IP_CT_DIR_MAX]),
-	.id	= NF_CT_EXT_ACCT,
-};
-
-int nf_conntrack_acct_init(void)
-{
-	int ret;
-
-#ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Plase use\n");
-	printk(KERN_WARNING "nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or\n");
-	printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
-#endif
-
-	ret = nf_ct_extend_register(&acct_extend);
-	if (ret < 0) {
-		printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
-		return ret;
-	}
-
-#ifdef CONFIG_SYSCTL
-	acct_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
-				acct_sysctl_table);
-
-	if (!acct_sysctl_header) {
-		nf_ct_extend_unregister(&acct_extend);
-
-		printk(KERN_ERR "nf_conntrack_acct: can't register to sysctl.\n");
-		return -ENOMEM;
-	}
-#endif
-
-	return 0;
-}
-
-void nf_conntrack_acct_fini(void)
-{
-#ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(acct_sysctl_header);
-#endif
-	nf_ct_extend_unregister(&acct_extend);
-}
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c519d09..28d03e6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -37,7 +37,6 @@
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_extend.h>
-#include <net/netfilter/nf_conntrack_acct.h>
 
 #define NF_CONNTRACK_VERSION	"0.5.0"
 
@@ -556,8 +555,6 @@ init_conntrack(const struct nf_conntrack_tuple *tuple,
 		return NULL;
 	}
 
-	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
-
 	spin_lock_bh(&nf_conntrack_lock);
 	exp = nf_ct_find_expectation(tuple);
 	if (exp) {
@@ -831,16 +828,17 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 	}
 
 acct:
+#ifdef CONFIG_NF_CT_ACCT
 	if (do_acct) {
-		struct nf_conn_counter *acct;
+		ct->counters[CTINFO2DIR(ctinfo)].packets++;
+		ct->counters[CTINFO2DIR(ctinfo)].bytes +=
+			skb->len - skb_network_offset(skb);
 
-		acct = nf_conn_acct_find(ct);
-		if (acct) {
-			acct[CTINFO2DIR(ctinfo)].packets++;
-			acct[CTINFO2DIR(ctinfo)].bytes +=
-				skb->len - skb_network_offset(skb);
-		}
+		if ((ct->counters[CTINFO2DIR(ctinfo)].packets & 0x80000000)
+		    || (ct->counters[CTINFO2DIR(ctinfo)].bytes & 0x80000000))
+			event |= IPCT_COUNTER_FILLING;
 	}
+#endif
 
 	spin_unlock_bh(&nf_conntrack_lock);
 
@@ -855,19 +853,15 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 		       const struct sk_buff *skb,
 		       int do_acct)
 {
+#ifdef CONFIG_NF_CT_ACCT
 	if (do_acct) {
-		struct nf_conn_counter *acct;
-
 		spin_lock_bh(&nf_conntrack_lock);
-		acct = nf_conn_acct_find(ct);
-		if (acct) {
-			acct[CTINFO2DIR(ctinfo)].packets++;
-			acct[CTINFO2DIR(ctinfo)].bytes +=
-				skb->len - skb_network_offset(skb);
-		}
+		ct->counters[CTINFO2DIR(ctinfo)].packets++;
+		ct->counters[CTINFO2DIR(ctinfo)].bytes +=
+			skb->len - skb_network_offset(skb);
 		spin_unlock_bh(&nf_conntrack_lock);
 	}
-
+#endif
 	if (del_timer(&ct->timeout)) {
 		ct->timeout.function((unsigned long)ct);
 		return true;
@@ -1035,7 +1029,6 @@ void nf_conntrack_cleanup(void)
 	nf_conntrack_proto_fini();
 	nf_conntrack_helper_fini();
 	nf_conntrack_expect_fini();
-	nf_conntrack_acct_fini();
 }
 
 struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced)
@@ -1175,10 +1168,6 @@ int __init nf_conntrack_init(void)
 	if (ret < 0)
 		goto out_fini_expect;
 
-	ret = nf_conntrack_acct_init();
-	if (ret < 0)
-		goto out_fini_helper;
-
 	/* For use by REJECT target */
 	rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
 	rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
@@ -1191,8 +1180,6 @@ int __init nf_conntrack_init(void)
 
 	return ret;
 
-out_fini_helper:
-	nf_conntrack_helper_fini();
 out_fini_expect:
 	nf_conntrack_expect_fini();
 out_fini_proto:
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 105a616..95a7967 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -37,7 +37,6 @@
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
-#include <net/netfilter/nf_conntrack_acct.h>
 #ifdef CONFIG_NF_NAT_NEEDED
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_protocol.h>
@@ -207,26 +206,22 @@ nla_put_failure:
 	return -1;
 }
 
+#ifdef CONFIG_NF_CT_ACCT
 static int
 ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
 			enum ip_conntrack_dir dir)
 {
 	enum ctattr_type type = dir ? CTA_COUNTERS_REPLY: CTA_COUNTERS_ORIG;
 	struct nlattr *nest_count;
-	const struct nf_conn_counter *acct;
-
-	acct = nf_conn_acct_find(ct);
-	if (!acct)
-		return 0;
 
 	nest_count = nla_nest_start(skb, type | NLA_F_NESTED);
 	if (!nest_count)
 		goto nla_put_failure;
 
-	NLA_PUT_BE64(skb, CTA_COUNTERS_PACKETS,
-		     cpu_to_be64(acct[dir].packets));
-	NLA_PUT_BE64(skb, CTA_COUNTERS_BYTES,
-		     cpu_to_be64(acct[dir].bytes));
+	NLA_PUT_BE32(skb, CTA_COUNTERS32_PACKETS,
+		     htonl(ct->counters[dir].packets));
+	NLA_PUT_BE32(skb, CTA_COUNTERS32_BYTES,
+		     htonl(ct->counters[dir].bytes));
 
 	nla_nest_end(skb, nest_count);
 
@@ -235,6 +230,9 @@ ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
 nla_put_failure:
 	return -1;
 }
+#else
+#define ctnetlink_dump_counters(a, b, c) (0)
+#endif
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
 static inline int
@@ -503,6 +501,11 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 			goto nla_put_failure;
 #endif
 
+		if (events & IPCT_COUNTER_FILLING &&
+		    (ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
+		     ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0))
+			goto nla_put_failure;
+
 		if (events & IPCT_RELATED &&
 		    ctnetlink_dump_master(skb, ct) < 0)
 			goto nla_put_failure;
@@ -573,15 +576,11 @@ restart:
 				cb->args[1] = (unsigned long)ct;
 				goto out;
 			}
-
+#ifdef CONFIG_NF_CT_ACCT
 			if (NFNL_MSG_TYPE(cb->nlh->nlmsg_type) ==
-						IPCTNL_MSG_CT_GET_CTRZERO) {
-				struct nf_conn_counter *acct;
-
-				acct = nf_conn_acct_find(ct);
-				if (acct)
-					memset(acct, 0, sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]));
-			}
+						IPCTNL_MSG_CT_GET_CTRZERO)
+				memset(&ct->counters, 0, sizeof(ct->counters));
+#endif
 		}
 		if (cb->args[1]) {
 			cb->args[1] = 0;
@@ -833,9 +832,14 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	u_int8_t u3 = nfmsg->nfgen_family;
 	int err = 0;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP)
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+#ifndef CONFIG_NF_CT_ACCT
+		if (NFNL_MSG_TYPE(nlh->nlmsg_type) == IPCTNL_MSG_CT_GET_CTRZERO)
+			return -ENOTSUPP;
+#endif
 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
 					  ctnetlink_done);
+	}
 
 	if (cda[CTA_TUPLE_ORIG])
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG, u3);
@@ -1148,8 +1152,6 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 			goto err;
 	}
 
-	nf_ct_acct_ext_add(ct, GFP_KERNEL);
-
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
 		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 869ef93..46ea542 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -25,7 +25,6 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_helper.h>
-#include <net/netfilter/nf_conntrack_acct.h>
 
 MODULE_LICENSE("GPL");
 
@@ -39,6 +38,19 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
 }
 EXPORT_SYMBOL_GPL(print_tuple);
 
+#ifdef CONFIG_NF_CT_ACCT
+static unsigned int
+seq_print_counters(struct seq_file *s,
+		   const struct ip_conntrack_counter *counter)
+{
+	return seq_printf(s, "packets=%llu bytes=%llu ",
+			  (unsigned long long)counter->packets,
+			  (unsigned long long)counter->bytes);
+}
+#else
+#define seq_print_counters(x, y)	0
+#endif
+
 struct ct_iter_state {
 	unsigned int bucket;
 };
@@ -134,7 +146,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 			l3proto, l4proto))
 		return -ENOSPC;
 
-	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
+	if (seq_print_counters(s, &ct->counters[IP_CT_DIR_ORIGINAL]))
 		return -ENOSPC;
 
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
@@ -145,7 +157,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 			l3proto, l4proto))
 		return -ENOSPC;
 
-	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
+	if (seq_print_counters(s, &ct->counters[IP_CT_DIR_REPLY]))
 		return -ENOSPC;
 
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 3e39c4f..d7e8983 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -8,7 +8,6 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_connbytes.h>
 #include <net/netfilter/nf_conntrack.h>
-#include <net/netfilter/nf_conntrack_acct.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
@@ -28,15 +27,12 @@ connbytes_mt(const struct sk_buff *skb, const struct net_device *in,
 	u_int64_t what = 0;	/* initialize to make gcc happy */
 	u_int64_t bytes = 0;
 	u_int64_t pkts = 0;
-	const struct nf_conn_counter *counters;
+	const struct ip_conntrack_counter *counters;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct)
 		return false;
-
-	counters = nf_conn_acct_find(ct);
-	if (!counters)
-		return false;
+	counters = ct->counters;
 
 	switch (sinfo->what) {
 	case XT_CONNBYTES_PKTS:
