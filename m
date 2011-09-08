From: Patrick McHardy <kaber@trash.net>
Subject: [RFC PATCH 12/11] netlink: improve flow control and speed up dumps
 with memory mapped I/O
Date: Thu, 08 Sep 2011 18:36:41 +0200
Message-ID: <4E68EF19.8070305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080602030607010109080807"
Cc: NetDev <netdev@vger.kernel.org>
To: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080602030607010109080807
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch on top of the memory mapped netlink I/O series is
meant to speed up dumps by dumping messages more aggressively.

Messages are dumped until half the ring is used, this is similar
to flow-control used with regular I/O with the difference that
all messages are constructed during a single poll call instead
of multiple recvmsg() calls.

The result is not as good as I expected, dumping 196611
routes using rtnl-route-dump from libmnl show the following
results (averaged over 10 runs):

user-time: -7.9%
system-time: -10.4%
real-time: +0.09%
CPU: -7.45%

Strangely the real time stays almost the same and CPU usage
decreases by a few percent - I would have expected a reduction
of real-time with identical CPU usage (99%). Not sure what
the reason is, will try to investigate further.


--------------080602030607010109080807
Content-Type: text/plain;
 name="nldump.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nldump.diff"

commit 1eadec60573240c2b6ee3ce942471b3e0656e4dc
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Sep 8 16:26:27 2011 +0200

    netlink: improve flow control and speed up dumps with memory mapped I/O
    
    Improve dump flow control with memory mapped I/O: dumps are only continued
    if at least half the ring is free, similar to regular I/O. This minimizes
    the risk of receiving socket errors when the socket is also used for receiving
    regular unicast messages.
    
    Additionally speed up dumps by dumping multiple messages at once until
    the dump is either complete or less than half the ring is free.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2f4745d..fadf216 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -530,6 +530,24 @@ static void netlink_forward_ring(struct netlink_ring *ring)
 	} while (ring->head != head);
 }
 
+static bool netlink_dump_space(struct netlink_sock *nlk)
+{
+	struct netlink_ring *ring = &nlk->rx_ring;
+	struct nl_mmap_hdr *hdr;
+	unsigned int n;
+
+	hdr = netlink_current_frame(ring, NL_MMAP_STATUS_UNUSED);
+	if (hdr == NULL)
+		return false;
+
+	n = ring->head + ring->frame_max / 2;
+	if (n > ring->frame_max)
+		n -= ring->frame_max;
+	hdr = __netlink_lookup_frame(ring, n);
+
+	return hdr->nm_status == NL_MMAP_STATUS_UNUSED;
+}
+
 static unsigned int netlink_poll(struct file *file, struct socket *sock,
 				 poll_table *wait)
 {
@@ -543,11 +561,12 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 		 * is performed here under the assumption that the entire ring
 		 * has been processed before invoking poll().
 		 */
-		if (nlk->cb != NULL) {
+		while (nlk->cb != NULL && netlink_dump_space(nlk)) {
 			err = netlink_dump(sk);
 			if (err < 0) {
 				sk->sk_err = err;
 				sk->sk_error_report(sk);
+				break;
 			}
 		}
 		netlink_rcv_wake(sk);

--------------080602030607010109080807--
