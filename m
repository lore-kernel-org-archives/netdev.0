From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 3/3] openvswitch: 802.1AD: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Mon, 27 Jul 2015 12:02:40 -0700
Message-ID: <CALnjE+o7a0zSQebOB2Vr2ZmVM=+Pd0NMZQEVOWd-vyvoOqV2VQ@mail.gmail.com>
References: <1437922355-3809-1-git-send-email-thomasfherbert@gmail.com>
	<1437922355-3809-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34102 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbbG0TCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 15:02:40 -0400
Received: by igk11 with SMTP id 11so75344408igk.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 12:02:40 -0700 (PDT)
In-Reply-To: <1437922355-3809-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 26, 2015 at 7:52 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes. Allows
> either 0x8100 or 0x88a8 on inner or outer tags.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/flow.c         |  84 +++++++++++++++---
>  net/openvswitch/flow.h         |   5 ++
>  net/openvswitch/flow_netlink.c | 196 ++++++++++++++++++++++++++++++++++-------
>  3 files changed, 243 insertions(+), 42 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 8db22ef..0abab37 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -298,21 +298,80 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
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
> +               key->eth.tci = htons(skb->vlan_tci);
> +
> +               /* Case where upstream
> +                * processing has already stripped the outer vlan tag.
> +                */
> +               if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
> +                       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16))) {
> +                               key->eth.tci = 0;
> +                               return 0;
> +                       }
> +
> +                       if (unlikely(!pskb_may_pull(skb,
> +                                                   sizeof(struct qtag_prefix) +
> +                                                   sizeof(__be16)))) {
> +                               return -ENOMEM;
> +                       }
> +
No need to curly brackets for single statement.

> +                       if (likely(qp->eth_type == htons(ETH_P_8021Q))) {
> +                               key->eth.cvlan.ctci =
> +                                       qp->tci | htons(VLAN_TAG_PRESENT);
> +                               key->eth.cvlan.c_tpid = qp->eth_type;
> +                               __skb_pull(skb, sizeof(struct qtag_prefix));
> +                       }
key->eth.cvlan.tci and tpid should be set irrespective of qp->eth_type
as it is done bellow for non offload case.

> +               }
>                 return 0;
> +       }
>
> -       if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> -                                        sizeof(__be16))))
> -               return -ENOMEM;
>
> -       qp = (struct qtag_prefix *) skb->data;
> -       key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> -       __skb_pull(skb, sizeof(struct qtag_prefix));
> +       if (qp->eth_type == htons(ETH_P_8021AD)) {
> +               struct qinqtag_prefix *qinqp =
> +                                       (struct qinqtag_prefix *)skb->data;
> +
> +               if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
> +                                       sizeof(__be16)))
> +                       return 0;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
> +                               sizeof(__be16)))) {
> +                       return -ENOMEM;
> +               }
No need to curly brackets for single statement.

> +               key->eth.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
> +               key->eth.cvlan.ctci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
> +               key->eth.cvlan.c_tpid = qinqp->inner_tpid;
> +
> +               __skb_pull(skb, sizeof(struct qinqtag_prefix));
> +
> +               return 0;
> +       }
> +       if (qp->eth_type == htons(ETH_P_8021Q)) {
> +               if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))
> +                       return -ENOMEM;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +                               sizeof(__be16))))
> +                       return 0;
> +               key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +
> +               __skb_pull(skb, sizeof(struct qtag_prefix));
> +       }
>
>         return 0;
>  }
> @@ -474,9 +533,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>          */
>
>         key->eth.tci = 0;
> -       if (skb_vlan_tag_present(skb))
> -               key->eth.tci = htons(skb->vlan_tci);
> -       else if (eth->h_proto == htons(ETH_P_8021Q))
> +       key->eth.cvlan.ctci = 0;
> +       key->eth.cvlan.c_tpid = 0;
> +       if ((skb_vlan_tag_present(skb)) ||
> +           eth_type_vlan(eth->h_proto))
>                 if (unlikely(parse_vlan(skb, key)))
>                         return -ENOMEM;
>
inside the function first skb vlan tag is checked and then it checks
for 8021Q and 8021AD. These are exact same checks. Why do you think it
is not redundant?

> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index b62cdb3..69c48c6 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h

...
>

...
>  static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
>                                 const struct nlattr **a, bool is_mask,
>                                 bool log)
> @@ -1024,6 +1049,104 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
>         nlattr_set(attr, val, ovs_key_lens);
>  }
>
> +static int parse_vlan_from_nlattrs(const struct nlattr *nla,
> +                                  struct sw_flow_match *match,
> +                                  u64 *key_attrs, bool *ie_valid,
> +                                  const struct nlattr **a, bool is_mask,
> +                                  bool log)
> +{
> +       int err;
> +       __be16 tci;
> +       const struct nlattr *encap;
> +
> +       *ie_valid = false;
> +       if (!is_mask) {
> +               u64 v_attrs = 0;
> +
> +               tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +
> +               if (tci & htons(VLAN_TAG_PRESENT)) {
> +                       err = parse_flow_nlattrs(nla, a, &v_attrs, log);
> +                       if (err)
> +                               return err;
> +                       if (!v_attrs)
> +                               return -EINVAL;
> +                       /* Another encap attribute here indicates
> +                        * a double tagged vlan.
> +                        */
> +                       if (v_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)) {
> +                               if (!(v_attrs & (1ULL << OVS_KEY_ATTR_VLAN))) {
> +                                       OVS_NLERR(log, "Inner encap attr is set for non VLAN frame");
> +                                       return -EINVAL;
> +                               }
> +                               v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +                               encap = a[OVS_KEY_ATTR_ENCAP];
> +                               v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +                               *ie_valid = true;
> +
> +                               err = cust_vlan_from_nlattrs(match, v_attrs,
> +                                                            &encap, is_mask,
> +                                                            log);
> +                               if (err)
> +                                       return err;
> +                               /* Insure that tci key attribute isn't
> +                                * overwritten by encapsulated customer tci.
> +                                */
> +                               v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +                               *key_attrs |= v_attrs;
> +                       } else {
> +                               *key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +                               err = parse_flow_nlattrs(nla, a, key_attrs,
> +                                                        log);
> +                               if (err)
> +                                       return err;
> +                       }
This code will not process nested flow attributes correctly. in case
of 8021AD where we have double nested encap attributes we need to
parse flow attributes to retrieve inner attributes. Same issue exist
for flow mask case.


> +               } else if (!tci) {
> +                       /* Corner case for truncated 802.1Q header. */
> +                       if (nla_len(nla)) {
> +                               OVS_NLERR(log, "Truncated 802.1Q header has non-zero encap attribute.");
> +                               return -EINVAL;
> +                       }
> +               } else {
> +                       OVS_NLERR(log, "Encap attr is set for non-VLAN frame");
> +                       return  -EINVAL;
> +               }
> +
> +       } else {
> +               u64 mask_v_attrs = 0;
> +
> +               tci = 0;
> +               if (a[OVS_KEY_ATTR_VLAN])
> +                       tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +
> +               if (!(tci & htons(VLAN_TAG_PRESENT))) {
> +                       OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
> +                                 ntohs(tci));
> +                       err = -EINVAL;
> +                       return err;
> +               }
> +               err = parse_flow_mask_nlattrs(nla, a, &mask_v_attrs,
> +                                             log);
> +               if (err)
> +                       return err;
> +
> +               if (mask_v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) {
> +                       err = cust_vlan_from_nlattrs(match, mask_v_attrs,
> +                                                    a, is_mask, log);
> +                       if (err)
> +                               return err;
> +
> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +                       *key_attrs |= mask_v_attrs;
> +              } else {
> +                       *key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +                       if (err)
> +                               return err;
> +               }
> +       }
...
