From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next V8 2/2] openvswitch: 802.1ad: Flow
 handling, actions, and parsing
Date: Wed, 6 May 2015 11:36:28 -0700
Message-ID: <CALnjE+rQBn3DB0p+NP_hkXDkoTWCB_HKhjo8wM0-VvOSLzO46w@mail.gmail.com>
References: <1430841087-20764-1-git-send-email-thomasfherbert@gmail.com>
	<1430841087-20764-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, ccp@atcnet.net,
	"dev@openvswitch.org" <dev@openvswitch.org>, therbert@redhat.com
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:47800 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751176AbbEFSg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:36:29 -0400
Received: by mail-ig0-f179.google.com with SMTP id sb11so2845056igb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:36:29 -0700 (PDT)
In-Reply-To: <1430841087-20764-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 8:51 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/actions.c      |  6 ++-
>  net/openvswitch/flow.c         | 83 +++++++++++++++++++++++++++++++------
>  net/openvswitch/flow.h         |  1 +
>  net/openvswitch/flow_netlink.c | 94 +++++++++++++++++++++++++++++++++++++++---
>  4 files changed, 165 insertions(+), 19 deletions(-)

checkpatch.pl complains about blank lines.

>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index b491c1c..0831019 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -219,7 +219,8 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>         int err;
>
>         err = skb_vlan_pop(skb);
> -       if (skb_vlan_tag_present(skb))
> +       if (skb_vlan_tag_present(skb) &&
> +           skb->protocol != htons(ETH_P_8021Q))
>                 invalidate_flow_key(key);
I think we need to invalidate the flow key even when protocol is
8021Q. This is because packet is changed from double vlan
encapsulation to single. In this case vlan 8021Q TCI is mapped to
different key struct member.

>         else
>                 key->eth.tci = 0;
> @@ -229,7 +230,8 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>  static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
>                      const struct ovs_action_push_vlan *vlan)
>  {
> -       if (skb_vlan_tag_present(skb))
> +       if (skb_vlan_tag_present(skb) &&
> +           skb->protocol != htons(ETH_P_8021Q))
>                 invalidate_flow_key(key);
Same goes here, we need to invalidate flow key here.

>         else
>                 key->eth.tci = vlan->vlan_tci;
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 2dacc7b..0430466 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -298,21 +298,79 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
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
> +
> +               key->eth.tci = htons(skb->vlan_tci);
> +
> +               /* Case where upstream
> +                * processing has already stripped the outer vlan tag.
> +                */
> +               if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
> +
> +                       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))
> +                               return 0;
> +
In case of error we need to clear key->eth.tci.

> +                       if (unlikely(!pskb_may_pull(skb,
> +                                                   sizeof(struct qtag_prefix) +
....
....
> +
>  static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
>                                 const struct nlattr **a, bool is_mask,
>                                 bool log)
> @@ -1049,6 +1072,8 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>         struct nlattr *newmask = NULL;
>         u64 key_attrs = 0;
>         u64 mask_attrs = 0;
> +       u64 v_attrs = 0;
> +       u64 mask_v_attrs = 0;
>         bool encap_valid = false;
Move local variable declaration to block where it is actually used.

>         int err;
>
> @@ -1058,7 +1083,9 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>
>         if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
>             (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
> -           (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
> +           ((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q)) ||
> +            (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) ==
> +             htons(ETH_P_8021AD)))) {
>                 __be16 tci;
>
>                 if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
> @@ -1074,9 +1101,31 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>                 encap_valid = true;
>
>                 if (tci & htons(VLAN_TAG_PRESENT)) {
> -                       err = parse_flow_nlattrs(encap, a, &key_attrs, log);
> -                       if (err)
> -                               return err;
> +
> +                       if (unlikely((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) ==
> +                           htons(ETH_P_8021AD)))) {
> +
> +                               err = parse_flow_nlattrs(encap, a, &v_attrs,
> +                                                        log);
> +                               if (err)
> +                                       return err;
> +                               if (v_attrs) {
> +                                       err = ovs_nested_vlan_from_nlattrs(
> +                                               match, v_attrs, a, false, log);
> +                                       if (err)
> +                                               return err;
> +                               }
> +                               /* Insure that tci key attribute isn't
> +                                * overwritten by encapsulated customer tci.
> +                                */
> +                               v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +                               key_attrs |= v_attrs;
> +                       } else {
> +                               err = parse_flow_nlattrs(encap, a, &key_attrs,
> +                                                        log);
> +                               if (err)
> +                                       return err;
> +                       }
>                 } else if (!tci) {
>                         /* Corner case for truncated 802.1Q header. */
>                         if (nla_len(encap)) {
Can you move this vlan key parsing to separate function.


> @@ -1133,6 +1182,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>                 if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
>                         __be16 eth_type = 0;
>                         __be16 tci = 0;
> +                       __be16 ctci = 0;
>
>                         if (!encap_valid) {
>                                 OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
> @@ -1167,6 +1217,23 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>                                 err = -EINVAL;
>                                 goto free_newmask;
>                         }
> +                       err = parse_flow_mask_nlattrs(encap, a, &mask_v_attrs,
> +                                                     log);
> +                       if (err)
> +                               goto free_newmask;
> +
> +                       if (mask_v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) {
> +                               ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +                               if (!(ctci & htons(VLAN_TAG_PRESENT))) {
> +                                       OVS_NLERR(log, "VLAN ctag present bit must have an exact match (ctci_mask=%x).",
> +                                                 ntohs(ctci));
> +                                       err = -EINVAL;
> +                                       goto free_newmask;
> +                               }
> +                               mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +                               mask_attrs |= mask_v_attrs;
> +                       }
> +
we need to always initialize ctci mask to 0xff. Same as we do it for tci.

>                 }
>
>                 err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);

I do not see key->eth.ctci mask set according to userspace mask attribute.
You could use ovs_nested_vlan_from_nlattrs().
