From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 14:55:42 -0700
Message-ID: <5541535E.1060908@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>	 <1430273488-8403-2-git-send-email-ast@plumgrid.com> <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36693 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbD2Vzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 17:55:45 -0400
Received: by igblo3 with SMTP id lo3so130048737igb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 14:55:44 -0700 (PDT)
In-Reply-To: <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/15 9:14 PM, Eric Dumazet wrote:
> On Tue, 2015-04-28 at 19:11 -0700, Alexei Starovoitov wrote:
>
>> +	if (pkt_dev->flags & F_DO_RX) {
>> +		local_bh_disable();
>> +		atomic_add(burst, &pkt_dev->skb->users);
>> +		do {
>> +			ret = netif_receive_skb(pkt_dev->skb);
>> +			if (ret == NET_RX_DROP)
>> +				pkt_dev->errors++;
>> +			pkt_dev->last_ok = 1;
>> +			pkt_dev->sofar++;
>> +			pkt_dev->seq_num++;
>> +		} while (--burst > 0);
>> +		local_bh_enable();
>> +		goto out;
>> +	}
>> +
>
> This looks buggy.
>
> skb can be put on a queue, so skb->next and skb->prev cannot be reused,
> or queues will be corrupted.

don't see the bug yet.
Any layer that wants to do such queueing should do skb_share_check
first. Just like ip_rcv does. So everything in IP world should
work fine, because it will be operating on clean cloned skb.

> Note that on TX, it is possible to have the same issue if you use a
> virtual device like bonding, and skb is queued on a slave qdisc.
>
> (Thats why we have this IFF_TX_SKB_SHARING flag)

yep, that's why xmit into veth is not useful for benchmarking of rx,
since the hottest functions are alloc_skb and fill_packet, while
netif_receive_skb is not even seen in top 10.
