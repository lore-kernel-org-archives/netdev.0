From: Thomas Graf <tgraf@suug.ch>
Subject: [ESP]: Ensure IV is in linear part of the skb to avoid BUG() due to OOB access
Date: Thu, 27 Mar 2008 23:58:42 +0100
Message-ID: <20080327225842.GX20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42338 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748AbYC0W6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 18:58:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ESP does not account for the IV size when calling pskb_may_pull() to
ensure everything it accesses directly is within the linear part of a
potential fragment. This results in a BUG() being triggered when the
both the IPv4 and IPv6 ESP stack is fed with an skb where the first
fragment ends between the end of the esp header and the end of the IV.

This bug was found by Dirk Nehring <dnehring@gmx.net> .

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv4/esp4.c
===================================================================
--- net-2.6.orig/net/ipv4/esp4.c	2008-03-27 23:47:48.000000000 +0100
+++ net-2.6/net/ipv4/esp4.c	2008-03-27 23:47:58.000000000 +0100
@@ -336,7 +336,7 @@
 	struct scatterlist *asg;
 	int err = -EINVAL;
 
-	if (!pskb_may_pull(skb, sizeof(*esph)))
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead)))
 		goto out;
 
 	if (elen <= 0)
Index: net-2.6/net/ipv6/esp6.c
===================================================================
--- net-2.6.orig/net/ipv6/esp6.c	2008-03-27 23:47:48.000000000 +0100
+++ net-2.6/net/ipv6/esp6.c	2008-03-27 23:47:58.000000000 +0100
@@ -282,7 +282,7 @@
 	struct scatterlist *sg;
 	struct scatterlist *asg;
 
-	if (!pskb_may_pull(skb, sizeof(*esph))) {
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead))) {
 		ret = -EINVAL;
 		goto out;
 	}
