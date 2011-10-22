From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY setsockopt
Date: Fri, 21 Oct 2011 23:49:00 -0700
Message-ID: <CAHo-OoxtAmzPjr4R7jQOk9GGQo7i-qVmoaY8vTYDQDj1HXsPNA@mail.gmail.com>
References: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com>
	<20111022.000406.350185785547409199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:60269 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab1JVGtC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 02:49:02 -0400
Received: by gyb13 with SMTP id 13so4463211gyb.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 23:49:01 -0700 (PDT)
In-Reply-To: <20111022.000406.350185785547409199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/21 David Miller <davem@davemloft.net>:
> From: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
> Date: Fri, 21 Oct 2011 15:22:05 -0700
>
>> From: Maciej =C5=BBenczykowski <maze@google.com>
>>
>> This change adds a sysctl (/proc/sys/net/core/allow_so_priority)
>> with a default of true (1), as such it does not change the default
>> behaviour of the Linux kernel.
>>
>> This sysctl can be set to false (0), this will result in non
>> CAP_NET_ADMIN processes being unable to set SO_PRIORITY socket
>> option.
>>
>> This is desireable if we want to rely on socket/skb priorities
>> being inferred from TOS/TCLASS bits.
>>
>> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>
> The socket layer is not the place to enforce this.
>
> The ingress into your MPLS/RSVP cloud that actually provides the
> quality of service is where you control and mangle the TOS as needed.
>
> Sorry, I'm not applying anything like this. =C2=A0Any machine on your
> network can spit out any TOS it wants, and if you have control over
> the apps change it's behavior there. =C2=A0If you don't have control =
over
> the apps then filter and mangle.

Hmm, so I already have container (cgroup) limits on what TOS settings,
a process is allowed to set (query: would you be interested in acceptin=
g a patch
for that at some point in the future?).

Normally setting IP_TOS also automatically sets sock->sk_priority
(based on a mapping), which
gets inherited into skb->priority, which can then be used for stuff
like hardware
priority queue dispatch (basically xps + skb->priority queue selection)=
=2E
Either via an XPS like mechanism, or a QDISC like mechanism (preferred)=
, or
an in-driver mechanism (currently have a hack which does this).

However, processes can also manually override the sk_priority by callin=
g
SO_PRIORITY directly, at which point their IP_TOS and SO_PRIORITY no
longer match.

This patch allows you to disable this ability.  It's not affecting the
on-the-wire bits
in any way, it's really only affecting packet classification at the
qdisc and in the driver.

As you can see this patch isn't about TOS, it's about the kernel
internal skb priority setting.

On a related note, while setting IP_TOS sets sk_priority, setting
IPV6_TCLASS does not
set sk_priority.  I'd like to see this behaviour be consistent. As
such was planning on
sending you a patch to add sk_priority =3D rt_tos2priority(val) to the
IPV6_TCLASS setsockopt
code path.  Is that ok?

- Maciej
