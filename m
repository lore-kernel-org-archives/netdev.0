From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v1 04/11] rocker: add pipeline model for rocker switch
Date: Sun, 4 Jan 2015 10:43:05 +0200
Message-ID: <CAJ3xEMitO-e4gRXAzp7F5F+1+Sq9+K8qQgTjEywA-FbX34bZ+g@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
	<20141231194709.31070.16657.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:49704 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbADInH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 03:43:07 -0500
Received: by mail-oi0-f43.google.com with SMTP id i138so39998779oig.2
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 00:43:05 -0800 (PST)
In-Reply-To: <20141231194709.31070.16657.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 9:47 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This adds rocker support for the net_flow_get_* operations. With this
> we can interrogate rocker.
>
> Here we see that for static configurations enabling the get operations
> is simply a matter of defining a pipeline model and returning the
> structures for the core infrastructure to encapsulate into netlink
> messages.

[..]

> diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
> new file mode 100644
> index 0000000..9544339
> --- /dev/null
> +++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
> @@ -0,0 +1,673 @@
> +#ifndef _MY_PIPELINE_H_
> +#define _MY_PIPELINE_H_
> +
> +#include <linux/if_flow.h>
> +
> +/* header definition */
> +#define HEADER_ETHERNET_SRC_MAC 1
> +#define HEADER_ETHERNET_DST_MAC 2
> +#define HEADER_ETHERNET_ETHERTYPE 3
> +struct net_flow_field ethernet_fields[3] = {
> +       { .name = "src_mac", .uid = HEADER_ETHERNET_SRC_MAC, .bitwidth = 48},
> +       { .name = "dst_mac", .uid = HEADER_ETHERNET_DST_MAC, .bitwidth = 48},
> +       { .name = "ethertype",
> +         .uid = HEADER_ETHERNET_ETHERTYPE,
> +         .bitwidth = 16},
> +};
> +
> +#define HEADER_ETHERNET 1
> +struct net_flow_header ethernet = {
> +       .name = "ethernet",
> +       .uid = HEADER_ETHERNET,
> +       .field_sz = 3,
> +       .fields = ethernet_fields,
> +};
> +
> +#define HEADER_VLAN_PCP 1
> +#define HEADER_VLAN_CFI 2
> +#define HEADER_VLAN_VID 3
> +#define HEADER_VLAN_ETHERTYPE 4
> +struct net_flow_field vlan_fields[4] = {
> +       { .name = "pcp", .uid = HEADER_VLAN_PCP, .bitwidth = 3,},
> +       { .name = "cfi", .uid = HEADER_VLAN_CFI, .bitwidth = 1,},
> +       { .name = "vid", .uid = HEADER_VLAN_VID, .bitwidth = 12,},
> +       { .name = "ethertype", .uid = HEADER_VLAN_ETHERTYPE, .bitwidth = 16,},
> +};
> +
> +#define HEADER_VLAN 2
> +struct net_flow_header vlan = {
> +       .name = "vlan",
> +       .uid = HEADER_VLAN,
> +       .field_sz = 4,
> +       .fields = vlan_fields,
> +};
> +
> +#define HEADER_IPV4_VERSION 1
> +#define HEADER_IPV4_IHL 2
> +#define HEADER_IPV4_DSCP 3
> +#define HEADER_IPV4_ECN 4
> +#define HEADER_IPV4_LENGTH 5
> +#define HEADER_IPV4_IDENTIFICATION 6
> +#define HEADER_IPV4_FLAGS 7
> +#define HEADER_IPV4_FRAGMENT_OFFSET 8
> +#define HEADER_IPV4_TTL 9
> +#define HEADER_IPV4_PROTOCOL 10
> +#define HEADER_IPV4_CSUM 11
> +#define HEADER_IPV4_SRC_IP 12
> +#define HEADER_IPV4_DST_IP 13
> +#define HEADER_IPV4_OPTIONS 14
> +struct net_flow_field ipv4_fields[14] = {
> +       { .name = "version",
> +         .uid = HEADER_IPV4_VERSION,
> +         .bitwidth = 4,},
> +       { .name = "ihl",
> +         .uid = HEADER_IPV4_IHL,
> +         .bitwidth = 4,},
> +       { .name = "dscp",
> +         .uid = HEADER_IPV4_DSCP,
> +         .bitwidth = 6,},
> +       { .name = "ecn",
> +         .uid = HEADER_IPV4_ECN,
> +         .bitwidth = 2,},
> +       { .name = "length",
> +         .uid = HEADER_IPV4_LENGTH,
> +         .bitwidth = 8,},
> +       { .name = "identification",
> +         .uid = HEADER_IPV4_IDENTIFICATION,
> +         .bitwidth = 8,},
> +       { .name = "flags",
> +         .uid = HEADER_IPV4_FLAGS,
> +         .bitwidth = 3,},
> +       { .name = "fragment_offset",
> +         .uid = HEADER_IPV4_FRAGMENT_OFFSET,
> +         .bitwidth = 13,},
> +       { .name = "ttl",
> +         .uid = HEADER_IPV4_TTL,
> +         .bitwidth = 1,},
> +       { .name = "protocol",
> +         .uid = HEADER_IPV4_PROTOCOL,
> +         .bitwidth = 8,},
> +       { .name = "csum",
> +         .uid = HEADER_IPV4_CSUM,
> +         .bitwidth = 8,},
> +       { .name = "src_ip",
> +         .uid = HEADER_IPV4_SRC_IP,
> +         .bitwidth = 32,},
> +       { .name = "dst_ip",
> +         .uid = HEADER_IPV4_DST_IP,
> +         .bitwidth = 32,},
> +       { .name = "options",
> +         .uid = HEADER_IPV4_OPTIONS,
> +         .bitwidth = -1,},
> +};
> +

John,

Repeating the feedback I provided you f2f in Dusseldorf when the WIP
code was within ixgbe, some/many code pieces in this patch (e.g the
above) are generic and hence should reside not within a low level
driver such as rocker, and also on a separate patch.

Or.
