From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 12:31:28 +0200
Message-ID: <20120403103128.GA20671@1984>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
 <1333448001-2507-4-git-send-email-pablo@netfilter.org>
 <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37614 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458Ab2DCKbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 06:31:36 -0400
Content-Disposition: inline
In-Reply-To: <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 03, 2012 at 07:27:50PM +0900, Tetsuo Handa wrote:
> pablo@netfilter.org:
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> >=20
> > If CONFIG_NF_CONNTRACK_TIMEOUT=3Dn we have following warning :
> >=20
> >   CC [M]  net/netfilter/xt_CT.o
> > net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v1=E2=80=
=99:
> > net/netfilter/xt_CT.c:284: warning: label =E2=80=98err4=E2=80=99 de=
fined but not used
> >=20
> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
> >  net/netfilter/xt_CT.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
> > index 0c8e438..138b75e 100644
> > --- a/net/netfilter/xt_CT.c
> > +++ b/net/netfilter/xt_CT.c
> > @@ -281,8 +281,10 @@ out:
> >  	info->ct =3D ct;
> >  	return 0;
> > =20
> > +#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
> >  err4:
> >  	rcu_read_unlock();
> > +#endif
> >  err3:
> >  	nf_conntrack_free(ct);
> >  err2:
> > --=20
> > 1.7.2.5
>=20
> Looking at that function:
>=20
> 216 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
> 217         if (info->timeout) {
> 218                 typeof(nf_ct_timeout_find_get_hook) timeout_find_=
get;
> 219                 struct ctnl_timeout *timeout;
> 220                 struct nf_conn_timeout *timeout_ext;
> 221=20
> 222                 rcu_read_lock();
> 223                 timeout_find_get =3D
> 224                         rcu_dereference(nf_ct_timeout_find_get_ho=
ok);
> 225=20
> 226                 if (timeout_find_get) {
> 227                         const struct ipt_entry *e =3D par->entryi=
nfo;
> 228                         struct nf_conntrack_l4proto *l4proto;
> 229=20
> 230                         if (e->ip.invflags & IPT_INV_PROTO) {
> 231                                 ret =3D -EINVAL;
> 232                                 pr_info("You cannot use inversion=
 on "
> 233                                          "L4 protocol\n");
> 234                                 goto err4;
> 235                         }
> 236                         timeout =3D timeout_find_get(info->timeou=
t);
> 237                         if (timeout =3D=3D NULL) {
> 238                                 ret =3D -ENOENT;
> 239                                 pr_info("No such timeout policy \=
"%s\"\n",
> 240                                         info->timeout);
> 241                                 goto err4;
> 242                         }
> 243                         if (timeout->l3num !=3D par->family) {
> 244                                 ret =3D -EINVAL;
> 245                                 pr_info("Timeout policy `%s' can =
only be "
> 246                                         "used by L3 protocol numb=
er %d\n",
> 247                                         info->timeout, timeout->l=
3num);
> 248                                 goto err4;
> 249                         }
> 250                         /* Make sure the timeout policy matches a=
ny existing
> 251                          * protocol tracker, otherwise default to=
 generic.
> 252                          */
> 253                         l4proto =3D __nf_ct_l4proto_find(par->fam=
ily,
> 254                                                        e->ip.prot=
o);
> 255                         if (timeout->l4proto->l4proto !=3D l4prot=
o->l4proto) {
> 256                                 ret =3D -EINVAL;
> 257                                 pr_info("Timeout policy `%s' can =
only be "
> 258                                         "used by L4 protocol numb=
er %d\n",
> 259                                         info->timeout,
> 260                                         timeout->l4proto->l4proto=
);
> 261                                 goto err4;
> 262                         }
> 263                         timeout_ext =3D nf_ct_timeout_ext_add(ct,=
 timeout,
> 264                                                             GFP_K=
ERNEL);
>                             We are under rcu_read_lock() here.

Good catch, that needs to be GFP_ATOMIC. I'll send a follow-up patch
for this.

Thanks.
