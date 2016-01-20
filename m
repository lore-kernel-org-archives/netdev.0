From: Tom Herbert <tom@herbertland.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Wed, 20 Jan 2016 15:27:38 -0800
Message-ID: <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<20160118.112455.212265265553435873.davem@davemloft.net>
	<CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	<1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:32775 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbcATX1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 18:27:39 -0500
Received: by mail-ig0-f175.google.com with SMTP id z14so112112791igp.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 15:27:39 -0800 (PST)
In-Reply-To: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 3:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-01-21 at 00:20 +0200, Or Gerlitz wrote:
>
>> Dave, I assume you refer to the RSS hash result which is written by
>> NIC HWs to the completion descriptor and then fed to the stack by the
>> driver calling skb_set_hash(.)? Well, this can be taken even further.
>>
>> Suppose a the NIC can be programmed by the kernel to provide a unique
>> flow tag on the completion descriptor per a given 5/12 tuple which
>> represents a TCP (or other logical) stream a higher level in the stack
>> is identifying to be in progress, and the driver plants that in
>> skb->mark before calling into the stack.
>>
>> I guess this could yield nice speed up for the GRO stack -- matching
>> based on single 32 bit value instead of per protocol (eth, vlan, ip,
>> tcp) checks [1] - or hint which packets from the current window of
>> "ready" completion descriptor could be grouped together for upper
>> processing?
>
> We already use the RSS hash (skb->hash) in GRO engine to speedup the
> parsing : If skb->hash differs, then there is no point trying to
> aggregate two packets.
>
> Note that if we had a l4 hash for all provided packets, GRO could use a
> hash table instead of one single list of skbs.
>
Besides that, GRO requires parsing the packet anyway so I don't see
much value in trying to optimize GRO by using the hash.

Unfortunately, the hardware hash from devices hasn't really lived up
to its potential. The original intent of getting the hash from device
was to be able to do packet steering (RPS and RFS) without touching
the header. But this never was implemented. eth_type_trans touches
headers and GRO is best when done before steering. Given the
weaknesses of Toeplitz we talked about recently and that fact that
Jenkins is really fast to compute, I am starting to think maybe we
should always do a software hash and not rely on HW for it...

>
>
