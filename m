From: Petr Tesarik <ptesarik@suse.cz>
Subject: [PATCH] Do not use TSO/GSO when there is urgent data
Date: Fri, 21 Nov 2008 13:19:45 +0100
Message-ID: <200811211319.45515.ptesarik@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ilpo =?utf-8?q?J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jan =?utf-8?q?=C5=A0embera?= <jsembera@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39108 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753556AbYKUMSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 07:18:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=12014

Since most (if not all) implementations of TSO and even the in-kernel
software GSO do not update the urgent pointer when splitting a large
segment, it is necessary to turn off TSO/GSO for all outgoing traffic
with the URG pointer set.

Looking at tcp_current_mss (and the preceding comment) I even think
this was the original intention. However, this approach is insufficient,
because TSO/GSO is turned off only for newly created frames, not for
frames which were already pending at the arrival of a message with
MSG_OOB set. These frames were created when TSO/GSO was enabled,
so they may be large, and they will have the urgent pointer set
in tcp_transmit_skb().

With this patch, such large packets will be fragmented again before
going to the transmit routine.

As a side note, at least the following NICs are known to screw up
the urgent pointer in the TCP header when doing TSO:

	Intel 82566MM (PCI ID 8086:1049)
	Intel 82566DC (PCI ID 8086:104b)
	Intel 82541GI (PCI ID 8086:1076)
	Broadcom NetXtreme II BCM5708 (PCI ID 14e4:164c)

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Jan Sembera <jsembera@suse.cz>
CC: Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>

--
 tcp_output.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -722,7 +722,8 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff 
*skb)
 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
-	if (skb->len <= mss_now || !sk_can_gso(sk)) {
+	if (skb->len <= mss_now || !sk_can_gso(sk) ||
+	    tcp_urg_mode(tcp_sk(sk))) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
@@ -1163,7 +1164,9 @@ static int tcp_init_tso_segs(struct sock *sk, struct 
sk_buff *skb,
 {
 	int tso_segs = tcp_skb_pcount(skb);
 
-	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now)) {
+	if (!tso_segs ||
+	    (tso_segs > 1 && (tcp_skb_mss(skb) != mss_now ||
+			      tcp_urg_mode(tcp_sk(sk))))) {
 		tcp_set_skb_tso_segs(sk, skb, mss_now);
 		tso_segs = tcp_skb_pcount(skb);
 	}
