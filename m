From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Tue, 5 Sep 2017 09:02:33 -0700
Message-ID: <CALx6S345jR6UtAGju9TaPxAOMgkBG2RZ+eMWz80ix1joSmQCog@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
 <87pob6bmjv.fsf@stressinduktion.org> <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
 <8760cytnif.fsf@stressinduktion.org> <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
 <87k21ez6r9.fsf@stressinduktion.org> <CALx6S34aDER1Gzpcw+p7+yr91mjiixCh6gnawKSxy7zhVQz+6Q@mail.gmail.com>
 <87r2vls8hp.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35656 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751979AbdIEQCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:02:36 -0400
Received: by mail-qk0-f172.google.com with SMTP id r141so12861832qke.2
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 09:02:36 -0700 (PDT)
In-Reply-To: <87r2vls8hp.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 5, 2017 at 4:14 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Tom Herbert <tom@herbertland.com> writes:
>
>> There is absolutely no requirement in IP that packets are delivered in
>> order-- there never has been and there never will be! If the ULP, like
>> Ethernet encapsulation, requires in order deliver then it needs to
>> implement that itself like TCP, GRE, and other protocols ensure that
>> with sequence numbers and reassembly. All of these hoops we do make
>> sure that packets always follow the same path and are always in order
>> are done for benefit of middlebox devices like stateful firewalls that
>> have force us to adopt their concept of network architecture-- in the
>> long run this is self-defeating and kills our ability to innovate.
>>
>> I'm not saying that we shouldn't consider legacy devices, but we
>> should scrutinize new development or solutions that perpetuate
>> incorrect design or bad assumptions.
>
> So configure RSS per port and ensure no fragments are send to those
> ports. This is possible and rather easy to do. It solves the problem
> with legacy software and it spreads out packets for your applications.
>
> It is not perfect but it is working and solves both problems.
>
Hannes,

I don't see how that solves anything. The purpose of RSS is to
distribute the load of protocol packets across queues. This needs to
work for UDP applications. For instance, if I were building a QUIC
server I'd want the sort of flow distribution that a TCP server would
give. You can't do that by configuring a few ports in the device.

If I were to suggest any HW change it would be to not do DPI on
fragments (MF or offset is set). This ensures that all packets of the
fragment train get hashed to the same queue and is on fact what RPS
has been doing for years without any complaints.

But even before I'd make that recommendation, I'd really like
understand what the problem actually is. The only thing I can garner
from this discussion and the Intel patch is that when fragments are
received OOO that is perceived as a problem. But the by the protocol
specification clearly says this is not a problem. So the questions
are: who is negatively affected by this? Is this a problem because
some artificial test that checks for everything to be in order is now
failing? Is this affecting real users? Is this an issue in the stack
or really with some implementation outside of the stack? If it is an
implementation outside of the stack, then are we just bandaid'ing over
someone else's incorrect implementation by patching the kernel (like
would have be the case if we change the kernel to interoperate with
Facebook's switch that couldn't handle OOO in twstate).

Thanks,
Tom

> Bye,
> Hannes
