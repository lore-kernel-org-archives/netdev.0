From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipt_REJECT: can't work with bridges
Date: Fri, 16 Jul 2010 14:16:32 +0200
Message-ID: <4C404DA0.1000204@trash.net>
References: <1279251163-2887-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279251163-2887-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 16.07.2010 05:32, schrieb Changli Gao:
> ipt_REJECT: can't work with bridges
> 
> ip_route_me_harder can't create the route cache when the outdev is the same with
> the indev for the skbs whichout a valid protocol set.
> 
> __mkroute_input functions has this check:
> 1998         if (skb->protocol != htons(ETH_P_IP)) {
> 1999                 /* Not IP (i.e. ARP). Do not create route, if it is
> 2000                  * invalid for proxy arp. DNAT routes are always valid.
> 2001                  *
> 2002                  * Proxy arp feature have been extended to allow, ARP
> 2003                  * replies back to the same interface, to support
> 2004                  * Private VLAN switch technologies. See arp.c.
> 2005                  */
> 2006                 if (out_dev == in_dev &&
> 2007                     IN_DEV_PROXY_ARP_PVLAN(in_dev) == 0) {
> 2008                         err = -EINVAL;
> 2009                         goto cleanup;
> 2010                 }
> 2011         }
> 
> This patch gives the new skb a valid protocol to bypass this check. In order to
> make ipt_REJECT work with bridges, you also need to enable ip_forward.

This actually also fixes a regression, back when we used skb_copy_expand
of the old skb, the protocol was properly set, which not only affects
bridges, but also TC classification and packet sockets.

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/ipv4/netfilter/ipt_REJECT.c |    1 +
>  1 file changed, 1 insertion(+)
> diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
> index bbbd273..e0bca39 100644
> --- a/net/ipv4/netfilter/ipt_REJECT.c
> +++ b/net/ipv4/netfilter/ipt_REJECT.c
> @@ -111,6 +111,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
>  	/* ip_route_me_harder expects skb->dst to be set */
>  	skb_dst_set_noref(nskb, skb_dst(oldskb));
>  
> +	nskb->protocol = __constant_htons(ETH_P_IP);

You don't need __constant_htons here however, the compiler is smart
enough to this itself. Please resend and add a note to the changelog
stating that this fixes a regression and I'll toss it into
nf-2.6.git.

Thanks!

>  	if (ip_route_me_harder(nskb, addr_type))
>  		goto free_nskb;
>  
> 

