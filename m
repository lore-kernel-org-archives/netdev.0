From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 14:23:02 +0300
Message-ID: <4BB08D96.8090909@iki.fi>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f222.google.com ([209.85.219.222]:59467 "EHLO
	mail-ew0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755452Ab0C2LXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 07:23:06 -0400
Received: by ewy22 with SMTP id 22so1777005ewy.37
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 04:23:04 -0700 (PDT)
In-Reply-To: <20100329111025.GA23927@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 01:36:40PM +0300, Timo Ter=E4s wrote:
>>>> We can still drop the locking, as ->dead can be made atomic_t.
>>> No it doesn't need to be atomic, reading an int is always atomic.
>> The only reason why it needs to be atomic is because of
>> xfrm_policy_kill() which writes '1' and checks if it was zero
>> previously. Since the idea is to get rid of the policy lock, we
>> can turn ->dead flag to atomic_t and use atomic_xchg for that.
>> Otherwise it would be ok to have it as just regular int.
>=20
> I don't see the point.  As long as the data paths do not take
> the lock changing this doesn't buy us much.  You're still making
> that cacheline exclusive.

To my understanding declaring an atomic_t, or reading it with
atomic_read does not make cache line exclusive. Only the atomic_*
writing to it take the cache line. And since this is done exactly
once for policy (or it's a bug/warn thingy) it does not impose
significant performance issue.

But looking at the code more. The check should not be needed.
xfrm_policy_kill() is only called if the entry is removed from
the hash list, which can happen only once.

Do you think we can just change it to unconditionally writing
to "policy->walk.dead =3D 1;" and be done with that?

Alternatively, we can move the ->dead check to be done while
holding the hash lock to guarantee no one else is writing
simultaneously.
