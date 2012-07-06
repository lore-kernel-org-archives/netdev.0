From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] bridge: netfilter: fix skb->nf_bridge NULL panic
 in br_nf_forward_finish
Date: Fri, 06 Jul 2012 17:06:46 +0200
Message-ID: <1341587206.3265.696.camel@edumazet-glaptop>
References: <1341584394.4789.34.camel@chief-river-32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58694 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab2GFPGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 11:06:51 -0400
Received: by eeit10 with SMTP id t10so3679740eei.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 08:06:50 -0700 (PDT)
In-Reply-To: <1341584394.4789.34.camel@chief-river-32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 22:19 +0800, Lin Ming wrote:
> I can reproduce similiar panic with 3.5-rc5 kernel as Massimo reported at:
> http://marc.info/?l=linux-netdev&m=134089242113979&w=2
> 
> The steps to reproduce as follow,
> 
> 1. On Host1, setup brige br0(192.168.1.106)
> 2. Boot a kvm guest(192.168.1.105) on Host1 and start httpd
> 3. Start IPVS service on Host1
>    ipvsadm -A -t 192.168.1.106:80 -s rr
>    ipvsadm -a -t 192.168.1.106:80 -r 192.168.1.105:80 -m
> 4. Run apache benchmark on Host2(192.168.1.101)
>    ab -n 1000 http://192.168.1.106/
> 
> The panic happened in br_nf_forward_finish because skb->nf_bridge is NULL.
> skb->nf_bridge is set to NULL in ip_vs_reply4 hook.
> 
> br_nf_forward_ip():
>   NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, in), parent,
>                 br_nf_forward_finish);
> 
> This calls IPVS hook ip_vs_reply4.
> 
> ip_vs_reply4
>   ip_vs_out
>     handle_response
>       ip_vs_notrack
>         nf_reset()
>         {
>           skb->nf_bridge = NULL;
>         }
> 
> This patch added skb->nf_bridge check in br_nf_forward_finish and the panic gone.
> But I am really not sure if this is the right fix.
> Please help to review.
> 
> The panic log attached.
...
> Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
> ---
>  net/bridge/br_netfilter.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index e41456b..10da415 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -719,7 +719,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
>  	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
>  	struct net_device *in;
>  
> -	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
> +	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb) && nf_bridge) {
>  		in = nf_bridge->physindev;
>  		if (nf_bridge->mask & BRNF_PKT_TYPE) {
>  			skb->pkt_type = PACKET_OTHERHOST;

So after your patch we have the code in the else clause :

} else {
	in = *((struct net_device **)(skb->cb));
}

But do we really have a "struct net_device" pointer stored in skb->cb[]
at this stage ?

AFAIK this is set only for ARP_FORWARD (br_nf_forward_arp() line 838 :
*d = (struct net_device *)in;),
not in br_nf_forward_ip()

If we have garbage instead, we can have other bugs later...
