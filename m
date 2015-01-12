From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 6/6] openvswitch: Support VXLAN Group Policy extension
Date: Mon, 12 Jan 2015 13:54:55 -0800
Message-ID: <CAEP_g=8TnrwdGiTOB_mKeQSsEakV8y2OU7_ARwi+j9WDYh=Wag@mail.gmail.com>
References: <cover.1421064100.git.tgraf@suug.ch> <60651d9355f4e34ed6686d95ad837467a1d2c888.1421064100.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:36949 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751033AbbALVzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:55:16 -0500
Received: by mail-qa0-f50.google.com with SMTP id k15so7271864qaq.9
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:55:15 -0800 (PST)
In-Reply-To: <60651d9355f4e34ed6686d95ad837467a1d2c888.1421064100.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 457ccf3..cea492b 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> +static int vxlan_tun_opt_from_nlattr(const struct nlattr *a,
> +                                    struct sw_flow_match *match, bool is_mask,
> +                                    bool log)
> +{
> +       struct nlattr *tb[OVS_VXLAN_EXT_MAX+1];
> +       unsigned long opt_key_offset;
> +       struct ovs_vxlan_opts opts;
> +       int err;
> +
> +       BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
> +
> +       err = nla_parse_nested(tb, OVS_VXLAN_EXT_MAX, a, vxlan_opt_policy);
> +       if (err < 0)
> +               return err;
> +
> +       memset(&opts, 0, sizeof(opts));
> +
> +       if (tb[OVS_VXLAN_EXT_MAX])
> +               opts.gbp = nla_get_u32(tb[OVS_VXLAN_EXT_MAX]);

Shouldn't this be OVS_VXLAN_EXT_GBP instead of OVS_VXLAN_EXT_MAX?
(They have the same value.)

> +       if (!is_mask)
> +               SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), false);
> +       else
> +               SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff, true);

Have you thought carefully about how the masking model work as other
extensions are potentially added? This was a little tricky with Geneve
because I wanted to be able to match on both "no options present" as
well as wildcard all options. The other interesting thing is how you
serialize them back correctly to userspace, which was the genesis of
the TUNNEL_OPTIONS_PRESENT flag.

My guess is that this may basically work fine now that there is only
one extension present but it is important to think about how it might
work with multiple independent extensions in the future. (I haven't
thought about it, I'm just asking.)

> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> index 266c595..dbd6c75 100644
> --- a/net/openvswitch/vport-vxlan.c
> +++ b/net/openvswitch/vport-vxlan.c
> +static int vxlan_ext_gbp(struct sk_buff *skb)
> +{
> +       const struct ovs_tunnel_info *tun_info;
> +       const struct ovs_vxlan_opts *opts;
> +
> +       tun_info = OVS_CB(skb)->egress_tun_info;
> +       opts = tun_info->options;
> +
> +       if (tun_info->options_len >= sizeof(*opts))
> +               return opts->gbp;
> +       else
> +               return 0;
> +}

If you set Geneve options and output to a VXLAN port (or vice versa),
you will get garbage, right? Is there any way that we can sanity check
that?
