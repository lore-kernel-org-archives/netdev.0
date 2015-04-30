From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V7 2/2] openvswitch: 802.1ad: Flow handling,
 actions, and vlan parsing
Date: Wed, 29 Apr 2015 18:27:42 -0700
Message-ID: <CALnjE+qtYW4JE5TT3WiOofe=Q+YkLEZ7e+MpJQYLs5f6wD3nvw@mail.gmail.com>
References: <1430261059-7920-1-git-send-email-thomasfherbert@gmail.com>
	<1430261059-7920-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	ccp@atcnet.net
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:60121 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750986AbbD3B1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:27:43 -0400
Received: by mail-ig0-f178.google.com with SMTP id yr2so722618igb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:27:43 -0700 (PDT)
In-Reply-To: <1430261059-7920-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 3:44 PM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans.
>
I saw multiple checkpatch.pl errors and warning.

> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
...
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 2dacc7b..6989451 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -298,21 +298,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>  static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>  {
>         struct qtag_prefix {
> -               __be16 eth_type; /* ETH_P_8021Q */
> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>                 __be16 tci;
>         };
> -       struct qtag_prefix *qp;
> +       struct qtag_prefix *qp = (struct qtag_prefix *) skb->data;
>
> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
> -               return 0;
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
I think there is bug in existing OVS where it does not check
vlan_proto before populating the flow key. Can you send a separate
patch to fix this issue?.

> +               /*
> +                * Case where upstream
> +                * processing has already stripped the outer vlan tag.
> +                */
> +               if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
> +
> +                       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))
> +                               return 0;
> +
If this returns from here then it can match on flow with tci which
expect vlan_proto to be 8021Q but with vlan_proto equal to 8021AD.

> +                       if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +                                       sizeof(__be16)))) {
> +                               return -ENOMEM;
> +                       }
> +
> +                       if (likely(qp->eth_type == htons(ETH_P_8021Q))) {
> +                               key->eth.ctci = qp->tci | htons(VLAN_TAG_PRESENT);
> +                               __skb_pull(skb, sizeof(struct qtag_prefix));
> +                       }
> +               }
> +                return 0;
> +       }
>

...

> @@ -1074,9 +1099,28 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>                 encap_valid = true;
>
>                 if (tci & htons(VLAN_TAG_PRESENT)) {
> -                       err = parse_flow_nlattrs(encap, a, &key_attrs, log);
> -                       if (err)
> -                               return err;
> +
> +                       if (unlikely((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) ==
> +                           htons(ETH_P_8021AD)))) {

Incorrect alignment.

> +
> +                               err = parse_flow_nlattrs(encap, a, &v_attrs, log);
> +                               if (err)
> +                                       return err;
> +                               if (v_attrs) {
v_attrs can to be defined in inner block where is actually used.

...
> @@ -1167,6 +1212,22 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>                                 err = -EINVAL;
>                                 goto free_newmask;
>                         }
> +                       err = parse_flow_mask_nlattrs(encap, a, &mask_v_attrs, log);
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

mask_v_attrs can be defined in block where it is used.

> +                       }
> +
>                 }
>
>                 err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
> @@ -1331,6 +1392,15 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>                 encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>                 if (!swkey->eth.tci)
>                         goto unencap;
> +       } else if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021AD)) {
Checking for swkey->eth.tci does not make sense here. There is check
for it in previous if condition.

> +               __be16 eth_type;
> +               eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))

What about eth.ctci?
