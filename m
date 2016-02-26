From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: lock ppp->flags in ppp_read() and ppp_poll()
Date: Fri, 26 Feb 2016 18:45:34 +0100
Message-ID: <c7c10511f505342837d57e9bb628fb145504f3e6.1456507305.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:56373 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422648AbcBZRpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:45:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ppp_read() and ppp_poll() can be called concurrently with ppp_ioctl().
In this case, ppp_ioctl() might call ppp_ccp_closed(), which may update
ppp->flags while ppp_read() or ppp_poll() is reading it.
The update done by ppp_ccp_closed() isn't atomic due to the bit mask
operation ('ppp->flags &= ~(SC_CCP_OPEN | SC_CCP_UP)'), so concurrent
readers might get transient values.
Reading incorrect ppp->flags may disturb the 'ppp->flags & SC_LOOP_TRAFFIC'
test in ppp_read() and ppp_poll(), which in turn can lead to improper
decision on whether the PPP unit file is ready for reading or not.

Since ppp_ccp_closed() is protected by the Rx and Tx locks (with
ppp_lock()), taking the Rx lock is enough for ppp_read() and ppp_poll()
to guarantee that ppp_ccp_closed() won't update ppp->flags
concurrently.

The same reasoning applies to ppp->n_channels. The 'n_channels' field
can also be written to concurrently by ppp_ioctl() (through
ppp_connect_channel() or ppp_disconnect_channel()). These writes aren't
atomic (simple increment/decrement), but are protected by both the Rx
and Tx locks (like in the ppp->flags case). So holding the Rx lock
before reading ppp->n_channels also prevents concurrent writes.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---

This was patch #2 of the 'ppp: fix locking issues related to ppp_ioctl()'
series. I haven't kept the extra locking of ppp->flags in
ppp_ioctl(PPPIOCGFLAGS), which was added in the original series,
because the ppp_mutex lock ensures we can't enter the PPPIOCSFLAGS case
concurrently.
This is still quite theoretical issue as I've never observed the error
in practice.

 drivers/net/ppp/ppp_generic.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index fc8ad00..e8a5936 100644
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
-- 
2.7.0
