From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: some merging notes
Date: Wed, 12 Dec 2012 09:15:52 +1100
Message-ID: <20121212091552.02c72c8926f9f9147b080d68@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5584850176030807581=="
Cc: "N, Mugunthan V" <mugunthanvnm@ti.com>, Bill Pemberton <wfp5p@virginia.edu>,
 Arnd Bergmann <arnd@arndb.de>, Greg KH <greg@kroah.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, Rusty Russell <rusty@rustcorp.com.au>,
 LKML <linux-kernel@vger.kernel.org>, Steven Rostedt <srostedt@redhat.com>,
 linux-next@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
 netdev@vger.kernel.org, Olof Johansson <olof@lixom.net>,
 Nathan Fontenot <nfont@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Linus <torvalds@linux-foundation.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============5584850176030807581==
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__12_Dec_2012_09_15_52_+1100_Ssu8zmAdj1_utdXl"

--Signature=_Wed__12_Dec_2012_09_15_52_+1100_Ssu8zmAdj1_utdXl
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Just some notes about the current state of some of the merges in
linux-next.

The powerpc tree
(git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc.git#next)
contains a commit that breaks the building of
lib/pSeries-reconfig-notifier-error-inject.c.  I applied a patch to
linux-next to disable CONFIG_PSERIES_RECONFIG_NOTIFIER_ERROR_INJECT.

The virtio tree
(git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux.git#virtio-next)
has a conflict with the net-next tree
(git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git#master)
that requires the following extra fix up patch:

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 33d6f6f..8afe32d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -147,7 +147,7 @@ struct padded_vnet_hdr {
  */
 static int vq2txq(struct virtqueue *vq)
 {
-	return (virtqueue_get_queue_index(vq) - 1) / 2;
+	return (vq->index - 1) / 2;
 }
=20
 static int txq2vq(int txq)
@@ -157,7 +157,7 @@ static int txq2vq(int txq)
=20
 static int vq2rxq(struct virtqueue *vq)
 {
-	return virtqueue_get_queue_index(vq) / 2;
+	return vq->index / 2;
 }
=20
 static int rxq2vq(int rxq)

The tty tree
(git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty.git#tty-next)
contains a new driver (SystemBase Multi-2/PCI) that fails to build for
(at least) the powerpc architecture.  I have applied a patch that
disables the driver (I made CONFIG_SB105X in
drivers/staging/sb105x/Kconfig depend on BROKEN).

The arm-soc tree
(git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc.git#for-next)
(which you will get in pieces) has a merge conflict against the omap_dss2
tree (git://gitorious.org/linux-omap-dss2/linux.git#for-next) that
requires the followin fix up patch:

diff --git a/arch/arm/mach-omap2/common.c b/arch/arm/mach-omap2/common.c
index 5c2fd48..2dabb9e 100644
--- a/arch/arm/mach-omap2/common.c
+++ b/arch/arm/mach-omap2/common.c
@@ -16,8 +16,6 @@
 #include <linux/init.h>
 #include <linux/platform_data/dsp-omap.h>
=20
-#include <plat/vram.h>
-
 #include "common.h"
 #include "omap-secure.h"
=20
@@ -32,7 +30,6 @@ int __weak omap_secure_ram_reserve_memblock(void)
=20
 void __init omap_reserve(void)
 {
-	omap_vram_reserve_sdram_memblock();
 	omap_dsp_reserve_sdram_memblock();
 	omap_secure_ram_reserve_memblock();
 	omap_barrier_reserve_memblock();

Part of the arm-soc tree also requires the following fixup patch due to a
conflict with the powerpc tree (patch from N, Mugunthan V
<mugunthanvnm@ti.com>):

diff --git a/arch/arm/mach-omap2/timer.c b/arch/arm/mach-omap2/timer.c
index 099e406..5fd5e23 100644
--- a/arch/arm/mach-omap2/timer.c
+++ b/arch/arm/mach-omap2/timer.c
@@ -192,7 +192,7 @@ static struct device_node * __init omap_get_timer_dt
(struct of_device_id *match, continue;
 		}
=20
-		prom_add_property(np, &device_disabled);
+		of_add_property(np, &device_disabled);
 		return np;
 	}
=20
There are also lots of conflicts due to the __dev* annotation removals -
a lot of which are in the driver-core tree
(git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git#drive=
r-core-next).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__12_Dec_2012_09_15_52_+1100_Ssu8zmAdj1_utdXl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQx7CYAAoJEECxmPOUX5FE//oQAJx10W6rsgKts32Ot1pEK2tR
AFyz0qsaqF2LraWSQCaj/ogBab3FPwA0snlghtfM52emu7brusLqw1WoULHwAlt2
Q/R6ZmVAxirzS6ZsX6KbVC1K3T3bzV3oKRnzM4lbwvsRufDuDbsdCZlAOcMyTXKn
MHCEL0LvmenR6ieZcjTYv9E06B4SFaFaHyvqVU9wsAwe1QE6XpBGMNNuGBLr8l9L
HT9dJuWqKdzwxnZg8mZ7R6csN6F35/GchTDmgkEen8j6ouDM+3NLcAERH6ks0kaw
duGLCLPcb9kkYMkSfnmej/NiL6ccbMdjq32zvqUTJwwGGJpoRtZ1HkUM0Y35N75L
mHlLLe3A/qXhd48ymdH/AT9pTlJb3q/nBMh5eWbVAyg76Ki+rdvC/9tNPlbSjpOI
6XbA6onHs2eJ+F6aOS/fqWFpHCLINA0VxAmLr3aaaCU29XUwmfLmMghtLKKXoJcj
9/8OtP9KQ92Ju/LHoeQ6Wzd9gY5+EKUpmgCeLVwO8iLV4Y37E/Wl1uHFjKyjQvZt
xlHYfsQIEsB7U3PTuE6hdqzSuHDwBCt9UG9ZKrjSatt6QDjdTkKVHKu9TwTGe8FT
mz5pRD2zOL85r9elvRBa0m2ImqsZeCAZTsQ5lh7yPDShk7xG82tv35prN9HarR28
mX1/SDhfqlO+CFQZ4TMt
=+DER
-----END PGP SIGNATURE-----

--Signature=_Wed__12_Dec_2012_09_15_52_+1100_Ssu8zmAdj1_utdXl--

--===============5584850176030807581==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============5584850176030807581==--
