From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v4 11/11] mtrr: bury MTRR - unexport mtrr_add() and mtrr_del()
Date: Mon, 24 Aug 2015 12:13:33 -0700
Message-ID: <1440443613-13696-12-git-send-email-mcgrof@do-not-panic.com>
References: <1440443613-13696-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bp@suse.de, bhelgaas@google.com, tomi.valkeinen@ti.com,
	airlied@linux.ie, linux-fbdev@vger.kernel.org, luto@amacapital.net,
	vinod.koul@intel.com, dan.j.williams@intel.com, toshi.kani@hp.com,
	benh@kernel.crashing.org, mst@redhat.com,
	akpm@linux-foundation.org, daniel.vetter@ffwll.ch,
	konrad.wilk@oracle.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	xen-devel@lists.xensource.com,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, Juergen Gross <jgross@suse.com>,
	Dave Airlie <airlied@redhat.com>,
	Antonino Daplas <adaplas@gmail.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	=?UTF-8?q?Ville=20Syrj=C3=A4l=C3=A4?= <syrjala@sci.fi
To: mingo@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440443613-13696-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Luis R. Rodriguez" <mcgrof@suse.com>

The crusade to replace mtrr_add() with architecture agnostic
arch_phys_wc_add() is complete, this will ensure write-combining
implementations (PAT on x86) is taken advantage instead of using
MTRR. With the crusade done now, hide direct MTRR access for
drivers.

Update x86 documentation on MTRR to reflect the completion of the
phasing out of direct access to MTRR, also add a note on platform
firmware code use of MTRRs based on the obituary discussion of
MTRRs on Linux [0].

[0] http://lkml.kernel.org/r/1438991330.3109.196.camel@hp.com

Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Suresh Siddha <sbsiddha@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Juergen Gross <jgross@suse.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Antonino Daplas <adaplas@gmail.com>
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: Ville Syrj=C3=A4l=C3=A4 <syrjala@sci.fi>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Davidlohr Bueso <dbueso@suse.de>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Andy Walls <awalls@md.metrocast.net>
Cc: x86@kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 Documentation/x86/mtrr.txt      | 20 ++++++++++++++++----
 arch/x86/kernel/cpu/mtrr/main.c |  2 --
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/Documentation/x86/mtrr.txt b/Documentation/x86/mtrr.txt
index 860bc3adc223..8a0bdb6e7370 100644
--- a/Documentation/x86/mtrr.txt
+++ b/Documentation/x86/mtrr.txt
@@ -6,10 +6,22 @@ Luis R. Rodriguez <mcgrof@do-not-panic.com> - April 9=
, 2015
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
 Phasing out MTRR use
=20
-MTRR use is replaced on modern x86 hardware with PAT. Over time the on=
ly type
-of effective MTRR that is expected to be supported will be for write-c=
ombining.
-As MTRR use is phased out device drivers should use arch_phys_wc_add()=
 to make
-MTRR effective on non-PAT systems while a no-op on PAT enabled systems=
=2E
+MTRR use is replaced on modern x86 hardware with PAT. Direct MTRR use =
by
+drivers on Linux is now completely phased out, device drivers should u=
se
+arch_phys_wc_add() in combination with ioremap_wc() to make MTRR effec=
tive on
+non-PAT systems while a no-op but equally effective on PAT enabled sys=
tems.
+
+Even if Linux does not use MTRR directly some x86 platform firmware ma=
y still
+set up MTRRs early before booting the OS, they do this as some platfor=
m
+firmware may still have implemented access to MTRRs which would be con=
trolled
+and handled by the platform firmware directly. An example of platform =
use of
+MTRR is through the use of SMI handlers, one case could be for fan con=
trol,
+the platform code would need uncachable access to some of its fan cont=
rol
+registers. Such platform access does not need any Operating System MTR=
R code in
+place other than mtrr_type_lookup() to ensure any OS specific mapping =
requests
+are aligned with platform MTRR setup. If MTRRs are only set up by the =
platform
+firmware code though and the OS does not make any specific MTRR mappin=
g
+requests mtrr_type_lookup() should always return MTRR_TYPE_INVALID.
=20
 For details refer to Documentation/x86/pat.txt.
=20
diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr=
/main.c
index e7ed0d8ebacb..f891b4750f04 100644
--- a/arch/x86/kernel/cpu/mtrr/main.c
+++ b/arch/x86/kernel/cpu/mtrr/main.c
@@ -448,7 +448,6 @@ int mtrr_add(unsigned long base, unsigned long size=
, unsigned int type,
 	return mtrr_add_page(base >> PAGE_SHIFT, size >> PAGE_SHIFT, type,
 			     increment);
 }
-EXPORT_SYMBOL(mtrr_add);
=20
 /**
  * mtrr_del_page - delete a memory type region
@@ -537,7 +536,6 @@ int mtrr_del(int reg, unsigned long base, unsigned =
long size)
 		return -EINVAL;
 	return mtrr_del_page(reg, base >> PAGE_SHIFT, size >> PAGE_SHIFT);
 }
-EXPORT_SYMBOL(mtrr_del);
=20
 /**
  * arch_phys_wc_add - add a WC MTRR and handle errors if PAT is unavai=
lable
--=20
2.4.3
