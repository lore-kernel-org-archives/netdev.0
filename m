From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix mask generation for nested attributes.
Date: Fri, 11 Sep 2015 09:04:21 -0700
Message-ID: <CALnjE+oAEk6J_NCq21QHXdX-y3kUxocuLgC8XAwWmpg+eyvHhg@mail.gmail.com>
References: <1441935378-19986-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34619 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbbIKQEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 12:04:23 -0400
Received: by igcpb10 with SMTP id pb10so48344468igc.1
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 09:04:22 -0700 (PDT)
In-Reply-To: <1441935378-19986-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 6:36 PM, Jesse Gross <jesse@nicira.com> wrote:
> Masks were added to OVS flows in a way that was backwards compatible
> with userspace programs that did not generate masks. As a result, it is
> possible that we may receive flows that do not have a mask and we need
> to synthesize one.
>
> Generating a mask requires iterating over attributes and descending into
> nested attributes. For each level we need to know the size to generate the
> correct mask. We do this with a linked table of attribute types.
>
> Although the logic to handle these nested attributes was there in concept,
> there are a number of bugs in practice. Examples include incomplete links
> between tables, variable length attributes being treated as nested and
> missing sanity checks.
>
Missing Fixes tag.

> Signed-off-by: Jesse Gross <jesse@nicira.com>

This patch adds white space space errors.

./scripts/checkpatch.pl
0001-openvswitch-Fix-mask-generation-for-nested-attribute.patch
....
....
total: 15 errors, 19 warnings, 0 checks, 130 lines checked

> ---
>  net/openvswitch/flow_netlink.c | 71 +++++++++++++++++++++++++++++-------------
>  1 file changed, 50 insertions(+), 21 deletions(-)
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c92d6a2..83a6847 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -57,6 +57,7 @@ struct ovs_len_tbl {
>  };
>

...
>         unsigned long opt_key_offset;
>         struct vxlan_metadata opts;
> -       int err;
>
>         BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
>
> -       err = nla_parse_nested(tb, OVS_VXLAN_EXT_MAX, a, vxlan_opt_policy);
> -       if (err < 0)
> -               return err;
> -
>         memset(&opts, 0, sizeof(opts));
> +       nla_for_each_nested(a, attr, rem) {
> +               int type = nla_type(a);
>
> -       if (tb[OVS_VXLAN_EXT_GBP])
> -               opts.gbp = nla_get_u32(tb[OVS_VXLAN_EXT_GBP]);
> +               if (type > OVS_VXLAN_EXT_MAX) {
> +                        OVS_NLERR(log, "VXLAN extension %d out of range max %d",
> +                                  type, OVS_VXLAN_EXT_MAX);
> +                        return -EINVAL;
> +                }
> +
> +                if (ovs_vxlan_ext_key_lens[type].len != nla_len(a) &&
> +                    !(ovs_vxlan_ext_key_lens[type].len == OVS_ATTR_NESTED ||
> +                      ovs_vxlan_ext_key_lens[type].len == OVS_ATTR_VARIABLE)) {

ovs_vxlan_ext_key_lens types is never set to nested or variable len.
so this would not true.

> +                        OVS_NLERR(log, "VXLAN extension %d has unexpected len %d expected %d",
> +                                  type, nla_len(a), ovs_vxlan_ext_key_lens[type].len);
> +                        return -EINVAL;
> +                }
> +
> +                switch (type) {
> +               case OVS_VXLAN_EXT_GBP:
> +                       opts.gbp = nla_get_u32(a);
> +                       break;
> +               default:
> +                        OVS_NLERR(log, "Unknown VXLAN extension attribute %d",
> +                                  type);
> +                        return -EINVAL;
> +               }
> +       }

Need to check for remaining bytes in this attribute.

>
>         if (!is_mask)
>                 SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), false);
> @@ -529,7 +553,8 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
>                 }
>
>                 if (ovs_tunnel_key_lens[type].len != nla_len(a) &&
> -                   ovs_tunnel_key_lens[type].len != OVS_ATTR_NESTED) {
> +                   !(ovs_tunnel_key_lens[type].len == OVS_ATTR_NESTED ||
> +                     ovs_tunnel_key_lens[type].len == OVS_ATTR_VARIABLE)) {
>                         OVS_NLERR(log, "Tunnel attr %d has unexpected len %d expected %d",
>                                   type, nla_len(a), ovs_tunnel_key_lens[type].len);
>                         return -EINVAL;
> @@ -1052,10 +1077,13 @@ static void nlattr_set(struct nlattr *attr, u8 val,
>
>         /* The nlattr stream should already have been validated */
>         nla_for_each_nested(nla, attr, rem) {
> -               if (tbl && tbl[nla_type(nla)].len == OVS_ATTR_NESTED)
> -                       nlattr_set(nla, val, tbl[nla_type(nla)].next);
> -               else
> +               if (tbl[nla_type(nla)].len == OVS_ATTR_NESTED) {
> +                       if (tbl[nla_type(nla)].next)
> +                               tbl = tbl[nla_type(nla)].next;
> +                       nlattr_set(nla, val, tbl);
> +               } else {
>                         memset(nla_data(nla), val, nla_len(nla));
> +               }
>         }
>  }
>
> @@ -1923,7 +1951,8 @@ static int validate_set(const struct nlattr *a,
>
>         if (key_type > OVS_KEY_ATTR_MAX ||
>             (ovs_key_lens[key_type].len != key_len &&
> -            ovs_key_lens[key_type].len != OVS_ATTR_NESTED))
> +            !(ovs_key_lens[key_type].len == OVS_ATTR_NESTED ||
> +              ovs_key_lens[key_type].len == OVS_ATTR_VARIABLE)))

Same check are done multiple times, It would be nice if we add helper
function for this.
