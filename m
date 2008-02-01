From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vlan tag match
Date: Thu, 31 Jan 2008 21:07:32 -0800
Message-ID: <20080131210732.25f42884@extreme>
References: <20080131.194644.03127203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:32873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764667AbYBAFHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 00:07:38 -0500
In-Reply-To: <20080131.194644.03127203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a way to use tc filters on vlan tag even if tag is buried in
skb due to hardware acceleration.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 include/linux/pkt_cls.h              |    3 ++-
 include/linux/tc_ematch/tc_em_meta.h |    1 +
 net/sched/em_meta.c                  |   17 +++++++++++++++++
 3 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 1c1dba9..40fac8c 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -459,7 +459,8 @@ enum
 #define	TCF_EM_U32		3
 #define	TCF_EM_META		4
 #define	TCF_EM_TEXT		5
-#define	TCF_EM_MAX		5
+#define        TCF_EM_VLAN		6
+#define	TCF_EM_MAX		6
 
 enum
 {
diff --git a/include/linux/tc_ematch/tc_em_meta.h b/include/linux/tc_ematch/tc_em_meta.h
index e21937c..c50d2ba 100644
--- a/include/linux/tc_ematch/tc_em_meta.h
+++ b/include/linux/tc_ematch/tc_em_meta.h
@@ -81,6 +81,7 @@ enum
  	TCF_META_ID_SK_SNDTIMEO,
  	TCF_META_ID_SK_SENDMSG_OFF,
  	TCF_META_ID_SK_WRITE_PENDING,
+	TCF_META_ID_VLAN_TAG,
 	__TCF_META_ID_MAX
 };
 #define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index a1e5619..9c2ec19 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -65,6 +65,7 @@
 #include <linux/string.h>
 #include <linux/skbuff.h>
 #include <linux/random.h>
+#include <linux/if_vlan.h>
 #include <linux/tc_ematch/tc_em_meta.h>
 #include <net/dst.h>
 #include <net/route.h>
@@ -170,6 +171,21 @@ META_COLLECTOR(var_dev)
 }
 
 /**************************************************************************
+ * vlan tag
+ **************************************************************************/
+
+META_COLLECTOR(int_vlan_tag)
+{
+	unsigned short tag;
+	if (vlan_get_tag(skb, &tag) < 0)
+		*err = -1;
+	else
+		dst->value = tag;
+}
+
+
+
+/**************************************************************************
  * skb attributes
  **************************************************************************/
 
@@ -520,6 +536,7 @@ static struct meta_ops __meta_ops[TCF_META_TYPE_MAX+1][TCF_META_ID_MAX+1] = {
 		[META_ID(SK_SNDTIMEO)]		= META_FUNC(int_sk_sndtimeo),
 		[META_ID(SK_SENDMSG_OFF)]	= META_FUNC(int_sk_sendmsg_off),
 		[META_ID(SK_WRITE_PENDING)]	= META_FUNC(int_sk_write_pend),
+		[META_ID(VLAN_TAG)]		= META_FUNC(int_vlan_tag),
 	}
 };
 
-- 
1.5.3.8

