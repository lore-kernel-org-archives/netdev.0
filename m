From: "Bernard, f6bvp" <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sat, 04 Oct 2008 20:30:26 +0200
Message-ID: <1223145027.23358.20.camel@f6bvp-5>
References: <20081002194845.GB2664@ami.dom.local>
	 <20081003073418.GA5235@ff.dom.local>  <20081003074351.GB5235@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:53733 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378AbYJDS3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Oct 2008 14:29:18 -0400
In-Reply-To: <20081003074351.GB5235@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek,

=46ollowing your indications I did it both ways !
Without =EF=BB=BFcommit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74 patch
kernel-2.6.27-rc7 is no longer subject to kernel panic when running ROS=
E
applications.
Reversely, when this patch is applied to rose-patched 2.6.25.10 kernel,
this one reboots a few seconds after ROSE application are started.
Otherwise it is very stable.
I checked about three times this behaviour for both kernels with and
without the incriminated patch.
This confirms without doubt that it is responsible of observed kernel
panic.
Is there however a possibility to find a solution to cure the problem
this patch was dedicated to ?=20

Bernard


Le vendredi 03 octobre 2008 =C3=A0 07:43 +0000, Jarek Poplawski a =C3=A9=
crit :
> On Fri, Oct 03, 2008 at 07:34:18AM +0000, Jarek Poplawski wrote:
> > On 02-10-2008 21:48, Jarek Poplawski wrote:
> > > On Thu, Oct 02, 2008 at 08:20:18PM +0200, Bernard, f6bvp wrote:
> > ...
> > >> Although I did not change anything, and contrarily to my previou=
s
> > >> observation, the system instability as shown above occurs
> > >> systematically.
> > >> There was no problem with Kernel 2.6.25-10 I was using before (w=
ith
> > >> patches for AX25 and ROSE that are now included in 2.6.27-rc7).
> >=20
> > Then it could be useful to try our luck with reverting some other
> > "suspicious" changes added in the meantime. My first candidate is
> > attached below. (So you could test this with vanilla 2.6.27-rc7 or
> > later, with or without any of the patches in this thread, and the
> > patch below reverted.)
>=20
> Hmm... Of course, you could do this other way as well: 2.6.25-10 etc.
> with this patch applied.
>=20
> Jarek P.
>=20
> >=20
> > >> I did not try 2.6.26 on this machine, thus I cannot tell if the =
bug was
> > >> already present.
> > >> Would it be worth to test 2.6.26 ?  =20
> > >=20
> > > Yes, but only if you think you can do it safely.
> >=20
> > This is still valid (it can wait).
> >=20
> > Jarek P.
> >=20
> > -------->
> >=20
> > commit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74
> > Author: David S. Miller <davem@davemloft.net>
> > Date:   Tue Jun 17 21:26:37 2008 -0700
> >=20
> >     ax25: Fix std timer socket destroy handling.
> >    =20
> >     Tihomir Heidelberg - 9a4gl, reports:
> >    =20
> >     --------------------
> >     I would like to direct you attention to one problem existing in=
 ax.25
> >     kernel since 2.4. If listening socket is closed and its SKB que=
ue is
> >     released but those sockets get weird. Those "unAccepted()" sock=
ets
> >     should be destroyed in ax25_std_heartbeat_expiry, but it will n=
ot
> >     happen. And there is also a note about that in ax25_std_timer.c=
:
> >     /* Magic here: If we listen() and a new link dies before it
> >     is accepted() it isn't 'dead' so doesn't get removed. */
> >    =20
> >     This issue cause ax25d to stop accepting new connections and I =
had to
> >     restarted ax25d approximately each day and my services were una=
vailable.
> >     Also netstat -n -l shows invalid source and device for those li=
stening
> >     sockets. It is strange why ax25d's listening socket get weird b=
ecause of
> >     this issue, but definitely when I solved this bug I do not have=
 problems
> >     with ax25d anymore and my ax25d can run for months without prob=
lems.
> >     --------------------
> >    =20
> >     Actually as far as I can see, this problem is even in releases
> >     as far back as 2.2.x as well.
> >    =20
> >     It seems senseless to special case this test on TCP_LISTEN stat=
e.
> >     Anything still stuck in state 0 has no external references and
> >     we can just simply kill it off directly.
> >    =20
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >=20
> > diff --git a/net/ax25/ax25_std_timer.c b/net/ax25/ax25_std_timer.c
> > index 96e4b92..cdc7e75 100644
> > --- a/net/ax25/ax25_std_timer.c
> > +++ b/net/ax25/ax25_std_timer.c
> > @@ -39,11 +39,9 @@ void ax25_std_heartbeat_expiry(ax25_cb *ax25)
> > =20
> >  	switch (ax25->state) {
> >  	case AX25_STATE_0:
> > -		/* Magic here: If we listen() and a new link dies before it
> > -		   is accepted() it isn't 'dead' so doesn't get removed. */
> > -		if (!sk || sock_flag(sk, SOCK_DESTROY) ||
> > -		    (sk->sk_state =3D=3D TCP_LISTEN &&
> > -		     sock_flag(sk, SOCK_DEAD))) {
> > +		if (!sk ||
> > +		    sock_flag(sk, SOCK_DESTROY) ||
> > +		    sock_flag(sk, SOCK_DEAD)) {
> >  			if (sk) {
> >  				sock_hold(sk);
> >  				ax25_destroy_socket(ax25);
>=20

