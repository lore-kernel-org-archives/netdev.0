From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 2/5] soreuseport: TCP/IPv4 implementation
Date: Wed, 16 Jan 2013 13:09:10 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301161259370.1764@cleese>
References: <alpine.DEB.2.00.1301141140330.3472@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:43633 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3APVJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:09:26 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so749406dae.21
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 13:09:25 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1301141140330.3472@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 	 * Unlike other sk lookup places we do not check
> @@ -73,8 +75,11 @@ int inet_csk_bind_conflict(const struct sock *sk,
> 		    (!sk->sk_bound_dev_if ||
> 		     !sk2->sk_bound_dev_if ||
> 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
> -			if (!reuse || !sk2->sk_reuse ||
> -			    sk2->sk_state == TCP_LISTEN) {
> +			if ((!reuse || !sk2->sk_reuse ||
> +			    sk2->sk_state == TCP_LISTEN) &&
> +			    (!reuseport || !sk2->sk_reuseport ||
> +			    (sk2->sk_state != TCP_TIME_WAIT &&
> +			     uid != sock_i_uid(sk2)))) {
> 				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
> 				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
> 				    sk2_rcv_saddr == sk_rcv_saddr(sk))


How about introducing some helper functions to make 
inet_csk_bid_conflict() and inet6_csk_bind_conflict() more readable as in 
patch below? We can add another test for reuseport() for soreuseport 
patches.

udp.c already has ipv4_rcv_saddr_equal() but it seems to call 
ipv6_only_sock() and not inet_v6_ipv6only() which is needed in 
inet{6}_csk_bid_conflict().So I added sk_rcv_saddr_equal().

Also the bind_conflict functions can return bool instead of int (not 
implemented in patch below).


If patch idea below is ok, I will send it officially.

Thanks,
Vijay


diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 1832927..c15d2eb 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -22,6 +22,8 @@

  #include <net/inet_sock.h>
  #include <net/request_sock.h>
+#include <net/tcp_states.h>
+#include <net/inet_timewait_sock.h>

  #define INET_CSK_DEBUG 1

@@ -205,6 +207,37 @@ static inline void inet_csk_clear_xmit_timer(struct sock *sk, const int what)
  #endif
  }

+/* The port cannot be reused if the older socket is in LISTEN state or if
+ * either the old or new one does not allow reuse
+ */
+static inline bool sk_reuse_equal(int reuse, const struct sock *sk2)
+{
+	return !reuse || !sk2->sk_reuse || sk2->sk_state == TCP_LISTEN;
+}
+
+/* The port cannot be reused if both sockets are bound to the same device or
+ * if either one is not bound
+ */
+static inline bool sk_bound_dev_equal(const struct sock *sk,
+				      const struct sock *sk2)
+{
+	return !sk->sk_bound_dev_if || !sk2->sk_bound_dev_if ||
+	       sk->sk_bound_dev_if == sk2->sk_bound_dev_if;
+}
+
+/* The port cannot be reused if both sockets have the same rcv_saddr
+ * or if either rcv_saddr is NULL
+ */
+static inline bool sk_rcv_saddr_equal(const struct sock *sk1,
+				      const struct sock *sk2)
+{
+	__be32 sk1_rcv_saddr = sk_rcv_saddr(sk1);
+	__be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
+
+	return !sk2_rcv_saddr || !sk1_rcv_saddr ||
+	       sk2_rcv_saddr == sk1_rcv_saddr;
+}
+
  /*
   *	Reset the retransmission timer
   */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d0670f0..375cca3 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -68,26 +68,15 @@ int inet_csk_bind_conflict(const struct sock *sk,
  	 */

  	sk_for_each_bound(sk2, node, &tb->owners) {
-		if (sk != sk2 &&
-		    !inet_v6_ipv6only(sk2) &&
-		    (!sk->sk_bound_dev_if ||
-		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
-			if (!reuse || !sk2->sk_reuse ||
-			    sk2->sk_state == TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
-				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
-				    sk2_rcv_saddr == sk_rcv_saddr(sk))
-					break;
-			}
-			if (!relax && reuse && sk2->sk_reuse &&
-			    sk2->sk_state != TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
+		if (sk != sk2 && !inet_v6_ipv6only(sk2) &&
+		    sk_bound_dev_equal(sk, sk2)) {
+			if (sk_reuse_equal(reuse, sk2) &&
+			    sk_rcv_saddr_equal(sk, sk2))
+				break;

-				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
-				    sk2_rcv_saddr == sk_rcv_saddr(sk))
-					break;
-			}
+			if (!relax && sk_reuse_equal(reuse, sk2) &&
+			    sk_rcv_saddr_equal(sk, sk2))
+				break;
  		}
  	}
  	return node != NULL;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 3064785..8ebe20d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -39,13 +39,9 @@ int inet6_csk_bind_conflict(const struct sock *sk,
  	 * vs net namespaces issues.
  	 */
  	sk_for_each_bound(sk2, node, &tb->owners) {
-		if (sk != sk2 &&
-		    (!sk->sk_bound_dev_if ||
-		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
-		    (!sk->sk_reuse || !sk2->sk_reuse ||
-		     sk2->sk_state == TCP_LISTEN) &&
-		     ipv6_rcv_saddr_equal(sk, sk2))
+		if (sk != sk2 && sk_bound_dev_equal(sk, sk2) &&
+		    sk_reuse_equal(sk->sk_reuse, sk2) &&
+		    ipv6_rcv_saddr_equal(sk, sk2))
  			break;
  	}
