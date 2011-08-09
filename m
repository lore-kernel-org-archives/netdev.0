From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH] ipv4: Fix ip_getsockopt for IP_PKTOPTIONS
Date: Tue, 9 Aug 2011 02:24:04 -0600
Message-ID: <20110809082404.GA24845@mail.gmail.com>
References: <1312672850-13676-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, tszocs@ixiacom.com,
	Linux Networking <netdev@vger.kernel.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:40553 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab1HIIYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:24:14 -0400
Received: by pzk37 with SMTP id 37so9724214pzk.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 01:24:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1312672850-13676-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Sun, 07 Aug 2011 02:20:50 +0300
>
> IP_PKTOPTIONS is broken for 32-bit applications running
> in COMPAT mode on 64-bit kernels.
> 
> This happens because msghdr's msg_flags field is always
> set to zero. When running in COMPAT mode this should be
> set to MSG_CMSG_COMPAT instead.
> 
> Signed-off-by: Tiberiu Szocs-Mihai <tszocs@ixiacom.com>
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>  net/ipv4/ip_sockglue.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index ab0c9ef..c77f5a8 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1067,7 +1067,7 @@ EXPORT_SYMBOL(compat_ip_setsockopt);
>   */
>  
>  static int do_ip_getsockopt(struct sock *sk, int level, int optname,
> -			    char __user *optval, int __user *optlen)
> +			    char __user *optval, int __user *optlen, unsigned flags)
>  {
>  	struct inet_sock *inet = inet_sk(sk);
>  	int val;
> @@ -1240,7 +1240,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>  
>  		msg.msg_control = optval;
>  		msg.msg_controllen = len;
> -		msg.msg_flags = 0;
> +		msg.msg_flags = flags;
>  
>  		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
>  			struct in_pktinfo info;
> @@ -1294,7 +1294,7 @@ int ip_getsockopt(struct sock *sk, int level,
>  {
>  	int err;
>  
> -	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
> +	err = do_ip_getsockopt(sk, level, optname, optval, optlen, 0);
>  #ifdef CONFIG_NETFILTER
>  	/* we need to exclude all possible ENOPROTOOPTs except default case */
>  	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&
> @@ -1327,7 +1327,8 @@ int compat_ip_getsockopt(struct sock *sk, int level, int optname,
>  		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
>  			ip_getsockopt);
>  
> -	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
> +	err = do_ip_getsockopt(sk, level, optname, optval, optlen, 
> +		MSG_CMSG_COMPAT);
>  
>  #ifdef CONFIG_NETFILTER
>  	/* we need to exclude all possible ENOPROTOOPTs except default case */
> -- 
> 1.7.2.5

I think the original patch can be simplified. Feedback is greatly
appreciated.

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ab0c9ef..f6eed68 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1240,7 +1240,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 
 		msg.msg_control = optval;
 		msg.msg_controllen = len;
-		msg.msg_flags = 0;
+		msg.msg_flags = MSG_CMSG_COMPAT;
 
 		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
 			struct in_pktinfo info;

-- 
Jean Sacren
