From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Mon, 30 Nov 2009 12:26:33 +0800
Message-ID: <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f188.google.com ([209.85.216.188]:54101 "EHLO
	mail-px0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbZK3E01 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 23:26:27 -0500
Received: by pxi26 with SMTP id 26so2275050pxi.21
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2009 20:26:33 -0800 (PST)
In-Reply-To: <20091128000401.GA3713@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 28, 2009 at 8:04 AM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> Changli Gao wrote, On 11/27/2009 09:14 AM:
>
>
> This case of the quantum smaller than the packet size should be treat=
ed
> as a broken config, so I don't think it's worth to do such a deep cha=
nge
> with additional delays and cpu cycles for all to fix it. A warning or
> lower limit should be enough (if necessary at all).
>

I don't think this change is deep. HTB has it own lower limit for
quantum 1000, but the MTU is various, and maybe larger than that. And
if we use IMQ to shape traffic, the skb will be defragmented by
conntrack, and its size will be larger than MTU.

The previous patch indeed introduces some additional CPU cycles.
Review  the new patch bellow please:

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2e38d1a..d55382b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -815,6 +815,17 @@ next:
                        goto next;
                }

+               if (unlikely(cl->un.leaf.deficit[level] < 0)) {
+                       cl->un.leaf.deficit[level] +=3D cl->quantum;
+                       htb_next_rb_node((level ? cl->parent->un.inner.=
ptr :
+                                         q->ptr[0]) + prio);
+                       cl =3D htb_lookup_leaf(q->row[level] + prio, pr=
io,
+                                            q->ptr[level] + prio,
+                                            q->last_ptr_id[level] + pr=
io);
+                       start =3D cl;
+                       goto next;
+               }
+
                skb =3D cl->un.leaf.q->dequeue(cl->un.leaf.q);
                if (likely(skb !=3D NULL))
                        break;

If you think it is acceptable, I'll resubmit it for inclusion.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
