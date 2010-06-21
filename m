From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Mon, 21 Jun 2010 20:57:52 +0100
Message-ID: <1277150272.2100.47.camel@achroite.uk.solarflarecom.com>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, davem@davemloft.net, netdev@vger.kernel.org,
	gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49506 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab0FUT55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 15:57:57 -0400
In-Reply-To: <20100204075101.16661.95658.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-03 at 23:51 -0800, Jeff Kirsher wrote:
> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> Program underlying ethernet devices with n-tuple flow classification
> filters.
> 
> This also adds a new flag to ethtool_flags, allowing n-tuple
> programming to be toggled using the set_flags call.

I just noticed a problem with the implementation which makes me wonder
whether this was tested at all:

[...]
> +static struct cmdline_info cmdline_ntuple[] = {
> +	{ "src-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
> +	{ "src-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
> +	{ "dst-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
> +	{ "dst-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
> +	{ "src-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
> +	{ "src-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
> +	{ "dst-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
> +	{ "dst-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL },
> +	{ "vlan", CMDL_INT, &ntuple_fs.vlan_tag, NULL },
> +	{ "vlan-mask", CMDL_UINT, &ntuple_fs.vlan_tag_mask, NULL },
> +	{ "user-def", CMDL_INT, &ntuple_fs.data, NULL },
> +	{ "user-def-mask", CMDL_UINT, &ntuple_fs.data_mask, NULL },
> +	{ "action", CMDL_INT, &ntuple_fs.action, NULL },
> +};
[...]
> +                       if (mode == MODE_SNTUPLE) {
> +                               if (!strcmp(argp[i], "flow-type")) {
> +                                       i += 1;
> +                                       if (i >= argc) {
> +                                               show_usage(1);
> +                                               break;
> +                                       }
> +                                       ntuple_fs.flow_type =
> +                                                   rxflow_str_to_type(argp[i]);
> +                                       i += 1;
> +                                       parse_generic_cmdline(argc, argp, i,
> +                                               &sntuple_changed,
> +                                               cmdline_ntuple,
> +                                               ARRAY_SIZE(cmdline_ntuple));
> +                                       i = argc;
> +                                       break;
> +                               } else {
> +                                       show_usage(1);
> +                               }
> +                               break;
> +                       }
[...]

parse_generic_cmdline() will write an int for each argument defined with
type CMDL_INT or CMDL_UINT.  But the fields in ntuple_fs are not all of
type int (or even 32-bit) - some of them are 16-bit or 64-bit, and some
of them are big-endian.  I also wonder whether anyone really wants to
enter an IPv4 address as a single integer.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

