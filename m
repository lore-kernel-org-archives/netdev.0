From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH V4 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Fri, 18 Aug 2017 07:50:03 -0700
Message-ID: <CALx6S3498iPfNs4Wt5RWjoxZS0nXHT=qvdSgZhZbqxswqJqdZw@mail.gmail.com>
References: <cover.1501539150.git.shli@fb.com> <CALx6S36DcpqqqhosdN4qNqTNYZkxZ=0Qy-=uKXHVM_yQoE4XbQ@mail.gmail.com>
 <20170810163033.kriwd2pivmuuzfnb@kernel.org> <CALx6S35UKD3AyqxM-zKMCANi=TR_e26mRjKYKH7QreckBu2dEg@mail.gmail.com>
 <20170810191314.vo6yl7dgndga4heh@kernel.org> <CALx6S34CwcYNtBzEoEMrBP3O54Fsnot=YzeHCNCM0yeuaFUozQ@mail.gmail.com>
 <20170815025224.trjgcp3z6i3cgfy2@kernel.org> <CALx6S34f2r-sQi_gNAS9mxTX0JPeOJrhN8q3wzD-14knCB7DUA@mail.gmail.com>
 <20170815224252.6vjkyqsngybl3z3m@kernel.org> <CALx6S34C5aT+UX-Rz39iu5FX-U-EAw23ZiBEcGP90HZRj4xf+g@mail.gmail.com>
 <20170817225521.ybb7cclaxs6skdem@kafai-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Shaohua Li <shli@kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34631 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdHROuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 10:50:04 -0400
Received: by mail-qk0-f173.google.com with SMTP id u139so53957325qka.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 07:50:04 -0700 (PDT)
In-Reply-To: <20170817225521.ybb7cclaxs6skdem@kafai-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We had been using the auto_flowlabels=1 (i.e. essentially enable flowlabel)
> mainly because we want to take the benefit of dst_negative_advice() when
> tcp_write_timeout() happens.
>
> During our test, our system handles quite well with changing flowlabel.
> The only exception we have hit is the TCP_RST sent from an inet_timewait_sock.
>
Martin,

That is interesting data. Have you determined why the middlebox has a
problem with flow label change in TW state but not other states?

Tom

> If we keep the flowlabel consistent (or persistent sk_txhash), there
> is no practical usage for us to turn on flowlabel and the problem also goes
> away.  We have it off for now.
>
>>
>> > There seems to have other bug in this side. From my understanding, commit
>> > 265f94ff54d6(net: Recompute sk_txhash on negative routing advice) tries to
>> > select a different route. But the multipath selection code
>> > (rt6_multipath_select) doesn't use sk_txhash or skb->hash, it does use
>> > fl6.flowlabel, but that is the flowlabel user sets. So looks like the commit
>> > doesn't change anything.
>> >
>> The routing functions typically don't use sock of skbuff, but use flow
>> structs instead. It may be reasonable to add a hash to those.
> The localhost's mutlipath selection is another existing issue.  AFAICT,
> it does not take the sk_txhash (or skb->hash) into account and the following
> dst_negative_advice() will also have no effect in the route selction.
> It is another issue to be fixed and to be figured out how to pass the
> sk_txhash down. (1)
>
> Shaohua is proposing to record the 20 bits of the sk_txhash in the
> tw_flowlabel of the 'struct inet_timewait_sock'.  The tw_flowlabel could
> potentially be used to do the multipath selection once we figured out
> how to tackle (1).
>
> Thanks,
> Martin
>
>
>>
>> > What's the 'src port for UDP encap'? I can't find the code setting skb->hash
>> > to sk_txhash in UDP side.
>> >
>> udp_flow_src_port is function call by UDP encaps to set source port.
>> This is call skb_get_hash. sk_set_txhash is function to set txhash
>> right now to random value. skb_set_hash_from_sk set skb->hash when
>> skbuff is owned by socket (skb_set_owner_w).
>>
>> Thanks,
>> Tom
>>
>>
>> > Thanks,
>> > Shaohua
