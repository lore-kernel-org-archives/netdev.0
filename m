From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.6] reference count cleanup continued -IPv6
Date: Wed, 31 Mar 2004 07:33:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406AE4AC.6020309@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Continuing the reference count clean up, this time
in tcp_v6_rcv().  We should not be doing a sock_put()
on a socket in TIMEWAIT state.

Applies to 2.6.4. Should apply to current bits as
well.

thanks,
Nivedita

diff -urN linux-2.6.4/net/ipv6/tcp_ipv6.c linux-2.6.4mc6/net/ipv6/tcp_ipv6.c
--- linux-2.6.4/net/ipv6/tcp_ipv6.c	2004-03-10 18:55:28.000000000 -0800
+++ linux-2.6.4mc6/net/ipv6/tcp_ipv6.c	2004-03-30 10:34:25.000000000 -0800
@@ -1639,7 +1639,7 @@

   no_tcp_socket:
   	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-		goto discard_and_relse;
+		goto discard_it;

   	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
   bad_packet:
@@ -1662,12 +1662,14 @@
   	goto discard_it;

   do_time_wait:
-	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-		goto discard_and_relse;
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+		tcp_tw_put((struct tcp_tw_bucket *) sk);
+		goto discard_it;
+	}

   	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
   		TCP_INC_STATS_BH(TcpInErrs);
-		sock_put(sk);
+		tcp_tw_put((struct tcp_tw_bucket *) sk);	
   		goto discard_it;
   	}
