From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 08:45:34 -0700
Message-ID: <20090929084534.41274f66@nehalam>
References: <1254178906-5293-1-git-send-email-iler.ml@gmail.com>
	<4AC1BDAD.1010400@gmail.com>
	<f36b08ee0909290155u177b1983y2eafa8b353a143e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Yakov Lerner <iler.ml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34322 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609AbZI2Ppg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 11:45:36 -0400
In-Reply-To: <f36b08ee0909290155u177b1983y2eafa8b353a143e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2009 11:55:18 +0300
Yakov Lerner <iler.ml@gmail.com> wrote:

> On Tue, Sep 29, 2009 at 10:56, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> >
> > Yakov Lerner a =C3=A9crit :
> > > Take 2.
> > >
> > > "Sharp improvement in performance of /proc/net/tcp when number of
> > > sockets is large and hashsize is large.
> > > O(numsock * hashsize) time becomes O(numsock + hashsize). On slow
> > > processors, speed difference can be x100 and more."
> > >
> > > I must say that I'm not fully satisfied with my choice of "st->sb=
ucket"
> > > for the new preserved index. The better name would be "st->snum".
> > > Re-using "st->sbucket" saves 4 bytes, and keeps the patch to one =
sourcefile.
> > > But "st->sbucket" has different meaning in OPENREQ and LISTEN sta=
tes;
> > > this can be confusing.
> > > Maybe better add "snum" member to struct tcp_iter_state ?
> > >
> > > Shall I change subject when sending "take N+1", or keep the old s=
ubject ?
> > >
> > > Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
> > > ---
> > > =C2=A0net/ipv4/tcp_ipv4.c | =C2=A0 35 +++++++++++++++++++++++++++=
++++++--
> > > =C2=A01 files changed, 33 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > > index 7cda24b..e4c4f19 100644
> > > --- a/net/ipv4/tcp_ipv4.c
> > > +++ b/net/ipv4/tcp_ipv4.c
> > > @@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp=
_iter_state *st)
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hlist_nulls_empt=
y(&tcp_hashinfo.ehash[st->bucket].twchain);
> > > =C2=A0}
> > >
> > > -static void *established_get_first(struct seq_file *seq)
> > > +static void *established_get_first_after(struct seq_file *seq, i=
nt bucket)
> > > =C2=A0{
> > > =C2=A0 =C2=A0 =C2=A0 struct tcp_iter_state *st =3D seq->private;
> > > =C2=A0 =C2=A0 =C2=A0 struct net *net =3D seq_file_net(seq);
> > > =C2=A0 =C2=A0 =C2=A0 void *rc =3D NULL;
> > >
> > > - =C2=A0 =C2=A0 for (st->bucket =3D 0; st->bucket < tcp_hashinfo.=
ehash_size; ++st->bucket) {
> > > + =C2=A0 =C2=A0 for (st->bucket =3D bucket; st->bucket < tcp_hash=
info.ehash_size;
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0++st->bucket) {
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sock *sk;
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct hlist_nul=
ls_node *node;
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct inet_time=
wait_sock *tw;
> > > @@ -2010,6 +2011,8 @@ static void *established_get_first(struct s=
eq_file *seq)
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (empty_bucket=
(st))
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
> > >
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 st->sbucket =3D st->n=
um;
> > > +
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_bh(loc=
k);
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sk_nulls_for_eac=
h(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (sk->sk_family !=3D st->family ||
> > > @@ -2036,6 +2039,11 @@ out:
> > > =C2=A0 =C2=A0 =C2=A0 return rc;
> > > =C2=A0}
> > >
> > > +static void *established_get_first(struct seq_file *seq)
> > > +{
> > > + =C2=A0 =C2=A0 return established_get_first_after(seq, 0);
> > > +}
> > > +
> > > =C2=A0static void *established_get_next(struct seq_file *seq, voi=
d *cur)
> > > =C2=A0{
> > > =C2=A0 =C2=A0 =C2=A0 struct sock *sk =3D cur;
> > > @@ -2064,6 +2072,9 @@ get_tw:
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (++st->buc=
ket < tcp_hashinfo.ehash_size &&
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 empty_bucket(st))
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 ;
> > > +
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 st->sbucket =3D st->n=
um;
> > > +
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (st->bucket >=
=3D tcp_hashinfo.ehash_size)
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return NULL;
> > >
> > > @@ -2107,6 +2118,7 @@ static void *tcp_get_idx(struct seq_file *s=
eq, loff_t pos)
> > >
> > > =C2=A0 =C2=A0 =C2=A0 if (!rc) {
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 st->state =3D TC=
P_SEQ_STATE_ESTABLISHED;
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 st->sbucket =3D 0;
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =C2=A0 =C2=A0=
 =C2=A0 =C2=A0=3D established_get_idx(seq, pos);
> > > =C2=A0 =C2=A0 =C2=A0 }
> > >
> > > @@ -2116,6 +2128,25 @@ static void *tcp_get_idx(struct seq_file *=
seq, loff_t pos)
> > > =C2=A0static void *tcp_seq_start(struct seq_file *seq, loff_t *po=
s)
> > > =C2=A0{
> > > =C2=A0 =C2=A0 =C2=A0 struct tcp_iter_state *st =3D seq->private;
> > > +
> > > + =C2=A0 =C2=A0 if (*pos && *pos >=3D st->sbucket &&
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 (st->state =3D=3D TCP_SEQ_STATE_EST=
ABLISHED ||
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0st->state =3D=3D TCP_SEQ_STAT=
E_TIME_WAIT)) {
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *cur;
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int nskip;
> > > +
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* for states estab a=
nd tw, st->sbucket is index (*pos) */
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* corresponding to t=
he beginning of bucket st->bucket */
> > > +
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 st->num =3D st->sbuck=
et;
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* jump to st->bucket=
, then skip (*pos - st->sbucket) items */
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 st->state =3D TCP_SEQ=
_STATE_ESTABLISHED;
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cur =3D established_g=
et_first_after(seq, st->bucket);
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (nskip =3D *pos -=
 st->num; cur && nskip > 0; --nskip)
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 cur =3D established_get_next(seq, cur);
> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return cur;
> > > + =C2=A0 =C2=A0 }
> > > +
> > > =C2=A0 =C2=A0 =C2=A0 st->state =3D TCP_SEQ_STATE_LISTENING;
> > > =C2=A0 =C2=A0 =C2=A0 st->num =3D 0;
> > > =C2=A0 =C2=A0 =C2=A0 return *pos ? tcp_get_idx(seq, *pos - 1) : S=
EQ_START_TOKEN;
> >
> > Just in case you are working on "take 3" of the patch, there is a f=
ondamental problem.
> >
> > All the scalability problems come from the fact that tcp_seq_start(=
)
> > *has* to rescan all the tables from the begining, because of lseek(=
) capability
> > on /proc/net/tcp file
> >
> > We probably could disable llseek() (on other positions than start o=
f the file),
> > and rely only on internal state (listening/established hashtable, h=
ash bucket, position in chain)
> >
> > I cannot imagine how an application could rely on lseek() on >0 pos=
ition in this file.
>=20
>=20
> I thought  /proc/net/tcp  can  both  be fast and allow lseek;
> (1) when no lseek was issued since last read
> (we can detect this), /proc/net/tcp can jump to the
> last known bucket (common case), vs
> (2) switch to slow mode (scan from the beginning of hash)
> when lseek was used , no ?

If you look at fib_hash and fib_trie, they already do the same thing.
  * fib_hash records last hash chain to avoid overhead of rescan.
  * fib_trie records last route and does fast lookup to restart from th=
ere.


--=20
