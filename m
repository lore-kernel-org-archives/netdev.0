From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Known problems with TCP window size on 2.6.7?
Date: Wed, 27 Oct 2004 14:53:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027145356.6c22959e.davem@davemloft.net>
References: <20041027110617.GA28757@vana.vc.cvut.cz>
	<E1CMml4-0001Cm-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vandrove@vc.cvut.cz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CMml4-0001Cm-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 22:18:30 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
> >   are there some known problems with 2.6.7 and TCP window growing up over limits?  
> 
> No.

Actually Herbert, we did have a window 16-bit overflow problem in 2.6.7
which I believe was first fixed in 2.6.8 or so.  It was fixed by this
patch:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/22 14:01:38-07:00 davem@nuts.davemloft.net 
#   [TCP]: Do not overflow 16-bit window field in tcp_select_window().
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/tcp_output.c
#   2004/07/22 14:01:10-07:00 davem@nuts.davemloft.net +8 -0
#   [TCP]: Do not overflow 16-bit window field in tcp_select_window().
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-10-27 14:39:15 -07:00
+++ b/net/ipv4/tcp_output.c	2004-10-27 14:39:15 -07:00
@@ -168,6 +168,14 @@
 	tp->rcv_wnd = new_win;
 	tp->rcv_wup = tp->rcv_nxt;
 
+	/* Make sure we do not exceed the maximum possible
+	 * scaled window.
+	 */
+	if (!tp->rcv_wscale)
+		new_win = min(new_win, MAX_TCP_WINDOW);
+	else
+		new_win = min(new_win, (65535U << tp->rcv_wscale));
+
 	/* RFC1323 scaling applied */
 	new_win >>= tp->rcv_wscale;
 
