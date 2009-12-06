From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Sun, 06 Dec 2009 23:44:21 +0100
Message-ID: <4B1C33C5.8030309@tvk.rwth-aachen.de>
References: <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
 <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
 <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
 <4B17A791.80808@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
 <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba>
 <4B1ADF79.6000101@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0912061206490.19391@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederic Leroy <fredo@starox.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:53919 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934341AbZLFWoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 17:44:16 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU900BYD5TXZI50@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sun, 06 Dec 2009 23:44:21 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.0912061206490.19391@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen schrieb:
> On Sat, 5 Dec 2009, Damian Lukowski wrote:
>=20
>> Frederic Leroy schrieb:
>>> Le Thu, 03 Dec 2009 15:10:11 +0100,
>>> Damian Lukowski <damian@tvk.rwth-aachen.de> a =E9crit :
>>>>> I suppose adding || !tp->retrans_stamp into the false condition i=
s
>>>>> fine as long as we don't then have a connection that can cause a
>>>>> connection to hang there forever for some reason (this needs to b=
e
>>>>> understood well enough, not just test driven in stables :-)).
>>>>>
>>>>>> Unluckily, I still cannot reproduce the scp stalls here, so it
>>>>>> would be nice if Frederic printed retrans_stamp together with
>>>>>> icsk_ca_state and icsk_retransmits, please.
>>>>> It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
>>>>> that might have some significant w.r.t what happens because of FR=
TO.
>>>> I made a patch for Frederic with Codebase
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.g=
it
>>>>
>>>> Thanks for testing.
>>> I made a new .11 trace with damian patch.
>>> The copy went to the end.
>> Could you please make another test and unplug the cable or drop ACKs=
 for
>> several seconds, so that some RTO retransmissions are performed?
>> I'd like to see if retrans_stamp remains constant. In the dmesg outp=
ut of
>> the 11th run, it seems to change while icsk_retransmits also increas=
es.
>> This is kind of bad for connection timeout calculation in the RTO ca=
se ...
>=20
>=20
> ...Good point, I think that's another bug in this area. We should pre=
vent=20
> retrans_stamp update when the RTO itself caused tp->retrans_out to be=
come
> zero. This bug affects also other things that are based on retrans_st=
amp,=20
> not only your code but there the effect is just less devastating.
>=20
> ...Anyway, we know already what happens by reading code when we know =
the=20
> case what to look for. If tcp_retransmit_skb encounters any error no=20
> retrans_stamp is changed (besides, cable might not be enough if you d=
on't=20
> lose the route, depends on configuration what happens). And if retran=
s_out=20
> is zero, the stamp gets updated (assuming the rexmit was successfully=
=20
> made without some error condition).
>=20
> What I think we need is something like this to handle all error cases=
=20
> cleanly (plus to fix that another bug I mentioned above):
>=20
> 	if (!icsk->icsk_retransmits)
> 		return false;
>=20
> 	if (unlikely(!tp->retrans_stamp)) {
> 		start_ts =3D TCP_SKB_CB(tcp_write_queue_head(sk))->when;
> 	} else {
> 		start_ts =3D tp->retrans_stamp;
> 	}
>=20
> ...and then use that timestamp in the substraction. It handles the ca=
se=20
> where retrans_stamp was never updated (agreeably there are corner cas=
es=20
> even then where the connection doesn't die exactly when we would want=
 when=20
> retrans_stamp got set on some high icsk_retransmits but still it woul=
d=20
> only be less than double of the specified time). ...We just need to a=
udit=20
> that tcp_write_queue_head and when are always valid when call happens=
 (I=20
> think they should be but that has to checked).

retransmits_timed_out() is called directly by tcp_retransmit_timer() an=
d by
tcp_write_timeout() which itself is only called by tcp_retransmit_timer=
().
As tcp_retransmit_timer() calls tcp_write_queue_head() at two points,
I think it is safe to assume, that it will be valid in
retransmits_timed_out() as well.
Also I have checked, that any call of tcp_transmit_skb() is preceded by
an update of cb->when. So it should be set and valid in
retransmits_timed_out(). Do you agree?

Anyway, how to proceed now? Should I make a patch and post it? If yes, =
on
which mailing list, which codebase? Or maybe it should be posted in a
series of patches, which also fixes the ENOMEM issue (which I do not re=
ally
have a clue about)?

Damian
