From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 06/12] ip_tunnel: push generic protocol
 handling to ip_tunnel module.
Date: Fri, 14 Jun 2013 17:20:53 -0700
Message-ID: <CAEP_g=_yK4omX-VBd+q9fRai+az0Bzgi8uh7rPmAnzJ1pzsxuw@mail.gmail.com>
References: <1371147884-9323-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:41095 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752857Ab3FOAVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 20:21:14 -0400
Received: by mail-ie0-f174.google.com with SMTP id 9so2742616iec.19
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 17:21:14 -0700 (PDT)
In-Reply-To: <1371147884-9323-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:24 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
>  static int gre_cisco_rcv(struct sk_buff *skb)
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index b7b8d15..c41faf8 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -442,23 +435,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>                 tunnel->i_seqno = ntohl(tpi->seq) + 1;
>         }
>
> -       /* Warning: All skb pointers will be invalidated! */
> -       if (tunnel->dev->type == ARPHRD_ETHER) {
> -               if (!pskb_may_pull(skb, ETH_HLEN)) {
> -                       tunnel->dev->stats.rx_length_errors++;
> -                       tunnel->dev->stats.rx_errors++;
> -                       goto drop;
> -               }
> -
> -               iph = ip_hdr(skb);
> -               skb->protocol = eth_type_trans(skb, tunnel->dev);
> -               skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
> -       }
> -
> -       skb->pkt_type = PACKET_HOST;
> -       __skb_tunnel_rx(skb, tunnel->dev);
> -
> -       skb_reset_network_header(skb);
>         err = IP_ECN_decapsulate(iph, skb);
>         if (unlikely(err)) {
>                 if (log_ecn_error)
> @@ -477,6 +453,12 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>         tstats->rx_bytes += skb->len;
>         u64_stats_update_end(&tstats->syncp);
>
> +       if (tunnel->dev->type == ARPHRD_ETHER) {
> +               skb->protocol = eth_type_trans(skb, tunnel->dev);
> +               skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
> +       } else {
> +               skb->dev = tunnel->dev;
> +       }

Why don't we set the tunnel device in the case of an L2 packet? This
appears related to the removal of __skb_tunnel_rx() but it seems there
is now less consistency between L2 and L3 tunnels.
