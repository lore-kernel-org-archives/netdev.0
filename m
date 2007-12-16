From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Fw: [PACKET]: Fix /proc/net/packet crash due to bogus private
 pointer
Date: Sat, 15 Dec 2007 23:56:04 -0800
Message-ID: <20071215235604.1a3f970a.akpm@linux-foundation.org>
References: <20071215203637.179878aa.akpm@linux-foundation.org>
	<a44ae5cd0712152237y2f6a17fcu6a718757c7c021a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Miles Lane" <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47944 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754164AbXLPH4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 02:56:50 -0500
In-Reply-To: <a44ae5cd0712152237y2f6a17fcu6a718757c7c021a3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 01:37:01 -0500 "Miles Lane" <miles.lane@gmail.com> =
wrote:
>

argh, please don't use linux-net.  It's basically dead afaik.

Suitable ccs restored.

> > On Sun, Dec 16, 2007 at 11:07:07AM +0800, Herbert Xu wrote:
> > >
> > > I suspect namespace borkage.  But just because you pin-pointed
> > > my patch I'll try to track it down :)
> >
> > Surprise surprise.  The namespace seq patch missed two spots in
> > AF_PACKET.
> >
> > [PACKET]: Fix /proc/net/packet crash due to bogus private pointer
> >
> > The seq_open_net patch changed the meaning of seq->private.
> > Unfortunately it missed two spots in AF_PACKET, which still
> > used the old way of dereferencing seq->private, thus causing
> > weird and wonderful crashes when reading /proc/net/packet.
> >
> > This patch fixes them.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 485af56..43e49f4 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -1878,7 +1878,7 @@ static void *packet_seq_start(struct seq_file=
 *seq, loff_t *pos)
> >
> >  static void *packet_seq_next(struct seq_file *seq, void *v, loff_t=
 *pos)
> >  {
> > -       struct net *net =3D seq->private;
> > +       struct net *net =3D seq_file_net(seq);
> >         ++*pos;
> >         return  (v =3D=3D SEQ_START_TOKEN)
> >                 ? sk_head(&net->packet.sklist)
> > @@ -1887,7 +1887,7 @@ static void *packet_seq_next(struct seq_file =
*seq, void *v, loff_t *pos)
> >
> >  static void packet_seq_stop(struct seq_file *seq, void *v)
> >  {
> > -       struct net *net =3D seq->private;
> > +       struct net *net =3D seq_file_net(seq);
> >         read_unlock(&net->packet.sklist_lock);
> >  }
> >
>
> ...
>
>=20
> Hmm.  I tried compiling again with this patch applied and lockdep
> turned back on, and got the following (I will try again with lockdep
> turned back off):
>=20
> Dec 15 13:44:39 syntropy kernel: process `cat' is using deprecated
> sysctl (syscall) net.ipv6.neigh.default.retrans_time; Use
> net.ipv6.neigh.default.retrans_time_ms instead.
> Dec 15 13:44:39 syntropy kernel:
> Dec 15 13:44:39 syntropy kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> Dec 15 13:44:39 syntropy kernel: [ BUG: bad unlock balance detected! =
]
> Dec 15 13:44:39 syntropy kernel: ------------------------------------=
-
> Dec 15 13:44:39 syntropy kernel: cat/4819 is trying to release lock
> (kkkkkkk<A5><BB><BB><BB><BB>=C8=A6<FD><DF>) at:
> Dec 15 13:44:39 syntropy kernel: [packet_seq_stop+0xe/0x10]
> packet_seq_stop+0xe/0x10
> Dec 15 13:44:39 syntropy kernel: but there are no more locks to relea=
se!
> Dec 15 13:44:39 syntropy kernel:
> Dec 15 13:44:39 syntropy kernel: other info that might help us debug =
this:
> Dec 15 13:44:39 syntropy kernel: 2 locks held by cat/4819:
> Dec 15 13:44:39 syntropy kernel:  #0:  (&p->lock){--..}, at:
> [crypto_algapi:seq_read+0x25/0x191c1] seq_read+0x25/0x26f

So your kernel is still feeding garbage into lockdep.

Are you really really sure that kernel had Herbert's patch applied?

