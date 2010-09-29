From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support
 Nokia Slim Modems
Date: Wed, 29 Sep 2010 12:02:20 +0530
Message-ID: <20100929063219.GA18733@bnru01.bnr.st.com>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
 <201009290125.07068.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	STEricsson_nomadik_linux <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36210 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751796Ab0I2Gce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 02:32:34 -0400
Content-Disposition: inline
In-Reply-To: <201009290125.07068.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi R=E9mi Denis-Courmontt

On Wed, Sep 29, 2010 at 00:25:06 +0200, R=E9mi Denis-Courmont wrote:
=20
> As far as I know, you don't need to do that in kernel space. I don't =
know the=20
> internals of the STE modem. Regardless of having or not having a pipe=
=20
> controller, Linux userspace can send pipe messages using a plain Phon=
et=20
> datagram socket. This avoids adding ioctl()'s and protocol stuff in k=
ernel=20
> space. Then, as far as kernel is concerned, only small changes to the=
 data=20
> path would be required.
>
Agreed partially. In fact, we initially followed the same approach.
However, following this approach, we faced problem situations which I
have described in detail in the mail '[PATCH 0/2] Phonet: Implement Pip=
e
Controller to support Nokia Slim Modems'.

We can introduce corrections in Phonet stack for the PS path which
would be minor. But then those changes look more like a hack. Further,
this change would be required at several places where PS communication
is happening with modem e.g. pep_reply, pipe_skb_send, pipe_snd_status,
etc.

=46urther, if a new function tomorrow is introduced for PS path
communication with modem then, that hack will have to be added to that
function also.
=20
> Both the Nokia modem plugin for oFono, and the (closed-source) Nokia =
N900 CSD-
> GPRS service work that way. In other words, the pipe 'signaling' is d=
one in=20
> userspace, while the pipe 'data' is done in kernel space for optimal=20
> performance.
>
=20
I am not much aware of modem used in Nokia N900 but I guess N900 modem
has pipe controller implemented inside it. So, the pipe 'data' works
fine with kernel.

If we use the same approach for Nokia Slim modems, this approach
introduces the problem of PS data traversing two times the phonet stack=
=2E
Again I have described this problem in the mail '[PATCH 0/2] Phonet:
Implement Pipe Controller to support Nokia Slim Modems'.

> For some background - Phonet pipes work very much like FTP. There are=
 two=20
> endpoints exchaning data, and one client ('owner') deciding which end=
points=20
> and when to establish a pipe between. In most case the client is also=
 one of=20
> the endpoint, but this is not required. With this patch, the client i=
s tied to=20
> being one of the endpoint. Arguably, this is not a problem for most u=
secases.=20
> But I am not sure this belongs in *kernel* space.

Based on problems described above, we thought it would be better to
handle in kernel. Later on, any user-space can establish Pipe connectio=
n
with modem using this approach e.g. Video telephony socket can establis=
h
its own pipe with modem, GPRS/3G socket can establish its own pipe with
modem.

=46urther, the pipe controller implementation allows the flexibility to
user-space of where it is sending the pipe 'data'.
Currently, the phonet stack by default is sending pipe 'data' to
dst_dev:dst_obj =3D 0x00:0x00 using the variable struct sockaddr_pn
pipe_srv.
Pipe controller implementation however maintains the remote-pep for any
particular user-space socket and always sends pipe data to that correct
destination remote-pep.

>=20
> > @@ -791,6 +1171,48 @@ static int pep_setsockopt(struct sock *sk, in=
t level,
> > int optname,
> >=20
> >         lock_sock(sk);
> >         switch (optname) {
> > +#ifdef CONFIG_PHONET_PIPECTRLR
> > +       case PNPIPE_CREATE:
> > +               if (val) {
> > +                       if (pn->pipe_state > PIPE_IDLE) {
> > +                               err =3D -EFAULT;
>=20
> Why EFAULT here? I can't see any user-space memory access failure.

Agreed. I think I should rather use -EAGAIN.
I will correct this in all the rest of places where you have indicated
-EFAULT should not be used.
I will send out a correction patch since phonet pipe controller patch i=
s already merged
by David.

>=20
> > @@ -877,11 +1313,11 @@ static int pipe_skb_send(struct sock *sk, st=
ruct
> > sk_buff *skb) } else
> >                 ph->message_id =3D PNS_PIPE_DATA;
> >         ph->pipe_handle =3D pn->pipe_handle;
> > -
> > -       err =3D pn_skb_send(sk, skb, &pipe_srv);
> > -       if (err && pn_flow_safe(pn->tx_fc))
> > -               atomic_inc(&pn->tx_credits);
> > -       return err;
> > +#ifdef CONFIG_PHONET_PIPECTRLR
> > +       return pn_skb_send(sk, skb, &spn);
> > +#else
> > +       return pn_skb_send(sk, skb, &pipe_srv);
> > +#endif
> >  }
>=20
> This reintroduces the bug that I fixed in=20
> 1a98214feef2221cd7c24b17cd688a5a9d85b2ea :-(

I apologise here as I accidently lost your commit here.
I will restore your commit here by sending patch.

>=20
> --=20
> R=E9mi Denis-Courmont
> Nokia Devices R&D, Maemo Software, Helsinki

Thanks & regards,
Kumar.
