From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: (usagi-core 15040) [PATCH] IPv6: Protect proxied addresses
 against DAD
Date: Wed, 20 Aug 2003 15:58:08 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308201449550.756-200000@rhea.tcs.hut.fi>
References: <20030820.204304.07033882.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-1858997066-1061384288=:756"
Cc: davem@redhat.com, <netdev@oss.sgi.com>, <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030820.204304.07033882.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-1858997066-1061384288=:756
Content-Type: TEXT/PLAIN; charset=iso-8859-15

On Wed, 20 Aug 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi> (at Wed, 20 Aug 2003 14:40:14 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>
> > --- linux-2.5.OLD/net/ipv6/ndisc.c	2003-08-20 14:10:16.000000000 +0300
> > +++ linux-2.5/net/ipv6/ndisc.c	2003-08-20 14:10:30.000000000 +0300
> > @@ -861,7 +861,8 @@
> >  		struct inet6_dev *in6_dev = in6_dev_get(dev);
> >
> >  		if (in6_dev && in6_dev->cnf.forwarding &&
> > -		    (addr_type & IPV6_ADDR_UNICAST) &&
> > +		    (addr_type & IPV6_ADDR_UNICAST ||
> > +		     addr_type == IPV6_ADDR_ANY) &&
> >  		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
> >  			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
> >
>
> I believe we don't need this chunk.

No, it is needed. Normal neighbor solicitations are sent using a unicast
source address, but DAD probes are sent using the unspecified address as
source.

If the check for IPV6_ADDR_ANY isn't done right there, the proxy won't
handle the DAD probes, since it never enters the shown if block.

The new
if (addr_type & IPV6_ADDR_UNICAST) {
...
} else { <- addr_type == IPV6_ADDR_ANY
...
}
block inside it handles the different cases sending a unicast NA to a
normal NS and a multicast NA to a DAD.

I've updated the comment in my new patch to clarify this. Please use it
instead.

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-1858997066-1061384288=:756
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="proxy_dad_v2.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0308201558080.756@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="proxy_dad_v2.patch"

LS0tIGxpbnV4LTIuNS5PTEQvbmV0L2lwdjYvbmRpc2MuYwkyMDAzLTA4LTIw
IDE0OjEwOjE2LjAwMDAwMDAwMCArMDMwMA0KKysrIGxpbnV4LTIuNS9uZXQv
aXB2Ni9uZGlzYy5jCTIwMDMtMDgtMjAgMTU6Mzk6MzkuMDAwMDAwMDAwICsw
MzAwDQpAQCAtODYxLDcgKzg2MSw4IEBADQogCQlzdHJ1Y3QgaW5ldDZfZGV2
ICppbjZfZGV2ID0gaW42X2Rldl9nZXQoZGV2KTsNCiANCiAJCWlmIChpbjZf
ZGV2ICYmIGluNl9kZXYtPmNuZi5mb3J3YXJkaW5nICYmDQotCQkgICAgKGFk
ZHJfdHlwZSAmIElQVjZfQUREUl9VTklDQVNUKSAmJg0KKwkJICAgIChhZGRy
X3R5cGUgJiBJUFY2X0FERFJfVU5JQ0FTVCB8fA0KKwkJICAgICBhZGRyX3R5
cGUgPT0gSVBWNl9BRERSX0FOWSkgJiYNCiAJCSAgICBwbmVpZ2hfbG9va3Vw
KCZuZF90YmwsICZtc2ctPnRhcmdldCwgZGV2LCAwKSkgew0KIAkJCWludCBp
bmMgPSBpcHY2X2FkZHJfdHlwZShkYWRkcikmSVBWNl9BRERSX01VTFRJQ0FT
VDsNCiANCkBAIC04NzQsMTIgKzg3NSwxOSBAQA0KIAkJCQllbHNlDQogCQkJ
CQluZF90Ymwuc3RhdHMucmN2X3Byb2Jlc191Y2FzdCsrOw0KIAkJCQkJDQot
CQkJCW5laWdoID0gbmVpZ2hfZXZlbnRfbnMoJm5kX3RibCwgbGxhZGRyLCBz
YWRkciwgZGV2KTsNCisJCQkJaWYgKGFkZHJfdHlwZSAmIElQVjZfQUREUl9V
TklDQVNUKSB7DQorCQkJCQluZWlnaCA9IG5laWdoX2V2ZW50X25zKCZuZF90
YmwsIGxsYWRkciwgc2FkZHIsIGRldik7DQogDQotCQkJCWlmIChuZWlnaCkg
ew0KLQkJCQkJbmRpc2Nfc2VuZF9uYShkZXYsIG5laWdoLCBzYWRkciwgJm1z
Zy0+dGFyZ2V0LA0KLQkJCQkJCSAgICAgIDAsIDEsIDAsIDEpOw0KLQkJCQkJ
bmVpZ2hfcmVsZWFzZShuZWlnaCk7DQorCQkJCQlpZiAobmVpZ2gpIHsNCisJ
CQkJCQluZGlzY19zZW5kX25hKGRldiwgbmVpZ2gsIHNhZGRyLCAmbXNnLT50
YXJnZXQsDQorCQkJCQkJCSAgICAgIDAsIDEsIDAsIDEpOw0KKwkJCQkJCW5l
aWdoX3JlbGVhc2UobmVpZ2gpOw0KKwkJCQkJfQ0KKwkJCQl9IGVsc2UgeyAv
KiBhZGRyX3R5cGUgPT0gSVBWNl9BRERSX0FOWSwgaS5lLiBhIERBRCBwcm9i
ZSAqLyANCisJCQkJCXN0cnVjdCBpbjZfYWRkciBtYWRkcjsNCisJCQkJCWlw
djZfYWRkcl9hbGxfbm9kZXMoJm1hZGRyKTsNCisJCQkJCW5kaXNjX3NlbmRf
bmEoZGV2LCBOVUxMLCAmbWFkZHIsICZtc2ctPnRhcmdldCwgDQorCQkJCQkJ
ICAgICAgMCwgMCwgMCwgMSk7DQogCQkJCX0NCiAJCQl9IGVsc2Ugew0KIAkJ
CQlzdHJ1Y3Qgc2tfYnVmZiAqbiA9IHNrYl9jbG9uZShza2IsIEdGUF9BVE9N
SUMpOw0K
---377318441-1858997066-1061384288=:756--
