From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 15:10:11 +0100
Message-ID: <4B17C6C3.1060000@tvk.rwth-aachen.de>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederic Leroy <fredo@starox.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:60945 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755959AbZLCOKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 09:10:07 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU20061UY10DT00@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Dec 2009 15:10:13 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen schrieb:
> On Thu, 3 Dec 2009, Damian Lukowski wrote:
>=20
>>> On Thu, 3 Dec 2009, Frederic Leroy wrote:
>>>> On Wed, Dec 02, 2009 at 08:17:44PM +0100, Damian Lukowski wrote:
>>>>> could you please printk retrans_stamp just before the return in=20
>>>>> include/net/tcp.h:retransmits_timed_out()?
>>>>> If the value is not monotonically increasing but is reset to 0 at=
 some
>>>>> point, this might lead to problems in tcp_write_timeout().
>>>>> It's the only idea I have now.
>>>> Your idea is good.
>>>> Only one out of 4 value is not null.
>>>>
>>>> Logs corresponding on http://wwW.starox.org/pub/scp_stall is .10
>>>>
>>>> I make 2 attempts. Printk corresponding to .10 are those after the=
 line=20
>>>> "wlan1 enter promiscuous mode"
>>> Nice thinking indeed Damian, thanks. ...But but, where exactly did =
you=20
>>> print? ...There are multiple returns and the return false branch is=
=20
>>> expected to have a zero retrans_stamp in a typical case but that is=
 not
>>> a problem because we never use the value.
>> Yes, it's the retrans_stamp in the subtraction I suspected to be 0.
>> I also suspect this to happen only in the ca_state < CA_Loss case,
>> so one first solution might be to return true whenever retrans_stamp=
 =3D=3D 0.
>=20
> I suppose adding || !tp->retrans_stamp into the false condition is fi=
ne=20
> as long as we don't then have a connection that can cause a connectio=
n=20
> to hang there forever for some reason (this needs to be understood we=
ll=20
> enough, not just test driven in stables :-)).
>=20
>> Unluckily, I still cannot reproduce the scp stalls here, so it would=
 be nice
>> if Frederic printed retrans_stamp together with icsk_ca_state and
>> icsk_retransmits, please.
>=20
> It wouldn't hurt to know tp->packets_out and tp->retrans_out too, tha=
t=20
> might have some significant w.r.t what happens because of FRTO.

I made a patch for Frederic with Codebase
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

Thanks for testing.


diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..c170948 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1268,7 +1268,8 @@ static inline bool retransmits_timed_out(const st=
ruct sock *sk,
 {
 	unsigned int timeout, linear_backoff_thresh;
=20
-	if (!inet_csk(sk)->icsk_retransmits)
+	if (!inet_csk(sk)->icsk_retransmits ||
+	    !tcp_sk(sk)->retrans_stamp)
 		return false;
=20
 	linear_backoff_thresh =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
@@ -1279,6 +1280,11 @@ static inline bool retransmits_timed_out(const s=
truct sock *sk,
 		timeout =3D ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
 			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
=20
+	printk("stamp, rstamp, retrans, ca, p_out, retr_out: "
+	       "%u, %u, %u, %u, %u, %u\n", tcp_time_stamp,
+	       tcp_sk(sk)->retrans_stamp, inet_csk(sk)->icsk_retransmits,
+	       inet_csk(sk)->icsk_ca_state, tcp_sk(sk)->packets_out,
+	       tcp_sk(sk)->retrans_out);
 	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=3D timeout;
 }
=20
--=20
1.6.4.4
