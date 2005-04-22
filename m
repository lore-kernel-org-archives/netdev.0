From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 15:22:49 +0200
Message-ID: <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504221342.10675.wolfgang.walter@studentenwerk.mhn.de> <1114172084.7679.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114172084.7679.15.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Freitag, 22. April 2005 14:14 schrieb jamal:
> On Fri, 2005-22-04 at 13:42 +0200, Wolfgang Walter wrote:
> > Am Freitag, 22. April 2005 02:18 schrieb jamal:
>
> [..]
>
> > > So i was wondering whether they OUT shouldnt be just a duplicate of
> > > FWD (instead FWD seems to be the dup of IN). Look at that sample i
> > > posted - all his policies look like that. What gives? Why are the I=
N
> > > and FWD exactly the same? bug in racoon/setkey?
> >
> > No. XFRM_POLICY_IN is only checked for incoming packets which are
> > delivered locally.
>
> For encrypted packets

I think for all packets otherwise it would not make sense to have allow a=
nd=20
block rules.

I'm not sure how packets of tunnels ending at a host are treated exactly.=
=20
Probably the tunnel-packet itself is checked against XFRM_POLICY_IN becau=
se=20
its destination is the host itself. Then it gets decrypted if an entry=20
appropriate in the sad in (dst,spi) exists. The inner packet gets extract=
ed=20
and decrypted and is then rerouted.

I think it is like that because

* you see those packets twice in PREROUTING (mangle) i.e. for an esp-tunn=
el:=20
first as esp-packet than the inner decrypted packet. If the inner packet =
is=20
to be routed, XFRM_POLICY_FWD is relevant, otherwise XFRM_POLICY_IN.

But maybe XFRM_POLICY_IN is bypassed for ipsec-packets.

I didn't try out transport-mode.

>
> > XFRM_POLICY_FWD is checked for incoming packets which are routed.
>
> For non-encrypted packets to be forwarded.

Again: for all packets.

Packets to be routed which are still encrypted here are ipsec-packets whi=
ch=20
are not destinated or originating from this host. Of course they may came=
 in=20
via a tunnel ending at this host:

a<--->N1<--->b<----ipsec-tunnel--->c<--->N2<--->d=20

If a communicates with d via esp (tunnel or transportmode) and b and c tu=
nnel=20
all packets between network N1 and N2 via ipsec then, on c, a ipsec packe=
t=20
from a to d would come in via the tunnel packed into another ipsec packet=
, is=20
extracted from the tunnel packet and is routed to d if XFRM_POLICY_FWD al=
lows=20
esp packets from a to d and XFRM_POLICY_OUT allows unencrypted communicat=
ion=20
between c and d for esp-packets from a to d.

>
> > That our XFRM_POLICY_IN matches XFRM_POLICY_FWD is more for convenien=
ce:
> > if a subnet is connected directly to a router we want to treat the
> > interface address of the router itself the same way. Instead of
> > constructing special rules which exactly match the interface address =
we
> > simply use the same rule as for forwarding.
>
> Ok, so it was design intent then.
>
> > XFRM_POLICY_OUT ist checked for every outgoing packet, be it locally
> > generated be it routed (which is different from netfilter).
> >
> > This asymmetry is a little bit inconsequent. Probably one should real=
ly
> > have XFRM_POLICY_FWD_IN and XFRM_POLICY_FWD_OUT. But XFRM_POLICY_OUT
> > would mainly be a copy of XFRM_POLICY_FWD_OUT then, I think.
>
> I did notice racoon or even setkey (version 0.5) for some rules (need t=
o
> investigate) would install two policy rules when i installed only one i=
.e
> racoon will install one in OUT and other in FWD direction.
>
> Example script and setkey -DP output attached. In this case i install
> two rules, but for one of them an extra rule is installed. Actually the
> pattern is quiet repeatable as you add more rules. This may also be wha=
t
> is happening to you maybe?

spdadd 192.168.2.100 192.168.3.10 any -P in ipsec
           esp/transport//require
           ah/transport//require;

installs both in and fwd rules (in RFC-mode). Use option -k for only sett=
ing=20
in rules (RFC only knows IN and OUT rules). This behaviour was added to=20
ipsec-tools. As far as I know earlier kernels had a bug and didn't check =
fwd=20
ruleset so that setkey and racoon worked by accident under linux.

racoon now behaves like pluto: it inserts always in and fwd rules. Its ea=
sier=20
than to check if a in or fwd rule or both is needed.=20

And no, we do not use setkey any more but ip xfrm (though setkey displays=
 more=20
information, i.e. it tells you if a policy is socket-specific). Reason is=
=20
that neither setkey  nor racoon can handle large rule sets. And for most =
fwd=20
rules we also set an in rule (as pluto does).

Greetings
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen
