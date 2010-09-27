From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix TSO FACK loss marking in tcp_mark_head_lost
Date: Mon, 27 Sep 2010 11:11:14 -0700 (PDT)
Message-ID: <20100927.111114.124003889.davem@davemloft.net>
References: <1285370526-18279-1-git-send-email-ycheng@google.com>
	<alpine.DEB.2.00.1009271520560.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759982Ab0I0SKz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 14:10:55 -0400
In-Reply-To: <alpine.DEB.2.00.1009271520560.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 27 Sep 2010 15:22:09 +0300 (EEST)

> On Fri, 24 Sep 2010, Yuchung Cheng wrote:
>=20
>> When TCP uses FACK algorithm to mark lost packets in
>> tcp_mark_head_lost(), if the number of packets in the (TSO) skb is
>> greater than the number of packets that should be marked lost, TCP
>> incorrectly exits the loop and marks no packets lost in the skb. Thi=
s
>> underestimates tp->lost_out and affects the recovery/retransmission.
>> This patch fargments the skb and marks the correct amount of packets
>> lost.
>>=20
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>>  net/ipv4/tcp_input.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>=20
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 1bc87a0..e4f472e 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -2532,7 +2532,8 @@ static void tcp_mark_head_lost(struct sock *sk=
, int packets)
>>  			cnt +=3D tcp_skb_pcount(skb);
>> =20
>>  		if (cnt > packets) {
>> -			if (tcp_is_sack(tp) || (oldcnt >=3D packets))
>> +			if ((tcp_is_sack(tp) && !tcp_is_fack(tp)) ||
>> +			    (oldcnt >=3D packets))
>>  				break;
>> =20
>>  			mss =3D skb_shinfo(skb)->gso_size;
>>=20
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

BTW, the history is that this code was added to fix a bug because
we didn't handle GSO packets at all at one point.

But, conservatively, we didn't do splits here for SACK, and it was
stated in the commit that we would look into it "at some point in the
future" :-)

--------------------
commit c137f3dda04b0aee1bc6889cdc69185f53df8a82
Author: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Date:   Mon Apr 7 22:32:38 2008 -0700

    [TCP]: Fix NewReno's fast rexmit/recovery problems with GSOed skb
   =20
    Fixes a long-standing bug which makes NewReno recovery crippled.
    With GSO the whole head skb was marked as LOST which is in
    violation of NewReno procedure that only wants to mark one packet
    and ended up breaking our TCP code by causing counter overflow
    because our code was built on top of assumption about valid
    NewReno procedure. This manifested as triggering a WARN_ON for
    the overflow in a number of places.
   =20
    It seems relatively safe alternative to just do nothing if
    tcp_fragment fails due to oom because another duplicate ACK is
    likely to be received soon and the fragmentation will be retried.
   =20
    Special thanks goes to Soeren Sonnenburg <kernel@nn7.de> who was
    lucky enough to be able to reproduce this so that the warning
    for the overflow was hit. It's not as easy task as it seems even
    if this bug happens quite often because the amount of outstanding
    data is pretty significant for the mismarkings to lead to an
    overflow.
   =20
    Because it's very late in 2.6.25-rc cycle (if this even makes in
    time), I didn't want to touch anything with SACK enabled here.
    Fragmenting might be useful for it as well but it's more or less
    a policy decision rather than mandatory fix. Thus there's no need
    to rush and we can postpone considering tcp_fragment with SACK
    for 2.6.26.
   =20
    In 2.6.24 and earlier, this very same bug existed but the effect
    is slightly different because of a small changes in the if
    conditions that fit to the patch's context. With them nothing
    got lost marker and thus no retransmissions happened.
   =20
    Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
    Signed-off-by: David S. Miller <davem@davemloft.net>
--------------------

To be honest, we should probably just remove the whole tcp_is_sack()
test, rather than special case FACK.

The cost isn't what it was when this code was added.  Back then we
didn't have Ilpo's restransmit queue coalescing code, so it would make
retransmit queue packet freeing more expensive.  But since the
coalescing code is there now, splitting all the time to record
accurate loss information should be fine.

Ilpo what do you say?
