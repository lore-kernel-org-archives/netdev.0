From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: [PATCH?] Fix sniffing of ARP replies
Date: Wed, 15 Oct 2003 19:11:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015171112.GA2469@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,
  after recent changes in packet_type interface I stopped setting
af_packet_priv - as you told that it is only for AF_PACKET, for nobody
else. And - things stopped working.

  After some debugging I found that there are skb's with ->sk == NULL -
namely ARP replies - and if af_packet_priv == NULL, these skbs are not
delivered to the registered ptype.

  Is change below correct, or should I simple set af_packet_priv to
non-NULL value, like I did before (and like I have to do it again for
older kernels, in the light of problems I'm seeing now)?
					Thanks,
						Petr Vandrovec


diff -urdN linux/net/core/dev.c linux/net/core/dev.c
--- linux/net/core/dev.c	2003-10-15 14:05:23.000000000 +0000
+++ linux/net/core/dev.c	2003-10-15 16:52:41.000000000 +0000
@@ -942,7 +942,8 @@
 		 * they originated from - MvS (miquels@drinkel.ow.org)
 		 */
 		if ((ptype->dev == dev || !ptype->dev) &&
-		    (struct sock *)ptype->af_packet_priv != skb->sk) {
+		    (ptype->af_packet_priv == NULL ||
+		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
 			struct sk_buff *skb2= skb_clone(skb, GFP_ATOMIC);
 			if (!skb2)
 				break;
