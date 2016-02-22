From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 5/5] ppp: protect ppp->npmode
Date: Mon, 22 Feb 2016 20:47:20 +0100
Message-ID: <77c1070fa01bc065e1ead63458999639d18715fb.1456167043.git.g.nault@alphalink.fr>
References: <cover.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53801 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549AbcBVUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:49:24 -0500
Content-Disposition: inline
In-Reply-To: <cover.1456167043.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ppp->npmode is read by ppp_ioctl(), ppp_receive_nonmp_frame() and
ppp_start_xmit(). But it is only modified by ppp_ioctl().
However, the only protected access is done by ppp_receive_nonmp_frame()
which runs under ppp_recv_lock() protection.

We could protect ppp->npmode with ppp_recv_lock() in ppp_start_xmit()
too, but taking the recv lock in the xmit path would look strange. So
this patch takes the xmit lock instead and holds both locks before
writing in ppp_ioctl().

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 24777f4..2eb39cd 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -767,11 +767,18 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		i = err;
 		if (cmd == PPPIOCGNPMODE) {
 			err = -EFAULT;
+
+			ppp_lock(ppp);
 			npi.mode = ppp->npmode[i];
+			ppp_unlock(ppp);
+
 			if (copy_to_user(argp, &npi, sizeof(npi)))
 				break;
 		} else {
+			ppp_lock(ppp);
 			ppp->npmode[i] = npi.mode;
+			ppp_unlock(ppp);
+
 			/* we may be able to transmit more packets now (??) */
 			netif_wake_queue(ppp->dev);
 		}
@@ -1023,13 +1030,18 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ppp *ppp = netdev_priv(dev);
 	int npi, proto;
 	unsigned char *pp;
+	enum NPmode npmode;
 
 	npi = ethertype_to_npindex(ntohs(skb->protocol));
 	if (npi < 0)
 		goto outf;
 
+	ppp_xmit_lock(ppp);
+	npmode = ppp->npmode[npi];
+	ppp_xmit_unlock(ppp);
+
 	/* Drop, accept or reject the packet */
-	switch (ppp->npmode[npi]) {
+	switch (npmode) {
 	case NPMODE_PASS:
 		break;
 	case NPMODE_QUEUE:
-- 
2.7.0
