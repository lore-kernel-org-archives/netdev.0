From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 06/10] wimax: document why wimax_msg_*() operations can be used in any state
Date: Wed, 27 May 2009 18:05:11 -0700
Message-ID: <f3aea79091a4fc501235f2e743cc073ebd962934.1243472510.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
 <e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
 <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
 <05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
 <ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
 <74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:59892 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756532AbZE1BFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:48 -0400
In-Reply-To: <74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243472509.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Funcion documentation for wimax_msg_alloc() and wimax_msg_send() needs
to clarify that they can be used in the very early stages of a
wimax_dev lifecycle.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-msg.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index 9ad4d89..d631a17 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -108,6 +108,12 @@
  * Don't use skb_push()/skb_pull()/skb_reserve() on the skb, as
  * wimax_msg_send() depends on skb->data being placed at the
  * beginning of the user message.
+ *
+ * Unlike other WiMAX stack calls, this call can be used way early,
+ * even before wimax_dev_add() is called, as long as the
+ * wimax_dev->net_dev pointer is set to point to a proper
+ * net_dev. This is so that drivers can use it early in case they need
+ * to send stuff around or communicate with user space.
  */
 struct sk_buff *wimax_msg_alloc(struct wimax_dev *wimax_dev,
 				const char *pipe_name,
@@ -115,7 +121,7 @@ struct sk_buff *wimax_msg_alloc(struct wimax_dev *wimax_dev,
 				gfp_t gfp_flags)
 {
 	int result;
-	struct device *dev = wimax_dev->net_dev->dev.parent;
+	struct device *dev = wimax_dev_to_dev(wimax_dev);
 	size_t msg_size;
 	void *genl_msg;
 	struct sk_buff *skb;
@@ -161,7 +167,6 @@ error_genlmsg_put:
 error_new:
 	nlmsg_free(skb);
 	return ERR_PTR(result);
-
 }
 EXPORT_SYMBOL_GPL(wimax_msg_alloc);
 
@@ -256,10 +261,16 @@ EXPORT_SYMBOL_GPL(wimax_msg_len);
  * Don't use skb_push()/skb_pull()/skb_reserve() on the skb, as
  * wimax_msg_send() depends on skb->data being placed at the
  * beginning of the user message.
+ *
+ * Unlike other WiMAX stack calls, this call can be used way early,
+ * even before wimax_dev_add() is called, as long as the
+ * wimax_dev->net_dev pointer is set to point to a proper
+ * net_dev. This is so that drivers can use it early in case they need
+ * to send stuff around or communicate with user space.
  */
 int wimax_msg_send(struct wimax_dev *wimax_dev, struct sk_buff *skb)
 {
-	struct device *dev = wimax_dev->net_dev->dev.parent;
+	struct device *dev = wimax_dev_to_dev(wimax_dev);
 	void *msg = skb->data;
 	size_t size = skb->len;
 	might_sleep();
-- 
1.6.2.3

