From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Provide compat policer stats in action policer
Date: Wed, 15 Dec 2004 14:01:28 +0100
Message-ID: <20041215130128.GK8493@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This should go in before 2.6.10. It fixes a forgotten case to provide
police backward compatibility statistics for old iproute2 versions
running on a new kernel with actions enabled. Should make distributions
happy with older iproute2 versions and all-included kernel configs
since they probably favour actions over plain policer.

Testing results:
  iproute2-2.4.7 on 2.6.10-rc3-bk8:
  cls-police: police creation succeeded
  cls-police: Sending 10 ICMP echo requests
  cls-police: police dumping succeeded with output:
  filter protocol ip pref 10 u32 
  filter protocol ip pref 10 u32 fh 800: ht divisor 1 
  filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 10:12 
  police 3 action drop rate 2Kbit burst 10Kb mtu 2Kb 
    match 00010000/00ff0000 at 8
   Sent 420 bytes 10 pkts (dropped 0, overlimits 0)  <-- This would have been missing
  cls-police: police deletion succeeded

 iproute2-2.6.9 on 2.6.10-rc3-bk8:
 ...
  filter protocol ip pref 10 u32 
  filter protocol ip pref 10 u32 fh 800: ht divisor 1 
  filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 10:12  (rule hit 10 success 10)
    match 00010000/00ff0000 at 8 (success 10 ) 
   police 0x4 rate 2000bit burst 10Kb mtu 2Kb action drop 
  ref 1 bind 1
   Sent 420 bytes 10 pkts (dropped 0, overlimits 0) 
 ...

 (Same results for fw classifier)

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc3-bk7.orig/net/sched/act_api.c	2004-12-14 14:24:34.000000000 +0100
+++ linux-2.6.10-rc3-bk7/net/sched/act_api.c	2004-12-14 16:15:13.000000000 +0100
@@ -418,6 +418,7 @@
 
 int tcf_action_copy_stats (struct sk_buff *skb,struct tc_action *a)
 {
+	int err;
 	struct gnet_dump d;
 	struct tcf_act_hdr *h = a->priv;
 	
@@ -428,7 +429,14 @@
 	if (NULL == h)
 		goto errout;
 
-	if (gnet_stats_start_copy(skb, TCA_ACT_STATS, h->stats_lock, &d) < 0)
+	if (a->type == TCA_OLD_COMPAT)
+		err = gnet_stats_start_copy_compat(skb, TCA_ACT_STATS,
+			TCA_STATS, TCA_XSTATS, h->stats_lock, &d);
+	else
+		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
+			h->stats_lock, &d);
+
+	if (err < 0)
 		goto errout;
 
 	if (NULL != a->ops && NULL != a->ops->get_stats)
