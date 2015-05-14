From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V7 2/2] openvswitch: 802.1ad: Flow handling,
 actions, and vlan parsing
Date: Thu, 14 May 2015 00:33:13 -0700
Message-ID: <CALnjE+pY4b4WxJbu8qzuexq+hcagNA8iwQ0DsPuh_o-PRaP8KA@mail.gmail.com>
References: <1431475596-16780-1-git-send-email-thomasfherbert@gmail.com>
	<1431475596-16780-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	ccp@atcnet.net, "dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:51671 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750893AbbENHdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 03:33:15 -0400
Received: by mail-ig0-f173.google.com with SMTP id sb11so66097191igb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 00:33:14 -0700 (PDT)
In-Reply-To: <1431475596-16780-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 5:06 PM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
...
...
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c691b1a..062e180 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -771,6 +771,51 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
>         return 0;
>  }
>
> +static int eth_type_vlan(__be16 ethertype)
> +{
> +       if (ethertype == htons(ETH_P_8021Q) || ethertype == htons(ETH_P_8021AD))
> +               return true;
> +       return false;
> +}
> +
You have open-coded same comparison in flow.c. May be you can define
it in header file  if_vlan.h. There are some use cases in that file
too for this function.

> +static int _ovs_vlan_from_nlattrs(struct sw_flow_match *match, u64 attrs,
> +                                 const struct nlattr **a, bool is_mask,
> +                                 bool log)
> +{
_ovs_vlan_from_nlattrs() is setting 8021AD, can you change name so
that it is clear.

> +       /* This should be nested inner or "customer" tci" */
> +       if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
> +               __be16 ctci;
> +
> +               ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +               if (!(ctci & htons(VLAN_TAG_PRESENT))) {
> +                       if (is_mask)
> +                               OVS_NLERR(log, "VLAN CTCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
> +                       else
> +                               OVS_NLERR(log, "VLAN CTCI does not have VLAN_TAG_PRESENT bit set.");
> +
> +                       return -EINVAL;
> +               }
> +               if (is_mask)
> +                       SW_FLOW_KEY_PUT(match, eth.ctci, htons(0xffff),
> +                                       is_mask);
> +               else

8021AD mask from user parameters is ignored and 0xffff is set. You
need to set default 0xffff mask for ctci and then override it with
user mask if given in the key.

> +                       SW_FLOW_KEY_PUT(match, eth.ctci, ctci, is_mask);
> +       }
> +       return 0;
> +}
> +
> +static int ovs_vlan_from_nlattrs(struct sw_flow_match *match, u64 attrs,
> +                                const struct nlattr **a, bool log)
> +{
> +       return _ovs_vlan_from_nlattrs(match, attrs, a, false, log);
> +}
> +
> +static int ovs_vlan_mask_from_nlattrs(struct sw_flow_match *match, u64 attrs,
> +                                     const struct nlattr **a, bool log)
> +{
> +       return _ovs_vlan_from_nlattrs(match, attrs, a, true, log);
> +}
> +
I do not see value in these functions. Can you directly call
_ovs_vlan_from_nlattrs().

>  static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
>                                 const struct nlattr **a, bool is_mask,
>                                 bool log)
> @@ -1024,6 +1069,113 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
>         nlattr_set(attr, val, ovs_key_lens);
>  }
>
> +static int _parse_vlan_from_nlattrs(const struct nlattr *nla,
> +                                   struct sw_flow_match *match,
> +                                   u64 *key_attrs,
> +                                   const struct nlattr **a, bool is_mask,
> +                                   bool log)
> +{
> +       int err;
> +       __be16 tci;
> +
> +       if (!is_mask) {
> +               u64 v_attrs = 0;
> +
> +               tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +
> +               if (tci & htons(VLAN_TAG_PRESENT)) {
> +                       if (unlikely((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) ==
> +                                     htons(ETH_P_8021AD)))) {
> +                               err = parse_flow_nlattrs(nla, a, &v_attrs, log);
> +                               if (err)
> +                                       return err;
> +                               if (v_attrs) {
> +                                       err = ovs_vlan_from_nlattrs(match,
> +                                                                   v_attrs, a,
> +                                                                   log);
> +                                       if (err)
> +                                               return err;
> +                               }
> +                               /* Insure that tci key attribute isn't
> +                                * overwritten by encapsulated customer tci.
> +                                */
> +                               v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);

We also need to clear v_attrs when key has single vlan tag which is
else part of this block.

> +                               *key_attrs |= v_attrs;
> +                       } else {
> +                               err = parse_flow_nlattrs(nla, a, key_attrs,
> +                                                        log);
> +                               if (err)
> +                                       return err;
> +                       }
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
For double vlan tag case we need to have double encap attributes in
flow key; one for each tag. So flow key should look like:

eth_type(0x88A8),vlan(vid=10),encap(eth_type(0x08100), vlan(vid=20),
encap(eth_type(0x0800), ...))

Can you adjust vlan parsing code according ?


> +       } else {
> +               u64 mask_v_attrs = 0;
> +
> +               tci = 0;
> +               if (a[OVS_KEY_ATTR_VLAN])
> +                       tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +
> +               if (!(tci & htons(VLAN_TAG_PRESENT))) {
...
...
> +
> +static int parse_vlan_from_nlattrs(const struct nlattr *nla,
> +                                  struct sw_flow_match *match,
> +                                  u64 *key_attrs,
> +                                  const struct nlattr **a,
> +                                  bool log)
> +{
> +       return _parse_vlan_from_nlattrs(nla, match, key_attrs, a, false, log);
> +}
You can move the key parsing block from _parse_vlan_from_nlattrs()
here and move mask block in function bellow and get ride of
_parse_vlan_from_nlattrs() function.

> +
> +static int parse_vlan_mask_from_nlattrs(const struct nlattr *nla,
> +                                       struct sw_flow_match *match,
> +                                       u64 *key_attrs,
> +                                       const struct nlattr **a,
> +                                       bool log)
> +{
> +       return _parse_vlan_from_nlattrs(nla, match, key_attrs, a, true, log);
> +}
> +
>  /**
