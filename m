From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [Query] TCP TFO Query
Date: Tue, 11 Dec 2012 14:04:29 -0800
Message-ID: <CAK6E8=edgWX1Ye3a6UrqfAaOUG0r=9N8ss39nqRbw8F3UA83Cw@mail.gmail.com>
References: <CAD6NSj5Qv3n+0a2rdTaiCtUtT5DXZEE4-K3qxaVX+XMK6Q=SFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ketan Kulkarni <ketkulka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:57632 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488Ab2LKWEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:04:51 -0500
Received: by mail-ie0-f176.google.com with SMTP id 13so14564717iea.35
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 14:04:51 -0800 (PST)
In-Reply-To: <CAD6NSj5Qv3n+0a2rdTaiCtUtT5DXZEE4-K3qxaVX+XMK6Q=SFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ketan,

On Tue, Dec 11, 2012 at 9:29 AM, Ketan Kulkarni <ketkulka@gmail.com> wrote:
> Hi,
> I am testing tcp tfo behavior with httping client and polipo server on 3.7rc-8
>
> One observation from my TFO testing  -If for a connection server sends
> a cookie to client, client always does TFO for subsequent connections.
> This is ok.
>
> If for some reason, server stops supporting TFO (either because server
> got restarted without TFO support (in my case) or because path changed
> and the nw node is dropping packet with unknown syn option or
> stripping the option), client does not clear up its cookie cache. It
> always sends data in syn and server never acks the syn-data and client
> retransmits.
>
> As per kernel code -if syn-data is not acked it is retransmitted
> immediately - with the assumption first syn was dropped (but the
> assumption server stopped supporting TFO might not have been
> considered)
>
> Will it be better to flush the cookie for this server and re-attempt
> the cookie "negotiation" on subsequent connection than to retransmit
> the data every time?
>
> Your thoughts?

In our initial design the client actually removes the cookie of the
particular server
(!= flush the entire cache though). Later on we changed to the current
behavior because
it does not have a performance penalty. It falls back to regular handshake:

SYN/cookie/data -> SYN-ACK acking ISN -> ACK(data).

It may happen frequently when a large server farms are upgrading to support TFO.

However there are always more options:
1) Server can selectively instrument to delete old cookies by sending a SYN-ACK
   acking initial sequence with a null TFO option (== caching a null cookie ==
   removing the older one).
2) another client-side flag in sysctl_tcp_fastopen to remove cookie if SYN-ACK
   only acks the syn sequence.
3) combination of 1 and 2.

More ideas are welcome :)

NOTE: I've checked in a patch so that syn-data not acked is not treated as a
network-drop.
http://patchwork.ozlabs.org/patch/171978/

Yuchung

>
> Thanks,
> Ketan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
