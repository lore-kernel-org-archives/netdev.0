From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] ebpf: add skb->hash to offset map for usage
 in {cls,act}_bpf or filters
Date: Mon, 03 Aug 2015 14:49:14 +0200
Message-ID: <55BF634A.10400@iogearbox.net>
References: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net> <CALx6S35Xw-14Z8=w2cg7dFFzfkEmkjuqU=37uG3Tb-OoW2JEoA@mail.gmail.com> <55BF072C.3000302@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37652 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbHCMtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 08:49:18 -0400
In-Reply-To: <55BF072C.3000302@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2015 08:16 AM, Alexei Starovoitov wrote:
> On 8/2/15 6:09 PM, Tom Herbert wrote:
>>> I was thinking whether to add skb_get_hash(), but then concluded the
>>> >raw skb->hash seems fine in this case: we can directly access the hash
>>> >w/o extra eBPF helper function call, it's filled out by many NICs on
>>> >ingress, and in case the entropy level would not be sufficient, people
>>> >can still implement their own specific sw fallback hash mix anyway.
>>> >
>> Maybe we should add the skb_get_hash also? It doesn't as useful if
>> some scenarios we get a valid hash and in others not.
>
> we also discussed whether it makes sense to expose l4_hash and sw_hash
> bits as well. imo, seems a bit of overkill, since such call into sw hash
> function like this exposes the logic of flow_dissector looking into
> inner header. There are pros and cons. I think if we expose
> flow_dissector it's cleaner to do it directly (instead of skb_get_hash).
> Alternatively we can obfuscate skb_get_hash by calling it
> 'please compute some a hash on a packet somehow', but that will be
> awkward to use. The programs can compute whatever hash they like anyway.

I don't have a particularly strong opinion if you want to expose skb_get_hash()
to eBPF as well as a helper function (note, it will add a function call as
extra cost each time), but as Alexei says, there are pros and cons on either
way. We just have to be careful as what this is being advertised to uapi, so
we can reserve ourselves changes in future. I would definitely avoid to expose
l4_hash and sw_hash, though, as that should really remain an implementation
detail inside the kernel, and flow dissector for your own hash function you
could actually already code up for your specific use case in eBPF, hm.
