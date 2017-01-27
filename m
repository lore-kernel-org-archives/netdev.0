From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 15:51:54 -0500
Message-ID: <CAF=yD-+GGAdvgXoZeMshyQXXh_3m9kjDGNFf9FQ43rxJgk__vw@mail.gmail.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com> <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com> <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
 <20170127151119.GB25829@oracle.com> <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
 <20170127170320.GD25829@oracle.com> <CAF=yD-J6r+myVVAb5uNL8-Fua7Gr5q8U+veqPB=xm4gNOTp5Tg@mail.gmail.com>
 <20170127200639.GF25829@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34590 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdA0UyL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:54:11 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so60710807wmi.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 12:52:35 -0800 (PST)
In-Reply-To: <20170127200639.GF25829@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 3:06 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/27/17 14:29), Willem de Bruijn wrote:
>>
>> As your patch state, the contract is that any packet delivered to a
>> driver has the entire L2 in its linear section. Drivers are not required
>> to be robust against shorter packets, so there is no reason to test
>> those.
>>
>> One option is to limit your fix to known fixed-header protocols.
>> In these cases hard_header_len is the minimum, so anything
>> smaller must be dropped.
>
> yes, but how would you you know that this is a fixed-header protocol
> or a var-hdrlen protocol? AIUI the hard_header_len itself will not
> tell you this info: it will be 77 for ax25, 14 for ethernet,
> but that does not tell me that ax25 is the "robust-er" driver
> with a min requirement of 21 for the hdrlen.

Right. Identifying the outliers is the hard part.

> That's why I was thinking of a IFF_L2_VARHDRLEN in the priv_flags
> of the net_device.
>
>> For protocols with variable header length it is fine to send packets
>> shorter than hard_header_len, even with corrupted content (i.e.,
>> even if they would fail that protocol's validate callback), as long as
>> they exceed the minimum length. ax25 already has a min length
>> check through its protocol-specific validate callback.
>
> Another option that comes to mind.. the real thorn-in-the-flesh
> here is the CAP_SYS_RAWIO check. Would it be a better idea to ask
> the test-suites (since they seem to be the major consumer of
> that path) to use a special PF_PACKET socket option instead, that

Introducing a sysctl has the same effect. It is not possible to
identify all callers dependent on the current ABI.

I see these options
- make capable() check conditional on sysctl (or interface flag, ..)
- limit capable() check to drivers with with .validate callback
- hardcode a list of known fixed length protocols that must fail
- let privileged applications shoot themselves in the foot (change nothing).

The first will break tests. Though with a runtime fix: flip the flag.

The second will break variable length header protocols unless
you exhaustively search for all variable length protocols and add
validate callbacks first.
