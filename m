From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9-rc1-mm5: TCP oopses
Date: Mon, 13 Sep 2004 19:08:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913190858.12544431.davem@davemloft.net>
References: <20040913015003.5406abae.akpm@osdl.org>
	<Xine.LNX.4.44.0409132019170.22477-200000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0409132019170.22477-200000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 20:25:38 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> I'm experiencing TCP related oopses with this kernel (not seen in -mm4), 
> .config file attached.
> 
> Here are two backtraces, the first happened a few seconds after logging 
> in via ssh, the second happened soon after boot (using selinux=0, just to 
> make sure).

I think I fixed this one yesterday.  Callers of tcp_fragment()
in tcp_output.c were not accounting packets correctly.  I
believe this is what will fix it, and this is in Linus's
tree already.

I guess you have an e1000 in this box? :)
(either that or some other card whose driver
enables TSO by default)

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/10 15:21:43-07:00 davem@nuts.davemloft.net 
#   [TCP]: Fix packet counting when fragmenting already sent packets.
#   
#   Calls to tcp_fragment() change the tso_factor of
#   an SKB, so we need to deal with that.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/09/10 15:21:13-07:00 davem@nuts.davemloft.net +12 -2
#   [TCP]: Fix packet counting when fragmenting already sent packets.
#   
#   Calls to tcp_fragment() change the tso_factor of
#   an SKB, so we need to deal with that.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-13 18:51:38 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-13 18:51:38 -07:00
@@ -681,8 +681,12 @@
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
 			if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
 				break;
-			/* Advance the send_head.  This one is sent out. */
+
+			/* Advance the send_head.  This one is sent out.
+			 * This call will increment packets_out.
+			 */
 			update_send_head(sk, tp, skb);
+
 			tcp_minshall_update(tp, mss_now, skb);
 			sent_pkts = 1;
 		}
@@ -968,11 +972,17 @@
 		return -EAGAIN;
 
 	if (skb->len > cur_mss) {
+		int old_factor = TCP_SKB_CB(skb)->tso_factor;
+		int new_factor;
+
 		if (tcp_fragment(sk, skb, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
 
 		/* New SKB created, account for it. */
-		tcp_inc_pcount(&tp->packets_out, skb);
+		new_factor = TCP_SKB_CB(skb)->tso_factor;
+		tcp_dec_pcount_explicit(&tp->packets_out,
+					new_factor - old_factor);
+		tcp_inc_pcount(&tp->packets_out, skb->next);
 	}
 
 	/* Collapse two adjacent packets if worthwhile and we can. */
