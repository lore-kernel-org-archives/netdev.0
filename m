From: Julio Kriger <juliokriger@gmail.com>
Subject: Re: [Netem] [PATCH] (3/3) netem: allow random reordering
Date: Sat, 21 May 2005 15:05:09 +0000
Message-ID: <682bc30a050521080551b561d5@mail.gmail.com>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
Reply-To: Julio Kriger <juliokriger@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_10705_15871841.1116687909176"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_10705_15871841.1116687909176
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi!
Here is a patch to 'tc' that add funcionality need to use the new
feature reorder.
Regards,
Julio


On 5/19/05, Stephen Hemminger <shemminger@osdl.org> wrote:
> Enhance the reorder feature of netem to allow random percent to be reorde=
red.
> Has expected backwards compatibility behaviour.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>=20
> Index: netem-2.6.12-rc4/include/linux/pkt_sched.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- netem-2.6.12-rc4.orig/include/linux/pkt_sched.h
> +++ netem-2.6.12-rc4/include/linux/pkt_sched.h
> @@ -427,6 +427,7 @@ enum
>         TCA_NETEM_UNSPEC,
>         TCA_NETEM_CORR,
>         TCA_NETEM_DELAY_DIST,
> +       TCA_NETEM_REORDER,
>         __TCA_NETEM_MAX,
>  };
>=20
> @@ -437,7 +438,7 @@ struct tc_netem_qopt
>         __u32   latency;        /* added delay (us) */
>         __u32   limit;          /* fifo limit (packets) */
>         __u32   loss;           /* random packet loss (0=3Dnone ~0=3D100%=
) */
> -       __u32   gap;            /* re-ordering gap (0 for delay all) */
> +       __u32   gap;            /* re-ordering gap (0 for none) */
>         __u32   duplicate;      /* random packet dup  (0=3Dnone ~0=3D100%=
) */
>         __u32   jitter;         /* random jitter in latency (us) */
>  };
> @@ -449,6 +450,12 @@ struct tc_netem_corr
>         __u32   dup_corr;       /* duplicate correlation  */
>  };
>=20
> +struct tc_netem_reorder
> +{
> +       __u32   probability;
> +       __u32   correlation;
> +};
> +
>  #define NETEM_DIST_SCALE       8192
>=20
>  #endif
> Index: netem-2.6.12-rc4/net/sched/sch_netem.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- netem-2.6.12-rc4.orig/net/sched/sch_netem.c
> +++ netem-2.6.12-rc4/net/sched/sch_netem.c
> @@ -62,11 +62,12 @@ struct netem_sched_data {
>         u32 gap;
>         u32 jitter;
>         u32 duplicate;
> +       u32 reorder;
>=20
>         struct crndstate {
>                 unsigned long last;
>                 unsigned long rho;
> -       } delay_cor, loss_cor, dup_cor;
> +       } delay_cor, loss_cor, dup_cor, reorder_cor;
>=20
>         struct disttable {
>                 u32  size;
> @@ -185,18 +186,18 @@ static int netem_enqueue(struct sk_buff
>          * of the queue.
>          * gap =3D=3D 0 is special case for no-reordering.
>          */
> -       if (q->gap =3D=3D 0 || q->counter !=3D q->gap) {
> +       if (q->gap =3D=3D 0 && q->counter < q->gap &&
> +           q->reorder < get_crandom(&q->reorder_cor)) {
>                 psched_time_t now;
>                 PSCHED_GET_TIME(now);
> -               PSCHED_TADD2(now,
> -                            tabledist(q->latency, q->jitter, &q->delay_c=
or, q->delay_dist),
> +               PSCHED_TADD2(now, tabledist(q->latency, q->jitter,
> +                                           &q->delay_cor, q->delay_dist)=
,
>                              cb->time_to_send);
> -
>                 ++q->counter;
>                 ret =3D q->qdisc->enqueue(skb, q->qdisc);
>         } else {
> -               q->counter =3D 0;
>                 PSCHED_GET_TIME(cb->time_to_send);
> +               q->counter =3D 0;
>                 ret =3D q->qdisc->ops->requeue(skb, q->qdisc);
>         }
>=20
> @@ -351,6 +352,19 @@ static int get_correlation(struct Qdisc
>         return 0;
>  }
>=20
> +static int get_reorder(struct Qdisc *sch, const struct rtattr *attr)
> +{
> +       struct netem_sched_data *q =3D qdisc_priv(sch);
> +       const struct tc_netem_reorder *r =3D RTA_DATA(attr);
> +
> +       if (RTA_PAYLOAD(attr) !=3D sizeof(*r))
> +               return -EINVAL;
> +
> +       q->reorder =3D r->probability;
> +       init_crandom(&q->reorder_cor, r->correlation);
> +       return 0;
> +}
> +
>  static int netem_change(struct Qdisc *sch, struct rtattr *opt)
>  {
>         struct netem_sched_data *q =3D qdisc_priv(sch);
> @@ -371,9 +385,15 @@ static int netem_change(struct Qdisc *sc
>         q->jitter =3D qopt->jitter;
>         q->limit =3D qopt->limit;
>         q->gap =3D qopt->gap;
> +       q->counter =3D 0;
>         q->loss =3D qopt->loss;
>         q->duplicate =3D qopt->duplicate;
>=20
> +       /* for compatiablity with earlier versions.
> +        * if gap is set, need to assume 100% probablity
> +        */
> +       q->reorder =3D ~0;
> +
>         /* Handle nested options after initial queue options.
>          * Should have put all options in nested format but too late now.
>          */
> @@ -395,6 +415,11 @@ static int netem_change(struct Qdisc *sc
>                         if (ret)
>                                 return ret;
>                 }
> +               if (tb[TCA_NETEM_REORDER-1]) {
> +                       ret =3D get_reorder(sch, tb[TCA_NETEM_REORDER-1])=
;
> +                       if (ret)
> +                               return ret;
> +               }
>         }
>=20
>=20
> @@ -412,7 +437,6 @@ static int netem_init(struct Qdisc *sch,
>         init_timer(&q->timer);
>         q->timer.function =3D netem_watchdog;
>         q->timer.data =3D (unsigned long) sch;
> -       q->counter =3D 0;
>=20
>         q->qdisc =3D qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
>         if (!q->qdisc) {
> @@ -444,6 +468,7 @@ static int netem_dump(struct Qdisc *sch,
>         struct rtattr *rta =3D (struct rtattr *) b;
>         struct tc_netem_qopt qopt;
>         struct tc_netem_corr cor;
> +       struct tc_netem_reorder reorder;
>=20
>         qopt.latency =3D q->latency;
>         qopt.jitter =3D q->jitter;
> @@ -457,6 +482,11 @@ static int netem_dump(struct Qdisc *sch,
>         cor.loss_corr =3D q->loss_cor.rho;
>         cor.dup_corr =3D q->dup_cor.rho;
>         RTA_PUT(skb, TCA_NETEM_CORR, sizeof(cor), &cor);
> +
> +       reorder.probability =3D q->reorder;
> +       reorder.correlation =3D q->reorder_cor.rho;
> +       RTA_PUT(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder);
> +
>         rta->rta_len =3D skb->tail - b;
>=20
>         return skb->len;
>=20
>=20
> _______________________________________________
> Netem mailing list
> Netem@lists.osdl.org
> http://lists.osdl.org/mailman/listinfo/netem
>=20
>=20
>=20


--=20
----------------------------
Julio Kriger
mailto:juliokriger@gmail.com

------=_Part_10705_15871841.1116687909176
Content-Type: application/octet-stream; name="tc_patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="tc_patch"

ZGlmZiAtTmF1ciBvcmlnL2lwcm91dGUyLTIuNi4xMS0wNTAzMzAvaW5jbHVkZS9saW51eC9wa3Rf
c2NoZWQuaCBuZXcvaXByb3V0ZTItMi42LjExLTA1MDMzMC9pbmNsdWRlL2xpbnV4L3BrdF9zY2hl
ZC5oCi0tLSBvcmlnL2lwcm91dGUyLTIuNi4xMS0wNTAzMzAvaW5jbHVkZS9saW51eC9wa3Rfc2No
ZWQuaAkyMDA1LTA0LTAxIDE5OjU4OjExLjAwMDAwMDAwMCArMDAwMAorKysgbmV3L2lwcm91dGUy
LTIuNi4xMS0wNTAzMzAvaW5jbHVkZS9saW51eC9wa3Rfc2NoZWQuaAkyMDA1LTA1LTIxIDExOjU5
OjEyLjAwMDAwMDAwMCArMDAwMApAQCAtNDI3LDYgKzQyNyw3IEBACiAJVENBX05FVEVNX1VOU1BF
QywKIAlUQ0FfTkVURU1fQ09SUiwKIAlUQ0FfTkVURU1fREVMQVlfRElTVCwKKwlUQ0FfTkVURU1f
UkVPUkRFUiwKIAlfX1RDQV9ORVRFTV9NQVgsCiB9OwogCkBAIC00MzcsNyArNDM4LDcgQEAKIAlf
X3UzMglsYXRlbmN5OwkvKiBhZGRlZCBkZWxheSAodXMpICovCiAJX191MzIgICBsaW1pdDsJCS8q
IGZpZm8gbGltaXQgKHBhY2tldHMpICovCiAJX191MzIJbG9zczsJCS8qIHJhbmRvbSBwYWNrZXQg
bG9zcyAoMD1ub25lIH4wPTEwMCUpICovCi0JX191MzIJZ2FwOwkJLyogcmUtb3JkZXJpbmcgZ2Fw
ICgwIGZvciBkZWxheSBhbGwpICovCisJX191MzIJZ2FwOwkJLyogcmUtb3JkZXJpbmcgZ2FwICgw
IGZvciBub25lKSAqLwogCV9fdTMyICAgZHVwbGljYXRlOwkvKiByYW5kb20gcGFja2V0IGR1cCAg
KDA9bm9uZSB+MD0xMDAlKSAqLwogCV9fdTMyCWppdHRlcjsJCS8qIHJhbmRvbSBqaXR0ZXIgaW4g
bGF0ZW5jeSAodXMpICovCiB9OwpAQCAtNDQ5LDYgKzQ1MCwxMiBAQAogCV9fdTMyCWR1cF9jb3Jy
OwkvKiBkdXBsaWNhdGUgY29ycmVsYXRpb24gICovCiB9OwogCitzdHJ1Y3QgdGNfbmV0ZW1fcmVv
cmRlcgoreworCV9fdTMyICAgcHJvYmFiaWxpdHk7CisJX191MzIgICBjb3JyZWxhdGlvbjsKK307
CisKICNkZWZpbmUgTkVURU1fRElTVF9TQ0FMRQk4MTkyCiAKICNlbmRpZgpkaWZmIC1OYXVyIG9y
aWcvaXByb3V0ZTItMi42LjExLTA1MDMzMC90Yy9xX25ldGVtLmMgbmV3L2lwcm91dGUyLTIuNi4x
MS0wNTAzMzAvdGMvcV9uZXRlbS5jCi0tLSBvcmlnL2lwcm91dGUyLTIuNi4xMS0wNTAzMzAvdGMv
cV9uZXRlbS5jCTIwMDUtMDQtMDEgMTk6NTg6MTEuMDAwMDAwMDAwICswMDAwCisrKyBuZXcvaXBy
b3V0ZTItMi42LjExLTA1MDMzMC90Yy9xX25ldGVtLmMJMjAwNS0wNS0yMSAxMDo1ODozMy4wMDAw
MDAwMDAgKzAwMDAKQEAgLTMzLDYgKzMzLDcgQEAKICIgICAgICAgICAgICAgICAgIFsgZHJvcCBQ
RVJDRU5UIFtDT1JSRUxBVElPTl1dIFxuIiBcCiAiICAgICAgICAgICAgICAgICBbIGR1cGxpY2F0
ZSBQRVJDRU5UIFtDT1JSRUxBVElPTl1dXG4iIFwKICIJCSAgWyBkaXN0cmlidXRpb24ge3VuaWZv
cm18bm9ybWFsfHBhcmV0b3xwYXJldG9ub3JtYWx9IF1cbiIgXAorIgkJICBbIHJlb3JkZXIgUEVS
Q0VOVCBbQ09SUkVMQVRJT05dXVxuIiBcCiAiICAgICAgICAgICAgICAgICBbIGdhcCBQQUNLRVRT
IF1cbiIpOwogfQogCkBAIC0xMjcsMTEgKzEyOCwxMyBAQAogCXN0cnVjdCBydGF0dHIgKnRhaWw7
CiAJc3RydWN0IHRjX25ldGVtX3FvcHQgb3B0OwogCXN0cnVjdCB0Y19uZXRlbV9jb3JyIGNvcjsK
KwlzdHJ1Y3QgdGNfbmV0ZW1fcmVvcmRlciByZW9yZGVyOwogCV9fczE2IGRpc3RfZGF0YVtNQVhE
SVNUXTsKIAogCW1lbXNldCgmb3B0LCAwLCBzaXplb2Yob3B0KSk7CiAJb3B0LmxpbWl0ID0gMTAw
MDsKIAltZW1zZXQoJmNvciwgMCwgc2l6ZW9mKGNvcikpOworCW1lbXNldCgmcmVvcmRlciwgMCwg
c2l6ZW9mKHJlb3JkZXIpKTsKIAogCXdoaWxlIChhcmdjID4gMCkgewogCQlpZiAobWF0Y2hlcygq
YXJndiwgImxpbWl0IikgPT0gMCkgewpAQCAtMTk3LDYgKzIwMCwxOSBAQAogCQkJCQlyZXR1cm4g
LTE7CiAJCQkJfQogCQkJfQorCQl9IGVsc2UgaWYgKG1hdGNoZXMoKmFyZ3YsICJyZW9yZGVyIikg
PT0gMCkgeworCQkJTkVYVF9BUkcoKTsKKwkJCWlmIChnZXRfcGVyY2VudCgmcmVvcmRlci5wcm9i
YWJpbGl0eSwgKmFyZ3YpKSB7CisJCQkJZXhwbGFpbjEoInJlb3JkZXIiKTsKKwkJCQlyZXR1cm4g
LTE7CisJCQl9CisJCQlpZiAoTkVYVF9JU19OVU1CRVIoKSkgeworCQkJCU5FWFRfQVJHKCk7CisJ
CQkJaWYgKGdldF9wZXJjZW50KCZyZW9yZGVyLmNvcnJlbGF0aW9uLCAqYXJndikpIHsKKwkJCQkJ
ZXhwbGFpbjEoInJlb3JkZXIiKTsKKwkJCQkJcmV0dXJuIC0xOworCQkJCX0KKwkJCX0KIAkJfSBl
bHNlIGlmIChtYXRjaGVzKCphcmd2LCAiZGlzdHJpYnV0aW9uIikgPT0gMCkgewogCQkJTkVYVF9B
UkcoKTsKIAkJCWRpc3Rfc2l6ZSA9IGdldF9kaXN0cmlidXRpb24oKmFyZ3YsIGRpc3RfZGF0YSk7
CkBAIC0yMTcsNiArMjMzLDcgQEAKIAogCWFkZGF0dHJfbChuLCAxMDI0LCBUQ0FfT1BUSU9OUywg
Jm9wdCwgc2l6ZW9mKG9wdCkpOwogCWFkZGF0dHJfbChuLCAxMDI0LCBUQ0FfTkVURU1fQ09SUiwg
JmNvciwgc2l6ZW9mKGNvcikpOworCWFkZGF0dHJfbChuLCAxMDI0LCBUQ0FfTkVURU1fUkVPUkRF
UiwgJnJlb3JkZXIsIHNpemVvZihyZW9yZGVyKSk7CiAKIAlpZiAoZGlzdF9zaXplID4gMCkgewog
CQlhZGRhdHRyX2wobiwgMzI3NjgsIFRDQV9ORVRFTV9ERUxBWV9ESVNULApAQCAtMjI5LDcgKzI0
Niw4IEBACiBzdGF0aWMgaW50IG5ldGVtX3ByaW50X29wdChzdHJ1Y3QgcWRpc2NfdXRpbCAqcXUs
IEZJTEUgKmYsIHN0cnVjdCBydGF0dHIgKm9wdCkKIHsKIAljb25zdCBzdHJ1Y3QgdGNfbmV0ZW1f
Y29yciAqY29yID0gTlVMTDsKLQlzdHJ1Y3QgdGNfbmV0ZW1fcW9wdCBxb3B0OworCWNvbnN0IHN0
cnVjdCB0Y19uZXRlbV9yZW9yZGVyICpyZW9yZGVyID0gTlVMTDsKKwlzdHJ1Y3QgdGNfbmV0ZW1f
cW9wdCBxb3B0OwkKIAlpbnQgbGVuID0gUlRBX1BBWUxPQUQob3B0KSAtIHNpemVvZihxb3B0KTsK
IAlTUFJJTlRfQlVGKGIxKTsKIApAQCAtMjUyLDYgKzI3MCwxMiBAQAogCQkJCXJldHVybiAtMTsK
IAkJCWNvciA9IFJUQV9EQVRBKHRiW1RDQV9ORVRFTV9DT1JSXSk7CiAJCX0KKwkJCisJCWlmICh0
YltUQ0FfTkVURU1fUkVPUkRFUl0pIHsKKwkJCWlmIChSVEFfUEFZTE9BRCh0YltUQ0FfTkVURU1f
UkVPUkRFUl0pIDwgc2l6ZW9mKCpyZW9yZGVyKSkKKwkJCQlyZXR1cm4gLTE7CisJCQlyZW9yZGVy
ID0gUlRBX0RBVEEodGJbVENBX05FVEVNX1JFT1JERVJdKTsKKwkJfQogCX0KIAogCWZwcmludGYo
ZiwgImxpbWl0ICVkIiwgcW9wdC5saW1pdCk7CkBAIC0yNzksNiArMzAzLDEzIEBACiAJCQlmcHJp
bnRmKGYsICIgJXMiLCBzcHJpbnRfcGVyY2VudChjb3ItPmR1cF9jb3JyLCBiMSkpOwogCX0KIAor
CWlmIChyZW9yZGVyICYmIHJlb3JkZXItPnByb2JhYmlsaXR5KSB7CisJCWZwcmludGYoZiwgIiBy
ZW9yZGVyICVzIiwKKwkJCQlzcHJpbnRfcGVyY2VudChyZW9yZGVyLT5wcm9iYWJpbGl0eSwgYjEp
KTsKKwkJaWYgKHJlb3JkZXIgJiYgcmVvcmRlci0+Y29ycmVsYXRpb24pCisJCQlmcHJpbnRmKGYs
ICIgJXMiLCBzcHJpbnRfcGVyY2VudChyZW9yZGVyLT5jb3JyZWxhdGlvbiwgYjEpKTsKKwl9CisK
IAlpZiAocW9wdC5nYXApCiAJCWZwcmludGYoZiwgIiBnYXAgJWx1IiwgKHVuc2lnbmVkIGxvbmcp
cW9wdC5nYXApOwogCg==
------=_Part_10705_15871841.1116687909176--
