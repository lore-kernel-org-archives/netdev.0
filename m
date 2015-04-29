From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] netif_receive_skb performance
Date: Wed, 29 Apr 2015 15:15:22 -0700
Message-ID: <554157FA.404@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com> <1430284980.3711.38.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35680 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbbD2WPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:15:25 -0400
Received: by igbyr2 with SMTP id yr2so132426235igb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:15:25 -0700 (PDT)
In-Reply-To: <1430284980.3711.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/15 10:23 PM, Eric Dumazet wrote:
> On Tue, 2015-04-28 at 19:11 -0700, Alexei Starovoitov wrote:
>> Hi,
>>
>> there were many requests for performance numbers in the past, but not
>> everyone has access to 10/40G nics and we need a common way to talk
>> about RX path performance without overhead of driver RX. That's
>> especially important when making changes to netif_receive_skb.
>
> Well, in real life, having to fetch RX descriptor and packet headers are
> the main cost, and skb->users == 1.

yes. you're describing the main cost of overall RX including drivers.
This pktgen rx mode is aiming to benchmark RX _after_ drivers.
I'm assuming driver vendors equally care a lot about performance of
their bits.

> So its nice trying to optimize netif_receive_skb(), but make sure you
> have something that can really exercise same code flows/stalls,
> otherwise you'll be tempted by wrong optimizations.
>
> I would for example use a ring buffer, so that each skb you provide to
> netif_receive_skb() has cold cache lines (at least skb->head if you want
> to mimic build_skb() or napi_get_frags()/napi_reuse_skb() behavior)

agree as well, but cache cold benchmarking is not a substitute for
cache hot. Both are valuable and numbers from both shouldn't be blindly
used to make decisions.
This pktgen rx mode simulates copybreak and/or small packets when
skb->data/head/... pointers and packet data itself is cache hot,
since driver's copybreak logic just touched it.
The ring-buffer approach with cold skbs is useful as well, but it will
benchmark different codepath through netif_receive_skb.
I think at the end we need both. This patch tackles simple case first.

> Also, this model of flooding one cpu (no irqs, no context switch) mask
> latencies caused by code size, since icache is fully populated, with a
> very specialized working set.
>
> If we want to pursue this model (like user space (DPDK and alike
> frameworks)), we might have to design a very different model than the
> IRQ driven one, by dedicating one or multiple cpu threads to run
> networking code with no state transition.

well, that's very different discussion. I would like to see this type
of model implemented in kernel, where we can dedicate a core for
network only processing. Though I think irq+napi are good enough for
doing batch processing of a lot of packets. My numbers show
that netif_receive_skb+ingress_qdisc+cls/act can do tens of millions
packet per second. imo that's a great base. We need skb alloc/free
and driver RX path to catch up. TX is already in good shape. Then
overall we'll have very capable packet processing machine from
one physical interface into another.
