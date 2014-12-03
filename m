From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2] ipv6: remove useless spin_lock/spin_unlock
Date: Tue, 02 Dec 2014 21:18:46 -0800
Message-ID: <1417583926.2902.10.camel@perches.com>
References: <547E6832.4070403@cn.fujitsu.com>
	 <547E7594.7010301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0142.hostedemail.com ([216.40.44.142]:54949 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751270AbaLCFSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 00:18:49 -0500
In-Reply-To: <547E7594.7010301@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-03 at 10:29 +0800, Duan Jiong wrote:
> xchg is atomic, so there is no necessary to use spin_lock/spin_unlock
> to protect it. At last, remove the redundant
> opt = xchg(&inet6_sk(sk)->opt, opt); statement.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
> v2: remove the redundant opt = xchg(&inet6_sk(sk)->opt, opt); statement.
> 
>  net/ipv6/ipv6_sockglue.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index e1a9583..66980d8 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -110,12 +110,8 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
>  			icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
>  			icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
>  		}
> -		opt = xchg(&inet6_sk(sk)->opt, opt);
> -	} else {
> -		spin_lock(&sk->sk_dst_lock);
> -		opt = xchg(&inet6_sk(sk)->opt, opt);
> -		spin_unlock(&sk->sk_dst_lock);
>  	}
> +	opt = xchg(&inet6_sk(sk)->opt, opt);
>  	sk_dst_reset(sk);
>  
>  	return opt;

The original function could now be written
integrating the multiple ifs like:
---
 net/ipv6/ipv6_sockglue.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index e1a9583..12c9c6b 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -102,20 +102,19 @@ static
 struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 					   struct ipv6_txoptions *opt)
 {
-	if (inet_sk(sk)->is_icsk) {
-		if (opt &&
-		    !((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
-		    inet_sk(sk)->inet_daddr != LOOPBACK4_IPV6) {
-			struct inet_connection_sock *icsk = inet_csk(sk);
-			icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
-			icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
-		}
-		opt = xchg(&inet6_sk(sk)->opt, opt);
-	} else {
-		spin_lock(&sk->sk_dst_lock);
-		opt = xchg(&inet6_sk(sk)->opt, opt);
-		spin_unlock(&sk->sk_dst_lock);
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (inet->is_icsk &&
+	    opt &&
+	    !((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
+	    inet->inet_daddr != LOOPBACK4_IPV6) {
+		struct inet_connection_sock *icsk = inet_csk(sk);
+
+		icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
+		icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 	}
+
+	opt = xchg(&inet6_sk(sk)->opt, opt);
 	sk_dst_reset(sk);
 
 	return opt;
