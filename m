From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Thu, 28 Sep 2017 23:29:48 +0200
Message-ID: <59CD69CC.7070809@iogearbox.net>
References: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net> <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net> <59C94FF4.8070900@iogearbox.net> <20170926172140.GB60144@C02RW35GFVH8.dhcp.broadcom.net> <E0D909EE5BB15A4699798539EA149D7F077E53D6@ORSMSX103.amr.corp.intel.com> <CAHashqBMfXp-uYH9ANfdaNfez9f4pcrOjnbX2WAFAdBwaJAtvw@mail.gmail.com> <E0D909EE5BB15A4699798539EA149D7F077E6438@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mchan@broadcom.com" <mchan@broadcom.com>
To: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45278 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbdI1V3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:29:55 -0400
In-Reply-To: <E0D909EE5BB15A4699798539EA149D7F077E6438@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2017 10:52 PM, Waskiewicz Jr, Peter wrote:
> On 9/28/17 12:59 PM, Andy Gospodarek wrote:
>> On Thu, Sep 28, 2017 at 1:59 AM, Waskiewicz Jr, Peter
>> <peter.waskiewicz.jr@intel.com> wrote:
>>> On 9/26/17 10:21 AM, Andy Gospodarek wrote:
>>>> On Mon, Sep 25, 2017 at 08:50:28PM +0200, Daniel Borkmann wrote:
>>>>> On 09/25/2017 08:10 PM, Andy Gospodarek wrote:
>>>>> [...]
>>>>>> First, thanks for this detailed description.  It was helpful to read
>>>>>> along with the patches.
>>>>>>
>>>>>> My only concern about this area being generic is that you are now in a
>>>>>> state where any bpf program must know about all the bpf programs in the
>>>>>> receive pipeline before it can properly parse what is stored in the
>>>>>> meta-data and add it to an skb (or perform any other action).
>>>>>> Especially if each program adds it's own meta-data along the way.
>>>>>>
>>>>>> Maybe this isn't a big concern based on the number of users of this
>>>>>> today, but it just starts to seem like a concern as there are these
>>>>>> hints being passed between layers that are challenging to track due to a
>>>>>> lack of a standard format for passing data between.
>>>>>
>>>>> Btw, we do have similar kind of programmable scratch buffer also today
>>>>> wrt skb cb[] that you can program from tc side, the perf ring buffer,
>>>>> which doesn't have any fixed layout for the slots, or a per-cpu map
>>>>> where you can transfer data between tail calls for example, then tail
>>>>> calls themselves that need to coordinate, or simply mangling of packets
>>>>> itself if you will, but more below to your use case ...
>>>>>
>>>>>> The main reason I bring this up is that Michael and I had discussed and
>>>>>> designed a way for drivers to communicate between each other that rx
>>>>>> resources could be freed after a tx completion on an XDP_REDIRECT
>>>>>> action.  Much like this code, it involved adding an new element to
>>>>>> struct xdp_md that could point to the important information.  Now that
>>>>>> there is a generic way to handle this, it would seem nice to be able to
>>>>>> leverage it, but I'm not sure how reliable this meta-data area would be
>>>>>> without the ability to mark it in some manner.
>>>>>>
>>>>>> For additional background, the minimum amount of data needed in the case
>>>>>> Michael and I were discussing was really 2 words.  One to serve as a
>>>>>> pointer to an rx_ring structure and one to have a counter to the rx
>>>>>> producer entry.  This data could be acessed by the driver processing the
>>>>>> tx completions and callback to the driver that received the frame off the wire
>>>>>> to perform any needed processing.  (For those curious this would also require a
>>>>>> new callback/netdev op to act on this data stored in the XDP buffer.)
>>>>>
>>>>> What you describe above doesn't seem to be fitting to the use-case of
>>>>> this set, meaning the area here is fully programmable out of the BPF
>>>>> program, the infrastructure you're describing is some sort of means of
>>>>> communication between drivers for the XDP_REDIRECT, and should be
>>>>> outside of the control of the BPF program to mangle.
>>>>
>>>> OK, I understand that perspective.  I think saying this is really meant
>>>> as a BPF<->BPF communication channel for now is fine.
>>>>
>>>>> You could probably reuse the base infra here and make a part of that
>>>>> inaccessible for the program with some sort of a fixed layout, but I
>>>>> haven't seen your code yet to be able to fully judge. Intention here
>>>>> is to allow for programmability within the BPF prog in a generic way,
>>>>> such that based on the use-case it can be populated in specific ways
>>>>> and propagated to the skb w/o having to define a fixed layout and
>>>>> bloat xdp_buff all the way to an skb while still retaining all the
>>>>> flexibility.
>>>>
>>>> Some level of reuse might be proper, but I'd rather it be explicit for
>>>> my use since it's not exclusively something that will need to be used by
>>>> a BPF prog, but rather the driver.  I'll produce some patches this week
>>>> for reference.
>>>
>>> Sorry for chiming in late, I've been offline.
>>>
>>> We're looking to add some functionality from driver to XDP inside this
>>> xdp_buff->data_meta region.  We want to assign it to an opaque
>>> structure, that would be specific per driver (think of a flex descriptor
>>> coming out of the hardware).  We'd like to pass these offloaded
>>> computations into XDP programs to help accelerate them, such as packet
>>> type, where headers are located, etc.  It's similar to Jesper's RFC
>>> patches back in May when passing through the mlx Rx descriptor to XDP.
>>>
>>> This is actually what a few of us are planning to present at NetDev 2.2
>>> in November.  If you're hoping to restrict this headroom in the xdp_buff
>>> for an exclusive use case with XDP_REDIRECT, then I'd like to discuss
>>> that further.
>>
>> No sweat, PJ, thanks for replying.  I saw the notes for your accepted
>> session and I'm looking forward to it.
>>
>> John's suggestion earlier in the thread was actually similar to the
>> conclusion I reached when thinking about Daniel's patch a bit more.
>> (I like John's better though as it doesn't get constrained by UAPI.)
>> Since redirect actions happen at a point where no other programs will
>> run on the buffer, that space can be used for this redirect data and
>> there are no conflicts.

Yep fully agree, it's not read anywhere else anymore or could go up
the stack where we'd read it out again, so that's the best solution
for your use-case moving forward, Andy. I do like that we don't expose
to uapi.

> Ah, yes, John and I spoke about this at Plumber's and this is basically
> what we came to as well.  A set of helpers that won't have to be in
> UAPI, but they will be potentially vendor-specific to extract the
> meta-data hints out for the XDP program to use.
>
>> It sounds like the idea behind your proposal includes populating some
>> data into the buffer before the XDP program is executed so that it can
>> be used by the program.  Would this data be useful later in the driver
>> or stack or are you just hoping to accelerate processing of frames in
>> the BPF program?
>
> Right now we're thinking it would only be useful for XDP programs to
> execute things quicker, i.e. not have to compute things that are already
> computed by the hardware (rxhash, ptype, header locations, etc.).  I
> don't have any plans to pass this data off elsewhere in the stack or
> back to the driver at this point.
>
>> If the headroom needed for redirect info was only added after it was
>> clear the redirect action was needed, would this conflict with the
>> information you are trying to provide?  I had planned to add this just
>> after the action was XDP_REDIRECT was selected or at the end of the
>> driver's ndo_xdp_xmit function -- it seems like it would not conflict.
>
> I'm pretty sure I misunderstood what you were going after with
> XDP_REDIRECT reserving the headroom.  Our use case (patches coming in a
> few weeks) will populate the headroom coming out of the driver to XDP,
> and then once the XDP program extracts whatever hints it wants via
> helpers, I fully expect that area in the headroom to get stomped by
> something else.  If we want to send any of that hint data up farther,
> we'll already have it extracted via the helpers, and the eBPF program
> can happily assign it to wherever in the outbound metadata area.

Sure, these two are compatible with each other; in your case it's
populated before the prog is called, and the prog can use it while
processing, in Andy's case it's populated after the prog was called
when we need to redirect, so both fine.

Thanks,
Daniel
