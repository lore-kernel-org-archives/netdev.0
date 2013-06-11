From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH, resend] xen-netback: don't de-reference vif pointer
 after having called xenvif_put()
Date: Tue, 11 Jun 2013 11:00:34 +0100
Message-ID: <51B7116202000078000DD069@nat28.tlf.novell.com>
References: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
 <20130611.020136.1037505762134627955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:43541 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab3FKKAf convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 11 Jun 2013 06:00:35 -0400
In-Reply-To: <20130611.020136.1037505762134627955.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When putting vif-s on the rx notify list, calling xenvif_put() must be
deferred until after the removal from the list and the issuing of the
notification, as both operations dereference the pointer.

Changing this got me to notice that the "irq" variable was effectively
unused (and was of too narrow type anyway).

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

---
 drivers/net/xen-netback/netback.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

--- 3.10-rc4/drivers/net/xen-netback/netback.c
+++ 3.10-rc4-xen-netback-vif-use-after-free/drivers/net/xen-netback/netback.c
@@ -662,7 +662,7 @@ static void xen_netbk_rx_action(struct x
 {
 	struct xenvif *vif = NULL, *tmp;
 	s8 status;
-	u16 irq, flags;
+	u16 flags;
 	struct xen_netif_rx_response *resp;
 	struct sk_buff_head rxq;
 	struct sk_buff *skb;
@@ -771,13 +771,13 @@ static void xen_netbk_rx_action(struct x
 					 sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
-		irq = vif->irq;
-		if (ret && list_empty(&vif->notify_list))
-			list_add_tail(&vif->notify_list, &notify);
 
 		xenvif_notify_tx_completion(vif);
 
-		xenvif_put(vif);
+		if (ret && list_empty(&vif->notify_list))
+			list_add_tail(&vif->notify_list, &notify);
+		else
+			xenvif_put(vif);
 		npo.meta_cons += sco->meta_slots_used;
 		dev_kfree_skb(skb);
 	}
@@ -785,6 +785,7 @@ static void xen_netbk_rx_action(struct x
 	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
 		notify_remote_via_irq(vif->irq);
 		list_del_init(&vif->notify_list);
+		xenvif_put(vif);
 	}
 
 	/* More work to do? */
