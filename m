From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2] xdp: Sample xdp program implementing ip forward
Date: Tue, 10 Oct 2017 21:06:07 +0200
Message-ID: <20171010210607.2af452e2@redhat.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
        <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Sunil.Goutham@cavium.com,
        daniel@iogearbox.net, dsahern@gmail.com,
        Christina Jacob <Christina.Jacob@cavium.com>, brouer@redhat.com
To: Christina Jacob <christina.jacob.koikara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Oct 2017 12:58:52 +0530
Christina Jacob <christina.jacob.koikara@gmail.com> wrote:

> +SEC("xdp3")
> +int xdp_prog3(struct xdp_md *ctx)
> +{
> +	void *data_end = (void *)(long)ctx->data_end;
> +	void *data = (void *)(long)ctx->data;
> +	struct ethhdr *eth = data;
> +	int rc = XDP_DROP, forward_to;
> +	long *value;
> +	struct trie_value *prefix_value;
> +	long *dest_mac = NULL, *src_mac = NULL;
> +	u16 h_proto;
> +	u64 nh_off;
> +	u32 ipproto;
> +	union key_4 key4;

Reverse-xmas tree rule: Prefer ordering declarations longest to shortest.


[...]
> +	if (h_proto == htons(ETH_P_ARP)) {
> +		return XDP_PASS;
> +	} else if (h_proto == htons(ETH_P_IP)) {
> +		int src_ip = 0, dest_ip = 0;
> +		struct direct_map *direct_entry;
> +
> +		ipproto = parse_ipv4(data, nh_off, data_end, &src_ip, &dest_ip);
> +		direct_entry = (struct direct_map *)bpf_map_lookup_elem
> +			(&exact_match, &dest_ip);
> +		/*check for exact match, this would give a faster lookup*/
> +		if (direct_entry && direct_entry->mac && direct_entry->arp.mac) {
> +			src_mac = &direct_entry->mac;
> +			dest_mac = &direct_entry->arp.mac;
> +			forward_to = direct_entry->ifindex;
> +		} else {
> +			/*Look up in the trie for lpm*/
> +			key4.b32[0] = 32;
> +			key4.b8[4] = dest_ip % 0x100;
> +			key4.b8[5] = (dest_ip >> 8) % 0x100;
> +			key4.b8[6] = (dest_ip >> 16) % 0x100;
> +			key4.b8[7] = (dest_ip >> 24) % 0x100;
> +			prefix_value = ((struct trie_value *)bpf_map_lookup_elem
> +					(&lpm_map, &key4));
> +			if (!prefix_value) {
> +				return XDP_DROP;
> +			} else {
> +				src_mac = &prefix_value->value;
> +				if (src_mac) {
> +					dest_mac = (long *)bpf_map_lookup_elem
> +						(&arp_table, &dest_ip);
> +					if (!dest_mac) {
> +						if (prefix_value->gw) {
> +							dest_ip = *(__be32 *)&prefix_value->gw;
> +							dest_mac = (long *)bpf_map_lookup_elem(&arp_table, &dest_ip);
> +						} else {
> +							return XDP_DROP;
> +						}
> +					}
> +					forward_to = prefix_value->ifindex;
> +				} else {
> +					return XDP_DROP;
> +				}
> +			}
> +		}
> +	} else {
> +		ipproto = 0;
> +	}

The nesting in this function is getting annoying to read.
Kernel code often use "early return" style coding to solve this.

A quick search turns up this guide, look at section "Early return"
 https://en.wikibooks.org/wiki/Computer_Programming/Coding_Style/Minimize_nesting

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
