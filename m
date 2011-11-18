From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 20:27:26 +0200
Message-ID: <4EC6A38E.6060404@iki.fi>
References: <20111117190925.GA23214@elliptictech.com>  <20111118162709.GA8342@elliptictech.com> <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47384 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab1KRS1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 13:27:33 -0500
Received: by bke11 with SMTP id 11so3760172bke.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 10:27:32 -0800 (PST)
In-Reply-To: <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 06:39 PM, Eric Dumazet wrote:
> Le vendredi 18 novembre 2011 =C3=A0 11:27 -0500, Nick Bowler a =C3=A9=
crit :
>> On 2011-11-17 14:09 -0500, Nick Bowler wrote:
>>> One of the tests we do with IPsec involves sending and receiving UD=
P
>>> datagrams of all sizes from 1 to N bytes, where N is much larger th=
an
>>> the MTU.  In this particular instance, the MTU is 1500 bytes and N =
is
>>> 10000 bytes.  This test works fine with IPv4, but I'm getting an
>>> occasional oops on Linus' master with IPv6 (output at end of email)=
=2E  We
>>> also run the same test where N is less than the MTU, and it does no=
t
>>> trigger this issue.  The resulting fallout seems to eventually lock=
 up
>>> the box (although it continues to work for a little while afterward=
s).
>>>
>>> The issue appears timing related, and it doesn't always occur.  Thi=
s
>>> probably also explains why I've not seen this issue before now, as =
we
>>> recently upgraded all our lab systems to machines from this century
>>> (with newfangled dual core processors).  This also makes it somewha=
t
>>> hard to reproduce, but I can trigger it pretty reliably by running =
'yes'
>>> in an ssh session (which doesn't use IPsec) while running the test:
>>> it'll usually trigger in 2 or 3 runs.  The choice of cipher suite
>>> appears to be irrelevant.
>>>
>>> I built a relatively old kernel (2.6.34) and could not reproduce th=
e
>>> issue there, so I ran a git bisect.  It pointed to the following, w=
hich
>>> (unsurprisingly) no longer reverts cleanly.
>>>
>>> Let me know if you need any more info.  I'll see if I can reproduce=
 the
>>> issue with a smaller test case...
>>
>> OK, here's a somewhat straigthforward way to reproduce it that I've
>> found.  It uses a short test program called "udp_burst" which simply
>> transmits a bunch of UDP datagrams at all sizes between 1 and 10000,
>> included at the end of this mail.
>>[snip]
>=20
> Please note commit 80c802f307 added a known bug, fixed in commit
> 0b150932197b (xfrm: avoid possible oopse in xfrm_alloc_dst)
>=20
> Given commit 80c802f307 complexity, we can assume other bugs are to b=
e
> fixed as well.
>=20
> Unfortunately, Timo seems unresponsive.

This looks quite different. And I've been trying to figure out what
causes this. However, the OOPS happens at ip6_fragment(), indicating
that there was not enough allocated headroom (skb underrun). My initial
thought is ipv6 bug that just got uncovered by my commit; especially
since ipv4 side is happy. But I haven't yet been able to figure this on=
e
out.

Could you also try Herbert's latest patch set:
  [0/6] Replace LL_ALLOCATED_SPACE to allow needed_headroom adjustment

This changes how the headroom is calculated, and *might* fix this issue
too if it's caused by the same SMP race condition which got uncovered b=
y
my other commit earlier.

- Timo
