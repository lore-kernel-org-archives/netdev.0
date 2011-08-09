From: Tiberiu Szocs-Mihai <tszocs@ixiacom.com>
Subject: Re: [PATCH] ipv4: Fix ip_getsockopt for IP_PKTOPTIONS
Date: Tue, 9 Aug 2011 11:41:09 +0300
Message-ID: <201108091141.10106.tszocs@ixiacom.com>
References: <1312672850-13676-1-git-send-email-dbaluta@ixiacom.com> <20110809082404.GA24845@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Baluta <dbaluta@ixiacom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Networking <netdev@vger.kernel.org>
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixqw-mail-out.ixiacom.com ([66.77.12.12]:22227 "EHLO
	ixqw-mail-out.ixiacom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab1HIIqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:46:23 -0400
In-Reply-To: <20110809082404.GA24845@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jean,

That was my first variant of the patch, but that way the code does more than 
it's suppose to do: the call of do_ip_getsockopt becomes unaware of the 
context from which it is called (ip_getsockopt or compat_ip_getsockopt). We 
should act in a compat manner only when called from compat_ip_getsockopt.

The issue that needed a fix was that in compat mode the flag was set to 0 thus 
silently disabling the call of put_cmsg_compat (see net/core/scm.c).

Thanks for the review,
Tiberiu


On Tuesday, August 09, 2011 11:24:04 am Jean Sacren wrote:
> From: Daniel Baluta <dbaluta@ixiacom.com>
> Date: Sun, 07 Aug 2011 02:20:50 +0300
> 
> > IP_PKTOPTIONS is broken for 32-bit applications running
> > in COMPAT mode on 64-bit kernels.
> > 
> > This happens because msghdr's msg_flags field is always
> > set to zero. When running in COMPAT mode this should be
> > set to MSG_CMSG_COMPAT instead.
> > 
> > Signed-off-by: Tiberiu Szocs-Mihai <tszocs@ixiacom.com>
> > Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> > ---
> > 
> >  net/ipv4/ip_sockglue.c |    9 +++++----
> >  1 files changed, 5 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> > index ab0c9ef..c77f5a8 100644
> > --- a/net/ipv4/ip_sockglue.c
> > +++ b/net/ipv4/ip_sockglue.c
> > @@ -1067,7 +1067,7 @@ EXPORT_SYMBOL(compat_ip_setsockopt);
> > 
> >   */
> >  
> >  static int do_ip_getsockopt(struct sock *sk, int level, int optname,
> > 
> > -			    char __user *optval, int __user *optlen)
> > +			    char __user *optval, int __user *optlen, unsigned flags)
> > 
> >  {
> >  
> >  	struct inet_sock *inet = inet_sk(sk);
> >  	int val;
> > 
> > @@ -1240,7 +1240,7 @@ static int do_ip_getsockopt(struct sock *sk, int
> > level, int optname,
> > 
> >  		msg.msg_control = optval;
> >  		msg.msg_controllen = len;
> > 
> > -		msg.msg_flags = 0;
> > +		msg.msg_flags = flags;
> > 
> >  		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
> >  		
> >  			struct in_pktinfo info;
> > 
> > @@ -1294,7 +1294,7 @@ int ip_getsockopt(struct sock *sk, int level,
> > 
> >  {
> >  
> >  	int err;
> > 
> > -	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
> > +	err = do_ip_getsockopt(sk, level, optname, optval, optlen, 0);
> > 
> >  #ifdef CONFIG_NETFILTER
> >  
> >  	/* we need to exclude all possible ENOPROTOOPTs except default case 
*/
> >  	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&
> > 
> > @@ -1327,7 +1327,8 @@ int compat_ip_getsockopt(struct sock *sk, int
> > level, int optname,
> > 
> >  		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
> >  		
> >  			ip_getsockopt);
> > 
> > -	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
> > +	err = do_ip_getsockopt(sk, level, optname, optval, optlen,
> > +		MSG_CMSG_COMPAT);
> > 
> >  #ifdef CONFIG_NETFILTER
> >  
> >  	/* we need to exclude all possible ENOPROTOOPTs except default case 
*/
> 
> I think the original patch can be simplified. Feedback is greatly
> appreciated.
> 
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index ab0c9ef..f6eed68 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1240,7 +1240,7 @@ static int do_ip_getsockopt(struct sock *sk, int
> level, int optname,
> 
>  		msg.msg_control = optval;
>  		msg.msg_controllen = len;
> -		msg.msg_flags = 0;
> +		msg.msg_flags = MSG_CMSG_COMPAT;
> 
>  		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
>  			struct in_pktinfo info;
