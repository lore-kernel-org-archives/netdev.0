From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 5/6] openvswitch: Rename GENEVE_TUN_OPTS() to TUN_METADATA_OPTS()
Date: Wed, 7 Jan 2015 14:46:23 -0800
Message-ID: <CAEP_g=-X_S1qmMQt3VjOUT9+qUEnxeJxUSf-B90Yktns72zWaA@mail.gmail.com>
References: <cover.1420594925.git.tgraf@suug.ch> <10cbd42aca443d862b8b62017b5a4356326e026f.1420594925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:35723 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750942AbbAGWqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:46:44 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so1623805qcv.22
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 14:46:43 -0800 (PST)
In-Reply-To: <10cbd42aca443d862b8b62017b5a4356326e026f.1420594925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> A subsequent patch will introduce VXLAN options. Rename the existing
> GENEVE_TUN_OPTS() to reflect its extended purpose of carrying generic
> tunnel metadata options.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This is generally a good idea (even outside of the larger context of
this patch series) although a couple comments below:

> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index d1eecf7..c60ae3f 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -387,20 +387,20 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
>         return __parse_flow_nlattrs(attr, a, attrsp, log, false);
>  }
>
> -static int genev_tun_opt_from_nlattr(const struct nlattr *a,
> -                                    struct sw_flow_match *match, bool is_mask,
> -                                    bool log)
> +static int tun_md_opt_from_nlattr(const struct nlattr *a,
> +                                 struct sw_flow_match *match, bool is_mask,
> +                                 bool log)

I think this is a somewhat overzealous conversion. This function is
verifying OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS and as such has some
elements of Geneve protocol knowledge baked in (such as the check that
the options are a multiple of 4 bytes). It's also nice for the log
messages to indicate which netlink key is causing the problem and not
be too generic.

> @@ -1148,10 +1145,10 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
>                 goto nla_put_failure;
>
>         if ((swkey->tun_key.ipv4_dst || is_mask)) {
> -               const struct geneve_opt *opts = NULL;
> +               const void *opts = NULL;
>
>                 if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
> -                       opts = GENEVE_OPTS(output, swkey->tun_opts_len);
> +                       opts = TUN_METADATA_OPTS(output, swkey->tun_opts_len);
>
>                 if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
>                                        swkey->tun_opts_len))

I think it's probably better to factor this block of code out into a
new function as you have done in the next patch (and include it with
this one). It makes it clearer that it is Geneve-specific.
