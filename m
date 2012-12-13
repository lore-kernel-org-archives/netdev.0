From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [Query] TCP TFO Query
Date: Wed, 12 Dec 2012 19:49:56 -0800
Message-ID: <CAK6E8=fNsEoBnA0UTo8ve0s39_jmyFF6XtmVD0+NgcwhPStm7w@mail.gmail.com>
References: <CAD6NSj5Qv3n+0a2rdTaiCtUtT5DXZEE4-K3qxaVX+XMK6Q=SFg@mail.gmail.com>
 <CAK6E8=edgWX1Ye3a6UrqfAaOUG0r=9N8ss39nqRbw8F3UA83Cw@mail.gmail.com> <CAD6NSj4dMG3OC0mb4Qiq2eXTNwFBonkcnw=gRF5YAef-5yjeVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ketan Kulkarni <ketkulka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:37588 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab2LMDuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 22:50:17 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so1557816iay.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 19:50:16 -0800 (PST)
In-Reply-To: <CAD6NSj4dMG3OC0mb4Qiq2eXTNwFBonkcnw=gRF5YAef-5yjeVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2012 at 10:17 AM, Ketan Kulkarni <ketkulka@gmail.com> wrote:
> Thanks Yuchung for your reply.
>
> My only concern is -If syn+data is sent by client and syn-ack only acks the
> ISN, then isnt this a sufficient indication that server now is not
> supporting the TFO? So for further connections to this server, instead of
> sending syn+data, only ask for cookie. (fall back to the state where it was
> all started) (Note that this condition is different from syn+data is dropped
> in the nw.)
>
> I agree with you in saying it doesn't lead to any performance penalty,
> however sending syn+data to a server seems a little odd when we know we have
> sufficient information to believe that it may not be accepted at first,
> retransmitted later. And otherwise we also have a way to fall back and
> re-attempt the TFO.
Your proposal sounds  reasonable. We can change that. In addition,
maybe we can change the server to send SYN-ACK acking ISN only with a
cookie option, if  the server prefers the client to still do SYN-data-cookie
next time for some reason. I will try prepare a rfc patch soon.

>
> Thoughts?
>
> Thanks,
> Ketan
>
> On Dec 12, 2012 3:34 AM, "Yuchung Cheng" <ycheng@google.com> wrote:
>>
>> Hi Ketan,
>>
>> On Tue, Dec 11, 2012 at 9:29 AM, Ketan Kulkarni <ketkulka@gmail.com>
>> wrote:
>> > Hi,
>> > I am testing tcp tfo behavior with httping client and polipo server on
>> > 3.7rc-8
>> >
>> > One observation from my TFO testing  -If for a connection server sends
>> > a cookie to client, client always does TFO for subsequent connections.
>> > This is ok.
>> >
>> > If for some reason, server stops supporting TFO (either because server
>> > got restarted without TFO support (in my case) or because path changed
>> > and the nw node is dropping packet with unknown syn option or
>> > stripping the option), client does not clear up its cookie cache. It
>> > always sends data in syn and server never acks the syn-data and client
>> > retransmits.
>> >
>> > As per kernel code -if syn-data is not acked it is retransmitted
>> > immediately - with the assumption first syn was dropped (but the
>> > assumption server stopped supporting TFO might not have been
>> > considered)
>> >
>> > Will it be better to flush the cookie for this server and re-attempt
>> > the cookie "negotiation" on subsequent connection than to retransmit
>> > the data every time?
>> >
>> > Your thoughts?
>>
>> In our initial design the client actually removes the cookie of the
>> particular server
>> (!= flush the entire cache though). Later on we changed to the current
>> behavior because
>> it does not have a performance penalty. It falls back to regular
>> handshake:
>>
>> SYN/cookie/data -> SYN-ACK acking ISN -> ACK(data).
>>
>> It may happen frequently when a large server farms are upgrading to
>> support TFO.
>>
>> However there are always more options:
>> 1) Server can selectively instrument to delete old cookies by sending a
>> SYN-ACK
>>    acking initial sequence with a null TFO option (== caching a null
>> cookie ==
>>    removing the older one).
> In the case I mentioned, this might not help because server got restarted
> with TFO disabled so having this option can help cases when server
> understands/supports tfo and know when to delete the client side cookie. Or
> may be I am missing something!!!
>
>> 2) another client-side flag in sysctl_tcp_fastopen to remove cookie if
>> SYN-ACK
>>    only acks the syn sequence.
> My view is to prefer keeping knobs as minimum as possible as otherwise imo
> we might put extra efforts on the user to know and understand why and what
> this flag is  when he is simply interested in TFO.
>
>> 3) combination of 1 and 2.
>>
>> More ideas are welcome :)
>>
>> NOTE: I've checked in a patch so that syn-data not acked is not treated as
>> a
>> network-drop.
>> http://patchwork.ozlabs.org/patch/171978/
>>
>> Yuchung
>>
>> >
>> > Thanks,
>> > Ketan
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
