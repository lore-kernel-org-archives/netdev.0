From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 4 Apr 2016 09:07:03 -0700
Message-ID: <57029127.3040303@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
 <57022A85.6040002@iogearbox.net> <20160404150700.1456ae80@redhat.com>
 <57026DFA.3090201@iogearbox.net>
 <CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
 <20160404171227.1f862cb1@redhat.com> <20160404152948.GA495@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	ogerlitz@mellanox.com
To: Brenden Blanco <bblanco@plumgrid.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36623 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbcDDQHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 12:07:24 -0400
Received: by mail-pf0-f182.google.com with SMTP id e128so125512960pfe.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 09:07:23 -0700 (PDT)
In-Reply-To: <20160404152948.GA495@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-04 08:29 AM, Brenden Blanco wrote:
> On Mon, Apr 04, 2016 at 05:12:27PM +0200, Jesper Dangaard Brouer wrote:
>> On Mon, 4 Apr 2016 11:09:57 -0300
>> Tom Herbert <tom@herbertland.com> wrote:
>>
>>> On Mon, Apr 4, 2016 at 10:36 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>>> On 04/04/2016 03:07 PM, Jesper Dangaard Brouer wrote:  
>>>>>
>>>>> On Mon, 04 Apr 2016 10:49:09 +0200 Daniel Borkmann <daniel@iogearbox.net>
>>>>> wrote:  
>>>>>>
>>>>>> On 04/02/2016 03:21 AM, Brenden Blanco wrote:  
>>>>>>>
>>>>>>> Add a new bpf prog type that is intended to run in early stages of the
>>>>>>> packet rx path. Only minimal packet metadata will be available, hence a
>>>>>>> new
>>>>>>> context type, struct xdp_metadata, is exposed to userspace. So far only
>>>>>>> expose the readable packet length, and only in read mode.
>>>>>>>
>>>>>>> The PHYS_DEV name is chosen to represent that the program is meant only
>>>>>>> for physical adapters, rather than all netdevs.
>>>>>>>
>>>>>>> While the user visible struct is new, the underlying context must be
>>>>>>> implemented as a minimal skb in order for the packet load_* instructions
>>>>>>> to work. The skb filled in by the driver must have skb->len, skb->head,
>>>>>>> and skb->data set, and skb->data_len == 0.
>>>>>>>  
>>>>> [...]  
>>>>>>
>>>>>>
>>>>>> Do you plan to support bpf_skb_load_bytes() as well? I like using
>>>>>> this API especially when dealing with larger chunks (>4 bytes) to
>>>>>> load into stack memory, plus content is kept in network byte order.
>>>>>>
>>>>>> What about other helpers such as bpf_skb_store_bytes() et al that
>>>>>> work on skbs. Do you intent to reuse them as is and thus populate
>>>>>> the per cpu skb with needed fields (faking linear data), or do you
>>>>>> see larger obstacles that prevent for this?  
>>>>>
>>>>>
>>>>> Argh... maybe the minimal pseudo/fake SKB is the wrong "signal" to send
>>>>> to users of this API.
>>>>>
>>>>> The hole idea is that an SKB is NOT allocated yet, and not needed at
>>>>> this level.  If we start supporting calling underlying SKB functions,
>>>>> then we will end-up in the same place (performance wise).  
>>>>
>>>>
>>>> I'm talking about the current skb-related BPF helper functions we have,
>>>> so the question is how much from that code we have we can reuse under
>>>> these constraints (obviously things like the tunnel helpers are a different
>>>> story) and if that trade-off is acceptable for us. I'm also thinking
>>>> that, for example, if you need to parse the packet data anyway for a drop
>>>> verdict, you might as well pass some meta data (that is set in the real
>>>> skb later on) for those packets that go up the stack.  
>>>
>>> Right, the meta data in this case is an abstracted receive descriptor.
>>> This would include items that we get in a device receive descriptor
>>> (computed checksum, hash, VLAN tag). This is purposely a small
>>> restricted data structure. I'm hoping we can minimize the size of this
>>> to not much more than 32 bytes (including pointers to data and
>>> linkage).
>>
>> I agree.
>>  
>>> How this translates to skb to maintain compatibility is with BPF
>>> interesting question. One other consideration is that skb's are kernel
>>> specific, we should be able to use the same BPF filter program in
>>> userspace over DPDK for instance-- so an skb interface as the packet
>>> abstraction might not be the right model...
>>
>> I agree.  I don't think reusing the SKB data structure is the right
>> model.  We should drop the SKB pointer from the API.
>>
>> As Tom also points out, making the BPF interface independent of the SKB
>> meta-data structure, would also make the eBPF program more generally
>> applicable.
> The initial approach that I tried went down this path. Alexei advised
> that I use the pseudo skb, and in the future the API between drivers and
> bpf can change to adopt non-skb context. The only user facing ABIs in
> this patchset are the IFLA, the xdp_metadata struct, and the name of the
> new enum.
> 
> The reason to use a pseudo skb for now is that there will be a fair
> amount of churn to get bpf jit and interpreter to understand non-skb
> context in the bpf_load_pointer() code. I don't see the need for
> requiring that for this patchset, as it will be internal-only change
> if/when we use something else.

Another option would be to have per driver JIT code to patch up the
skb read/loads with descriptor reads and metadata. From a strictly
performance stand point it should be better than pseudo skbs.

.John
