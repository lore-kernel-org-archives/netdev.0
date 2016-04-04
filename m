From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 04 Apr 2016 23:01:57 +0200
Message-ID: <5702D645.1090401@iogearbox.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com> <1459560118-5582-5-git-send-email-bblanco@plumgrid.com> <1459622455.18188.5.camel@sipsolutions.net> <20160403063834.GE21980@gmail.com> <1459755310.18188.13.camel@sipsolutions.net> <57023AA0.5080600@iogearbox.net> <20160404184619.GC68392@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com, ogerlitz@mellanox.com,
	john.fastabend@gmail.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55443 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbcDDVCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 17:02:06 -0400
In-Reply-To: <20160404184619.GC68392@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2016 08:46 PM, Alexei Starovoitov wrote:
> On Mon, Apr 04, 2016 at 11:57:52AM +0200, Daniel Borkmann wrote:
>> On 04/04/2016 09:35 AM, Johannes Berg wrote:
>>> On Sat, 2016-04-02 at 23:38 -0700, Brenden Blanco wrote:
>>>>
>>>> Having a common check makes sense. The tricky thing is that the type can
>>>> only be checked after taking the reference, and I wanted to keep the
>>>> scope of the prog brief in the case of errors. I would have to move the
>>>> bpf_prog_get logic into dev_change_bpf_fd and pass a bpf_prog * into the
>>>> ndo instead. Would that API look fine to you?
>>>
>>> I can't really comment, I wasn't planning on using the API right now :)
>>>
>>> However, what else is there that the driver could possibly do with the
>>> FD, other than getting the bpf_prog?
>>>
>>>> A possible extension of this is just to keep the bpf_prog * in the
>>>> netdev itself and expose a feature flag from the driver rather than
>>>> an ndo. But that would mean another 8 bytes in the netdev.
>>>
>>> That also misses the signal to the driver when the program is
>>> set/removed, so I don't think that works. I'd argue it's not really
>>> desirable anyway though since I wouldn't expect a majority of drivers
>>> to start supporting this.
>>
>> I think ndo is probably fine for this purpose, see also my other mail. I
>> think currently, the only really driver specific code would be to store
>> the prog pointer somewhere and to pass needed meta data to populate the
>> fake skb.
>
> yes. I think ndo is better and having bpf_prog in the driver priv
> part is likely better as well, since driver may decide to put it into
> their ring struct for faster fetch or layout prog pointer next to other
> priv fields for better cache.
> Having prog in 'struct net_device' may look very sensible right now,
> since there is not much code around it, but later it may be causing
> some performance headachces. I think it's better to have complete
> freedom in the drivers and later move code to generic part.
> Same applies to your other comment about moving mlx4_bpf_set() and
> mlx4_call_bpf() into generic. It's better for them to be driver
> specific in the moment. Right now we have only mlx4 anyway.

Sure, right now it's only mlx4, but we need to make sure that once this gets
adapted/extended by others, that we won't end up with programs that can only
be run by specific drivers e.g., due to meta data only available for this kind
of driver but not others supporting XDP. So, some form of generic part will
be needed in any case, also makes it easier for testing changes.

>> Maybe mid-term drivers might want to reuse this hook/signal for offloading
>> as well, not yet sure ... how would that relate to offloading of cls_bpf?
>> Should these be considered two different things (although from an offloading
>> perspective they are not really). _Conceptually_, XDP could also be seen
>> as a software offload for the facilities we support with cls_bpf et al.
>
> agree. 'conceptually' phys_dev bpf program is similar to sched_cls bpf program.
> If we can reuse some of the helpers that would be great...
> but only if we can maintain highest performance.
> hw offloading may be more convenient from cls_bpf side for some drivers,
> but nothing obviously stops them from hw offloading of bpf_type_phys_dev

Right, I assume such a f.e. JIT backend on driver side might be generic enough
to be able to support both things as it will mostly boil down to different
helpers and some subset of helpers are used by both anyway.
