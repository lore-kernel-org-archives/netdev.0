From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] NFC: nci: hci: Fix releasing uninitialized skbs
Date: Sun, 31 May 2015 17:44:45 -0700
Message-ID: <1433119485.2984.36.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Several of these goto exit; uses should be direct returns
as skb is not yet initialized by nci_hci_get_param().

Miscellanea:

o Use !memcmp instead of memcmp() == 0
o Remove unnecessary goto from if () {... goto exit;} else {...} exit:

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/nfc/nci/hci.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index ed54ec5..af002df 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -639,22 +639,19 @@ int nci_hci_dev_session_init(struct nci_dev *ndev)
 				 ndev->hci_dev->init_data.gates[0].gate,
 				 ndev->hci_dev->init_data.gates[0].pipe);
 	if (r < 0)
-		goto exit;
+		return r;
 
 	r = nci_hci_get_param(ndev, NCI_HCI_ADMIN_GATE,
 			      NCI_HCI_ADMIN_PARAM_SESSION_IDENTITY, &skb);
 	if (r < 0)
-		goto exit;
+		return r;
 
 	if (skb->len &&
 	    skb->len == strlen(ndev->hci_dev->init_data.session_id) &&
-	    memcmp(ndev->hci_dev->init_data.session_id,
-		   skb->data, skb->len) == 0 &&
+	    !memcmp(ndev->hci_dev->init_data.session_id, skb->data, skb->len) &&
 	    ndev->ops->hci_load_session) {
 		/* Restore gate<->pipe table from some proprietary location. */
 		r = ndev->ops->hci_load_session(ndev);
-		if (r < 0)
-			goto exit;
 	} else {
 		r = nci_hci_dev_connect_gates(ndev,
 					      ndev->hci_dev->init_data.gate_count,
@@ -667,8 +664,6 @@ int nci_hci_dev_session_init(struct nci_dev *ndev)
 				      ndev->hci_dev->init_data.session_id,
 				      strlen(ndev->hci_dev->init_data.session_id));
 	}
-	if (r == 0)
-		goto exit;
 
 exit:
 	kfree_skb(skb);


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
