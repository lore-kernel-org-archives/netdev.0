From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V14 3/3] openvswitch: 802.1ad: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Mon, 5 Oct 2015 17:27:16 -0700
Message-ID: <CALnjE+rPSvWBuwLTXq0mpaC6NJZF2rGdn7DyVNPMtDQKws2FGg@mail.gmail.com>
References: <1443670380-4245-1-git-send-email-thomasfherbert@gmail.com>
	<1443670380-4245-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37678 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbbJFA1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 20:27:17 -0400
Received: by igcpe7 with SMTP id pe7so13641991igc.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 17:27:16 -0700 (PDT)
In-Reply-To: <1443670380-4245-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 8:33 PM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/actions.c      |   4 +-
>  net/openvswitch/flow.c         |  87 +++++++++++++++++----
>  net/openvswitch/flow.h         |  11 ++-
>  net/openvswitch/flow_netlink.c | 167 +++++++++++++++++++++++++++++++++++++----
>  net/openvswitch/vport-netdev.c |   4 +-
>  5 files changed, 239 insertions(+), 34 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 315f533..c544371 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -236,7 +236,7 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>         if (skb_vlan_tag_present(skb))
>                 invalidate_flow_key(key);
>         else
> -               key->eth.tci = 0;
> +               key->eth.vlan.tci = 0;
Since new tpid field is introduced, it needs to be updated here.

>         return err;
>  }
>
> @@ -246,7 +246,7 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
>         if (skb_vlan_tag_present(skb))
>                 invalidate_flow_key(key);
>         else
> -               key->eth.tci = vlan->vlan_tci;
> +               key->eth.vlan.tci = vlan->vlan_tci;
Same as above, tpid needs to be updated here.

>         return skb_vlan_push(skb, vlan->vlan_tpid,
>                              ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
>  }
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index c8db44a..86a2cb0 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -305,21 +305,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
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
> +       struct qinqtag_prefix {
> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
> +               __be16 tci;
> +               __be16 inner_tpid; /* ETH_P_8021Q */
> +               __be16 ctci;
> +       };
> +
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
Comment regarding qp pointer is ignored from previous review. Most of
comment in this function from earlier review still apply.

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
> +               struct qinqtag_prefix *qinqp =
> +                                       (struct qinqtag_prefix *)skb->data;
> +
This code can be further simplified by just defining struct
qtag_prefix. and parsing it twice in this case.

> +               if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
> +                                       sizeof(__be16)))
> +                       return 0;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
> +                               sizeof(__be16))))
> +                       return -ENOMEM;
> +               key->eth.vlan.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
> +               key->eth.vlan.tpid = qp->eth_type;
> +               key->eth.cvlan.tci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
> +               key->eth.cvlan.tpid = qinqp->inner_tpid;
> +
> +               __skb_pull(skb, sizeof(struct qinqtag_prefix));
>
> -       qp = (struct qtag_prefix *) skb->data;
> -       key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> -       __skb_pull(skb, sizeof(struct qtag_prefix));
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
...
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c92d6a2..08f56ab 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -811,6 +811,27 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>         return 0;
>  }
>
...

>  static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                                 u64 attrs, const struct nlattr **a,
>                                 bool is_mask, bool log)
> @@ -845,7 +866,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                         return -EINVAL;
>                 }
>
> -               SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
> +               SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
>                 attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
>         }
>
> @@ -1064,6 +1085,93 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
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
> +                               OVS_NLERR(log, "Invalid Inner VLAN frame");
> +                               return -EINVAL;
> +                       }
> +                       SW_FLOW_KEY_PUT(match, eth.vlan.tpid,
> +                                       nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]),
> +                                                    is_mask);
eth.vlan.tpid is only set in case of double nested vlan case.
> +                       encap = a[OVS_KEY_ATTR_ENCAP];
> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +
This bit masking can be grouped with the following operation.
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
> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +               }
> +               *key_attrs |= v_attrs;
> +
> +               if (*ie_valid) {
> +                       err = parse_flow_nlattrs(*nla, a, key_attrs, log);
> +                       if (err)
> +                               return err;
> +               }
Why is the parsing is not done inside the nested block?

> +
> +       } else {
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
Double nested eth-type mask should be 0xffff. Same as single nested
eth-type check
> +                       encap = a[OVS_KEY_ATTR_ENCAP];
> +                       mask_v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +
> +                       err = cust_vlan_from_nlattrs(match, a, is_mask, log);
> +                       if (err)
> +                               return err;
> +                       *nla = encap;
> +
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_ETHERTYPE);
> +               }
> +
> +               *key_attrs |= mask_v_attrs;
> +               if (*ie_valid) {
> +                       err = parse_flow_mask_nlattrs(*nla, a, key_attrs, log);
Same as above. I think the parsing can be done inside the nested block.

> +                       if (err)
> +                               return err;
> +               }
> +       }
> +       return 0;
> +}
> +
...
> @@ -1525,6 +1660,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>  unencap:
>         if (encap)
>                 nla_nest_end(skb, encap);
> +       if (in_encap)
> +               nla_nest_end(skb, in_encap);
>
Inner nested encap should end first.
