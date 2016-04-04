From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver filter
Date: Mon, 4 Apr 2016 11:09:57 -0300
Message-ID: <CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
	<57022A85.6040002@iogearbox.net>
	<20160404150700.1456ae80@redhat.com>
	<57026DFA.3090201@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	gerlitz@mellanox.com, john fastabend <john.fastabend@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36798 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbcDDOKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 10:10:25 -0400
Received: by mail-ig0-f171.google.com with SMTP id f1so73424965igr.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 07:10:24 -0700 (PDT)
In-Reply-To: <57026DFA.3090201@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 4, 2016 at 10:36 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 04/04/2016 03:07 PM, Jesper Dangaard Brouer wrote:
>>
>> On Mon, 04 Apr 2016 10:49:09 +0200 Daniel Borkmann <daniel@iogearbox.net>
>> wrote:
>>>
>>> On 04/02/2016 03:21 AM, Brenden Blanco wrote:
>>>>
>>>> Add a new bpf prog type that is intended to run in early stages of the
>>>> packet rx path. Only minimal packet metadata will be available, hence a
>>>> new
>>>> context type, struct xdp_metadata, is exposed to userspace. So far only
>>>> expose the readable packet length, and only in read mode.
>>>>
>>>> The PHYS_DEV name is chosen to represent that the program is meant only
>>>> for physical adapters, rather than all netdevs.
>>>>
>>>> While the user visible struct is new, the underlying context must be
>>>> implemented as a minimal skb in order for the packet load_* instructions
>>>> to work. The skb filled in by the driver must have skb->len, skb->head,
>>>> and skb->data set, and skb->data_len == 0.
>>>>
>> [...]
>>>
>>>
>>> Do you plan to support bpf_skb_load_bytes() as well? I like using
>>> this API especially when dealing with larger chunks (>4 bytes) to
>>> load into stack memory, plus content is kept in network byte order.
>>>
>>> What about other helpers such as bpf_skb_store_bytes() et al that
>>> work on skbs. Do you intent to reuse them as is and thus populate
>>> the per cpu skb with needed fields (faking linear data), or do you
>>> see larger obstacles that prevent for this?
>>
>>
>> Argh... maybe the minimal pseudo/fake SKB is the wrong "signal" to send
>> to users of this API.
>>
>> The hole idea is that an SKB is NOT allocated yet, and not needed at
>> this level.  If we start supporting calling underlying SKB functions,
>> then we will end-up in the same place (performance wise).
>
>
> I'm talking about the current skb-related BPF helper functions we have,
> so the question is how much from that code we have we can reuse under
> these constraints (obviously things like the tunnel helpers are a different
> story) and if that trade-off is acceptable for us. I'm also thinking
> that, for example, if you need to parse the packet data anyway for a drop
> verdict, you might as well pass some meta data (that is set in the real
> skb later on) for those packets that go up the stack.

Right, the meta data in this case is an abstracted receive descriptor.
This would include items that we get in a device receive descriptor
(computed checksum, hash, VLAN tag). This is purposely a small
restricted data structure. I'm hoping we can minimize the size of this
to not much more than 32 bytes (including pointers to data and
linkage).

How this translates to skb to maintain compatibility is with BPF
interesting question. One other consideration is that skb's are kernel
specific, we should be able to use the same BPF filter program in
userspace over DPDK for instance-- so an skb interface as the packet
abstraction might not be the right model...

Tom
