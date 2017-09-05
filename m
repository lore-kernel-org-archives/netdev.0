From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Tue, 05 Sep 2017 21:20:32 +0200
Message-ID: <87fuc1q7en.fsf@stressinduktion.org>
References: <20170830230409.15176-1-saeedm@mellanox.com>
        <87fuc7ong0.fsf@stressinduktion.org>
        <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
        <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
        <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
        <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
        <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
        <87pob6bmjv.fsf@stressinduktion.org>
        <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
        <8760cytnif.fsf@stressinduktion.org>
        <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
        <87k21ez6r9.fsf@stressinduktion.org>
        <CALx6S34aDER1Gzpcw+p7+yr91mjiixCh6gnawKSxy7zhVQz+6Q@mail.gmail.com>
        <87r2vls8hp.fsf@stressinduktion.org>
        <CALx6S345jR6UtAGju9TaPxAOMgkBG2RZ+eMWz80ix1joSmQCog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49925 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751955AbdIETUg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 15:20:36 -0400
In-Reply-To: <CALx6S345jR6UtAGju9TaPxAOMgkBG2RZ+eMWz80ix1joSmQCog@mail.gmail.com>
        (Tom Herbert's message of "Tue, 5 Sep 2017 09:02:33 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

Tom Herbert <tom@herbertland.com> writes:

> On Tue, Sep 5, 2017 at 4:14 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Tom Herbert <tom@herbertland.com> writes:
>>
>>> There is absolutely no requirement in IP that packets are delivered in
>>> order-- there never has been and there never will be! If the ULP, like
>>> Ethernet encapsulation, requires in order deliver then it needs to
>>> implement that itself like TCP, GRE, and other protocols ensure that
>>> with sequence numbers and reassembly. All of these hoops we do make
>>> sure that packets always follow the same path and are always in order
>>> are done for benefit of middlebox devices like stateful firewalls that
>>> have force us to adopt their concept of network architecture-- in the
>>> long run this is self-defeating and kills our ability to innovate.
>>>
>>> I'm not saying that we shouldn't consider legacy devices, but we
>>> should scrutinize new development or solutions that perpetuate
>>> incorrect design or bad assumptions.
>>
>> So configure RSS per port and ensure no fragments are send to those
>> ports. This is possible and rather easy to do. It solves the problem
>> with legacy software and it spreads out packets for your applications.
>>
>> It is not perfect but it is working and solves both problems.
>>
> Hannes,
>
> I don't see how that solves anything. The purpose of RSS is to
> distribute the load of protocol packets across queues. This needs to
> work for UDP applications. For instance, if I were building a QUIC
> server I'd want the sort of flow distribution that a TCP server would
> give. You can't do that by configuring a few ports in the device.

I seriously am with you and I think you are on the right track. I would
also much rather like to see fragmentation *not* happening and would
like to see hardware logic *not* parsing deep down into packets and
protocols. We can agree on that!

Albeit I don't understand the problem with my approach:

If you know that you are running a QUIC server and know your environment
(safe against reordering), run `ethtool -N ethX rx-flow-hash udp4 sdfn'
on the box and you would get spreading of UDP packets based on the UDP
src+dst port numbers to the rx queues. Otherwise only source and
destination addresses are being considered, which is the safe default
(maybe this is sometimes enough).

Intel network cards warn you if you actually switch the mode:

-- >8 --
drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:                                  "enabling UDP RSS: fragmented packets may arrive out of order to the stack above\n");
drivers/net/ethernet/intel/igb/igb_ethtool.c:                           "enabling UDP RSS: fragmented packets may arrive out of order to the stack above\n");
drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c:                       e_warn(drv, "enabling UDP RSS: fragmented packets may arrive out of order to the stack above\n");
-- 8< --

I argue that we can't change the default.

Furthermore I tried to argue that in a cloud where you don't know which
applications you run within the encapsulated networks, it is very hard
to predict which protocols can be considered safe against those
effects. I agree, that most of the time, it probably should not
matter. But given the rule about kernel backwards compatibility I do
have doubts that this change would go unnoticed.

I am the devil's advocate here and argue it is on us to show that is
safe before we change the semantics.

> If I were to suggest any HW change it would be to not do DPI on
> fragments (MF or offset is set). This ensures that all packets of the
> fragment train get hashed to the same queue and is on fact what RPS
> has been doing for years without any complaints.

The same UDP flow could consist out of fragments and non-fragmented
packets. Even if hardware would act according to what you wrote,
reordering is very much possible within the same UDP flow.

In case of QUIC, as far as I know, it uses destination ports 80 and
443. Like we already notify NICs about vxlan and geneve port numbers, we
could selectively enable RSS for UDP ports on those destination port
numbers to tell the NIC it won't receive fragments on those ports and
thus do RSS. The same way the NIC could be notified if reordering on
this port is possible. This could be done for example via a lightweight
setsockopt.

The situation with encapsulation is even more complicated:

We are basically only interested in the UDP/vxlan/Ethernet/IP/UDP
constellation. If we do the fragmentation inside the vxlan tunnel and
carry over the skb hash to all resulting UDP/vxlan packets source ports,
we are fine and reordering on the receiver NIC won't happen in this
case. If the fragmentation happens on the outer UDP header, this will
result in reordering of the inner L2 flow. Unfortunately this depends on
how the vxlan tunnel was set up, how other devices do that and (I
believe so) on the kernel version.

Given the fact that we tell the NICs the receiving port of vxlan tunnels
anyway (and I only can assume) they are doing RSS on that, we probably
have reordering anyway on those tunnels. So maybe you are right and it
doesn't matter in the end for encapsulated packets, by accident.

> But even before I'd make that recommendation, I'd really like
> understand what the problem actually is. The only thing I can garner
> from this discussion and the Intel patch is that when fragments are
> received OOO that is perceived as a problem. But the by the protocol
> specification clearly says this is not a problem. So the questions
> are: who is negatively affected by this? Is this a problem because
> some artificial test that checks for everything to be in order is now
> failing? Is this affecting real users? Is this an issue in the stack
> or really with some implementation outside of the stack? If it is an
> implementation outside of the stack, then are we just bandaid'ing over
> someone else's incorrect implementation by patching the kernel (like
> would have be the case if we change the kernel to interoperate with
> Facebook's switch that couldn't handle OOO in twstate).

I agree with that and I would also love to hear more feedback on
this. Unfortunately I don't know.

Bye,
Hannes
