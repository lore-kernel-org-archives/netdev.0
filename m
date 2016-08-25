From: Tom Herbert <tom@herbertland.com>
Subject: Re: A second case of XPS considerably reducing single-stream performance
Date: Thu, 25 Aug 2016 14:02:05 -0700
Message-ID: <CALx6S37+Gpx7jeV-U-PE4wf593F-AUVEeOpU1R0-h6cDfNQnow@mail.gmail.com>
References: <549357ea-dfda-284b-cdd6-4408060f9ca8@hpe.com> <a661ff61-9cf8-fe86-ca20-2181394e1dbb@hpe.com>
 <CAKgT0UeQ_cL4aaSSc47EgzbYp7WZF7C-4+JG6T7gw78J3rv+ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hpe.com>, Netdev <netdev@vger.kernel.org>,
        sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38583 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754447AbcHYVDP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 17:03:15 -0400
Received: by mail-it0-f54.google.com with SMTP id n128so112697689ith.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:02:06 -0700 (PDT)
In-Reply-To: <CAKgT0UeQ_cL4aaSSc47EgzbYp7WZF7C-4+JG6T7gw78J3rv+ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 12:19 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Aug 24, 2016 at 4:46 PM, Rick Jones <rick.jones2@hpe.com> wrote:
>> Also, while it doesn't seem to have the same massive effect on throughput, I
>> can also see out of order behaviour happening when the sending VM is on a
>> node with a ConnectX-3 Pro NIC.  Its driver is also enabling XPS it would
>> seem.  I'm not *certain* but looking at the traces it appears that with the
>> ConnectX-3 Pro there is more interleaving of the out-of-order traffic than
>> there is with the Skyhawk.  The ConnectX-3 Pro happens to be in a newer
>> generation server with a newer processor than the other systems where I've
>> seen this.
>>
>> I do not see the out-of-order behaviour when the NIC at the sending end is a
>> BCM57840.  It does not appear that the bnx2x driver in the 4.4 kernel is
>> enabling XPS.
>>
>> So, it would seem that there are three cases of enabling XPS resulting in
>> out-of-order traffic, two of which result in a non-trivial loss of
>> performance.
>>
>> happy benchmarking,
>>
>> rick jones
>
> The problem is that there is no socket associated with the guest from
> the host's perspective.  This is resulting in the traffic bouncing
> between queues because there is no saved socket  to lock the interface
> onto.
>
> I was looking into this recently as well and had considered a couple
> of options.  The first is to fall back to just using skb_tx_hash()
> when skb->sk is null for a given buffer.  I have a patch I have been
> toying around with but I haven't submitted it yet.  If you would like
> I can submit it as an RFC to get your thoughts.  The second option is
> to enforce the use of RPS for any interfaces that do not perform Rx in
> NAPI context.  The correct solution for this is probably some
> combination of the two as you have to have all queueing done in order
> at every stage of the packet processing.
>
I have thought several times about creating flow states for packets
coming from VMs. This can be done similar to how we do RFS, call flow
dissector to get a hash of the flow and then use that to index into a
table that contains the last queue-- only change the queue when
criteria are meant to prevent OOO. This would result in flow dissector
on such packets which seems a bit expensive, it would be nice if the
VM can just give us the hash in a TX descriptor. There are other
benefits with a more advanced mechanism, for instance we might be able
to cache routes or IP tables results (stuff we might keep if there
were a transport socket).

Tom
