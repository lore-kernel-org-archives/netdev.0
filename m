From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Fri, 13 Sep 2013 00:06:52 +0800
Message-ID: <CAA7+ByXUnTi1+-yreK+q03Cbqg+FM7DTfQ9qXbyRbZ0N508JBQ@mail.gmail.com>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	<1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hong Zhiguo <zhiguohong@tencent.com>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:46961 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab3ILQGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 12:06:53 -0400
Received: by mail-qc0-f171.google.com with SMTP id x19so3240qcw.16
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 09:06:52 -0700 (PDT)
In-Reply-To: <1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You're right, Vlad.
One thing is missing in Eric's fix, NULL dereference is still possible
in br_handle_local_finish. Above is the new version of fix.

On Thu, Sep 12, 2013 at 11:57 PM, Hong Zhiguo <honkiko@gmail.com> wrote:
> not check IFF_BRIDGE_PORT within br_handle_frame
>
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> ---
>  net/bridge/br_input.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index a2fd37e..da4714a 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -60,7 +60,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
>  int br_handle_frame_finish(struct sk_buff *skb)
>  {
>         const unsigned char *dest = eth_hdr(skb)->h_dest;
> -       struct net_bridge_port *p = br_port_get_rcu(skb->dev);
> +       enet_bridge_port *p = rcu_dereference(skb->dev->rx_handler_data);
>         struct net_bridge *br;
>         struct net_bridge_fdb_entry *dst;
>         struct net_bridge_mdb_entry *mdst;
> @@ -143,7 +143,7 @@ drop:
>  /* note: already called with rcu_read_lock */
>  static int br_handle_local_finish(struct sk_buff *skb)
>  {
> -       struct net_bridge_port *p = br_port_get_rcu(skb->dev);
> +       struct net_bridge_port *p = rcu_dereference(skb->dev->rx_handler_data);
>         u16 vid = 0;
>
>         br_vlan_get_tag(skb, &vid);
> @@ -173,7 +173,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>         if (!skb)
>                 return RX_HANDLER_CONSUMED;
>
> -       p = br_port_get_rcu(skb->dev);
> +       p = rcu_dereference(skb->dev->rx_handler_data);
>
>         if (unlikely(is_link_local_ether_addr(dest))) {
>                 /*
> --
> 1.7.0.4
>



-- 
best regards
Hong Zhiguo
