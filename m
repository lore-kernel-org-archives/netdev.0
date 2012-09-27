From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Thu, 27 Sep 2012 15:03:13 -0700
Message-ID: <CAEP_g=_2SQVoOFNADm4+uJdg_6wFedbnX3-ygk1_16R+E576eg@mail.gmail.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
 <1348769294.5093.1566.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:50031 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754738Ab2I0WDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:03:34 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so2341098oag.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 15:03:33 -0700 (PDT)
In-Reply-To: <1348769294.5093.1566.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 27, 2012 at 11:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-09-27 at 10:52 -0700, Jesse Gross wrote:
>
>> When I was thinking about doing this, my original plan was to handle
>> GRO/GSO by extending the current handlers to be able to look inside
>> GRE and then loop around to process the inner packet (similar to what
>> is done today with skb_flow_dissect() for RPS).  Is there a reason to
>> do it in the device?
>>
>> Pushing it earlier/later in the stack obviously increases the benefit
>> and it will also be more compatible with the forthcoming OVS tunneling
>> hooks, which will be flow based and therefore won't have a device.
>>
>> Also, the next generation of NICs will support this type of thing in
>> hardware so putting the software versions very close to the NIC will
>> give us a more similar abstraction.
>
> This sounds not feasible with all kind of tunnels, for example IPIP
> tunnels, or UDP encapsulation, at least with current stack (not OVS)

Hmm, I think we might be talking about different things since I can't
think of why it wouldn't be feasible (and none of it should be
specific to OVS).  What I was planning would result in the creation of
large but still encapsulated packets.  The merging would be purely
based on the headers in each layer being the same (as GRO is today) so
the logic of the IP stack, UDP stack, etc. isn't processed until
later.

> Also note that pushing earlier means forcing the checksumming earlier
> and it consumes a lot of cpu cycles. Hopefully NIC will help us in the
> future.

It is a good point that if the packet isn't actually destined to us
then probably none of this is worth it (although I suspect that the
relative number of tunnel packets that are passed through vs.
terminated is fairly low).  Many NICs are capable of supplying
CHECKSUM_COMPLETE packets here, even if it is not exposed by the
drivers.

> Using a napi_struct permits to eventually have separate cpus, and things
> like RPS/RSS to split the load.

We should be able to split the load today using RPS since we can look
into the GRE flow once the packet comes off the NIC (assuming that it
is using NAPI).
