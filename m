From: Yakov Lerner <iler.ml@gmail.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 11:55:18 +0300
Message-ID: <f36b08ee0909290155u177b1983y2eafa8b353a143e0@mail.gmail.com>
References: <1254178906-5293-1-git-send-email-iler.ml@gmail.com>
	 <4AC1BDAD.1010400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:64944 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbZI2IzQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 04:55:16 -0400
Received: by bwz6 with SMTP id 6so1831857bwz.37
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 01:55:19 -0700 (PDT)
In-Reply-To: <4AC1BDAD.1010400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2009 at 10:56, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
>
> Yakov Lerner a =E9crit :
> > Take 2.
> >
> > "Sharp improvement in performance of /proc/net/tcp when number of
> > sockets is large and hashsize is large.
> > O(numsock * hashsize) time becomes O(numsock + hashsize). On slow
> > processors, speed difference can be x100 and more."
> >
> > I must say that I'm not fully satisfied with my choice of "st->sbuc=
ket"
> > for the new preserved index. The better name would be "st->snum".
> > Re-using "st->sbucket" saves 4 bytes, and keeps the patch to one so=
urcefile.
> > But "st->sbucket" has different meaning in OPENREQ and LISTEN state=
s;
> > this can be confusing.
> > Maybe better add "snum" member to struct tcp_iter_state ?
> >
> > Shall I change subject when sending "take N+1", or keep the old sub=
ject ?
> >
> > Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
> > ---
> > =A0net/ipv4/tcp_ipv4.c | =A0 35 +++++++++++++++++++++++++++++++++--
> > =A01 files changed, 33 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > index 7cda24b..e4c4f19 100644
> > --- a/net/ipv4/tcp_ipv4.c
> > +++ b/net/ipv4/tcp_ipv4.c
> > @@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp_i=
ter_state *st)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_nulls_empty(&tcp_hashinfo.ehash[s=
t->bucket].twchain);
> > =A0}
> >
> > -static void *established_get_first(struct seq_file *seq)
> > +static void *established_get_first_after(struct seq_file *seq, int=
 bucket)
> > =A0{
> > =A0 =A0 =A0 struct tcp_iter_state *st =3D seq->private;
> > =A0 =A0 =A0 struct net *net =3D seq_file_net(seq);
> > =A0 =A0 =A0 void *rc =3D NULL;
> >
> > - =A0 =A0 for (st->bucket =3D 0; st->bucket < tcp_hashinfo.ehash_si=
ze; ++st->bucket) {
> > + =A0 =A0 for (st->bucket =3D bucket; st->bucket < tcp_hashinfo.eha=
sh_size;
> > + =A0 =A0 =A0 =A0 =A0++st->bucket) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock *sk;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct hlist_nulls_node *node;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct inet_timewait_sock *tw;
> > @@ -2010,6 +2011,8 @@ static void *established_get_first(struct seq=
_file *seq)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (empty_bucket(st))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> >
> > + =A0 =A0 =A0 =A0 =A0 =A0 st->sbucket =3D st->num;
> > +
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_bh(lock);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_nulls_for_each(sk, node, &tcp_hashin=
fo.ehash[st->bucket].chain) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_family !=3D =
st->family ||
> > @@ -2036,6 +2039,11 @@ out:
> > =A0 =A0 =A0 return rc;
> > =A0}
> >
> > +static void *established_get_first(struct seq_file *seq)
> > +{
> > + =A0 =A0 return established_get_first_after(seq, 0);
> > +}
> > +
> > =A0static void *established_get_next(struct seq_file *seq, void *cu=
r)
> > =A0{
> > =A0 =A0 =A0 struct sock *sk =3D cur;
> > @@ -2064,6 +2072,9 @@ get_tw:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (++st->bucket < tcp_hashinfo.ehas=
h_size &&
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 empty_b=
ucket(st))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 st->sbucket =3D st->num;
> > +
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (st->bucket >=3D tcp_hashinfo.ehash_=
size)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> >
> > @@ -2107,6 +2118,7 @@ static void *tcp_get_idx(struct seq_file *seq=
, loff_t pos)
> >
> > =A0 =A0 =A0 if (!rc) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->state =3D TCP_SEQ_STATE_ESTABLISHED=
;
> > + =A0 =A0 =A0 =A0 =A0 =A0 st->sbucket =3D 0;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =A0 =A0 =A0 =A0=3D established_get_i=
dx(seq, pos);
> > =A0 =A0 =A0 }
> >
> > @@ -2116,6 +2128,25 @@ static void *tcp_get_idx(struct seq_file *se=
q, loff_t pos)
> > =A0static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
> > =A0{
> > =A0 =A0 =A0 struct tcp_iter_state *st =3D seq->private;
> > +
> > + =A0 =A0 if (*pos && *pos >=3D st->sbucket &&
> > + =A0 =A0 =A0 =A0 (st->state =3D=3D TCP_SEQ_STATE_ESTABLISHED ||
> > + =A0 =A0 =A0 =A0 =A0st->state =3D=3D TCP_SEQ_STATE_TIME_WAIT)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 void *cur;
> > + =A0 =A0 =A0 =A0 =A0 =A0 int nskip;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 /* for states estab and tw, st->sbucket i=
s index (*pos) */
> > + =A0 =A0 =A0 =A0 =A0 =A0 /* corresponding to the beginning of buck=
et st->bucket */
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 st->num =3D st->sbucket;
> > + =A0 =A0 =A0 =A0 =A0 =A0 /* jump to st->bucket, then skip (*pos - =
st->sbucket) items */
> > + =A0 =A0 =A0 =A0 =A0 =A0 st->state =3D TCP_SEQ_STATE_ESTABLISHED;
> > + =A0 =A0 =A0 =A0 =A0 =A0 cur =3D established_get_first_after(seq, =
st->bucket);
> > + =A0 =A0 =A0 =A0 =A0 =A0 for (nskip =3D *pos - st->num; cur && nsk=
ip > 0; --nskip)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur =3D established_get_n=
ext(seq, cur);
> > + =A0 =A0 =A0 =A0 =A0 =A0 return cur;
> > + =A0 =A0 }
> > +
> > =A0 =A0 =A0 st->state =3D TCP_SEQ_STATE_LISTENING;
> > =A0 =A0 =A0 st->num =3D 0;
> > =A0 =A0 =A0 return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TO=
KEN;
>
> Just in case you are working on "take 3" of the patch, there is a fon=
damental problem.
>
> All the scalability problems come from the fact that tcp_seq_start()
> *has* to rescan all the tables from the begining, because of lseek() =
capability
> on /proc/net/tcp file
>
> We probably could disable llseek() (on other positions than start of =
the file),
> and rely only on internal state (listening/established hashtable, has=
h bucket, position in chain)
>
> I cannot imagine how an application could rely on lseek() on >0 posit=
ion in this file.


I thought  /proc/net/tcp  can  both  be fast and allow lseek;
(1) when no lseek was issued since last read
(we can detect this), /proc/net/tcp can jump to the
last known bucket (common case), vs
(2) switch to slow mode (scan from the beginning of hash)
when lseek was used , no ?
