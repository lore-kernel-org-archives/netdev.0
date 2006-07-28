From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 tcpAttemptFails counter error
Date: Fri, 28 Jul 2006 07:40:37 -0400
Message-ID: <1154086839.3395.16.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:52104 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751368AbWG1LTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 07:19:55 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have changed my patch with your advice and it looks more effective.

On Monday 24 July 2006 17:22, David Miller wrote:
> From: Wei Yongjun <yjwei@nanjing-fnst.com>
> Date: Wed, 05 Jul 2006 05:19:54 -0400
>
> > In my test, those direct state transition can not be counted to
> > tcpAttemptFails. Following is my patch:
> >
> > Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>
>
> This change can be implemented more simply, I believe.
>
> Except for the tcp_minisocks.c change, all the paths
> changed go to tcp_done() which is what actually transfers
> the state to TCP_CLOSE.  Therefore, tcp_done() can
> simply be modified to check if the current state is
> TCP_SYN_RECV, and is so bump the counter.
>
> Once you implement it this way, please audit all call paths
> to make sure we don't now bump this counter twice.

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- a/include/net/tcp.h	2006-07-28 16:19:14.492052104 -0400
+++ b/include/net/tcp.h	2006-07-28 16:22:03.414372008 -0400
@@ -904,6 +904,9 @@ static inline void tcp_set_state(struct 
 
 static inline void tcp_done(struct sock *sk)
 {
+	if(sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
+		TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
+
 	tcp_set_state(sk, TCP_CLOSE);
 	tcp_clear_xmit_timers(sk);
 
--- a/net/ipv4/tcp_ipv4.c	2006-07-28 16:23:21.677474208 -0400
+++ b/net/ipv4/tcp_ipv4.c	2006-07-28 16:23:48.854342696 -0400
@@ -437,7 +437,6 @@ void tcp_v4_err(struct sk_buff *skb, u32
 			       It can f.e. if SYNs crossed.
 			     */
 		if (!sock_owned_by_user(sk)) {
-			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 			sk->sk_err = err;
 
 			sk->sk_error_report(sk);
@@ -855,7 +854,6 @@ int tcp_v4_conn_request(struct sock *sk,
 drop_and_free:
 	reqsk_free(req);
 drop:
-	TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 	return 0;
 }
 
--- a/net/ipv4/tcp_minisocks.c	2006-07-28 16:23:55.862277328 -0400
+++ b/net/ipv4/tcp_minisocks.c	2006-07-28 16:25:18.263750400 -0400
@@ -592,8 +592,10 @@ struct sock *tcp_check_req(struct sock *
 		/* RFC793: "second check the RST bit" and
 		 *	   "fourth, check the SYN bit"
 		 */
-		if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN))
+		if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN)) {
+			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 			goto embryonic_reset;
+		}
 
 		/* ACK sequence verified above, just make sure ACK is
 		 * set.  If ACK not set, just silently drop the packet.
--- a/net/ipv6/tcp_ipv6.c	2006-07-28 16:25:36.651954968 -0400
+++ b/net/ipv6/tcp_ipv6.c	2006-07-28 16:26:00.808282648 -0400
@@ -429,7 +429,6 @@ static void tcp_v6_err(struct sk_buff *s
 	case TCP_SYN_RECV:  /* Cannot happen.
 			       It can, it SYNs are crossed. --ANK */ 
 		if (!sock_owned_by_user(sk)) {
-			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 			sk->sk_err = err;
 			sk->sk_error_report(sk);		/* Wake people up to see the error (see connect in sock.c) */
 
@@ -815,7 +814,6 @@ drop:
 	if (req)
 		reqsk_free(req);
 
-	TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 	return 0; /* don't send reset */
 }
 


