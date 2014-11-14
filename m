From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: linux-next: ath9k: build failure, ath_cmn_process_fft() redefinition
Date: Thu, 13 Nov 2014 16:07:47 -0800
Message-ID: <20141114000747.GA6865@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremiah Mahler <jmmahler@gmail.com>, linux-kernel@vger.kernel.org,
	ath9k-devel@qca.qualcomm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org
To: Oleksij Rempel <linux@rempel-privat.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In version 20141113 of the linux-next kernel, if it is compiled with
CONFIG_ATH9K_DEBUGFS unset, an error about ath_cmn_process_fft() being
redefined will be produced.

  make
  ...
    LD [M]  drivers/net/wireless/ath/ath9k/ath9k_hw.o
    CC [M]  drivers/net/wireless/ath/ath9k/common-spectral.o
    CC      lib/debug_locks.o
    CC      lib/random32.o
  drivers/net/wireless/ath/ath9k/common-spectral.c:40:5: error:
  redefinition of =E2=80=98ath_cmn_process_fft=E2=80=99
   int ath_cmn_process_fft(struct ath_spec_scan_priv *spec_priv, struct
  ieee80211_hdr *hdr,
       ^
  In file included from drivers/net/wireless/ath/ath9k/common.h:27:0,
                   from drivers/net/wireless/ath/ath9k/ath9k.h:27,
                   from
  drivers/net/wireless/ath/ath9k/common-spectral.c:18:
  drivers/net/wireless/ath/ath9k/common-spectral.h:146:19: note: previo=
us
  definition of =E2=80=98ath_cmn_process_fft=E2=80=99 was here
   static inline int ath_cmn_process_fft(struct ath_spec_scan_priv
  *spec_priv,
                     ^
  scripts/Makefile.build:257: recipe for target
  'drivers/net/wireless/ath/ath9k/common-spectral.o' failed
  make[5]: *** [drivers/net/wireless/ath/ath9k/common-spectral.o] Error=
 1
  scripts/Makefile.build:402: recipe for target
  'drivers/net/wireless/ath/ath9k' failed
  make[4]: *** [drivers/net/wireless/ath/ath9k] Error 2
  scripts/Makefile.build:402: recipe for target 'drivers/net/wireless/a=
th'
  failed
  make[3]: *** [drivers/net/wireless/ath] Error 2
  scripts/Makefile.build:402: recipe for target 'drivers/net/wireless'
  failed
  make[2]: *** [drivers/net/wireless] Error 2
  scripts/Makefile.build:402: recipe for target 'drivers/net' failed
  make[1]: *** [drivers/net] Error 2
  Makefile:953: recipe for target 'drivers' failed
  make: *** [drivers] Error 2
  make: *** Waiting for unfinished jobs....
    CC      lib/bust_spinlocks.o
  ...

Bisecting the kernel found that the following patch was the cause.

  commit 67dc74f15f147b9f88702de2952d2951e3e000ec
  Author: Oleksij Rempel <linux@rempel-privat.de>
  Date:   Thu Nov 6 08:53:30 2014 +0100
 =20
      ath9k: move spectral.* to common-spectral.*
     =20
      and rename exports from ath9k_spectral_* to ath9k_cmn_spectral_*
     =20
      Signed-off-by: Oleksij Rempel <linux@rempel-privat.de>
      Signed-off-by: John W. Linville <linville@tuxdriver.com>

This patch mostly consists of renaming functions and moving code but
there was a functional change to the Makefile.

common-spectral.h uses CONFIG_ATH9K_DEBUGFS to conditionally provide a
prototype of ath_cmn_process_fft() when set or to define it as a noop
when it is unset.  The Makefile was changed so that CONFIG_ATH9K_DEBUGF=
S
no longer applied to common-spectral and this will result in two
definitions of ath_cmn_process_fft().

  > --- a/drivers/net/wireless/ath/ath9k/Makefile
  > +++ b/drivers/net/wireless/ath/ath9k/Makefile
  > @@ -16,8 +16,7 @@ ath9k-$(CONFIG_ATH9K_DFS_CERTIFIED) +=3D dfs.o
  >  ath9k-$(CONFIG_ATH9K_TX99) +=3D tx99.o
  >  ath9k-$(CONFIG_ATH9K_WOW) +=3D wow.o
  >
  > -ath9k-$(CONFIG_ATH9K_DEBUGFS) +=3D debug.o \
  > -                                spectral.o
  > +ath9k-$(CONFIG_ATH9K_DEBUGFS) +=3D debug.o
  >
  >  ath9k-$(CONFIG_ATH9K_STATION_STATISTICS) +=3D debug_sta.o
  >
  > @@ -59,7 +58,8 @@ obj-$(CONFIG_ATH9K_COMMON) +=3D ath9k_common.o
  >  ath9k_common-y:=3D       common.o \
  >                         common-init.o \
  >                         common-beacon.o \
  > -                       common-debug.o
  > +                       common-debug.o \
  > +                       common-spectral.o

Reverting the patch solves one error, but then a new one is produced.

  make
  ...
    MODPOST 185 modules
    CC      arch/x86/boot/edd.o
    VOFFSET arch/x86/boot/voffset.h
  ERROR: "ath9k_cmn_spectral_scan_trigger"
  [drivers/net/wireless/ath/ath9k/ath9k.ko] undefined!
  scripts/Makefile.modpost:90: recipe for target '__modpost' failed
  make[1]: *** [__modpost] Error 1
  ...

This error is caused by the patch before it.

  commit f00a422cc81ef665f5098c0bc43cb0c616e55a9b
  Author: Oleksij Rempel <linux@rempel-privat.de>
  Date:   Thu Nov 6 08:53:29 2014 +0100
 =20
      ath9k: move ath9k_spectral_scan_ from main.c to spectral.c
     =20
      Now we should be ready to make this code common.
     =20
      Signed-off-by: Oleksij Rempel <linux@rempel-privat.de>
      Signed-off-by: John W. Linville <linville@tuxdriver.com>

Since the code was moved from main.c to spectral.c, it is now involved
with CONFIG_ATH9K_DEBUGFS, which causes it to break.

Reverting both the above patches resolves the build errors.

--=20
Jeremiah Mahler
jmmahler@gmail.com
http://github.com/jmahler
