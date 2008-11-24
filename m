From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: [PATCH] [ROSE] zero length frame filtering in af_rose.c
Date: Mon, 24 Nov 2008 22:49:40 +0100
Message-ID: <492B2174.1030503@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:38347 "EHLO smtp2-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbYKXWnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 17:43:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since changeset e79ad711a0108475c1b3a03815527e7237020b08 from  mainline,
>From David S. Miller, 
empty packet can be transmitted on connected socket for datagram protocols.

However, this patch broke a high level application using ROSE network protocol with connected datagram.

Bulletin Board Stations perform bulletins forwarding between BBS stations via ROSE network using a forward protocol.
Now, if for some reason, a buffer in the application software happens to be empty at a specific moment,
ROSE sends an empty packet via unfiltered packet socket.
When received, this ROSE packet introduces perturbations of data exchange of BBS forwarding,
for the application message forwarding protocol is waiting for something else.
We agree that a more careful programming of the application protocol would avoid this situation and we are
willing to debug it.
But, as an empty frame is no use and does not have any meaning for ROSE protocol,
we may consider filtering zero length data both when sending and receiving socket data.

The proposed patch repaired BBS data exchange through ROSE network that were broken since 2.6.22.11 kernel.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 net/rose/af_rose.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8a54cff..92af3a6 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1075,6 +1075,10 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 	unsigned char *asmptr;
 	int n, size, qbit = 0;
 
+	/* ROSE empty frame has no meaning : don't send */
+	if (len == 0)
+		return 0;
+
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
 
@@ -1268,6 +1272,12 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reset_transport_header(skb);
 	copied     = skb->len;
 
+	/* ROSE empty frame has no meaning : ignore it */
+	if (copied == 0) {
+		skb_free_datagram(sk, skb);
+		return copied;
+	}
+
 	if (copied > size) {
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
-- 
1.5.5

