From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Tue, 26 Jan 2016 01:13:33 +0100
Message-ID: <56A6BA2D.2090604@iogearbox.net>
References: <2036003091.741801453376409338.JavaMail.weblogic@ep2mlwas01a>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"willemb@google.com" <willemb@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"eyal.birger@gmail.com" <eyal.birger@gmail.com>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>,
	"fruggeri@aristanetworks.com" <fruggeri@aristanetworks.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>,
	Geon-ho Kim <gh007.kim@samsung.com>,
	Hak-Bong Lee <hakbong5.lee@samsung.com>
To: maninder1.s@samsung.com, Vaneet Narang <v.narang@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32852 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbcAZANk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 19:13:40 -0500
In-Reply-To: <2036003091.741801453376409338.JavaMail.weblogic@ep2mlwas01a>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2016 12:40 PM, Maninder Singh wrote:
>> The other sock_put() in packet_release() to drop the final ref and call into
>> sk_free(), which drops the 1 ref on the sk_wmem_alloc from init time. Since you
>> got into __sk_free() via sock_wfree() destructor, your socket must have invoked
>> packet_release() prior to this (perhaps kernel destroying the process).
>>
>> What kernel do you use?
>
> Issue is coming for 3.10.58.

[ sorry for late reply ]

What driver are you using (is that in-tree)? Can you reproduce the same issue
with a latest -net kernel, for example (or, a 'reasonably' recent one like 4.3 or
4.4)? There has been quite a bit of changes in err queue handling (which also
accounts rmem) as well. How reliably can you trigger the issue? Does it trigger
with a completely different in-tree network driver as well with your tests? Would
be useful to track/debug sk_rmem_alloc increases/decreases to see from which path
new rmem is being charged in the time between packet_release() and packet_sock_destruct()
for that socket ...

>>> Driver calls dev_kfree_skb_any->dev_kfree_skb_irq
>>> and it adds buffer in completion queue to free and raises softirq NET_TX_SOFTIRQ
>>>
>>> net_tx_action->__kfree_skb->skb_release_all->skb_release_head_state->sock_wfree->
>>> __sk_free->packet_sock_destruct
>>>
>>> Also purging of receive queue has been taken care in other protocols.
