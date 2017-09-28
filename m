From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Thu, 28 Sep 2017 15:58:55 -0400
Message-ID: <CAHashqBMfXp-uYH9ANfdaNfez9f4pcrOjnbX2WAFAdBwaJAtvw@mail.gmail.com>
References: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
 <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net> <59C94FF4.8070900@iogearbox.net>
 <20170926172140.GB60144@C02RW35GFVH8.dhcp.broadcom.net> <E0D909EE5BB15A4699798539EA149D7F077E53D6@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mchan@broadcom.com" <mchan@broadcom.com>
To: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:56731 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdI1T7R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 15:59:17 -0400
Received: by mail-qk0-f182.google.com with SMTP id g128so2554931qke.13
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 12:59:16 -0700 (PDT)
In-Reply-To: <E0D909EE5BB15A4699798539EA149D7F077E53D6@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 1:59 AM, Waskiewicz Jr, Peter
<peter.waskiewicz.jr@intel.com> wrote:
> On 9/26/17 10:21 AM, Andy Gospodarek wrote:
>> On Mon, Sep 25, 2017 at 08:50:28PM +0200, Daniel Borkmann wrote:
>>> On 09/25/2017 08:10 PM, Andy Gospodarek wrote:
>>> [...]
>>>> First, thanks for this detailed description.  It was helpful to read
>>>> along with the patches.
>>>>
>>>> My only concern about this area being generic is that you are now in a
>>>> state where any bpf program must know about all the bpf programs in the
>>>> receive pipeline before it can properly parse what is stored in the
>>>> meta-data and add it to an skb (or perform any other action).
>>>> Especially if each program adds it's own meta-data along the way.
>>>>
>>>> Maybe this isn't a big concern based on the number of users of this
>>>> today, but it just starts to seem like a concern as there are these
>>>> hints being passed between layers that are challenging to track due to a
>>>> lack of a standard format for passing data between.
>>>
>>> Btw, we do have similar kind of programmable scratch buffer also today
>>> wrt skb cb[] that you can program from tc side, the perf ring buffer,
>>> which doesn't have any fixed layout for the slots, or a per-cpu map
>>> where you can transfer data between tail calls for example, then tail
>>> calls themselves that need to coordinate, or simply mangling of packets
>>> itself if you will, but more below to your use case ...
>>>
>>>> The main reason I bring this up is that Michael and I had discussed and
>>>> designed a way for drivers to communicate between each other that rx
>>>> resources could be freed after a tx completion on an XDP_REDIRECT
>>>> action.  Much like this code, it involved adding an new element to
>>>> struct xdp_md that could point to the important information.  Now that
>>>> there is a generic way to handle this, it would seem nice to be able to
>>>> leverage it, but I'm not sure how reliable this meta-data area would be
>>>> without the ability to mark it in some manner.
>>>>
>>>> For additional background, the minimum amount of data needed in the case
>>>> Michael and I were discussing was really 2 words.  One to serve as a
>>>> pointer to an rx_ring structure and one to have a counter to the rx
>>>> producer entry.  This data could be acessed by the driver processing the
>>>> tx completions and callback to the driver that received the frame off the wire
>>>> to perform any needed processing.  (For those curious this would also require a
>>>> new callback/netdev op to act on this data stored in the XDP buffer.)
>>>
>>> What you describe above doesn't seem to be fitting to the use-case of
>>> this set, meaning the area here is fully programmable out of the BPF
>>> program, the infrastructure you're describing is some sort of means of
>>> communication between drivers for the XDP_REDIRECT, and should be
>>> outside of the control of the BPF program to mangle.
>>
>> OK, I understand that perspective.  I think saying this is really meant
>> as a BPF<->BPF communication channel for now is fine.
>>
>>> You could probably reuse the base infra here and make a part of that
>>> inaccessible for the program with some sort of a fixed layout, but I
>>> haven't seen your code yet to be able to fully judge. Intention here
>>> is to allow for programmability within the BPF prog in a generic way,
>>> such that based on the use-case it can be populated in specific ways
>>> and propagated to the skb w/o having to define a fixed layout and
>>> bloat xdp_buff all the way to an skb while still retaining all the
>>> flexibility.
>>
>> Some level of reuse might be proper, but I'd rather it be explicit for
>> my use since it's not exclusively something that will need to be used by
>> a BPF prog, but rather the driver.  I'll produce some patches this week
>> for reference.
>
> Sorry for chiming in late, I've been offline.
>
> We're looking to add some functionality from driver to XDP inside this
> xdp_buff->data_meta region.  We want to assign it to an opaque
> structure, that would be specific per driver (think of a flex descriptor
> coming out of the hardware).  We'd like to pass these offloaded
> computations into XDP programs to help accelerate them, such as packet
> type, where headers are located, etc.  It's similar to Jesper's RFC
> patches back in May when passing through the mlx Rx descriptor to XDP.
>
> This is actually what a few of us are planning to present at NetDev 2.2
> in November.  If you're hoping to restrict this headroom in the xdp_buff
> for an exclusive use case with XDP_REDIRECT, then I'd like to discuss
> that further.
>

No sweat, PJ, thanks for replying.  I saw the notes for your accepted
session and I'm looking forward to it.

John's suggestion earlier in the thread was actually similar to the
conclusion I reached when thinking about Daniel's patch a bit more.
(I like John's better though as it doesn't get constrained by UAPI.)
Since redirect actions happen at a point where no other programs will
run on the buffer, that space can be used for this redirect data and
there are no conflicts.

It sounds like the idea behind your proposal includes populating some
data into the buffer before the XDP program is executed so that it can
be used by the program.  Would this data be useful later in the driver
or stack or are you just hoping to accelerate processing of frames in
the BPF program?

If the headroom needed for redirect info was only added after it was
clear the redirect action was needed, would this conflict with the
information you are trying to provide?  I had planned to add this just
after the action was XDP_REDIRECT was selected or at the end of the
driver's ndo_xdp_xmit function -- it seems like it would not conflict.

(There's also Jesper's series from today -- I've seen it but have not
had time to fully grok all of those changes.)

Thoughts?
