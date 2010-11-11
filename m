From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 08:03:32 +0100
Message-ID: <1289459012.17691.1001.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>
	 <1289427705.17691.52.camel@edumazet-laptop>
	 <4CDB226A.8080903@candelatech.com>
	 <1289432184.17691.141.camel@edumazet-laptop>
	 <4CDB2EBC.2090905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47679 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab0KKHDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 02:03:36 -0500
Received: by wyb28 with SMTP id 28so339451wyb.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 23:03:35 -0800 (PST)
In-Reply-To: <4CDB2EBC.2090905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 15:46 -0800, Ben Greear a =C3=A9cri=
t :
> On 11/10/2010 03:36 PM, Eric Dumazet wrote:
> > Le mercredi 10 novembre 2010 =C3=A0 14:53 -0800, Ben Greear a =C3=A9=
crit :
> >
> >> I did similar, and then wrote extra code to detect a 64-bit kernel=
 and if
> >> so assume that the counters wrap at 64 bits so I didn't have to po=
ll so
> >> often to make sure I didn't miss a wrap for a 10G NIC.  If instead=
 one wraps at 33
> >> bits and the other at 36, there is no way for me to deal with the =
wrap
> >> properly w/out explicitly knowing about that 33 and 36.
> >>
> >
> > How do you define 'wrap around' ? Maybe your definition is wrong.
>=20
> Maybe so.  My algorithm looks like:
>=20
>   // uint64 accum;
>   // uint32 old;
>   // uint32 new;
>   if (old > new) {
>       // This assumes counters wrap at 32 bits (ie, 0xFFFFFFFF).
>       accum +=3D ((uint32)(0xFFFFFFFF) - old) + new;
>   }
>   else if (old < new) {
>       accum +=3D new - old;
>   }
>   old =3D new;
>=20
> ...
>=20
> Is there some way I can do this w/out the (0xFFFFFFFF - old),
> and thus the assumption of 32-bit counters?
>=20

Yes, please take a look at RRD for an example, then you can adapt to
your needs.

<quote>

http://www.mrtg.org/rrdtool/tut/rrdtutorial.en.html

At the time of writing this document, RRDtool knows of counters that ar=
e
either 32 bits or 64 bits of size. These counters can handle the
following different values:

 - 32 bits: 0 ..           4294967295
 - 64 bits: 0 .. 18446744073709551615

If these numbers look strange to you, you can view them in their
hexadecimal form:

 - 32 bits: 0 ..         FFFFFFFF
 - 64 bits: 0 .. FFFFFFFFFFFFFFFF

RRDtool handles both counters the same. If an overflow occurs and the
delta would be negative, RRDtool first adds the maximum of a small
counter + 1 to the delta. If the delta is still negative, it had to be
the large counter that wrapped. Add the maximum possible value of the
large counter + 1 and subtract the erroneously added small value.

There is a risk in this: suppose the large counter wrapped while adding
a huge delta, it could happen, theoretically, that adding the smaller
value would make the delta positive. In this unlikely case the results
would not be correct. The increase should be nearly as high as the
maximum counter value for that to happen, so chances are you would have
several other problems as well and this particular problem would not
even be worth thinking about. Even though, I did include an example, so
you can judge for yourself.

The next section gives you some numerical examples for counter-wraps.
Try to do the calculations yourself or just believe me if your
calculator can't handle the numbers :)

Correction numbers:

 - 32 bits: (4294967295 + 1) =3D                                4294967=
296
 - 64 bits: (18446744073709551615 + 1)
                                    - correction1 =3D 18446744069414584=
320

 Before:        4294967200
 Increase:                100
 Should become: 4294967300
 But really is:             4
 Delta:        -4294967196
 Correction1:  -4294967196 + 4294967296 =3D 100

 Before:        18446744073709551000
 Increase:                             800
 Should become: 18446744073709551800
 But really is:                        184
 Delta:        -18446744073709550816
 Correction1:  -18446744073709550816
                                + 4294967296 =3D -18446744069414583520
 Correction2:  -18446744069414583520
                   + 18446744069414584320 =3D 800

 Before:        18446744073709551615 ( maximum value )
 Increase:      18446744069414584320 ( absurd increase, minimum for
 Should become: 36893488143124135935             this example to work )
 But really is: 18446744069414584319
 Delta:                     -4294967296
 Correction1:  -4294967296 + 4294967296 =3D 0
 (not negative -> no correction2)

 Before:        18446744073709551615 ( maximum value )
 Increase:      18446744069414584319 ( one less increase )
 Should become: 36893488143124135934
 But really is: 18446744069414584318
 Delta:                     -4294967297
 Correction1:  -4294967297 + 4294967296 =3D -1
 Correction2:  -1 + 18446744069414584320 =3D 18446744069414584319

As you can see from the last two examples, you need strange numbers for
RRDtool to fail (provided it's bug free of course), so this should not
happen. However, SNMP or whatever method you choose to collect the data=
,
might also report wrong numbers occasionally. We can't prevent all
errors, but there are some things we can do. The RRDtool "create"
command takes two special parameters for this. They define the minimum
and maximum allowed values. Until now, we used "U", meaning "unknown".
If you provide values for one or both of them and if RRDtool receives
data points that are outside these limits, it will ignore those values.
=46or a thermometer in degrees Celsius, the absolute minimum is just un=
der
-273. For my router, I can assume this minimum is much higher so I woul=
d
set it to 10, where as the maximum temperature I would set to 80. Any
higher and the device would be out of order.

=46or the speed of my car, I would never expect negative numbers and al=
so
I would not expect a speed higher than 230. Anything else, and there
must have been an error. Remember: the opposite is not true, if the
numbers pass this check, it doesn't mean that they are correct. Always
judge the graph with a healthy dose of suspicion if it seems weird to
you.

http://www.mrtg.org/rrdtool/doc/rrdcreate.en.html

COUNTER

    is for continuous incrementing counters like the ifInOctets counter
in a router. The COUNTER data source assumes that the counter never
decreases, except when a counter overflows. The update function takes
the overflow into account. The counter is stored as a per-second rate.
When the counter overflows, RRDtool checks if the overflow happened at
the 32bit or 64bit border and acts accordingly by adding an appropriate
value to the result.

</quote>


