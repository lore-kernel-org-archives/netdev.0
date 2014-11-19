From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix mask generation for IPv6 labels.
Date: Tue, 18 Nov 2014 22:09:42 -0800
Message-ID: <CALnjE+qrkw92tZ-wgpGOPtbuMJVVCfo--7w6PAGO6OW4skiGQQ@mail.gmail.com>
References: <1416336857-61405-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:42871 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753833AbaKSGJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 01:09:48 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so415871igd.13
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 22:09:42 -0800 (PST)
In-Reply-To: <1416336857-61405-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 10:54 AM, Joe Stringer <joestringer@nicira.com> wrote:
> When userspace doesn't provide a mask, OVS datapath generates a fully
> unwildcarded mask for the flow. This is done by taking a copy of the
> flow key, then iterating across its attributes, setting all values to
> 0xff. This works for most attributes, as the length of the netlink
> attribute typically matches the length of the value. However, IPv6
> labels only use the lower 20 bits of the field. This patch makes a
> special case to handle this.
>
> This fixes the following error seen when installing IPv6 flows without a mask:
>
> openvswitch: netlink: Invalid IPv6 flow label value (value=ffffffff, max=fffff)
>
We should allow exact match mask here rather than generating
wildcarded mask. So that ovs can catch invalid ipv6.label.


> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  net/openvswitch/flow_netlink.c |   22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index fa4ec2e..7a5b28f 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -825,7 +825,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
>         return 0;
>  }
>
> -static void nlattr_set(struct nlattr *attr, u8 val, bool is_attr_mask_key)
> +static void mask_set_nlattr(struct nlattr *attr)
>  {
>         struct nlattr *nla;
>         int rem;
> @@ -835,16 +835,18 @@ static void nlattr_set(struct nlattr *attr, u8 val, bool is_attr_mask_key)
>                 /* We assume that ovs_key_lens[type] == -1 means that type is a
>                  * nested attribute
>                  */
> -               if (is_attr_mask_key && ovs_key_lens[nla_type(nla)] == -1)
> -                       nlattr_set(nla, val, false);
> +               if (ovs_key_lens[nla_type(nla)] == -1)
> +                       nla_for_each_nested(nla, attr, rem)
> +                               memset(nla_data(nla), 0xff, nla_len(nla));
>                 else
> -                       memset(nla_data(nla), val, nla_len(nla));
> -       }
> -}
> +                       memset(nla_data(nla), 0xff, nla_len(nla));
>
> -static void mask_set_nlattr(struct nlattr *attr, u8 val)
> -{
> -       nlattr_set(attr, val, true);
> +               if (nla_type(nla) == OVS_KEY_ATTR_IPV6) {
> +                       struct ovs_key_ipv6 *ipv6_key = nla_data(nla);
> +
> +                       ipv6_key->ipv6_label &= htonl(0x000FFFFF);
> +               }
> +       }
>  }
>
>  /**
> @@ -926,7 +928,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>                 if (!newmask)
>                         return -ENOMEM;
>
> -               mask_set_nlattr(newmask, 0xff);
> +               mask_set_nlattr(newmask);
>
>                 /* The userspace does not send tunnel attributes that are 0,
>                  * but we should not wildcard them nonetheless.
> --
> 1.7.10.4
>
