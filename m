From: Helmut Grohne <h.grohne@cygnusnetworks.de>
Subject: [PATCH] issues with printk "mppe_compress[%d]: osize too small! ..."
Date: Fri, 11 Oct 2013 14:57:38 +0200
Message-ID: <C01514A3-58D1-4114-AE71-2666AA7F72DD@cygnusnetworks.de>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: multipart/mixed; boundary="Apple-Mail=_BA187A61-4FF1-420E-8BCF-EFFFBFF6F88B"
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Apple-Mail=_BA187A61-4FF1-420E-8BCF-EFFFBFF6F88B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

Dear kernel maintainers,

I ran into an issue that causes "mppe_compress[%d]: osize too small! =85"
message to be printed. While debugging the issue, I stumbled across two
additional issues with the code in question.

1) The printk gives a "have" and a "need" value. However the "need"
   value does not represent the actual need, because the printed need
   is based on the osize variable instead of the isize variable used in
   the test. This appears to by a typo an is as old as the ppp_mppe.c
   file. The first patch attached changes the parameter to printk to
   print the actual need.

2) The message in question can be triggered by network packets. If that
   happens, there are a lot of printks and the whole system slows down
   to a crawl. Whenever network packets are processed, the printks must
   be rate limited in some way, so my second patch adds a call to
   net_ratelimit(). Note that even though checkpatch suggested to
   convert the printks to netdev_dbg, I felt that a bug fix should be
   minimal and thus not change this aspect.

Please consider these patches and CC me in replies.

Helmut


--Apple-Mail=_BA187A61-4FF1-420E-8BCF-EFFFBFF6F88B
Content-Disposition: attachment;
	filename=0001-mppe-print-correct-osize-required-for-compression.patch
Content-Type: application/octet-stream;
	name="0001-mppe-print-correct-osize-required-for-compression.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=2077ef588c202c1e8b23f5292e6b64d7cd69a9daba=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Helmut=20Grohne=20<h.grohne@cygnusnetworks.de>=0A=
Date:=20Fri,=2011=20Oct=202013=2014:18:50=20+0200=0ASubject:=20[PATCH]=20=
mppe:=20print=20correct=20osize=20required=20for=20compression=0A=0AAn=20=
example=20message=20looks=20like=20this:=0A=0Amppe_compress[76]:=20osize=20=
too=20small!=20(have:=201404=20need:=201408)=0A=0AThe=20value=20printed=20=
as=20"need"=20is=20not=20the=20one=20that=20is=20actually=20needed,=0A=
because=20it=20is=20based=20on=20osize=20instead=20of=20isize=20as=20=
used=20in=20the=20test.=20In=0Athe=20old=20implementation=20the=20"need"=20=
value=20would=20always=204=20greater=20than=20the=0A"have"=20value.=0A=0A=
Signed-off-by:=20Helmut=20Grohne=20<h.grohne@cygnusnetworks.de>=0A---=0A=20=
drivers/net/ppp/ppp_mppe.c=20|=20=20=20=202=20+-=0A=201=20file=20=
changed,=201=20insertion(+),=201=20deletion(-)=0A=0Adiff=20--git=20=
a/drivers/net/ppp/ppp_mppe.c=20b/drivers/net/ppp/ppp_mppe.c=0Aindex=20=
9a1849a..3d595a8=20100644=0A---=20a/drivers/net/ppp/ppp_mppe.c=0A+++=20=
b/drivers/net/ppp/ppp_mppe.c=0A@@=20-385,7=20+385,7=20@@=20=
mppe_compress(void=20*arg,=20unsigned=20char=20*ibuf,=20unsigned=20char=20=
*obuf,=0A=20=09=09/*=20Drop=20the=20packet=20if=20we=20should=20encrypt=20=
it,=20but=20can't.=20*/=0A=20=09=09printk(KERN_DEBUG=20=
"mppe_compress[%d]:=20osize=20too=20small!=20"=0A=20=09=09=20=20=20=20=20=
=20=20"(have:=20%d=20need:=20%d)\n",=20state->unit,=0A-=09=09=20=20=20=20=
=20=20=20osize,=20osize=20+=20MPPE_OVHD=20+=202);=0A+=09=09=20=20=20=20=20=
=20=20osize,=20isize=20+=20MPPE_OVHD=20+=202);=0A=20=09=09return=20-1;=0A=
=20=09}=0A=20=0A--=20=0A1.7.10.4=0A=0A=

--Apple-Mail=_BA187A61-4FF1-420E-8BCF-EFFFBFF6F88B
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii



--Apple-Mail=_BA187A61-4FF1-420E-8BCF-EFFFBFF6F88B
Content-Disposition: attachment;
	filename=0001-mppe-rate-limit-osize-too-small.patch
Content-Type: application/octet-stream;
	name="0001-mppe-rate-limit-osize-too-small.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=203332d572e21f52d65df841ba85537b65d336007e=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Helmut=20Grohne=20<h.grohne@cygnusnetworks.de>=0A=
Date:=20Fri,=2011=20Oct=202013=2014:34:06=20+0200=0ASubject:=20[PATCH]=20=
mppe:=20rate=20limit=20"osize=20too=20small"=0A=0AThese=20messages=20=
occur=20per=20packet=20and=20can=20be=20triggered=20by=20remote=20sites.=20=
As=0Asuch=20they=20must=20be=20rate=20limited=20in=20order=20to=20not=20=
clog=20the=20kernel=20log=0Abuffers.=20The=20corresponding=20messages=20=
from=20ppp_generic.c=20are=20already=20rate=0Alimited.=20Example:=0A=0A=
mppe_compress[76]:=20osize=20too=20small!=20(have:=201404=20need:=20=
1408)=0Appp:=20compressor=20dropped=20pkt=0Amppe_compress[76]:=20osize=20=
too=20small!=20(have:=201404=20need:=201408)=0Appp:=20compressor=20=
dropped=20pkt=0Amppe_compress[76]:=20osize=20too=20small!=20(have:=20=
1404=20need:=201408)=0Amppe_compress[76]:=20osize=20too=20small!=20=
(have:=201404=20need:=201408)=0A=0ASigned-off-by:=20Helmut=20Grohne=20=
<h.grohne@cygnusnetworks.de>=0A---=0A=20drivers/net/ppp/ppp_mppe.c=20|=20=
=20=2015=20+++++++++------=0A=201=20file=20changed,=209=20insertions(+),=20=
6=20deletions(-)=0A=0Adiff=20--git=20a/drivers/net/ppp/ppp_mppe.c=20=
b/drivers/net/ppp/ppp_mppe.c=0Aindex=209a1849a..7e71a7a=20100644=0A---=20=
a/drivers/net/ppp/ppp_mppe.c=0A+++=20b/drivers/net/ppp/ppp_mppe.c=0A@@=20=
-52,6=20+52,7=20@@=0A=20#include=20<linux/string.h>=0A=20#include=20=
<linux/crypto.h>=0A=20#include=20<linux/mm.h>=0A+#include=20=
<linux/net.h>=0A=20#include=20<linux/ppp_defs.h>=0A=20#include=20=
<linux/ppp-comp.h>=0A=20#include=20<linux/scatterlist.h>=0A@@=20-383,9=20=
+384,10=20@@=20mppe_compress(void=20*arg,=20unsigned=20char=20*ibuf,=20=
unsigned=20char=20*obuf,=0A=20=09/*=20Make=20sure=20we=20have=20enough=20=
room=20to=20generate=20an=20encrypted=20packet.=20*/=0A=20=09if=20(osize=20=
<=20isize=20+=20MPPE_OVHD=20+=202)=20{=0A=20=09=09/*=20Drop=20the=20=
packet=20if=20we=20should=20encrypt=20it,=20but=20can't.=20*/=0A-=09=09=
printk(KERN_DEBUG=20"mppe_compress[%d]:=20osize=20too=20small!=20"=0A-=09=
=09=20=20=20=20=20=20=20"(have:=20%d=20need:=20%d)\n",=20state->unit,=0A=
-=09=09=20=20=20=20=20=20=20osize,=20osize=20+=20MPPE_OVHD=20+=202);=0A+=09=
=09if=20(net_ratelimit())=0A+=09=09=09printk(KERN_DEBUG=20=
"mppe_compress[%d]:=20osize=20too=20small!=20"=0A+=09=09=09=20=20=20=20=20=
=20=20"(have:=20%d=20need:=20%d)\n",=20state->unit,=0A+=09=09=09=20=20=20=
=20=20=20=20osize,=20osize=20+=20MPPE_OVHD=20+=202);=0A=20=09=09return=20=
-1;=0A=20=09}=0A=20=0A@@=20-497,9=20+499,10=20@@=20mppe_decompress(void=20=
*arg,=20unsigned=20char=20*ibuf,=20int=20isize,=20unsigned=20char=20=
*obuf,=0A=20=09=20*=20this=20is=20to=20account=20for=20possible=20PFC.=0A=
=20=09=20*/=0A=20=09if=20(osize=20<=20isize=20-=20MPPE_OVHD=20-=201)=20{=0A=
-=09=09printk(KERN_DEBUG=20"mppe_decompress[%d]:=20osize=20too=20small!=20=
"=0A-=09=09=20=20=20=20=20=20=20"(have:=20%d=20need:=20%d)\n",=20=
state->unit,=0A-=09=09=20=20=20=20=20=20=20osize,=20isize=20-=20=
MPPE_OVHD=20-=201);=0A+=09=09if=20(net_ratelimit())=0A+=09=09=09=
printk(KERN_DEBUG=20"mppe_decompress[%d]:=20osize=20too=20small!=20"=0A+=09=
=09=09=20=20=20=20=20=20=20"(have:=20%d=20need:=20%d)\n",=20state->unit,=0A=
+=09=09=09=20=20=20=20=20=20=20osize,=20isize=20-=20MPPE_OVHD=20-=201);=0A=
=20=09=09return=20DECOMP_ERROR;=0A=20=09}=0A=20=09osize=20=3D=20isize=20=
-=20MPPE_OVHD=20-=202;=09/*=20assume=20no=20PFC=20*/=0A--=20=0A1.7.10.4=0A=
=0A=

--Apple-Mail=_BA187A61-4FF1-420E-8BCF-EFFFBFF6F88B--
