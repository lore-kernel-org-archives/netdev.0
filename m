From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.6] sock_put() on a TIMEWAIT socket
Date: Sun, 28 Mar 2004 18:04:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40678444.3070402@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Instances of sock_put() being used instead of tcp_tw_put().
This is for the 2.6 tree.

Patch applies to 2.6.4, but should apply cleanly
to later versions as well.

thanks,
Nivedita


diff -urN linux-2.6.4/net/ipv4/tcp_ipv4.c linux-2.6.4mc/net/ipv4/tcp_ipv4.c
--- linux-2.6.4/net/ipv4/tcp_ipv4.c	2004-03-10 18:55:25.000000000 -0800
+++ linux-2.6.4mc/net/ipv4/tcp_ipv4.c	2004-03-28 17:26:52.000000000 -0800
@@ -1825,12 +1825,15 @@
  	goto discard_it;

  do_time_wait:
-	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
-		goto discard_and_relse;
+	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+		tcp_tw_put((struct tcp_tw_bucket *) sk);
+		goto discard_it;
+	}

  	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
  		TCP_INC_STATS_BH(TcpInErrs);
-		goto discard_and_relse;
+		tcp_tw_put((struct tcp_tw_bucket *) sk);
+		goto discard_it;
  	}
  	switch (tcp_timewait_state_process((struct tcp_tw_bucket *)sk,
  					   skb, th, skb->len)) {
