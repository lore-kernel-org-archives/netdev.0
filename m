From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Thu, 21 Jan 2016 00:20:24 +0200
Message-ID: <CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<20160118.112455.212265265553435873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33387 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbcATWUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 17:20:25 -0500
Received: by mail-ig0-f182.google.com with SMTP id z14so111104476igp.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 14:20:25 -0800 (PST)
In-Reply-To: <20160118.112455.212265265553435873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2016 at 6:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Mon, 18 Jan 2016 11:27:03 +0100
>
>> Down in the driver layer (RX), I think it is too early to categorize
>> Related/Unrelated SKB's, because we want to delay touching packet-data
>> as long as possible (waiting for the prefetcher to get data into
>> cache).
>
> You don't need to touch the headers in order to have a good idea
> as to whether there is a strong possibility packets are related
> or not.
>
> We have the hash available.

Dave, I assume you refer to the RSS hash result which is written by
NIC HWs to the completion descriptor and then fed to the stack by the
driver calling skb_set_hash(.)? Well, this can be taken even further.

Suppose a the NIC can be programmed by the kernel to provide a unique
flow tag on the completion descriptor per a given 5/12 tuple which
represents a TCP (or other logical) stream a higher level in the stack
is identifying to be in progress, and the driver plants that in
skb->mark before calling into the stack.

I guess this could yield nice speed up for the GRO stack -- matching
based on single 32 bit value instead of per protocol (eth, vlan, ip,
tcp) checks [1] - or hint which packets from the current window of
"ready" completion descriptor could be grouped together for upper
processing?

Or.

[1] some details to complete (...) here, on the last protocol hop we
do need to verify that it would be correct to stick the incoming
packet to the existing pending packet of this stream
