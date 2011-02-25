From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] udp: avoid searching when no ports are available
Date: Fri, 25 Feb 2011 18:45:00 +0200
Message-ID: <AANLkTimodVFC8969md-f7iebS_9WvVahV9fPFFLtup73@mail.gmail.com>
References: <1298633711-11924-1-git-send-email-dbaluta@ixiacom.com>
	<1298635575.2659.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Rohan Chitradurga <rohan@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38948 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511Ab1BYQpD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 11:45:03 -0500
Received: by wwb22 with SMTP id 22so562460wwb.1
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 08:45:02 -0800 (PST)
In-Reply-To: <1298635575.2659.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 2:06 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 25 f=E9vrier 2011 =E0 13:35 +0200, Daniel Baluta a =E9cri=
t :
>> udp_lib_get_port uses a bitmap to mark used ports.
>>
>> When no ports are available we spend a lot of time, searching
>> for a port while holding hslot lock. Avoid this by checking if
>> bitmap is full.
>>
>>
>> Signed-off-by: Rohan Chitradurga <rohan@ixiacom.com>
>> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
>> ---
>> =A0net/ipv4/udp.c | =A0 =A06 ++++++
>> =A01 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index d37baaa..3e3592d 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -225,6 +225,12 @@ int udp_lib_get_port(struct sock *sk, unsigned =
short snum,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 udp_lib_lport_inuse(net,=
 snum, hslot, bitmap, sk,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 saddr_comp, udptable->log);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* avoid searching when no=
 ports are available */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bitmap_full(bitmap, PO=
RTS_PER_CHAIN)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unloc=
k_bh(&hslot->lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 snum =3D first;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Iterate on all poss=
ible values of snum for this hash.
>
> Really ? I wonder how you got your performance numbers then.
>
> First, PORTS_PER_CHAIN is wrong here, since its value is the max
> possible value (256 bits)

You are right. I have been working/testing on 2.6.32 where:

#define PORTS_PER_CHAIN (65536 / UDP_HTABLE_SIZE)

and I thought that the latest kernel has the same meaning
for PORTS_PER_CHAIN.

>
> #define UDP_HTABLE_SIZE_MIN =A0 =A0 =A0 =A0 =A0 =A0 =A0(CONFIG_BASE_S=
MALL ? 128 : 256)
> #define MAX_UDP_PORTS 65536
> #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN) =A0 -> =
256
>
> As soon as your machine (and most current machines have) has enough
> memory, UDP hash table size is not 256, but 1024 or 2048
>
> dmesg | grep "UDP hash"
> [ =A0 =A01.735203] UDP hash table entries: 2048 (order: 6, 327680 byt=
es)
>
> So real bitmap size is 64 or 32 bits.
>
> Your call to bitmap_full() always return false.

I guess now, the correct bitmap size is MAX_UDP_PORTS / (udptable->mask=
 + 1)
or  MAX_UDP_PORTS >> udptable->log,  right?

> I dont like this patch. If you have special UDP needs on a small
> machine, just add to kernel boot param "uhash_entries=3D8192", so tha=
t the
> bitmap has 8 bits only.

We don't have special needs on a small machine. We just want that when
when all UDP ports are exhausted, bind calls to fail faster.

I will be back with tests on latest kernel.

thanks,
Daniel.
