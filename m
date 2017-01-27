From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 14:29:06 -0500
Message-ID: <CAF=yD-J6r+myVVAb5uNL8-Fua7Gr5q8U+veqPB=xm4gNOTp5Tg@mail.gmail.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com> <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com> <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
 <20170127151119.GB25829@oracle.com> <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
 <20170127170320.GD25829@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36252 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbdA0T36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 14:29:58 -0500
Received: by mail-wm0-f66.google.com with SMTP id r126so60383864wmr.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 11:29:53 -0800 (PST)
In-Reply-To: <20170127170320.GD25829@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On (01/27/17 10:28), Willem de Bruijn wrote:
>> > Would it make sense to only do the CAP_SYS_RAWIO branch if the
>> > driver declares itself to have variable length L2 headers, via, e.g.,
>> > some priv flag?
>>
>> At the time, the comments were not specific to AX25. Again, we should
>> probably put that bypass behind a flag, enabling validating in the common case.
>
> Just to make sure I'm on the same page as you (since you have more
> history with this one..) we are going to have a priv_flags like
> IFF_VAR_L2HDR which (today) would only be set for ax25, and
> we would only take the CAP_SYS_RAWIO branch for IFF_VAR_L2HDR, right?

I suggested a sysctl. But either approach may cause test applications
that depend on current behavior to start failing.

As your patch state, the contract is that any packet delivered to a
driver has the entire L2 in its linear section. Drivers are not required
to be robust against shorter packets, so there is no reason to test
those.

One option is to limit your fix to known fixed-header protocols.
In these cases hard_header_len is the minimum, so anything
smaller must be dropped.

For protocols with variable header length it is fine to send packets
shorter than hard_header_len, even with corrupted content (i.e.,
even if they would fail that protocol's validate callback), as long as
they exceed the minimum length. ax25 already has a min length
check through its protocol-specific validate callback.
