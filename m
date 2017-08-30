From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: multi-queue over IFF_NO_QUEUE "virtual" devices
Date: Wed, 30 Aug 2017 16:37:49 -0700
Message-ID: <CAM_iQpV4y2sd=5UJ5vLzXwM4UpTNA2GY6mf5AfBLJ_UpGGWc_A@mail.gmail.com>
References: <21cdcfc2-0efc-c0df-6542-05bb8078d866@gmail.com> <85342893-b84f-4922-1e23-8c9fe0e5f1e0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>, andrew@lunn.ch,
        David Miller <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37764 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdH3XiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:38:10 -0400
Received: by mail-pg0-f45.google.com with SMTP id 83so23923369pgb.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 16:38:10 -0700 (PDT)
In-Reply-To: <85342893-b84f-4922-1e23-8c9fe0e5f1e0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 8:49 PM, Florian Fainelli <f.fainelli@gmail.com> wr=
ote:
> Le 08/07/17 =C3=A0 15:26, Florian Fainelli a =C3=A9crit :
>> Hi,
>>
>> Most DSA supported Broadcom switches have multiple queues per ports
>> (usually 8) and each of these queues can be configured with different
>> pause, drop, hysteresis thresholds and so on in order to make use of the
>> switch's internal buffering scheme and have some queues achieve some
>> kind of lossless behavior (e.g: LAN to LAN traffic for Q7 has a higher
>> priority than LAN to WAN for Q0).
>>
>> This is obviously very workload specific, so I'd want maximum
>> programmability as much as possible.
>>
>> This brings me to a few questions:
>>
>> 1) If we have the DSA slave network devices currently flagged with
>> IFF_NO_QUEUE becoming multi-queue (on TX) aware such that an application
>> can control exactly which switch egress queue is used on a per-flow
>> basis, would that be a problem (this is the dynamic selection of the TX
>> queue)?
>
> So I have this part figured out, with a bunch of changes network devices
> created by DSA are now multiqueue aware and the Broadcom tag layer is
> capable of extracting the queue index, passing it in the tag where
> expected and having the switch forward to the appropriate switch port
> and queue within that port. It also sets the queue mapping in the SKB
> for later consumption by the master network device driver: bcmsysport.c
> because of 2).
>
>>
>> 2) The conduit interface (CPU) port network interface has a congestion
>> control scheme which requires each of its TX queues (32 or 16) to be
>> statically mapped to each of the underlying switch port queues because
>> the congestion/ HW needs to inspect the queue depths of the switch to
>> accept/reject a packet at the CPU's TX ring level. Do we have a good way
>> with tc to map a virtual/stacked device's queue(s) on-top of its
>> physical/underlying device's queues (this is the static queue mapping
>> necessary for congestion to work)?
>
> That part I have not figured out yet, with some static mapping I can
> obtain the results that I want and was even considering the possibility
> of doing something like this:
>
> - register a network device notifier with bcmsysport.c (master network
> device) for this setup
> - expose a helper function allowing me to obtain a given DSA network
> device port index
> - whenever DSA creates network devices reconfigure the ring and queue
> mapping of the TX queues managed by bcmsysport.c with the DSA network
> device port index that has just been registered and just do a 1-1
> mapping of the 8 queues
>
> You would end-up with something like:
>
> gphy (port 0) queues 0-7 mapped to systemport queues 0-7
> rgmii_1 (port 1) queues 0-7 mapped to systemport queues 8-15
> rgmii_2 (port 2) queues 0-7 mapped to systemport queues 16 through 23
> moca (port 7) queues 0-7 mapped to systemport queues 24-31
>
> This should be working because bcmsysport's TX queues are not under
> direct control by the user, they are used via DSA created network
> devices which indicate the queue they want to use. When the DSA
> interfaces are brought down, their respective systemport queues now
> become unused. This also works because the number of physical ports of
> the switch times the number of queues is matching the number of TX
> queues from systemport (like if someone designed it with that exact
> purpose in mind ;)).
>
> The only problem with that approach of course is that it embeds a policy
> within the systemport driver.
>
> Ideally I would really like to configure this via tc by setting up a
> mapping between queues of one network devices to queues of another
> network device, is that a possible thing, Jamal, Cong, Jiri, do you know?

I am not sure if I understand the mapping you are talking about here.

TC layer rarely deals with hardware queues directly (except probably mq),
so this question probably don't belong to TC.

OTOH, TC can modify skb->hash, so you can redirect packets to a specific
queue, but this doesn't sound like what you are you looking for.

Maybe Jiri has more thoughts here since he works on TC offloading things.
