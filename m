From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Thu, 10 Feb 2005 17:16:12 -0800
Message-ID: <20050210171612.3bd2d8c6.davem@davemloft.net>
References: <0523RGW12@server5.heliogroup.fr>
	<420BE1F8.1080500@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hubert.tonneau@fullpliant.org, shemminger@osdl.org, romieu@fr.zoreil.com,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <420BE1F8.1080500@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2005 14:36:40 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Hubert Tonneau wrote:
> > It does not seem to solve the problem:
> > . Linux 2.6.9 takes 15 seconds to copy 105 MB to the Mac OSX
> > . Linux 2.6.10 with the TCP patch still takes 325 seconds.
> 
> 
> is there a packet trace somewhere?

I know what's wrong, no trace needed, Stephen's patch misses
tcp_push_one() and similar.

He only added the PSH bit setting to tcp_write_xmit().

Hubert, try this patch instead.

===== net/ipv4/tcp_output.c 1.77 vs edited =====
--- 1.77/net/ipv4/tcp_output.c	2005-01-18 12:23:36 -08:00
+++ edited/net/ipv4/tcp_output.c	2005-02-10 16:42:42 -08:00
@@ -408,6 +408,16 @@
 		sk->sk_send_head = skb;
 }
 
+static inline void tcp_tso_set_push(struct sk_buff *skb)
+{
+	/* Force push to be on for any TSO frames to workaround
+	 * problems with busted implementations like Mac OS-X that
+	 * hold off socket reveive wakeups until push is seen.
+	 */
+	if (tcp_skb_pcount(skb) > 1)
+		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
+}
+
 /* Send _single_ skb sitting at the send head. This function requires
  * true push pending frames to setup probe timer etc.
  */
@@ -419,6 +429,7 @@
 	if (tcp_snd_test(tp, skb, cur_mss, TCP_NAGLE_PUSH)) {
 		/* Send it out now. */
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+		tcp_tso_set_push(skb);
 		if (!tcp_transmit_skb(sk, skb_clone(skb, sk->sk_allocation))) {
 			sk->sk_send_head = NULL;
 			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
@@ -755,6 +766,7 @@
 			}
 
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
+			tcp_tso_set_push(skb);
 			if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
 				break;
 
@@ -1096,6 +1108,7 @@
 	 * is still in somebody's hands, else make a clone.
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	tcp_tso_set_push(skb);
 
 	err = tcp_transmit_skb(sk, (skb_cloned(skb) ?
 				    pskb_copy(skb, GFP_ATOMIC):
@@ -1668,6 +1681,7 @@
 
 			TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
+			tcp_tso_set_push(skb);
 			err = tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC));
 			if (!err) {
 				update_send_head(sk, tp, skb);
