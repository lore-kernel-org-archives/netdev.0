From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Tue, 15 Dec 2015 12:26:46 -0800
Message-ID: <CALx6S36bA_PJLpqPbqM_gnZLUE3v7J9iBndGqj=HQLG8hQ_0_w@mail.gmail.com>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
	<1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35152 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbbLOU0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 15:26:47 -0500
Received: by mail-ig0-f182.google.com with SMTP id to4so39515241igc.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 12:26:46 -0800 (PST)
In-Reply-To: <1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 12:01 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> udp tunnel offloads tend to aggregate datagrams based on inner
> headers. gro engine gets notified by tunnel implementations about
> possible offloads. The match is solely based on the port number.
>
> Imagine a tunnel bound to port 53, the offloading will look into all
> DNS packets and tries to aggregate them based on the inner data found
> within. This could lead to data corruption and malformed DNS packets.
>
> While this patch minimizes the problem and helps an administrator to find
> the issue by querying ip tunnel/fou, a better way would be to match on
> the specific destination ip address so if a user space socket is bound
> to the same address it will conflict.
>
I don't know... seems like this is more likely to add code into the
critical path rather than solve a problem impacting anyone yet. No
other GRO code needs to be namespace aware and none of these fancy HW
offloads for UDP encapsulations are going to care anything about
namespaces.

I think you point out the real underlying problem though, the UDP
offloads are restricted only be done by destination port and nothing
else. A more flexible method would be to allow matching on based
addresses, four tuples, interfaces etc. (latter may be needed to
offload connected UDP).

Tom

> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  drivers/net/geneve.c   |  2 +-
>  drivers/net/vxlan.c    |  2 +-
>  include/net/protocol.h |  2 +-
>  net/ipv4/fou.c         |  2 +-
>  net/ipv4/udp_offload.c | 10 +++++++---
>  5 files changed, 11 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index c2b79f5d1c89b6..b70ce46a5e7040 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -376,7 +376,7 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
>         int err;
>
>         if (sa_family == AF_INET) {
> -               err = udp_add_offload(&gs->udp_offloads);
> +               err = udp_add_offload(sock_net(sk), &gs->udp_offloads);
>                 if (err)
>                         pr_warn("geneve: udp_add_offload failed with status %d\n",
>                                 err);
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index ba363cedef8082..2428175c4dd4bb 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -621,7 +621,7 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>         int err;
>
>         if (sa_family == AF_INET) {
> -               err = udp_add_offload(&vs->udp_offloads);
> +               err = udp_add_offload(net, &vs->udp_offloads);
>                 if (err)
>                         pr_warn("vxlan: udp_add_offload failed with status %d\n", err);
>         }
> diff --git a/include/net/protocol.h b/include/net/protocol.h
> index d6fcc1fcdb5b09..da689f5432dee2 100644
> --- a/include/net/protocol.h
> +++ b/include/net/protocol.h
> @@ -107,7 +107,7 @@ int inet_del_offload(const struct net_offload *prot, unsigned char num);
>  void inet_register_protosw(struct inet_protosw *p);
>  void inet_unregister_protosw(struct inet_protosw *p);
>
> -int  udp_add_offload(struct udp_offload *prot);
> +int  udp_add_offload(struct net *net, struct udp_offload *prot);
>  void udp_del_offload(struct udp_offload *prot);
>
>  #if IS_ENABLED(CONFIG_IPV6)
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index bd903fe0f7508d..976f0dcf699197 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -498,7 +498,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
>         sk->sk_allocation = GFP_ATOMIC;
>
>         if (cfg->udp_config.family == AF_INET) {
> -               err = udp_add_offload(&fou->udp_offloads);
> +               err = udp_add_offload(net, &fou->udp_offloads);
>                 if (err)
>                         goto error;
>         }
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index f9386160cbee02..5d396b96ae8bb9 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -21,6 +21,7 @@ static struct udp_offload_priv __rcu *udp_offload_base __read_mostly;
>
>  struct udp_offload_priv {
>         struct udp_offload      *offload;
> +       possible_net_t  net;
>         struct rcu_head         rcu;
>         struct udp_offload_priv __rcu *next;
>  };
> @@ -241,13 +242,14 @@ out:
>         return segs;
>  }
>
> -int udp_add_offload(struct udp_offload *uo)
> +int udp_add_offload(struct net *net, struct udp_offload *uo)
>  {
>         struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_ATOMIC);
>
>         if (!new_offload)
>                 return -ENOMEM;
>
> +       write_pnet(&new_offload->net, net);
>         new_offload->offload = uo;
>
>         spin_lock(&udp_offload_lock);
> @@ -311,7 +313,8 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>         rcu_read_lock();
>         uo_priv = rcu_dereference(udp_offload_base);
>         for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
> -               if (uo_priv->offload->port == uh->dest &&
> +               if (net_eq(read_pnet(&uo_priv->net), dev_net(skb->dev)) &&
> +                   uo_priv->offload->port == uh->dest &&
>                     uo_priv->offload->callbacks.gro_receive)
>                         goto unflush;
>         }
> @@ -389,7 +392,8 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>
>         uo_priv = rcu_dereference(udp_offload_base);
>         for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
> -               if (uo_priv->offload->port == uh->dest &&
> +               if (net_eq(read_pnet(&uo_priv->net), dev_net(skb->dev)) &&
> +                   uo_priv->offload->port == uh->dest &&
>                     uo_priv->offload->callbacks.gro_complete)
>                         break;
>         }
> --
> 2.5.0
>
