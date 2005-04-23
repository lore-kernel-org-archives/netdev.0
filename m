From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Sat, 23 Apr 2005 23:03:35 +0200
Message-ID: <200504232303.35549.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de> <1114278545.7669.75.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114278545.7669.75.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Samstag, 23. April 2005 19:49 schrieb jamal:
> On Fri, 2005-22-04 at 15:22 +0200, Wolfgang Walter wrote:
> So to allow pass-through of esp packets from a<->d at c, you will have
> to essentially create special policy rules (at FWD and OUT) to basicall=
y
> just allow if src/dst =3D a/d, correct?

Yes.

>
> > spdadd 192.168.2.100 192.168.3.10 any -P in ipsec
> >            esp/transport//require
> >            ah/transport//require;
> >
> > installs both in and fwd rules (in RFC-mode).
>
> What is "RFC mode"?

The RFCs for ipsec talk about the SPD. This database must be consulted fo=
r=20
every packet entering or leaving. Its defined as an ordered database. A r=
ules=20
has direction, selectors (i.e. src, dst, next layer protocoll, src-port,=20
dst-port, icmp-type) and processing info (BYPASS =3D not handled by ipsec=
,=20
DISCARD =3D drop the packet, PROTECT =3D handled by ipsec).

So setkey in RFC mode sets in anf fwd rules as RFC-in =3D linux-in + linu=
x-fwd.

>
> > Use option -k for only setting  in rules (RFC only knows IN and OUT
> > rules). This behaviour was added to
> > ipsec-tools. As far as I know earlier kernels had a bug and didn't ch=
eck
> > fwd ruleset so that setkey and racoon worked by accident under linux.
> >
> >
> > racoon now behaves like pluto: it inserts always in and fwd rules. It=
s
> > easier than to check if a in or fwd rule or both is needed.
>
> I think i am still lost on the desire to have the FWD database. Unless
> we are trying to use SPD for firewalling?

SPD is indeed also a sort of firewall. You can use it to construct i.e. a=
=20
vpn-gateway and forbid any non-vpn-traffic entering or leaving.

How the SPD is implemented is of course not specified. I think KLIPS use =
a=20
mixing of routing and netfilter and "ipsec-netdevices" to realise the SPD.

My personal view is that 2.6 native SPD is better. Its easier to understa=
nd=20
and protect i.e. vpn-gateways.

Using selectors other than src, dst in the SPD is tricky, by the way, bec=
ause=20
of fragments. Say a rule selects packets from a to b with protocol tcp an=
d=20
dst-port 80 to be sent through a tunnel you must have an extra rule (and=20
tunnel) for the fragments (and all fragments are tunneled then).

Maybe more complex selectors should be realised by netfilter, a module wh=
ich=20
can mark packets. And SPD uses that mark. Then statefull policies are=20
possible, i.e.

I don't know if linux handles ICMP traffic well, often one must check the=
=20
payload against the SPD. I had no time yet to do some tests.

>
> > And no, we do not use setkey any more but ip xfrm (though setkey disp=
lays
> > more information, i.e. it tells you if a policy is socket-specific).
>
> Should be fixable in ip xfrm ..
>
> >  Reason is
> > that neither setkey  nor racoon can handle large rule sets. And for m=
ost
> > fwd rules we also set an in rule (as pluto does).
>
> Do you know why pfkey doesnt scale? Herbert?

It seems to deliver the whole message at once. If one increase the=20
socket-buffer (must change racoon and setkey source, at least with versio=
n=20
0.3.3) enough one gets complete dumps, ie. But sometimes there seems to b=
e=20
still problems - i.e. if you send a lot of messages. Maybe the kernel can=
 not=20
create these large messages because it cannot allocate enough memory in t=
hat=20
moment or racoon cannot read fast enough.

Greetings,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen
