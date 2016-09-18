From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 2/2] net sched ife action: Introduce skb tcindex metadata encap decap
Date: Sun, 18 Sep 2016 07:21:16 -0400
Message-ID: <1474197676-10512-2-git-send-email-jhs@emojatatu.com>
References: <1474197676-10512-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35501 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754693AbcIRLV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 07:21:26 -0400
Received: by mail-io0-f196.google.com with SMTP id q92so3713065ioi.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 04:21:25 -0700 (PDT)
In-Reply-To: <1474197676-10512-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Sample use case of how this is encoded:
user space via tuntap (or a connected VM/Machine/container)
encodes the tcindex TLV.

Sample use case of decoding:
IFE action decodes it and the skb->tc_index is then used to classify.
So something like this for encoded ICMP packets:

.. first decode then reclassify... skb->tcindex will be set
sudo $TC filter add dev $ETH parent ffff: prio 2 protocol 0xbeef \
u32 match u32 0 0 flowid 1:1 \
action ife decode reclassify

...next match the decode icmp packet...
sudo $TC filter add dev $ETH parent ffff: prio 4 protocol ip \
u32 match ip protocol 1 0xff flowid 1:1 \
action continue

... last classify it using the tcindex classifier and do someaction..
sudo $TC filter add dev $ETH parent ffff: prio 5 protocol ip \
handle 0x11 tcindex classid 1:1 \
action blah..

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/tc_act/tc_ife.h | 3 ++-
 net/sched/Kconfig                  | 5 +++++
 net/sched/Makefile                 | 1 +
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tc_act/tc_ife.h b/include/uapi/linux/tc_act/tc_ife.h
index 4ece02a..cd18360 100644
--- a/include/uapi/linux/tc_act/tc_ife.h
+++ b/include/uapi/linux/tc_act/tc_ife.h
@@ -32,8 +32,9 @@ enum {
 #define IFE_META_HASHID 2
 #define	IFE_META_PRIO 3
 #define	IFE_META_QMAP 4
+#define	IFE_META_TCINDEX 5
 /*Can be overridden at runtime by module option*/
-#define	__IFE_META_MAX 5
+#define	__IFE_META_MAX 6
 #define IFE_META_MAX (__IFE_META_MAX - 1)
 
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 7795d5a..87956a7 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -793,6 +793,11 @@ config NET_IFE_SKBPRIO
         depends on NET_ACT_IFE
         ---help---
 
+config NET_IFE_SKBTCINDEX
+        tristate "Support to encoding decoding skb tcindex on IFE action"
+        depends on NET_ACT_IFE
+        ---help---
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 148ae0d..4bdda36 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_ACT_SKBMOD)	+= act_skbmod.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
+obj-$(CONFIG_NET_IFE_SKBTCINDEX)	+= act_meta_skbtcindex.o
 obj-$(CONFIG_NET_ACT_TUNNEL_KEY)+= act_tunnel_key.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
-- 
1.9.1
