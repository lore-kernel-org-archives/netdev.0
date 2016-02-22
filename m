From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/5] ppp: fix unprotected accesses to ppp->flags and
 ppp->n_channels
Date: Mon, 22 Feb 2016 20:47:15 +0100
Message-ID: <e236fb1f9ddb31fcedcfda5c1b4a4389c09be7ab.1456167043.git.g.nault@alphalink.fr>
References: <cover.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53799 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550AbcBVUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:49:24 -0500
Content-Disposition: inline
In-Reply-To: <cover.1456167043.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading ppp->flags has to be done under protection of ppp_recv_lock()
or ppp_xmit_lock() (for Rx and Tx paths respectively). Therefore, both
locks have to be held before writing.

This patch adds missing locking in ppp_read(), ppp_poll() and
ppp_ioctl(). As a side effect, it fixes unprotected access to
ppp->n_channels in ppp_read() and ppp_poll(), which has the same
locking requirements as ppp->flags.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 4d342ae..4af548b 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -443,9 +443,14 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 			 * network traffic (demand mode).
 			 */
 			struct ppp *ppp = PF_TO_PPP(pf);
+
+			ppp_recv_lock(ppp);
 			if (ppp->n_channels == 0 &&
-			    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
+			    (ppp->flags & SC_LOOP_TRAFFIC) == 0) {
+				ppp_recv_unlock(ppp);
 				break;
+			}
+			ppp_recv_unlock(ppp);
 		}
 		ret = -EAGAIN;
 		if (file->f_flags & O_NONBLOCK)
@@ -532,9 +537,12 @@ static unsigned int ppp_poll(struct file *file, poll_table *wait)
 	else if (pf->kind == INTERFACE) {
 		/* see comment in ppp_read */
 		struct ppp *ppp = PF_TO_PPP(pf);
+
+		ppp_recv_lock(ppp);
 		if (ppp->n_channels == 0 &&
 		    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
 			mask |= POLLIN | POLLRDNORM;
+		ppp_recv_unlock(ppp);
 	}
 
 	return mask;
@@ -678,7 +686,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		break;
 
 	case PPPIOCGFLAGS:
+		ppp_lock(ppp);
 		val = ppp->flags | ppp->xstate | ppp->rstate;
+		ppp_unlock(ppp);
+
 		if (put_user(val, p))
 			break;
 		err = 0;
-- 
2.7.0
