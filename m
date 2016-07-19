From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and rewrite
Date: Tue, 19 Jul 2016 15:05:37 -0700
Message-ID: <20160719220536.GH64618@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-13-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36028 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbcGSWFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 18:05:42 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so2098414pfg.3
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 15:05:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468955817-10604-13-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 12:16:57PM -0700, Brenden Blanco wrote:
> Add a sample that rewrites and forwards packets out on the same
> interface. Observed single core forwarding performance of ~10Mpps.
> 
> Since the mlx4 driver under test recycles every single packet page, the
> perf output shows almost exclusively just the ring management and bpf
> program work. Slowdowns are likely occurring due to cache misses.

long term we need to resurrect your prefetch patch. sux to leave
so much performance on the table.

> +static int parse_ipv4(void *data, u64 nh_off, void *data_end)
> +{
> +	struct iphdr *iph = data + nh_off;
> +
> +	if (iph + 1 > data_end)
> +		return 0;
> +	return iph->protocol;
> +}
> +
> +static int parse_ipv6(void *data, u64 nh_off, void *data_end)
> +{
> +	struct ipv6hdr *ip6h = data + nh_off;
> +
> +	if (ip6h + 1 > data_end)
> +		return 0;
> +	return ip6h->nexthdr;
> +}
...
> +	if (h_proto == htons(ETH_P_IP))
> +		index = parse_ipv4(data, nh_off, data_end);
> +	else if (h_proto == htons(ETH_P_IPV6))
> +		index = parse_ipv6(data, nh_off, data_end);
> +	else
> +		index = 0;
> +
> +	value = bpf_map_lookup_elem(&dropcnt, &index);
> +	if (value)
> +		*value += 1;
> +
> +	if (index == 17) {

not an obvious xdp example. if you'd have to respin for other
reasons please consider 'proto' name and IPPROTO_UDP here.

Acked-by: Alexei Starovoitov <ast@kernel.org>
