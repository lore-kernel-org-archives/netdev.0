From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V19 3/3] openvswitch: 802.1AD: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Sat, 31 Oct 2015 07:49:50 -0700
Message-ID: <CALnjE+r3fGttW5-Xy0PCo+TV6Rk0WTKoROoVqRF+ioUDpw=Eag@mail.gmail.com>
References: <1446224902-21246-1-git-send-email-thomasfherbert@gmail.com>
	<1446224902-21246-4-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Thomas F Herbert <therbert@redhat.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34762 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbJaOtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 10:49:51 -0400
Received: by igpw7 with SMTP id w7so26636879igp.1
        for <netdev@vger.kernel.org>; Sat, 31 Oct 2015 07:49:50 -0700 (PDT)
In-Reply-To: <1446224902-21246-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 10:08 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  net/openvswitch/actions.c      |   6 +-
>  net/openvswitch/flow.c         |  76 +++++++++----
>  net/openvswitch/flow.h         |   8 +-
>  net/openvswitch/flow_netlink.c | 235 +++++++++++++++++++++++++++++++----------
>  4 files changed, 251 insertions(+), 74 deletions(-)
>
...
...
> +
> +static int __parse_vlan_from_nlattrs(const struct nlattr **nla,
> +                                    struct sw_flow_match *match,
> +                                    u64 *key_attrs, bool inner,
> +                                    const struct nlattr **a, bool is_mask,
> +                                    bool log)
> +{
**nla is unused argument in this function.

> +       int err;
> +       u64 v_attrs = *key_attrs;
> +
> +       err = encode_vlan_from_nlattrs(match, a, is_mask, inner, log);
> +       if (err)
> +               return err;
> +
> +       v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +
> +       /* Insure that tci key attribute isn't
> +        * overwritten by encapsulated customer tci.
> +        * Ethertype is cleared because it is c_tpid.
> +        */
> +       v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +       v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +
> +       *key_attrs = v_attrs;
> +
> +       return 0;
> +}
> +
> +static int parse_vlan_from_nlattrs(const struct nlattr **nla,
> +                                  struct sw_flow_match *match,
> +                                  u64 *key_attrs, bool *ie_valid,
> +                                  const struct nlattr **a, bool is_mask,
> +                                  bool log)
> +{
encap passed by reference here, but caller does not make use of this,
So we can just pass pointer to encap.
> +       int err;
> +       const struct nlattr *encap;
> +       u64 v_attrs = 0;
> +
> +       if (!is_mask) {
> +               err = __parse_vlan_from_nlattrs(nla, match, key_attrs,
> +                                               false, a, is_mask, log);
> +               if (err)
> +                       return err;
> +
> +               /* Another encap attribute here indicates
> +                * the presence of a double tagged vlan.
> +                */
> +               encap = a[OVS_KEY_ATTR_ENCAP];
> +
> +               err = parse_flow_nlattrs(encap, a, &v_attrs, log);
> +               if (err)
> +                       return err;
> +
> +               if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
> +                   eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
> +                       if (!((v_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
> +                             (v_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
> +                               OVS_NLERR(log, "Invalid Inner VLAN frame");
> +                               return -EINVAL;
> +                       }
> +                       *ie_valid = true;
> +                       err = __parse_vlan_from_nlattrs(&encap, match, &v_attrs,
> +                                                       true, a, is_mask, log);

__parse_vlan_from_nlattrs() is not parsing inner encap nlattr in this
case. If we move above call to parse_flow_nlattrs() to
__parse_vlan_from_nlattrs() we can fix this issue.

> +                       if (err)
> +                               return err;
> +                       *key_attrs |= v_attrs;
> +               }
> +       } else {
> +               err = __parse_vlan_from_nlattrs(nla, match, key_attrs,
> +                                               false, a, is_mask, log);
> +               if (err)
> +                       return err;
> +
> +               encap = a[OVS_KEY_ATTR_ENCAP];
> +
> +               err = parse_flow_nlattrs(encap, a, &v_attrs, log);
> +               if (err)
> +                       return err;
> +
> +               if (v_attrs & (1 << OVS_KEY_ATTR_ENCAP)) {
> +                       if (!*ie_valid) {
> +                               OVS_NLERR(log, "Encap mask attribute is set for non-CVLAN frame.");
> +                               return -EINVAL;
> +                       }
> +                       err = __parse_vlan_from_nlattrs(nla, match,
> +                                                       &v_attrs, true, a,
> +                                                       is_mask,
> +                                                       log);
> +                       if (err)
> +                               return err;
> +                       *key_attrs |= v_attrs;
> +               }
> +       }
> +       return 0;
> +}
> +
