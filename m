From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 1/2] bpf: add a longest prefix match trie map
 implementation
Date: Sat, 14 Jan 2017 08:55:54 -0800
Message-ID: <587A581A.6060304@fb.com>
References: <20170114121727.14784-1-daniel@zonque.org>
 <20170114121727.14784-2-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dh.herrmann@gmail.com>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57233 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751394AbdANQ4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 11:56:14 -0500
In-Reply-To: <20170114121727.14784-2-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/17 4:17 AM, Daniel Mack wrote:
> +static struct bpf_map *trie_alloc(union bpf_attr *attr)
> +{
> +	size_t cost, cost_per_node;
> +	struct lpm_trie *trie;
> +	int ret;
> +
> +	/* check sanity of attributes */
> +	if (attr->max_entries == 0 ||
> +	    attr->map_flags != BPF_F_NO_PREALLOC ||
> +	    attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
> +	    attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
> +	    attr->value_size == 0)
> +		return ERR_PTR(-EINVAL);

could you also make it root only for now ?
Like we did for lru map:
         if (lru && !capable(CAP_SYS_ADMIN))
                 /* LRU implementation is much complicated than other
                  * maps.  Hence, limit to CAP_SYS_ADMIN for now.
                  */
                 return ERR_PTR(-EPERM);

trie is not that complicated, but I think socket_filters
(the only unpriv prog type today) can live a release or
two without ability to use it.

In patch 2/2 there are some comments not in networking style:
+	/*
+	 * Perform longest prefix-match on @key/@n_bits. That is,

As far as performance it has to be measured from datapath.
Like create tc+cls_bpf prog that does a dozen of trie lookups,
attach it to veth or tap and use
samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
to send traffic into it.
Like: samples/bpf/test_cls_bpf.sh does.

Another alternative is to extend samples/bpf/map_perf_test
It has perf tests for most map types today (including lru)
and trie would be natural addition there.
I would prefer this latter option.

Thanks!
