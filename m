From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V16 3/3] openvswitch: 802.1AD: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Thu, 15 Oct 2015 16:02:55 -0700
Message-ID: <CALnjE+o4o1RWf12F9wyeZfb9=Y+nw+Bta=NA+we1zQ+4yGLYNA@mail.gmail.com>
References: <1444917715-27093-1-git-send-email-thomasfherbert@gmail.com>
	<1444917715-27093-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36788 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbbJOXC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 19:02:56 -0400
Received: by ioii196 with SMTP id i196so106077425ioi.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:02:55 -0700 (PDT)
In-Reply-To: <1444917715-27093-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 7:01 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/actions.c      |   6 +-
>  net/openvswitch/flow.c         |  75 ++++++++++++++----
>  net/openvswitch/flow.h         |   8 +-
>  net/openvswitch/flow_netlink.c | 169 +++++++++++++++++++++++++++++++++++++----
>  net/openvswitch/vport-netdev.c |   4 +-
>  5 files changed, 228 insertions(+), 34 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 315f533..09cc1c9 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -236,7 +236,8 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>         if (skb_vlan_tag_present(skb))
>                 invalidate_flow_key(key);
>         else
> -               key->eth.tci = 0;
> +               key->eth.vlan.tci = 0;
> +               key->eth.vlan.tpid = 0;
>         return err;
>  }
>
> @@ -246,7 +247,8 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
>         if (skb_vlan_tag_present(skb))
>                 invalidate_flow_key(key);
>         else
> -               key->eth.tci = vlan->vlan_tci;
> +               key->eth.vlan.tci = vlan->vlan_tci;
> +               key->eth.vlan.tpid = vlan->vlan_tpid;
>         return skb_vlan_push(skb, vlan->vlan_tpid,
>                              ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
>  }
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index c8db44a..8a4e298 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -302,24 +302,69 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>                                   sizeof(struct icmp6hdr));
>  }
>
> -static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
> +struct qtag_prefix {
> +       __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
> +       __be16 tci;
> +};
> +
Now we can just use newly defined struct vlan_header here.

> +/* Parse vlan tag from vlan header.
> + * Returns ERROR on memory error.
> + * Returns 0 if it encounters a non-vlan or incomplete packet.
> + * Returns 1 after successfully parsing vlan tag.
> + */
> +
> +static int parse_vlan_tag(struct sk_buff *skb, __be16 vlan_proto,
> +                         __be16 vlan_tci, struct vlan_head *vlan)
>  {
> -       struct qtag_prefix {
> -               __be16 eth_type; /* ETH_P_8021Q */
> -               __be16 tci;
> -       };
> -       struct qtag_prefix *qp;
> +       if (likely(!eth_type_vlan(vlan_proto)))
> +               return 0;
>
>         if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
>                 return 0;
>
>         if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> -                                        sizeof(__be16))))
> +                                sizeof(__be16))))
>                 return -ENOMEM;
>
> -       qp = (struct qtag_prefix *) skb->data;
> -       key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +       vlan->tci = vlan_tci | htons(VLAN_TAG_PRESENT);
> +       vlan->tpid = vlan_proto;
> +
>         __skb_pull(skb, sizeof(struct qtag_prefix));
> +       return 1;
> +}
> +
> +static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +       struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
> +       int res;
> +
> +       if (likely(skb_vlan_tag_present(skb))) {
> +               key->eth.vlan.tci = htons(skb->vlan_tci);
> +               key->eth.vlan.tpid = skb->vlan_proto;
> +
> +               /* Case where ingress processing has already stripped
> +                * the outer vlan tag.
> +                */
> +               res = parse_vlan_tag(skb, qp->eth_type, qp->tci,
> +                                    &key->eth.cvlan);
> +               if (res < 0)
> +                       return res;
> +               /* For inner tag, return 0 because neither
> +                * non-existant nor partial inner tag is an error.
> +                */
> +               return 0;
> +       }
> +       res = parse_vlan_tag(skb, qp->eth_type, qp->tci, &key->eth.vlan);
> +       if (res <= 0)
> +               /* This is an outer tag in the non-accelerated VLAN
> +                * case. Return error unless it is a complete vlan tag.
> +                */
> +               return res;
> +
> +       /* Parse inner vlan tag if present for non-accelerated case. */
> +       res = parse_vlan_tag(skb, qp->eth_type, qp->tci, &key->eth.cvlan);
> +       if (res <= 0)
> +               return res;
>
same qp pointer is passed for inner and outer vlan parameters here. It
is better to just pass skb and keep qp inside parse_vlan_tag()
function.

>         return 0;
>  }
> @@ -480,12 +525,12 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>          * update skb->csum here.
>          */
>
> -       key->eth.tci = 0;
> -       if (skb_vlan_tag_present(skb))
> -               key->eth.tci = htons(skb->vlan_tci);
> -       else if (eth->h_proto == htons(ETH_P_8021Q))
> -               if (unlikely(parse_vlan(skb, key)))
> -                       return -ENOMEM;
> +       key->eth.vlan.tci = 0;
> +       key->eth.vlan.tpid = 0;
> +       key->eth.cvlan.tci = 0;
> +       key->eth.cvlan.tpid = 0;
Lets move this over to parse_vlan().

> +       if (unlikely(parse_vlan(skb, key)))
> +               return -ENOMEM;
>
>         key->eth.type = parse_ethertype(skb);
>         if (unlikely(key->eth.type == htons(0)))
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c92d6a2..5cff83c 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
...


>  static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                                 u64 attrs, const struct nlattr **a,
>                                 bool is_mask, bool log)
> @@ -845,7 +875,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                         return -EINVAL;
>                 }
>
> -               SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
> +               SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
>                 attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
>         }
>
> @@ -1064,6 +1094,86 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
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
> +       if (!is_mask) {
> +               u64 v_attrs = 0;
> +
attributes does not need 64 bits, 32 bits are sufficient.
> +               err = parse_flow_nlattrs(*nla, a, &v_attrs, log);
> +               if (err)
> +                       return err;
> +               /* Another encap attribute here indicates
> +                * the presence of a double tagged vlan.
> +                */
> +               if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
> +                   eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
> +                       if (!((v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
> +                             (v_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
After changing v_attrs type, there is no need to use 1ULL.

> +                               OVS_NLERR(log, "Invalid Inner VLAN frame");
> +                               return -EINVAL;
> +                       }
> +                       encap = a[OVS_KEY_ATTR_ENCAP];
> +
> +                       err = cust_vlan_from_nlattrs(match, a, is_mask, log);
> +                       if (err)
> +                               return err;
> +                       *ie_valid = true;
> +                       *nla = encap;
> +
> +                       /* Insure that tci key attribute isn't
> +                        * overwritten by encapsulated customer tci.
> +                        * Ethertype is cleared because it is c_tpid.
> +                        */
> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +
> +                       *key_attrs |= v_attrs;
> +                       err = parse_flow_nlattrs(*nla, a, key_attrs, log);
> +                       if (err)
> +                               return err;
> +               }
Apart from the check for vlan and encap attribute, this whole block
looks pretty much same for key and mask attribute. Can you define
another function to factor out this code.

> +
> +       } else {
> +               u64 mask_v_attrs = 0;
> +
same as above mask_v_attrs does not need 64 bits, u32 is fine here.

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
> +                       mask_v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_ETHERTYPE);
> +
After changing the type, there is no need to use 1ULL.

> +                       *key_attrs |= mask_v_attrs;
> +                       err = parse_flow_mask_nlattrs(*nla, a, key_attrs, log);
> +                       if (err)
> +                               return err;
> +               }
> +       }
> +       return 0;
> +}
> +
>  /**
>   * ovs_nla_get_match - parses Netlink attributes into a flow key and
>   * mask. In case the 'mask' is NULL, the flow is treated as exact match
...

> @@ -1320,6 +1437,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>  {
>         struct ovs_key_ethernet *eth_key;
>         struct nlattr *nla, *encap;
> +       struct nlattr *in_encap = NULL;
>
>         if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>                 goto nla_put_failure;
> @@ -1368,17 +1486,36 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>         ether_addr_copy(eth_key->eth_src, output->eth.src);
>         ether_addr_copy(eth_key->eth_dst, output->eth.dst);
>
> -       if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
> +       if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
>                 __be16 eth_type;
> -               eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
> +
> +               eth_type = !is_mask ? output->eth.vlan.tpid : htons(0xffff);
> +
Since tpid mask is checked at flow install time, lets just return
output->eth.vlan.tpid for mask too.

>                 if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> -                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.vlan.tci))
>                         goto nla_put_failure;
>                 encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> -               if (!swkey->eth.tci)
> +               if (!swkey->eth.vlan.tci)
>                         goto unencap;
> -       } else
> +               if (swkey->eth.cvlan.tci) {
> +                       __be16 eth_type;
> +
> +                       /* Customer tci is nested but uses same key attribute.
> +                        */
> +                       eth_type = !is_mask ? output->eth.cvlan.tpid :
> +                                             htons(0xffff);
same as above, Lets just return output->eth.cvlan.tpid even for mask.
