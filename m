From: Asim Shankar <asimshankar@gmail.com>
Subject: [PATCH] - sch_htb: Drop packet when direct queue overflows
Date: Thu, 21 Apr 2005 15:41:24 -0500
Message-ID: <7bca1cb505042113417a5d9f59@mail.gmail.com>
References: <7bca1cb50504211221655fd54c@mail.gmail.com>
	 <20050421195605.GJ577@postel.suug.ch>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_721_21838107.1114116084952"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050421195605.GJ577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_721_21838107.1114116084952
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> > If a packet is classified as HTB_DIRECT but the direct_queue is
> > already full, then the packet doesn't get enqueued but sch->q.qlen++
> > will happen a few lines later. Overflowing of the direct_queue
> > probably rarely happens in practice, but I was playing around and
> > noticed it happen in some corner cases of my testing.
>=20
> Yes, that's a bug.
>=20
> > Should the packet be dropped instead? Like:
> >
> > if (cl =3D=3D HTB_DIRECT) {
> >         /* enqueue to helper queue */
> >         if (q->direct_queue.qlen < q->direct_qlen) {
> >                 __skb_queue_tail(&q->direct_queue, skb);
> >                 q->direct_pkts++;
> >         } else {
> >                sch->qstats.drops++;
> >                 kfree_skb(skb);
> >                 return NET_XMIT_DROP;
> >        }
> > }
>=20
> Can you send a patch?
>=20
Patched pasted and attached:

--- linux-2.6.11.7/net/sched/sch_htb.c=092005-04-07 13:57:45.000000000 -050=
0
+++ linux-2.6.11.7-new/net/sched/sch_htb.c=092005-04-21 14:17:36.272065816 =
-0500
@@ -717,6 +717,10 @@
 =09if (q->direct_queue.qlen < q->direct_qlen) {
 =09    __skb_queue_tail(&q->direct_queue, skb);
 =09    q->direct_pkts++;
+=09} else {
+=09    kfree_skb (skb);
+=09    sch->qstats.drops++;
+=09    return NET_XMIT_DROP;
 =09}
 #ifdef CONFIG_NET_CLS_ACT
     } else if (!cl) {

------=_Part_721_21838107.1114116084952
Content-Type: text/plain; name="patch-htb-2.6.11.7"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="patch-htb-2.6.11.7"

LS0tIGxpbnV4LTIuNi4xMS43L25ldC9zY2hlZC9zY2hfaHRiLmMJMjAwNS0wNC0wNyAxMzo1Nzo0
NS4wMDAwMDAwMDAgLTA1MDAKKysrIGxpbnV4LTIuNi4xMS43LW5ldy9uZXQvc2NoZWQvc2NoX2h0
Yi5jCTIwMDUtMDQtMjEgMTQ6MTc6MzYuMjcyMDY1ODE2IC0wNTAwCkBAIC03MTcsNiArNzE3LDEw
IEBACiAJaWYgKHEtPmRpcmVjdF9xdWV1ZS5xbGVuIDwgcS0+ZGlyZWN0X3FsZW4pIHsKIAkgICAg
X19za2JfcXVldWVfdGFpbCgmcS0+ZGlyZWN0X3F1ZXVlLCBza2IpOwogCSAgICBxLT5kaXJlY3Rf
cGt0cysrOworCX0gZWxzZSB7CisJICAgIGtmcmVlX3NrYiAoc2tiKTsKKwkgICAgc2NoLT5xc3Rh
dHMuZHJvcHMrKzsKKwkgICAgcmV0dXJuIE5FVF9YTUlUX0RST1A7CiAJfQogI2lmZGVmIENPTkZJ
R19ORVRfQ0xTX0FDVAogICAgIH0gZWxzZSBpZiAoIWNsKSB7Cg==
------=_Part_721_21838107.1114116084952--
