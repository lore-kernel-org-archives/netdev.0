From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.4] sock_put() on a TIMEWAIT socket
Date: Sun, 28 Mar 2004 18:03:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406783DA.3090900@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Caught an instance of sock_put() being used instead of
tcp_tw_put().

If the refcnt goes to 0, tcp_tw_put() will release a
tcp_tw_bucket back into the tcp timewait cache, whereas
the sock_put() decrement will release a sock struct back
into the sk cache.  Not sure how the slab caches handle
this, but tw is a smaller structure and the next caller
who gets this tw pointer thinking it's a sock could
potentially write past memory that it should (?).

Patch applies to 2.4.25.

thanks,
Nivedita


diff -urN linux-2.4.25/net/ipv4/tcp_ipv4.c linux-2.4.25mc/net/ipv4/tcp_ipv4.c
--- linux-2.4.25/net/ipv4/tcp_ipv4.c	2003-11-28 10:26:21.000000000 -0800
+++ linux-2.4.25mc/net/ipv4/tcp_ipv4.c	2004-03-28 16:35:01.000000000 -0800
@@ -1804,7 +1804,8 @@
  do_time_wait:
  	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
  		TCP_INC_STATS_BH(TcpInErrs);
-		goto discard_and_relse;
+		tcp_tw_put((struct tcp_tw_bucket *) sk);
+		goto discard_it;
  	}
  	switch(tcp_timewait_state_process((struct tcp_tw_bucket *)sk,
  					  skb, th, skb->len)) {
