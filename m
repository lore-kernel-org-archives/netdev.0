From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Mon, 04 Sep 2017 19:57:30 +0200
Message-ID: <87k21ez6r9.fsf@stressinduktion.org>
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
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38869 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753949AbdIDR5d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 13:57:33 -0400
In-Reply-To: <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
        (Tom Herbert's message of "Mon, 4 Sep 2017 10:11:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

Tom Herbert <tom@herbertland.com> writes:

>> The problem is that you end up having two streams, one fragmented and
>> one non-fragmented, but actually they belong to the same stream. It is
>> known to break stuff, see:
>>
>> <https://patchwork.ozlabs.org/patch/59235/>
>>
>> I would agree with you, but we can't break existing setups,
>> unfortunately.
>>
> I'm not sure what "existing setups" means here. If this is referring
> to the Internet then out of order packets and fragments abound-- any
> assumption of in order delivery for IP packets is useless there.

Network cards don't know where traffic originates from, even on the same
card. Clouds nowadays try to convince everyone to virtualize existing
workloads. So I *assume* that at least for traffic that seems to be in
one L2 domain out of order should not occur or things will break.

Ethernet for a long time appeared to do very much in order delivery and
guarantees that. Thus for people it appeared that UDP packets are also
strictly in order. Encapsulating Ethernet inside UDP thus must preserve
those properties, especially if used for virtualization. Unfortunately
fragmentation happens and the stack has to deal with it somehow.

I do know about some software that uses UDP in multicast that is prone
to misbehave in case of OoO frames. It uses a small reassemble queue but
if reordering gets too high, it will simply drop data. This might be
acceptable up to a specific degree.

I guess one application you could harm is plain old simple syslog, which
often generated fragmented packets. Luckily one often has time stamps in
there to reassemble the log lines but one had to do this manually.

L2 domains are not bound to local networks anymore, thanks to vxlan etc.

If you are in a controlled environment and you do know your software
that runs perfectly well, certainly, no doubt, UDP hashing can be
enabled. I would argue we can't do that generally.

> Btw, TCP has exactly the same problem in this regard that UDP has with
> regard to fragmentation. The reason that TCP isn't considered an issue
> is the assumption that TCP will do PMTU discovery and set DF (I would
> bet that devices don't actually check for DF and vendors don't test
> when it's not set!).

I don't know.

For the application the stream will appear in order at the socket level
and OoO or fragmentation won't break anything. End systems will have a
harder time reassembling the stream and thus fast paths couldn't be
used. Is that what you are referring to?

Thanks,
Hannes
