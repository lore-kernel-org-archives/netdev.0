From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Tue, 1 Dec 2009 17:18:32 +0800
Message-ID: <412e6f7f0912010118l19b3a759n925138fbc6dd6f56@mail.gmail.com>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local>
	 <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com>
	 <20091130111020.GA7114@ff.dom.local>
	 <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com>
	 <20091201080151.GA6408@ff.dom.local>
	 <20091201084332.GB6408@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:62463 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbZLAJS2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 04:18:28 -0500
Received: by pzk1 with SMTP id 1so3504540pzk.33
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 01:18:35 -0800 (PST)
In-Reply-To: <20091201084332.GB6408@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2009 at 4:43 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
> On Tue, Dec 01, 2009 at 08:01:51AM +0000, Jarek Poplawski wrote:
>> On Tue, Dec 01, 2009 at 10:32:26AM +0800, Changli Gao wrote:
>> > On Mon, Nov 30, 2009 at 7:10 PM, Jarek Poplawski <jarkao2@gmail.co=
m> wrote:
> ...
>> > > And this patch is very similar, except ->peek()/dequeue(). Addit=
ional
>> > > lookups are done instead of dequeuing the first found class, whi=
ch
>> > > might be quite long in some cases.
>> >
>> > If the quantum is set correctly, there isn't difference except of =
a
>> > comparison. In the other case, I think some additional CPU cycles =
are
>> > better than overflow.
>>
>> No, my main point is there _is_ a difference when the quantum is set
>> correctly. Just these additional lookups.
>
> And, again, there are less invasive ways to fix such overflow, like
>
> htb_dequeue_tree()
> {
> ...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(skb !=3D NULL)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cl->un.leaf.de=
ficit[level] -=3D qdisc_pkt_len(skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (cl->un.lea=
f.deficit[level] < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0cl->un.leaf.deficit[level] +=3D cl->quantum;
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (cl->un.leaf.deficit[level] < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cl->un.leaf.deficit[level] =3D -cl-=
>quantum;

How about this:
         if (cl->un.leaf.deficit[level] < 0) {
                cl->un.leaf.deficit[level] =3D 0;
                if (!(cl->warned & HTB_WARN_QUANTUM_SMALL)) {
                        printk(KERN_WARNING
                               "HTB: quantum of class %X is small.
Consider r2q change.\n",
                               cl->common.classid);
                    cl->warned |=3D HTB_WARN_QUANTUM_SMALL;
                }
         }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* or other limit */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0ptr[0]) + prio);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* this used t=
o be after charge_class but this constelation
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 gives =
us slightly better performance */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cl->un.le=
af.q->q.qlen)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0htb_deactivate(q, cl);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0htb_charge_cla=
ss(q, cl, level, skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return skb;
> }
>
> or even always zeroing cl->un.leaf.deficit[level] on activation or
> deactivation (it's seems unlikely one activity period is enough for
> such an overflow).
>

I found this from http://luxik.cdi.cz/~devik/qos/htb/manual/theory.htm:

   HTB uses "real" DRR as defined in [4]. CBQ in Linux uses one where
the quantum can be lower than MTU - it is more generic but it is also
no longer O(1) complexity. It also means that you have to use right
scale for rate->quantum conversion so that all quantums are larger
than MTU.

To keep it O(1) complexity, HTB requires users use the right scale for
quantum. So my first two patches are in the wrong direction.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
