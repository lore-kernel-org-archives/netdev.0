From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v3 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Wed, 23 Apr 2014 15:37:13 +0900
Message-ID: <CAKD1Yr1N43cA5DqV2kPi3hGpTF5uqPgLvtcuF7Ac8uDuj_ZyTw@mail.gmail.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398179656-9313-1-git-send-email-lorenzo@google.com> <20140422154842.GC1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:53077 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbaDWGhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 02:37:34 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so510974iec.36
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 23:37:33 -0700 (PDT)
In-Reply-To: <20140422154842.GC1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 12:48 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> +     *optp = NULL;
>> +     *dstp = NULL;
>> +     *hlimit = *tclass = *dontfrag = -1;
>
> Do we need those? If we return != 0 from ip6_datagram_send_common we
> know the in/out arguments may or maybe got an update an as such cannot
> use them.
>
> Caller can initialize dstp = NULL so we can pass dstp to dst_release in the
> error path in the caller function (dst_release checks for argument != NULL).

Initalizing optp was not useful. As you say, the callers won't use it
if we return an error. I've removed it.

I've also removed the initialization of dstp. After thinking about it,
I agree it's bad for the callers to rely on this function to set dstp
to NULL on failure. It's more reasonable for the callers to assume
that the dst pointer they pass in won't be touched on failure.

As for hlimit, tclass and dontfrag, they (and connected), I think it's
useful to initialize them here because it simplifies the code. Since
we set them to -1 early on, we can later do things like "if (*hlimit <
0) { set the default hop limit }" and have things work regardless of
whether a hop limit was passed in via cmsg. I don't think it's
confusing: variables are all calculated and returned by this function,
and the callers should not be setting them since they have no
information on what to set them to. Also, they don't need to be freed.
I've moved them closer to where they are actually set.

>> +     if (!ipv6_addr_any(daddr))
>> +             fl6->daddr = *daddr;
>> +     else
>> +             fl6->daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
>
> Maybe a newline?

Added.

> We would also need a fl6_sock_release here because we finished processing
> it.
>
> You could also release the flowlabel after fl6_merge_options and could remove
> the fl6_sock_release after ip6_sk_dst_lookup_flow in the error handling.

Yes, that's better. Done.
