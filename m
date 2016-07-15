From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: bridge: rearrange flood vs
 unicast receive paths
Date: Fri, 15 Jul 2016 10:35:16 -0700
Message-ID: <CAM_iQpXXoprcz48c-AYgOridkQWSv+5+7v4V5pT1rUu4_FoXMQ@mail.gmail.com>
References: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
	<1468465802-4571-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1468465802-4571-3-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2016 at 8:10 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> This patch removes one conditional from the unicast path by using the fact
> that skb is NULL only when the packet is multicast or is local.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/bridge/br_input.c | 29 ++++++++++++++---------------
>  1 file changed, 14 insertions(+), 15 deletions(-)
>
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 0b6d32619468..c20c5be6fc22 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -134,10 +134,10 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>         struct net_bridge_port *p = br_port_get_rcu(skb->dev);
>         const unsigned char *dest = eth_hdr(skb)->h_dest;
>         struct net_bridge_fdb_entry *dst = NULL;
> +       bool mcast_hit = false, unicast = true;
>         struct net_bridge_mdb_entry *mdst;
>         struct net_bridge *br;
>         struct sk_buff *skb2;
> -       bool unicast = true;
>         u16 vid = 0;
>
>         if (!p || p->state == BR_STATE_DISABLED)
> @@ -177,30 +177,29 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>                 if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
>                     br_multicast_querier_exists(br, eth_hdr(skb))) {
>                         if ((mdst && mdst->mglist) ||
> -                           br_multicast_is_router(br))
> +                           br_multicast_is_router(br)) {
>                                 skb2 = skb;
> -                       br_multicast_forward(mdst, skb, skb2);
> -                       skb = NULL;
> -                       if (!skb2)
> -                               goto out;
> +                               br->dev->stats.multicast++;
> +                       }
> +                       mcast_hit = true;
>                 } else {
>                         skb2 = skb;
> +                       br->dev->stats.multicast++;
>                 }
>                 unicast = false;
> -               br->dev->stats.multicast++;


Looks like you change the unconditional increment of this counter,
is this intended?
