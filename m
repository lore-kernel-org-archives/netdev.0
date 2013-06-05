From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] xen-netback: don't de-reference vif pointer after
 having called xenvif_put()
Date: Wed, 05 Jun 2013 15:03:11 +0100
Message-ID: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__PartDCEC2F0F.3__="
Cc: "xen-devel" <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
To: "Ian Campbell" <ian.campbell@citrix.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:37384 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833Ab3FEODQ (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Wed, 5 Jun 2013 10:03:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__PartDCEC2F0F.3__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

When putting vif-s on the rx notify list, calling xenvif_put() must be
deferred until after the removal from the list and the issuing of the
notification, as both operations dereference the pointer.

Changing this got me to notice that the "irq" variable was effectively
unused (and was of too narrow type anyway).

Signed-off-by: Jan Beulich <jbeulich@suse.com>

---
 drivers/net/xen-netback/netback.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

--- 3.10-rc4/drivers/net/xen-netback/netback.c
+++ 3.10-rc4-xen-netback-vif-use-after-free/drivers/net/xen-netback/netback=
.c
@@ -662,7 +662,7 @@ static void xen_netbk_rx_action(struct x
 {
 	struct xenvif *vif =3D NULL, *tmp;
 	s8 status;
-	u16 irq, flags;
+	u16 flags;
 	struct xen_netif_rx_response *resp;
 	struct sk_buff_head rxq;
 	struct sk_buff *skb;
@@ -771,13 +771,13 @@ static void xen_netbk_rx_action(struct x
 					 sco->meta_slots_used);
=20
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
-		irq =3D vif->irq;
-		if (ret && list_empty(&vif->notify_list))
-			list_add_tail(&vif->notify_list, &notify);
=20
 		xenvif_notify_tx_completion(vif);
=20
-		xenvif_put(vif);
+		if (ret && list_empty(&vif->notify_list))
+			list_add_tail(&vif->notify_list, &notify);
+		else
+			xenvif_put(vif);
 		npo.meta_cons +=3D sco->meta_slots_used;
 		dev_kfree_skb(skb);
 	}
@@ -785,6 +785,7 @@ static void xen_netbk_rx_action(struct x
 	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
 		notify_remote_via_irq(vif->irq);
 		list_del_init(&vif->notify_list);
+		xenvif_put(vif);
 	}
=20
 	/* More work to do? */




--=__PartDCEC2F0F.3__=
Content-Type: text/plain; name="linux-3.10-rc4-xen-netback-vif-use-after-free.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="linux-3.10-rc4-xen-netback-vif-use-after-free.patch"

xen-netback: don't de-reference vif pointer after having called xenvif_put(=
)=0A=0AWhen putting vif-s on the rx notify list, calling xenvif_put() must =
be=0Adeferred until after the removal from the list and the issuing of =
the=0Anotification, as both operations dereference the pointer.=0A=0AChangi=
ng this got me to notice that the "irq" variable was effectively=0Aunused =
(and was of too narrow type anyway).=0A=0ASigned-off-by: Jan Beulich =
<jbeulich@suse.com>=0A=0A---=0A drivers/net/xen-netback/netback.c |   11 =
++++++-----=0A 1 file changed, 6 insertions(+), 5 deletions(-)=0A=0A--- =
3.10-rc4/drivers/net/xen-netback/netback.c=0A+++ 3.10-rc4-xen-netback-vif-u=
se-after-free/drivers/net/xen-netback/netback.c=0A@@ -662,7 +662,7 @@ =
static void xen_netbk_rx_action(struct x=0A {=0A 	struct xenvif *vif =
=3D NULL, *tmp;=0A 	s8 status;=0A-	u16 irq, flags;=0A+	u16 =
flags;=0A 	struct xen_netif_rx_response *resp;=0A 	struct sk_buff_head=
 rxq;=0A 	struct sk_buff *skb;=0A@@ -771,13 +771,13 @@ static void =
xen_netbk_rx_action(struct x=0A 					 =
sco->meta_slots_used);=0A =0A 		RING_PUSH_RESPONSES_AND_CHECK_NOTIF=
Y(&vif->rx, ret);=0A-		irq =3D vif->irq;=0A-		if (ret && =
list_empty(&vif->notify_list))=0A-			list_add_tail(&vif-=
>notify_list, &notify);=0A =0A 		xenvif_notify_tx_completion(vif);=
=0A =0A-		xenvif_put(vif);=0A+		if (ret && =
list_empty(&vif->notify_list))=0A+			list_add_tail(&vif-=
>notify_list, &notify);=0A+		else=0A+			=
xenvif_put(vif);=0A 		npo.meta_cons +=3D sco->meta_slots_used;=0A=
 		dev_kfree_skb(skb);=0A 	}=0A@@ -785,6 +785,7 @@ static =
void xen_netbk_rx_action(struct x=0A 	list_for_each_entry_safe(vif, tmp, =
&notify, notify_list) {=0A 		notify_remote_via_irq(vif->irq);=0A=
 		list_del_init(&vif->notify_list);=0A+		xenvif_put(=
vif);=0A 	}=0A =0A 	/* More work to do? */=0A
--=__PartDCEC2F0F.3__=--
