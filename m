From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 13:19:54 +0100
Message-ID: <4B17ACEA.9060804@tvk.rwth-aachen.de>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederic Leroy <fredo@starox.org>, Netdev <netdev@vger.kernel.org>,
	Asdo <asdo@shiftmail.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:54298 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753466AbZLCMtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:49:49 -0500
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU200G4YSX736E0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Dec 2009 13:19:55 +0100 (CET)
In-reply-to: <4B17A791.80808@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Damian Lukowski schrieb:
> Ilpo J=E4rvinen schrieb:
>> I've added Greg as CC to make him aware of this issue in early as it=
 now=20
>> affects 2.6.32 too (rather important to get dealt quickly in stable =
once=20
>> we have a tested solution since TCP is pretty broken with the silent=
=20
>> deaths this problem seems to cause). ...One possibility would be to =
just=20
>> queue the tested revert to stable and sort this thing out for 2.6.33=
 in=20
>> net-2.6.
>>
>> Opinions, Dave?, Greg?
>>
>> Now back to the issue...
>>
>> You said in the other mail that "All further test are on linus-stabl=
e=20
>> tree.", which has this contradiction that Linus does not maintain st=
able=20
>> trees. Which exactly was the tree used for the .9. test, Linus' tree=
 or=20
>> the 2.6.31 stable tree? I suppose the former since the revert wouldn=
't=20
>> apply to 2.6.31 so I just want to confirm.
>>
>>
>> On Thu, 3 Dec 2009, Frederic Leroy wrote:
>>> On Wed, Dec 02, 2009 at 08:17:44PM +0100, Damian Lukowski wrote:
>>>> could you please printk retrans_stamp just before the return in=20
>>>> include/net/tcp.h:retransmits_timed_out()?
>>>> If the value is not monotonically increasing but is reset to 0 at =
some
>>>> point, this might lead to problems in tcp_write_timeout().
>>>> It's the only idea I have now.
>>> Your idea is good.
>>> Only one out of 4 value is not null.
>>>
>>> Logs corresponding on http://wwW.starox.org/pub/scp_stall is .10
>>>
>>> I make 2 attempts. Printk corresponding to .10 are those after the =
line=20
>>> "wlan1 enter promiscuous mode"
>> Nice thinking indeed Damian, thanks. ...But but, where exactly did y=
ou=20
>> print? ...There are multiple returns and the return false branch is=20
>> expected to have a zero retrans_stamp in a typical case but that is =
not
>> a problem because we never use the value.
>=20
> Yes, it's the retrans_stamp in the subtraction I suspected to be 0.
> I also suspect this to happen only in the ca_state < CA_Loss case,
> so one first solution might be to return true whenever retrans_stamp =
=3D=3D 0.

return false, of course.

> Unluckily, I still cannot reproduce the scp stalls here, so it would =
be nice
> if Frederic printed retrans_stamp together with icsk_ca_state and
> icsk_retransmits, please.
>=20
> Damian
>=20
>> ...Anyway, if I'm wrong with my suspicion and it still holds that we=
 have=20
>> zero retrans_stamp in the substraction too, it could have something =
to do=20
>> with this snippet:
>>
>> static void tcp_try_to_open(struct sock *sk, int flag)
>> {
>>         struct tcp_sock *tp =3D tcp_sk(sk);
>>
>>         tcp_verify_left_out(tp);
>>
>>         if (!tp->frto_counter && tp->retrans_out =3D=3D 0)
>>                 tp->retrans_stamp =3D 0;
>>
>> ...It bit me last time when FRTO was enabled after very small modifi=
cation=20
>> (without running a full verification after the trivial looking=20
>> modification). ...So I've worked around this clearing for FRTO as yo=
u=20
>> can see :-).
>>
>>
>> Also, we have the another mystery to be solved, the fast retransmiss=
ion is=20
>> not triggered for some reason (or alternatively not captured in to a=
=20
>> log), even in the working .9. case. It would be easy to see whether =
it=20
>> works at all from TCP point of view by looking into mibs once you ha=
ve=20
>> have some transfers in a working configuration:
>>
>> grep -A1 TCP /proc/net/netstat
>>
>> ...luckily this fast retransmit issue is less crucial as almost all =
people=20
>> are pretty happy already if their RTO-based recovery works even if t=
he=20
>> fast recovery would not. So figuring it out can be postponed (if one=
 has=20
>> to prioritize) until the silent death issue is out of the way.
>>
>>
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

