From: Marc Herbert <marc.herbert@free.fr>
Subject: TcpOutSegs way too optimistic (netstat -s)
Date: Sat, 15 May 2004 00:11:28 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405150007090.8193@fcat>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


TcpOutSegs is currently incremented even when
"tp->af_specific->queue_xmit(skb, 0)" fails (think about a full qdisc
for instance).

See fix below.



===== net/ipv4/tcp_output.c 1.19 vs edited =====
--- 1.19/net/ipv4/tcp_output.c	Fri May 14 22:32:18 2004
+++ edited/net/ipv4/tcp_output.c	Fri May 14 23:19:37 2004
@@ -276,13 +276,7 @@
 		if (skb->len != tcp_header_size)
 			tcp_event_data_sent(tp, skb, sk);

-		TCP_INC_STATS(TcpOutSegs);
-
 		err = tp->af_specific->queue_xmit(skb, 0);
-		if (err <= 0)
-			return err;
-
-		tcp_enter_cwr(tp);

 		/* NET_XMIT_CN is special. It does not guarantee,
 		 * that this packet is lost. It tells that device
@@ -290,7 +284,15 @@
 		 * drops some packets of the same priority and
 		 * invokes us to send less aggressively.
 		 */
-		return err == NET_XMIT_CN ? 0 : err;
+		if(err == NET_XMIT_CN)
+			err = 0;
+		if (!err)
+			TCP_INC_STATS(TcpOutSegs);
+
+		if (err > 0)
+			tcp_enter_cwr(tp);
+
+		return err;
 	}
 	return -ENOBUFS;
 #undef SYSCTL_FLAG_TSTAMPS
