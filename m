From: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken. In 4.0.0-rc3
Date: Mon, 16 Mar 2015 22:09:04 +0300
Message-ID: <994171426532944__42801.5455873266$1426533273$gmane$org@web7m.yandex.ru>
References: <390621425930628@web28o.yandex.ru>
	 <3625951426018334@web26j.yandex.ru>
	 <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	 <726281426513068@web10o.yandex.ru> <BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward19m.cmail.yandex.net ([5.255.216.150]:37578 "EHLO
	forward19m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752669AbbCPTOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 15:14:08 -0400
In-Reply-To: <BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

16.03.2015, 17:01, "fugang.duan@freescale.com" <fugang.duan@freescale.c=
om>:
>>>
>>> =9ADo you have any lost for reproduce the issue ?
>> =9ACurrent net tree does not have this issue, it works fine. Thanks =
to all.
>>
>> =9AFrom git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
>>
>> =9Aapx@astra:~$ uname -r
>> =9A4.0.0-rc3-00150-g10640d3-dirty
>>
>
> I test the commit f00bbd2 that include the patch 2b995f63987.
> But cannot reproduce your issue. Pls double confirm it in your board.

Confirmed that net-next is buggy.

Client kernel version:
apx@astra:~$ uname -r
4.0.0-rc3-00875-gf00bbd2-dirty

100M file of zeros on client:
apx@astra:~$ ls -l zeros=20
-rw-r--r-- 1 apx apx 104857600 =CD=C1=D2 10 22:33 zeros

=46ile contents (ran on client host):
apx@astra:~$ hd zeros=20
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |..........=
=2E.....|
*
06400000

NFS server kernel version:
apx@ct:~$ uname -r
4.0.0-rc2-00480-g29e70e6

100M file of zeros on client:
apx@ct:~$ ls -l zeros=20
-rw-r--r-- 1 apx apx 104857600 =CD=C1=D2 10 22:33 zeros

=46ile contents (ran on server host):
apx@ct:~$ hd zeros   =20
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |..........=
=2E.....|
*
001d4a80  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 1c f0 9f e5  |..........=
=2E.....|
*
001d4aa0  1c f0 9f e5 74 fb 00 00  bc ff 93 00 c0 ff 93 00  |....t.....=
=2E.....|
001d4ab0  c4 ff 93 00 c8 ff 93 00  cc ff 93 00 d0 ff 93 00  |..........=
=2E.....|
001d4ac0  d4 ff 93 00 d8 ff 93 00  13 00 00 00 28 63 29 20  |..........=
=2E.(c) |
001d4ad0  43 6f 70 79 72 69 67 68  74 20 32 30 30 37 2d 32  |Copyright =
2007-2|
001d4ae0  30 31 32 2c 20 46 72 65  65 73 63 61 6c 65 20 53  |012, Frees=
cale S|
001d4af0  65 6d 69 63 6f 6e 64 75  63 74 6f 72 2e 20 41 6c  |emiconduct=
or. Al|
001d4b00  6c 20 72 69 67 68 74 73  20 72 65 73 65 72 76 65  |l rights r=
eserve|
001d4b10  64 2e 00 00 dd 00 2c 41  11 73 00 00 d3 74 00 00  |d.....,A.s=
=2E..t..|
001d4b20  3d 75 00 00 a9 78 00 00  4f 78 00 00 75 77 00 00  |=3Du...x..=
Ox..uw..|
001d4b30  07 76 00 00 c3 79 00 00  09 7a 00 00 75 7a 00 00  |.v...y...z=
=2E.uz..|

Any other client works fine with this server.
And note that corruption is not random, it looks like a zero page (vect=
ors at beginning),
so somewhere pointer to data is corrupted (and set to zero(?)).
This is repeated many times.

I use an Embedsky E9 board: http://en.embedsky.com/product_info.php?cat=
eid=3D169&id=3D169
It is SabreSD-alike board with a fewer peripherials, and at network sid=
e it has a different PHY,
instead of Atheros it has a Realtek RTL8211E, and I have to initialize =
it this way (board early fixup patch):

--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -166,6 +166,19 @@ static int ar8035_phy_fixup(struct phy_device *dev=
)
=20
 #define PHY_ID_AR8035 0x004dd072
=20
+static int rtl8211e_phy_fixup(struct phy_device *dev)
+{
+       phy_write(dev, 0x00, 0x3140);
+       msleep(10);
+       phy_write(dev, 0x00, 0x3340);
+       msleep(10);
+
+       return 0;
+}
+
+#define PHY_ID_RTL8211E 0x001cc915
+#define REALTEK_PHY_ID_MASK 0x001fffff
+
 static void __init imx6q_enet_phy_init(void)
 {
        if (IS_BUILTIN(CONFIG_PHYLIB)) {
@@ -177,6 +190,8 @@ static void __init imx6q_enet_phy_init(void)
                                ar8031_phy_fixup);
                phy_register_fixup_for_uid(PHY_ID_AR8035, 0xffffffef,
                                ar8035_phy_fixup);
+               phy_register_fixup_for_uid(PHY_ID_RTL8211E, REALTEK_PHY=
_ID_MASK,
+                               rtl8211e_phy_fixup);
        }
 }

(LAKML folks told me this should go somewhere in network driver, but no=
w it is there)

Without this there is no network at all, and I had ran this code for ye=
ar without any glitch. 3.19 kernel works fine.
(It causes "-dirty" in kernel version)
And different phy initialization cannot cause a non-random stream corru=
ption.

I've found commit that produces a bug by looking a changes between 3.19=
 (surely working)
 and 4.0.0-rc3 (surely non-working) in freescale network driver.

Hope this helps.

--
 =E1=CE=C4=D2=C5=CA
