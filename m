From: "Vitaly E. Lavrov" <lve@guap.ru>
Subject: [RFC PATCH] tc filter not show last u32 filter
Date: Tue, 21 Apr 2015 20:53:03 +0300
Message-ID: <55368E7F.4030005@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.guap.ru ([91.151.188.3]:17517 "EHLO mail.guap.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbbDUSIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2015 14:08:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"tc filter show" does not show last U32 filter on 32-bit systems (tested on x86).

Additional condition: filter does not have action and CONFIG_NET_CLS_ACT=y

Example: tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip dst 10.200.2.2 flowid 1:20

Function tcf_action_copy_stats() returns an error because the (struct tc_action *)a->priv is NULL (for 32bit systems).

The sequence of calls:

u32_dump()
   cls_u32.c:1009 if (tcf_exts_dump_stats(skb, &n->exts) < 0) goto nla_put_failure;

   tcf_exts_dump_stats()
      cls_api.c:606  if (tcf_action_copy_stats(skb, a, 1) < 0) return -1;

      tcf_action_copy_stats()
         act_api.c:604 struct tcf_common *p = a->priv;
         act_api.c:606 if (p == NULL) goto errout; // return -1;

One of variants correcting this error is a verify the existence of action before calling tcf_action_copy_stats().

Patch for kernel 3.18.10

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index aad6a67..8e7ad61 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -602,9 +602,11 @@ EXPORT_SYMBOL(tcf_exts_dump);
  int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
  {
  #ifdef CONFIG_NET_CLS_ACT
-       struct tc_action *a = tcf_exts_first_act(exts);
-       if (tcf_action_copy_stats(skb, a, 1) < 0)
-               return -1;
+       if(tcf_exts_is_available(exts)) {
+               struct tc_action *a = tcf_exts_first_act(exts);
+               if (tcf_action_copy_stats(skb, a, 1) < 0)
+                       return -1;
+       }
  #endif
         return 0;
  }


This will fix the bug 84661 https://bugzilla.kernel.org/show_bug.cgi?id=84661

In 64bit system a->priv is not NULL, but is not a valid pointer, but because of a->type == 0 and
compat_mode == 1 returns a value 0.

"tc filter show dev eth0".
------------------------
tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip dst 10.200.2.2 flowid 1:20
tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip dst 10.200.2.3 flowid 1:30
tc filter show dev eth0
....
(1) filter parent 1: protocol ip pref 100 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:20
   match 0ac80202/ffffffff at 16
(2) filter parent 1: protocol ip pref 100 u32 fh 800::801 order 2049 key ht 800 bkt 0 flowid 1:30
   match 0ac80203/ffffffff at 16
------------------------
64bit system
(1) a->priv == 0x80000800
(2) a->priv == 0x80000801

32bit system
(1) a->priv == 0x0
(2) a->priv == 0x0

I could not understand the reason for this difference between 32-bit and 64-bit systems.
