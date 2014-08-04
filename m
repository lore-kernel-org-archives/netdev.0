From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v3 4/4 RFC] pktgen: Allow sending IPv4 TCP packets
Date: Mon, 4 Aug 2014 14:32:45 +0100
Message-ID: <53DF8B7D.9010604@citrix.com>
References: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>	<1406737212-23351-5-git-send-email-zoltan.kiss@citrix.com> <20140731.213220.2290285957519220651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <steffen.klassert@secunet.com>, <minipli@googlemail.com>,
	<dborkman@redhat.com>, <tgraf@suug.ch>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140731.213220.2290285957519220651.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/08/14 05:32, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
>> @@ -3017,29 +3029,40 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>>   	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
>>
>>   	skb_set_transport_header(skb, skb->len);
>> -	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
>> +
>> +	if (pkt_dev->flags & F_TCP) {
>> +		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
>> +			  sizeof(struct tcphdr) - pkt_dev->pkt_overhead;
>> +		tcph = (struct tcphdr *)skb_put(skb, sizeof(struct tcphdr));
>> +		memset(tcph, 0, sizeof(*tcph));
>> +		tcph->source = htons(pkt_dev->cur_udp_src);
>> +		tcph->dest = htons(pkt_dev->cur_udp_dst);
>> +		tcph->doff = sizeof(struct tcphdr) >> 2;
>> +	} else {
>> +		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
>> +			  sizeof(struct udphdr) - pkt_dev->pkt_overhead;
>> +		udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
>> +		udph->source = htons(pkt_dev->cur_udp_src);
>> +		udph->dest = htons(pkt_dev->cur_udp_dst);
>> +		udph->len = htons(datalen + sizeof(struct udphdr));
>> +		udph->check = 0;
>> +	}
>> +
>
> As more protocols (SCTP, etc.) get supported, this is going to become
> completely unmanageable.  Please use callbacks or something like that
> so this function doesn't turn into even more spaghetti.
OK

>
>> +	} else if (pkt_dev->flags & F_TCP) {
>> +		struct inet_sock inet;
>> +
>> +		inet.inet_saddr = iph->saddr;
>> +		inet.inet_daddr = iph->daddr;
>> +		skb->ip_summed = CHECKSUM_NONE;
>> +		tcp_v4_send_check((struct sock *)&inet, skb);
>
> Please don't do things like this.  Making fake sockets on the stack, don't
> do it.
>
> Do other non-socket contexts compute TCP checksums this way?  Check
> netfilter or similar, see what they do.
>
> Worst case export __tcp_v4_send_check() or just duplicate it's contents
> in the tcp case here.
Indeed, it was a quick and dirty solution. I'll duplicate the relevant 
bits __tcp_v4_send_check
