From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next 4/4] bpf: xdp: Add XDP example for head
 adjustment
Date: Wed, 7 Dec 2016 11:34:24 +0100
Message-ID: <20161207113424.4e6fe238@redhat.com>
References: <1481088714-54512-1-git-send-email-kafai@fb.com>
        <1481088714-54512-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>, brouer@redhat.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751704AbcLGKeq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 05:34:46 -0500
In-Reply-To: <1481088714-54512-5-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Dec 2016 21:31:54 -0800
Martin KaFai Lau <kafai@fb.com> wrote:

> The XDP prog checks if the incoming packet matches any VIP:PORT
> combination in the BPF hashmap.  If it is, it will encapsulate
> the packet with a IPv4/v6 header as instructed by the value of
> the BPF hashmap and then XDP_TX it out.
> 
> The VIP:PORT -> IP-Encap-Info can be specified by the cmd args
> of the user prog.
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>  samples/bpf/Makefile              |   4 +
>  samples/bpf/bpf_helpers.h         |   2 +
>  samples/bpf/bpf_load.c            |  94 ++++++++++++++
>  samples/bpf/bpf_load.h            |   1 +
>  samples/bpf/xdp1_user.c           |  93 --------------
>  samples/bpf/xdp_tx_iptnl_common.h |  37 ++++++
>  samples/bpf/xdp_tx_iptnl_kern.c   | 232 ++++++++++++++++++++++++++++++++++
>  samples/bpf/xdp_tx_iptnl_user.c   | 253 ++++++++++++++++++++++++++++++++++++++

I got confused by the file name "iptnl", I didn't realize this was
short for iptunnel, before after reading the actually XDP program code.

These are "samples" XDP programs that normal people are expected to
find/discover, could we name it "xdp_tx_tunnel" or "xdp_tx_iptunnel"?
(To guide peoples search for this)

I will likely add a "xdp_tx_vlan" example as I have a customer use-case
that needs this for DDoS scrubbing[1]

[1] http://prototype-kernel.readthedocs.io/en/latest/networking/XDP/use-cases/xdp_use_case_ddos_scrubber.html#forward-clean-traffic

[...]
> diff --git a/samples/bpf/xdp_tx_iptnl_kern.c b/samples/bpf/xdp_tx_iptnl_kern.c
> new file mode 100644
> index 000000000000..d88c064175aa
> --- /dev/null
> +++ b/samples/bpf/xdp_tx_iptnl_kern.c
> @@ -0,0 +1,232 @@
> +/* Copyright (c) 2016 Facebook
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.

Can we add short description of the program, to let readers know if
this is the sample they are looking for. Max 3 lines, like:

 This program demonstrate how XDP does packet header adjustment, here
 by adding an encapsulation tunnel header based on a BPF hashmap.

> + */
> +#include <uapi/linux/bpf.h>
> +#include <linux/in.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_packet.h>
> +#include <linux/if_vlan.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include "bpf_helpers.h"
> +#include "xdp_tx_iptnl_common.h"
> +
> +struct bpf_map_def SEC("maps") rxcnt = {
> +	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
> +	.key_size = sizeof(__u32),
> +	.value_size = sizeof(__u64),
> +	.max_entries = 256,
> +};
> +
> +struct bpf_map_def SEC("maps") vip2tnl = {
> +	.type = BPF_MAP_TYPE_HASH,
> +	.key_size = sizeof(struct vip),
> +	.value_size = sizeof(struct iptnl_info),
> +	.max_entries = MAX_IPTNL_ENTRIES,
> +};

[...]

> diff --git a/samples/bpf/xdp_tx_iptnl_user.c b/samples/bpf/xdp_tx_iptnl_user.c
> new file mode 100644
> index 000000000000..9aeef7579af4
> --- /dev/null
> +++ b/samples/bpf/xdp_tx_iptnl_user.c
> @@ -0,0 +1,253 @@
> +/* Copyright (c) 2016 Facebook
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
[...]
> +
> +static void usage(const char *cmd)
> +{

Wondering if there should be a descriptive header, that says e.g. 
"XDP tunnel sample" or if command filename "xdp_tx_iptunnel" or
"xdp_tx_tunnel" would be descriptive enough.


> +	printf("Usage: %s [...]\n", cmd);
> +	printf("    -i <ifindex> Interface Index\n");
> +	printf("    -a <vip-service-address> IPv4 or IPv6\n");
> +	printf("    -p <vip-service-port> A port range (e.g. 433-444) is also allowed\n");
> +	printf("    -s <source-ip> Used in the IPTunnel Header\n");
> +	printf("    -d <dest-ip> Used in the IPTunnel header>\n");
> +	printf("    -m <dest-MAC> Used in sending the IP Tunneled pkt>\n");
> +	printf("    -T <stop-after-X-seconds> Default: 0 (forever)\n");
> +	printf("    -P <IP-Protocol> Default is TCP\n");
> +	printf("    -h Display this help\n");
> +}

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
