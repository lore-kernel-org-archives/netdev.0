From: Joe Cao <caoco2002@yahoo.com>
Subject: Re: TCP stack bug related to F-RTO?
Date: Fri, 25 Sep 2009 08:58:15 -0700 (PDT)
Message-ID: <773030.8168.qm@web63404.mail.re1.yahoo.com>
References: <alpine.DEB.2.00.0909251556130.13543@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, caoco2002@yahoo.com
To: Ray Lee <ray-lk@madrabbit.org>,
	=?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753140AbZIYP6N@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0909251556130.13543@wel-95.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Ilpo,

Thanks for the reply!  Do you happen to know which patch fixed the prob=
lem? Is there a bug tracking system for linux kernel?

I studied the FRTO code in latest kernel 2.6.31.  It seems the problem =
is still there: =20

1. Every time a RTO fires, because tcp_is_sackfrto(tp) returns 1, tcp_u=
se_frto() returns true.  And the server tcp enters FRTO.
2. After the head of write queue is retransmitted, two new data packets=
 are transmitted, the server receives two dup-ACKs.  That will make the=
 TCP enter tcp_enter_frto_loss(), however, that only rests ssthresh and=
 some other fields.
3. After another longer RTO fires, because tcp_is_sackfrto(tp) returns =
1, tcp_use_frto() again returns true.  The stack enters FRTO again.
4. The above repeats and the stack couldn't retransmits the lost packet=
s faster.

Is my understanding above correct?

Thanks,
Joe=20

--- On Fri, 9/25/09, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Subject: Re: TCP stack bug related to F-RTO?
> To: "Ray Lee" <ray-lk@madrabbit.org>
> Cc: "Joe Cao" <caoco2002@yahoo.com>, "Netdev" <netdev@vger.kernel.org=
>, "LKML" <linux-kernel@vger.kernel.org>, jcaoco2002@yahoo.com
> Date: Friday, September 25, 2009, 6:09 AM
> On Thu, 24 Sep 2009, Ray Lee wrote:
>=20
> > [adding netdev cc:]
> >=20
> > On Thu, Sep 24, 2009 at 10:43 AM, Joe Cao <caoco2002@yahoo.com>
> wrote:
> > >
> > > Hello,
> > >
> > > I have found the following behavior with
> different versions of linux=20
> > > kernel. The attached pcap trace is collected with
> server=20
> > > (192.168.0.13) running 2.6.24 and shows the
> problem. Basically the=20
> > > behavior is like this:=20
> > >
> > > 1. The client opens up a big window,
> > > 2. the server sends 19 packets in a row (pkt #14-
> #32 in the trace), but all of them are dropped due to some
> congestion.
> > > 3. The server hits RTO and retransmits pkt #14 in
> #33
> > > 4. The client immediately acks #33 (=3D#14), and
> the server (seems like to enter F-RTO) expends the window
> and sends *NEW* pkt #35 & #36.=3DA0 Timeoute is doubled to
> 2*RTO; The client immediately sends two Dup-ack to #35 and
> #36.
> > > 5. after 2*RTO, pkt #15 is retransmitted in #39.
> > > 6. The client immediately acks #39 (=3D#15) in #40,
> and the server continues to expand the window and sends two
> *NEW* pkt #41 & #42. Now the timeoute is doubled to 4
> *RTO.
> > > 8. After 4*RTO timeout, #16 is retransmitted.
> > > 9....
> > > 10. The above steps repeats for retransmitting
> pkt #16-#32 and each time the timeout is doubled.
> > > 11. It takes a long long time to retransmit all
> the lost packets and before that is done, the client sends a
> RST because of timeout.
> > >
> > > The above behavior looks like F-RTO is in effect.
> =A0And there seems to=20
> > > be a bug in the TCP's congestion control and
> retransmission algorithm.=20
> > > Why doesn't the TCP on server (running 2.6.24)
> enter the slow start?=20
> > > Why should the server take that long to recover
> from a short period=20
> > > of packet loss?
> > >
> > > Has anyone else noticed similar problem before?
> =A0If my analysis was=20
> > > wrong, can anyone gives me some pointers to
> what's really wrong and=20
> > > how to fix it?
>=20
> Yes, 2.6.24 is an obsoleted version with known wrongs in
> FRTO=20
> implementation. Fixes never when to 2.6.24 stable series as
> it was=20
> _already_ obsoleted when the problems where reported and
> found. The=20
> correct fixes may be found from 2.6.25.7 (.7 iirc) and are
> included from=20
> 2.6.26 onward too.
>=20
> Just in case you happen to run ubuntu based kernel from
> that era (of=20
> course you should be reporting the bug here then...), a
> word of warning:=20
> it seemed nearly impossible for them to get a simple thing
> like that=20
> fixed, I haven't been looking if they'd eventually come to
> some sensible=20
> conclusion in that matter or is it still unresolved (or
> e.g., closed=20
> without real resolution).
>=20
> --=20
>  i.


     =20
