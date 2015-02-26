From: Andre Valentin <avalentin@marcant.net>
Subject: Re: Kernel Panic with vti Interfaces
Date: Fri, 27 Feb 2015 00:58:10 +0100
Message-ID: <54EFB312.8040309@marcant.net>
References: <54EC4C63.3050006@marcant.net> <20150226114052.GB20631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.marcant.net ([217.14.160.186]:54387 "EHLO
	mail2.marcant.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbbB0AYw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 19:24:52 -0500
In-Reply-To: <20150226114052.GB20631@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen!

>> From: =3D?utf8?q?Andr=3DC3=3DA9=3D20Valentin?=3D <avalentin@marcant.=
net>
>> Date: Tue, 24 Feb 2015 00:24:08 +0100
>> Subject: [PATCH] kernel: fix xfrm tunnel checks if vti parent SA/dev=
ice is in transition
>>
>> The outer_mode check results in the error if it is not checked for v=
alidity.
>> Because I do not know how to handle this situation, I decided to ret=
urn
>> -EINVAL if outer_mode is null.
>>
>> ---
>>  .../618-net_fixup_xfrm_tunnel_check.patch          |   16 +++++++++=
+++++++
>>  1 files changed, 16 insertions(+), 0 deletions(-)
>>  create mode 100644 target/linux/generic/patches-3.18/618-net_fixup_=
xfrm_tunnel_check.patch
>>
>> diff --git a/target/linux/generic/patches-3.18/618-net_fixup_xfrm_tu=
nnel_check.patch b/target/linux/generic/patches-3.18/618-net_fixup_xfrm=
_tunnel_check.patch
>> new file mode 100644
>> index 0000000..f79b1f7
>> --- /dev/null
>> +++ b/target/linux/generic/patches-3.18/618-net_fixup_xfrm_tunnel_ch=
eck.patch
>> @@ -0,0 +1,16 @@
>> +--- a/include/net/xfrm.h    2015-02-11 08:01:12.000000000 +0100
>> ++++ b/include/net/xfrm.h    2015-02-24 00:04:03.102709830 +0100
>> +@@ -1805,8 +1805,12 @@ static inline int xfrm_tunnel_check(stru
>> +                    tunnel =3D true;
>> +            break;
>> +    }
>> +-   if (tunnel && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL))
>> ++   if (tunnel && !x->outer_mode) {
>> ++                printk(KERN_NOTICE "xfrm_tunnel_check: outer_mode =
is 0, returning -EINVAL\n");
>> +            return -EINVAL;
>
> Returning -EINVAL here would just paper over the real bug.
>
> We should never get a state without outer_mode from a lookup.
> Using such a state will lead to a crash anyway, even without
> using vti devices. Looks like you get an uninitialized state
> with the lookup. When a xfrm_state is initialized, the outer
> mode is added and after that inserted to the lookup tables.
> It should never loose the outer_mode pointer.

Okay, I will take a deeper look at the other modifications of
the platform.

Here are some log entries around the event:
=46ri Feb 27 00:31:24 2015 daemon.info syslog: 09[ENC] generating CREAT=
E_CHILD_SA request 10 [ N(REKEY_SA) SA No KE TSi TSr ]
=46ri Feb 27 00:31:24 2015 daemon.info syslog: 09[NET] sending packet: =
from a.b.c.d[500] to c.d.e.f[500] (541 bytes)
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.530000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.540000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.550000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 daemon.info syslog: 04[NET] received packet:=
 from c.d.e.f[500] to a.b.c.d[500] (529 bytes)
=46ri Feb 27 00:31:25 2015 daemon.info syslog: 04[ENC] parsed CREATE_CH=
ILD_SA response 10 [ SA No KE TSi TSr ]
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.580000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.630000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.640000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.650000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.720000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.730000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.730000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.740000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.750000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.750000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 kern.notice kernel: [255629.790000] xfrm_tun=
nel_check: outer_mode is 0, returning -EINVAL
=46ri Feb 27 00:31:25 2015 daemon.info syslog: 04[IKE] CHILD_SA myhost-=
vti{111} established with SPIs c65bd3e4_i cd2e85f8_o and TS 0.0.0.0/0 :=
:/0 =3D=3D=3D 0.0.0.0/0 ::/0
=46ri Feb 27 00:31:25 2015 authpriv.info syslog: 04[IKE] CHILD_SA myhos=
t-vti{111} established with SPIs c65bd3e4_i cd2e85f8_o and TS 0.0.0.0/0=
 ::/0 =3D=3D=3D 0.0.0.0/0 ::/0

>
> I have never seen this, is the patch above the only locally
> applied patch?
No, the kernel is coming from the current openwrt 3.18 trunk.
It's 3.18.7 with serveral patches coming from openwrt.
I already checked the IPsec related patches but the error
persisted.

I will remove more patches to be sure and forward my results!

> Is this reproducible?

Yes, it this happens on every pppoe reconnect. That annoyed me
a bit and I dived into it ;-)

Kind regards,

Andr=E9 Valentin



Mit freundlichen Gr=FC=DFen
 Andr=E9 Valentin
Systemadministrator
--

++++++WIR ZIEHEN UM++++++
Ab dem 09.03.2015 erreichen Sie uns unter folgender Anschrift.

MarcanT GmbH
Herforder Stra=DFe 163 a
33609 Bielefeld

Bitte beachten Sie, dass ab dem 09.03.2015 alle Rechnungen und
Korrespondenz nur noch auf die oben genannte Anschrift ausgestellt
werden. Aktualisieren Sie bitte Ihre Stammdaten entsprechend. Wir
w=FCnschen uns, den Umzug f=FCr Sie und uns ohne Beeintr=E4chtigungen d=
es
Tagesgesch=E4ftes abwickeln zu k=F6nnen. Sollte es dennoch zu Schwierig=
keiten
kommen, hoffen wir auf Ihr Verst=E4ndnis.
Auf unser Rechenzentrum hat der Umzug keinen Einfluss; die Funktionen
wurden bereits Anfang Februar auf unsere Redundanzrechenzentren verteil=
t.
++++++++++++++++++++++++++++++++++++

MarcanT GmbH, Ravensberger Str. 10 G, D - 33602 Bielefeld
=46on: +49 (521) 95945-0 | Fax: +49 (521) 95945-18
URL: http://www.marcant.net | http://www.global-m2m.com

Internet * Netzwerk * Mobile Daten
Citrix Silver Solution Advisor

Gesch=E4ftsf=FChrer: Thorsten Hojas
Handelsregister: AG Bielefeld, HRB 35827 USt-ID Nr.: DE 190203238
___________________________________________________________
Ausserhalb unserer Gesch=E4ftszeiten (Montag bis Freitag von 8:30 Uhr b=
is
17:30 Uhr, ausgenommen gesetzliche Feiertage in NRW) stehen wir Ihnen
gem=E4=DF Ihrer jeweiligen Service-Level-Agreements unter der Ihnen
mitgeteilten Telefonnummer f=FCr St=F6rungen und Notf=E4lle zur Verf=FC=
gung.
Sie k=F6nnen nat=FCrlich auch gerne jederzeit unter support@marcant.net=
 ein
Ticket er=F6ffnen, welches am n=E4chsten Arbeitstag bearbeitet wird.
