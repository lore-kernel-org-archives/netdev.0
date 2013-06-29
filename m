From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] gre: fix a regression in ioctl
Date: Sat, 29 Jun 2013 10:16:12 +0800
Message-ID: <1372472172.29178.1.camel@cr0>
References: <1372471480-28992-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165Ab3F2CQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 22:16:20 -0400
In-Reply-To: <1372471480-28992-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 10:04 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> When testing GRE tunnel, I got:
> 
>  # ip tunnel show
>  get tunnel gre0 failed: Invalid argument
>  get tunnel gre1 failed: Invalid argument
> 
> This is a regression introduced by commit c54419321455631079c7d
> ("GRE: Refactor GRE tunneling code.") because previously we
> only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
> after that commit, the check is moved for all commands.
> 
> So, just move it back inside SIOCADDTUNNEL and SIOCCHGTUNNEL.
> 
> After this patch I got:
> 
>  # ip tunnel show
>  gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
>  gre1: gre/ip  remote 192.168.122.101  local 192.168.122.45  ttl inherit 
> 
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index c326e86..354d78c 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -314,11 +314,6 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
>  
>  	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
>  		return -EFAULT;
> -	if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
> -	    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
> -	    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING))) {
> -		return -EINVAL;
> -	}
>  	p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
>  	p.o_flags = gre_flags_to_tnl_flags(p.o_flags);

Self-NAK. p.i_flags is converted to tunnel flags, therefore should
probably check TUNNEL_* instead of GRE_*.

I will send v2.
