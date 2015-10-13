From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V15 3/3] 802.1AD: Flow handling, actions, vlan
 parsing and netlink attributes
Date: Mon, 12 Oct 2015 23:47:29 -0700
Message-ID: <CALnjE+qdqBrzZ_p6RCHLr63tSWTKPnTWhQuWsJ8dvAmq-bf9rQ@mail.gmail.com>
References: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
	<1444520433-1958-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37797 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbJMGra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:47:30 -0400
Received: by igcpe7 with SMTP id pe7so8569134igc.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:47:29 -0700 (PDT)
In-Reply-To: <1444520433-1958-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2015 at 4:40 PM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/actions.c      |   6 +-
>  net/openvswitch/flow.c         |  92 +++++++++++++++++++----
>  net/openvswitch/flow.h         |  11 ++-
>  net/openvswitch/flow_netlink.c | 166 +++++++++++++++++++++++++++++++++++++----
>  net/openvswitch/vport-netdev.c |   4 +-
>  5 files changed, 245 insertions(+), 34 deletions(-)
>
...

> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index c8db44a..0f9479c 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -305,21 +305,83 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>  static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>  {
>         struct qtag_prefix {
> -               __be16 eth_type; /* ETH_P_8021Q */
> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>                 __be16 tci;
>         };
> -       struct qtag_prefix *qp;
> +       struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
>
> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
> +       if (likely(skb_vlan_tag_present(skb))) {
> +               key->eth.vlan.tci = htons(skb->vlan_tci);
> +               key->eth.vlan.tpid = skb->vlan_proto;
> +
> +               /* Case where upstream
> +                * processing has already stripped the outer vlan tag.
> +                */
> +               if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
> +                       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16))) {
> +                               key->eth.vlan.tci = 0;
> +                               return 0;
> +                       }
> +
> +                       if (unlikely(!pskb_may_pull(skb,
> +                                                   sizeof(struct qtag_prefix) +
> +                                                   sizeof(__be16))))
> +                               return -ENOMEM;
> +
> +                       qp = (struct qtag_prefix *)skb->data;
> +                       key->eth.cvlan.tci =
> +                               qp->tci | htons(VLAN_TAG_PRESENT);
> +                       key->eth.cvlan.tpid = qp->eth_type;
> +
> +                       __skb_pull(skb, sizeof(struct qtag_prefix));
> +               }
>                 return 0;
>
> -       if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> -                                        sizeof(__be16))))
> -               return -ENOMEM;
> +       } else if (qp->eth_type == htons(ETH_P_8021AD)) {
> +
> +               if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))
> +                       return 0;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +                               sizeof(__be16))))
> +                       return -ENOMEM;
> +
> +               qp = (struct qtag_prefix *)skb->data;
> +               key->eth.vlan.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +               key->eth.vlan.tpid = qp->eth_type;
> +
> +               __skb_pull(skb, sizeof(struct qtag_prefix));
>
> -       qp = (struct qtag_prefix *) skb->data;
> -       key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> -       __skb_pull(skb, sizeof(struct qtag_prefix));
> +               if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))
> +                       return 0;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +                               sizeof(__be16))))
> +                       return -ENOMEM;
> +
There is no check for inner protocol in the packet.

> +               key->eth.cvlan.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +               key->eth.cvlan.tpid = qp->eth_type;
> +
> +               __skb_pull(skb, sizeof(struct qtag_prefix));
> +
> +               return 0;
> +
> +       } else if (qp->eth_type == htons(ETH_P_8021Q)) {
> +               if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))
> +                       return 0;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +                               sizeof(__be16))))
> +                       return -ENOMEM;
> +               key->eth.vlan.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +               key->eth.vlan.tpid = qp->eth_type;
> +
> +               __skb_pull(skb, sizeof(struct qtag_prefix));
> +       }
>
>         return 0;
>  }
I see lot of duplicate code here. How about code below:

struct qtag_prefix {
        __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
        __be16 tci;
};

/* Return  < 0 on memory error
 * Return   == 0 on non vlan or incomplete packet packet
 * Return > 0 on successfully parsing vlan tag.
 */
static int parse_vlan_tag(__be16 vlan_proto, struct sk_buff *skb,
                          struct vlan_tag *cvlan)
{
        if (likely(!eth_type_vlan(skb->vlan_proto)))
                return 0;

        if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16))) {
                vlan->tci = 0;
                return 0;
        }

        if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
sizeof(__be16))))
                        return -ENOMEM;

        qp = (struct qtag_prefix *)skb->data;
        key->eth.cvlan.tci = qp->tci | htons(VLAN_TAG_PRESENT);
        key->eth.cvlan.tpid = qp->eth_type;

        __skb_pull(skb, sizeof(struct qtag_prefix));
        return 1;
}

static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
{
        struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
        int res;

        if (likely(skb_vlan_tag_present(skb))) {
                key->eth.vlan.tci = htons(skb->vlan_tci);
                key->eth.vlan.tpid = skb->vlan_proto;

                /* Case where upstream
                 * processing has already stripped the outer vlan tag.
                 */
                res = parse_vlan_tag(skb->vlan_proto, skb, &key->eth.cvlan);
                if (res < 0)
                        return res;
                /* Since this was inner tag, return zero in either
success or failure
                 * in parsing inner tag.
                 */
                return 0;
        }
        res = parse_vlan_tag(qp->eth_type, skb, &key->eth.vlan);
        if (res <= 0)
                return res;

        res = parse_vlan_tag(key->eth.vlan.tpid, skb, &key->eth.vlan);
        if (res <= 0)
                return res;

        return 0;
}

> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index fe527d2..539494e 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -68,7 +68,16 @@ struct sw_flow_key {
>         struct {
>                 u8     src[ETH_ALEN];   /* Ethernet source address. */
>                 u8     dst[ETH_ALEN];   /* Ethernet destination address. */
> -               __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
> +               struct {
> +                       __be16 tpid;    /* Outer Vlan type 802.1q or 802.1ad.*/
> +                       __be16 tci;     /* 0 if no VLAN, VLAN_TAG_PRESENT */
> +                                       /* set otherwise. */
> +               } vlan;
> +               struct {
> +                       __be16 tpid;    /* Inner Vlan DL_type 802.1q.*/
> +                       __be16 tci;     /* 0 if no CVLAN, VLAN_TAG_PRESENT */
> +                                       /* set otherwise. */
> +               } cvlan;

We need to define structure for vlan tag key here for the pseudo code to work.

>                 __be16 type;            /* Ethernet frame type. */
>         } eth;
>         union {
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c92d6a2..af06683 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -811,6 +811,33 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>         return 0;
>  }
>
>  static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                                 u64 attrs, const struct nlattr **a,
>                                 bool is_mask, bool log)
> @@ -845,7 +872,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                         return -EINVAL;
>                 }
>
> -               SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
> +               SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
>                 attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
>         }
>
> @@ -1064,6 +1091,86 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
>         nlattr_set(attr, val, ovs_key_lens);
>  }
>
> +static int parse_vlan_from_nlattrs(const struct nlattr **nla,
> +                                  struct sw_flow_match *match,
> +                                  u64 *key_attrs, bool *ie_valid,
> +                                  const struct nlattr **a, bool is_mask,
> +                                  bool log)
> +{
> +       int err;
> +       const struct nlattr *encap;
> +
...

> +               u64 mask_v_attrs = 0;
> +
> +               err = parse_flow_mask_nlattrs(*nla, a, &mask_v_attrs, log);
> +               if (err)
> +                       return err;
> +
> +               if (mask_v_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
> +                       if (!*ie_valid) {
> +                               OVS_NLERR(log, "Encap mask attribute is set for non-CVLAN frame.");
> +                               err = -EINVAL;
> +                               return err;
> +                       }
> +                       encap = a[OVS_KEY_ATTR_ENCAP];
> +
> +                       err = cust_vlan_from_nlattrs(match, a, is_mask, log);
> +                       if (err)
> +                               return err;
> +                       *nla = encap;
> +
There is no checking for ATTR_VLAN or ATTR_ETHERTYPE. This can result
in null pointer deference in cust_vlan_from_nlattrs().

> +                       mask_v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_ETHERTYPE);
> +
> +                       *key_attrs |= mask_v_attrs;
> +                       err = parse_flow_mask_nlattrs(*nla, a, key_attrs, log);
> +                       if (err)
> +                               return err;
> +               }
> +       }
> +       return 0;
> +}
> +
...

>
>         if (swkey->eth.type == htons(ETH_P_802_2)) {
>                 /*
> @@ -1525,6 +1659,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>  unencap:
>         if (encap)
>                 nla_nest_end(skb, encap);
> +       if (in_encap)
> +               nla_nest_end(skb, in_encap);
>

As pointed in last review, inner encap attribute should be terminated first.
