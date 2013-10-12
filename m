From: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Subject: [Patch 1/1]: libertas/sdio: fix releasing memory twice.
Date: Sat, 12 Oct 2013 18:02:09 +0200
Message-ID: <D5BD8103-A6A6-4070-878B-99FC5883725F@goldelico.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: multipart/mixed; boundary=Apple-Mail-219--440396343
To: "John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>,
	"H. Nikolaus Schaller" <hns@goldelico.com>,
	Dan Williams <dcbw@redhat.com>, Harro Haan <hrhaan@gmail.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Belisko Marek <marek@goldelico.com>,
	NeilBrown Brown <neilb@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Apple-Mail-219--440396343
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

While upgrading the GTA04 kernel to 3.12-rc4 we came across
an issue with libertas/sdio referencing stale memory on ifconfig up
when trying to load the firmware (for a second time).

I am not at all sure if the patch is how it should be done and the right
location, but it appears to work for us with resetting priv->helper_fw =
to NULL
before asynchronously loading the firmware again.




--Apple-Mail-219--440396343
Content-Disposition: attachment;
	filename=0001-libertas-sdio-fix-releasing-memory-twice.patch
Content-Type: application/octet-stream;
	name="0001-libertas-sdio-fix-releasing-memory-twice.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=20f6864491ea45d2bd877a37fbb4a618e42fe03fbe=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20"H.=20Nikolaus=20Schaller"=20=
<hns@goldelico.com>=0ADate:=20Sat,=2012=20Oct=202013=2017:49:31=20+0200=0A=
Subject:=20[PATCH]=20libertas/sdio:=20fix=20releasing=20memory=20twice.=20=
We=20have=20connected=0A=20a=20Wi2Wi=20W2CBW003=20to=20an=20OMAP3=20=
using=20SDIO.=20We=20have=20seen=20an=0A=20issue=20(not=20related=20with=20=
this=20patch)=20that=20sometimes=20power=20is=0A=20not=20turned=20off.=20=
This=20did=20lead=20to=20a=20kernel=20Oops=20if=20an=0A=20ifconfig=20up=20=
/=20down=20/=20up=20when=20the=20chip=20was=20not=20powered=20down.=0A=20=
This=20leads=20to=20a=20second=20call=20to=20lbs_get_firmware_async()=0A=20=
with=20the=20same=20priv=20data=20-=20and=20that=20tries=20to=0A=20=
release_firmware(priv->helper_fw);=20This=20appears=20to=20be=0A=20=
wrong,=20since=20it=20was=20alredy=20released=20in=20the=0A=20=
if_sdio_do_prog_firmware.=0A=0ASigned-off-by:=20H.=20Nikolaus=20Schaller=20=
<hns@goldelico.com>=0A---=0A=20drivers/net/wireless/libertas/if_sdio.c=20=
|=20=20=2013=20+++++++++++++=0A=201=20files=20changed,=2013=20=
insertions(+),=200=20deletions(-)=0A=0Adiff=20--git=20=
a/drivers/net/wireless/libertas/if_sdio.c=20=
b/drivers/net/wireless/libertas/if_sdio.c=0Aindex=204557833..a04eb41=20=
100644=0A---=20a/drivers/net/wireless/libertas/if_sdio.c=0A+++=20=
b/drivers/net/wireless/libertas/if_sdio.c=0A@@=20-769,6=20+769,19=20@@=20=
static=20int=20if_sdio_prog_firmware(struct=20if_sdio_card=20*card)=0A=20=
=09=09return=200;=0A=20=09}=0A=20=0A+=09/*=20This=20is=20missing=20in=20=
lbs_get_firmware_async()=0A+=09=20*=20and=20therefore=20a=20second=20=
call=20using=20the=20same=20priv=20structure=0A+=09=20*=20may=20find=20a=20=
stale=20helper_fw=20entry=20that=20has=20already=20been=0A+=09=20*=20=
released=20by=20release_firmware(helper)=20in=0A+=09=20*=20=
if_sdio_do_prog_firmware().=0A+=09=20*=20Or=20doing=20that=20release=20=
in=20if_sdio_do_prog_firmware()=0A+=09=20*=20is=20a=20duplicate=20and=20=
should=20not=20be=20there.=0A+=09=20*=20Anyways,=20this=20can=20happen=20=
if=20a=20ifconfig=20up=20/=20down=20/=20up=0A+=09=20*=20sequence=20is=20=
issued.=0A+=09=20*/=0A+=0A+=09card->priv->helper_fw=20=3D=20NULL;=0A+=0A=20=
=09ret=20=3D=20lbs_get_firmware_async(card->priv,=20&card->func->dev,=20=
card->model,=0A=20=09=09=09=09=20=20=20=20=20fw_table,=20=
if_sdio_do_prog_firmware);=0A=20=0A--=20=0A1.7.7.4=0A=0A=

--Apple-Mail-219--440396343--
