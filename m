From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Tue, 23 Aug 2011 09:29:37 +0200
Message-ID: <1314084577.4791.30.camel@edumazet-laptop>
References: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
	 <1314078115-8121-4-git-send-email-sathya.perla@emulex.com>
	 <1314081677.4791.28.camel@edumazet-laptop>
	 <3367B80B08154D42A3B2BC708B5D41F642D8EDB9C6@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39538 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab1HWH3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 03:29:43 -0400
Received: by wyg24 with SMTP id 24so3990490wyg.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 00:29:42 -0700 (PDT)
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F642D8EDB9C6@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 ao=C3=BBt 2011 =C3=A0 00:06 -0700, Sathya.Perla@Emulex.Com =
a =C3=A9crit :
> >-----Original Message-----
> >From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >Sent: Tuesday, August 23, 2011 12:11 PM
> >
> >Le mardi 23 ao=C3=BBt 2011 =C3=A0 11:11 +0530, Sathya Perla a =C3=A9=
crit :
> >> The rx_drops_no_frags HW counter for RSS rings is 16bits in HW and=
 can
> >> wraparound often. Maintain a 32-bit accumulator in the driver to p=
revent
> >> frequent wraparound.
> >>
> >> Also, incorporated Eric's feedback to use ACCESS_ONCE() for the
> >accumulator
> >> write.
> <...>
> >>
> >> +static void accumulate_16bit_val(u32 *acc, u16 val)
> >> +{
> >> +#define lo(x)			(x & 0xFFFF)
> >> +#define hi(x)			(x & 0xFFFF0000)
> >> +	bool wrapped =3D val < lo(*acc);
> >> +	u32 newacc =3D hi(*acc) + val;
> >> +
> >> +	if (wrapped)
> >> +		newacc +=3D 65536;
> >> +	ACCESS_ONCE(*acc) =3D newacc;
> >> +}
> >> +
> >
> >I still feel something is wrong here :
> >
> >>  void be_parse_stats(struct be_adapter *adapter)
> >>  {
> >>  	struct be_erx_stats_v1 *erx =3D be_erx_stats_from_cmd(adapter);
> >> @@ -394,9 +406,13 @@ void be_parse_stats(struct be_adapter *adapte=
r)
> >>  	}
> >>
> >>  	/* as erx_v1 is longer than v0, ok to use v1 defn for v0 access =
*/
> >> -	for_all_rx_queues(adapter, rxo, i)
> >> -		rx_stats(rxo)->rx_drops_no_frags =3D
> >> -			erx->rx_drops_no_fragments[rxo->q.id];
> >
> >previous code was not doing a sum_of_all_queues.
> Yes, the new code still *does not* do a sum of all queues. The code j=
ust=20
> parses per-queue stats. For each queue, the 16 bit
> HW stats value is taken and stored in a 32-bit *per-queue* variable.
> The comment that "driver accumulates a 32-bit val" may be misleading.=
 The
> code here is not doing a sum of the per-queue stat.

Ah ok, I now see the code intent, and everything seems fine now, thanks
for explaining.


