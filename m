From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v3] net: add recursion limit to GRO
Date: Thu, 20 Oct 2016 08:49:18 -0700
Message-ID: <CALx6S36yZeg_RrQXMEXQxOq8FGOnvhDeyfwvYt3kvGwhkcTVCg@mail.gmail.com>
References: <7429d1a2eaceec5e4563be8c67e86e1a515f21b5.1476971359.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34402 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933573AbcJTPtT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:49:19 -0400
Received: by mail-qk0-f194.google.com with SMTP id n189so4895591qke.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 08:49:19 -0700 (PDT)
In-Reply-To: <7429d1a2eaceec5e4563be8c67e86e1a515f21b5.1476971359.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 6:58 AM, Sabrina Dubroca <sd@queasysnail.net> wrote=
:
> Currently, GRO can do unlimited recursion through the gro_receive
> handlers.  This was fixed for tunneling protocols by limiting tunnel GRO
> to one level with encap_mark, but both VLAN and TEB still have this
> problem.  Thus, the kernel is vulnerable to a stack overflow, if we
> receive a packet composed entirely of VLAN headers.
>
> This patch adds a recursion counter to the GRO layer to prevent stack
> overflow.  When a gro_receive function hits the recursion limit, GRO is
> aborted for this skb and it is processed normally.  This recursion
> counter is put in the GRO CB, but could be turned into a percpu counter
> if we run out of space in the CB.
>
> Thanks to Vladim=C3=ADr Bene=C5=A1 <vbenes@redhat.com> for the initial bu=
g report.
>
> Fixes: CVE-2016-7039
> Fixes: 9b174d88c257 ("net: Add Transparent Ethernet Bridging GRO support.=
")
> Fixes: 66e5133f19e9 ("vlan: Add GRO support for non hardware accelerated =
vlan")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reviewed-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> v2: add unlikely() annotations, suggested by Eric Dumazet
>     benchmark didn't show a difference between CB and pcpu variable for
>     the recursion counter, so I'm sticking with the CB
>
> v3: add call_gro_receive_sk, suggested by Tom Herbert
>
Acked-by: Tom Herbert <tom@herbertland.com>

>  drivers/net/geneve.c      |  2 +-
>  drivers/net/vxlan.c       |  2 +-
>  include/linux/netdevice.h | 39 ++++++++++++++++++++++++++++++++++++++-
>  net/8021q/vlan.c          |  2 +-
>  net/core/dev.c            |  1 +
>  net/ethernet/eth.c        |  2 +-
>  net/ipv4/af_inet.c        |  2 +-
>  net/ipv4/fou.c            |  4 ++--
>  net/ipv4/gre_offload.c    |  2 +-
>  net/ipv4/udp_offload.c    |  2 +-
>  net/ipv6/ip6_offload.c    |  2 +-
>  11 files changed, 49 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 3c20e87bb761..16af1ce99233 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -453,7 +453,7 @@ static struct sk_buff **geneve_gro_receive(struct soc=
k *sk,
>
>         skb_gro_pull(skb, gh_len);
>         skb_gro_postpull_rcsum(skb, gh, gh_len);
> -       pp =3D ptype->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ptype->callbacks.gro_receive, head, skb);
>         flush =3D 0;
>
>  out_unlock:
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e7d16687538b..c1639a3e95a4 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -583,7 +583,7 @@ static struct sk_buff **vxlan_gro_receive(struct sock=
 *sk,
>                 }
>         }
>
> -       pp =3D eth_gro_receive(head, skb);
> +       pp =3D call_gro_receive(eth_gro_receive, head, skb);
>         flush =3D 0;
>
>  out:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 465e128699a1..91ee3643ccc8 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2169,7 +2169,10 @@ struct napi_gro_cb {
>         /* Used to determine if flush_id can be ignored */
>         u8      is_atomic:1;
>
> -       /* 5 bit hole */
> +       /* Number of gro_receive callbacks this packet already went throu=
gh */
> +       u8 recursion_counter:4;
> +
> +       /* 1 bit hole */
>
>         /* used to support CHECKSUM_COMPLETE for tunneling protocols */
>         __wsum  csum;
> @@ -2180,6 +2183,40 @@ struct napi_gro_cb {
>
>  #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
>
> +#define GRO_RECURSION_LIMIT 15
> +static inline int gro_recursion_inc_test(struct sk_buff *skb)
> +{
> +       return ++NAPI_GRO_CB(skb)->recursion_counter =3D=3D GRO_RECURSION=
_LIMIT;
> +}
> +
> +typedef struct sk_buff **(*gro_receive_t)(struct sk_buff **, struct sk_b=
uff *);
> +static inline struct sk_buff **call_gro_receive(gro_receive_t cb,
> +                                               struct sk_buff **head,
> +                                               struct sk_buff *skb)
> +{
> +       if (unlikely(gro_recursion_inc_test(skb))) {
> +               NAPI_GRO_CB(skb)->flush |=3D 1;
> +               return NULL;
> +       }
> +
> +       return cb(head, skb);
> +}
> +
> +typedef struct sk_buff **(*gro_receive_sk_t)(struct sock *, struct sk_bu=
ff **,
> +                                            struct sk_buff *);
> +static inline struct sk_buff **call_gro_receive_sk(gro_receive_sk_t cb,
> +                                                  struct sock *sk,
> +                                                  struct sk_buff **head,
> +                                                  struct sk_buff *skb)
> +{
> +       if (unlikely(gro_recursion_inc_test(skb))) {
> +               NAPI_GRO_CB(skb)->flush |=3D 1;
> +               return NULL;
> +       }
> +
> +       return cb(sk, head, skb);
> +}
> +
>  struct packet_type {
>         __be16                  type;   /* This is really htons(ether_typ=
e). */
>         struct net_device       *dev;   /* NULL is wildcarded here       =
    */
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 8de138d3306b..f2531ad66b68 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -664,7 +664,7 @@ static struct sk_buff **vlan_gro_receive(struct sk_bu=
ff **head,
>
>         skb_gro_pull(skb, sizeof(*vhdr));
>         skb_gro_postpull_rcsum(skb, vhdr, sizeof(*vhdr));
> -       pp =3D ptype->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ptype->callbacks.gro_receive, head, skb);
>
>  out_unlock:
>         rcu_read_unlock();
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b09ac57f4348..dbc871306910 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4511,6 +4511,7 @@ static enum gro_result dev_gro_receive(struct napi_=
struct *napi, struct sk_buff
>                 NAPI_GRO_CB(skb)->flush =3D 0;
>                 NAPI_GRO_CB(skb)->free =3D 0;
>                 NAPI_GRO_CB(skb)->encap_mark =3D 0;
> +               NAPI_GRO_CB(skb)->recursion_counter =3D 0;
>                 NAPI_GRO_CB(skb)->is_fou =3D 0;
>                 NAPI_GRO_CB(skb)->is_atomic =3D 1;
>                 NAPI_GRO_CB(skb)->gro_remcsum_start =3D 0;
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 66dff5e3d772..02acfff36028 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -439,7 +439,7 @@ struct sk_buff **eth_gro_receive(struct sk_buff **hea=
d,
>
>         skb_gro_pull(skb, sizeof(*eh));
>         skb_gro_postpull_rcsum(skb, eh, sizeof(*eh));
> -       pp =3D ptype->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ptype->callbacks.gro_receive, head, skb);
>
>  out_unlock:
>         rcu_read_unlock();
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 1effc986739e..9648c97e541f 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1391,7 +1391,7 @@ struct sk_buff **inet_gro_receive(struct sk_buff **=
head, struct sk_buff *skb)
>         skb_gro_pull(skb, sizeof(*iph));
>         skb_set_transport_header(skb, skb_gro_offset(skb));
>
> -       pp =3D ops->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ops->callbacks.gro_receive, head, skb);
>
>  out_unlock:
>         rcu_read_unlock();
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index cf50f7e2b012..030d1531e897 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -249,7 +249,7 @@ static struct sk_buff **fou_gro_receive(struct sock *=
sk,
>         if (!ops || !ops->callbacks.gro_receive)
>                 goto out_unlock;
>
> -       pp =3D ops->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ops->callbacks.gro_receive, head, skb);
>
>  out_unlock:
>         rcu_read_unlock();
> @@ -441,7 +441,7 @@ static struct sk_buff **gue_gro_receive(struct sock *=
sk,
>         if (WARN_ON_ONCE(!ops || !ops->callbacks.gro_receive))
>                 goto out_unlock;
>
> -       pp =3D ops->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ops->callbacks.gro_receive, head, skb);
>         flush =3D 0;
>
>  out_unlock:
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index 96e0efecefa6..d5cac99170b1 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -229,7 +229,7 @@ static struct sk_buff **gre_gro_receive(struct sk_buf=
f **head,
>         /* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
>         skb_gro_postpull_rcsum(skb, greh, grehlen);
>
> -       pp =3D ptype->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ptype->callbacks.gro_receive, head, skb);
>         flush =3D 0;
>
>  out_unlock:
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index f9333c963607..b2be1d9757ef 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -295,7 +295,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **hea=
d, struct sk_buff *skb,
>
>         skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating u=
dp header */
>         skb_gro_postpull_rcsum(skb, uh, sizeof(struct udphdr));
> -       pp =3D udp_sk(sk)->gro_receive(sk, head, skb);
> +       pp =3D call_gro_receive_sk(udp_sk(sk)->gro_receive, sk, head, skb=
);
>
>  out_unlock:
>         rcu_read_unlock();
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index e7bfd55899a3..1fcf61f1cbc3 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -246,7 +246,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_bu=
ff **head,
>
>         skb_gro_postpull_rcsum(skb, iph, nlen);
>
> -       pp =3D ops->callbacks.gro_receive(head, skb);
> +       pp =3D call_gro_receive(ops->callbacks.gro_receive, head, skb);
>
>  out_unlock:
>         rcu_read_unlock();
> --
> 2.10.0
>
