From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH 0/8] Use correctly the Xen memory terminologies in Linux
Date: Tue, 28 Jul 2015 16:02:41 +0100
Message-ID: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ian.campbell@citrix.com>, <stefano.stabellini@eu.citrix.com>,
	<linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Jiri Slaby <jslaby@suse.com>, Juergen Gross <jgross@suse.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<linux-api@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-fbdev@vger.kernel.org>, <linux-input@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>, <linux-scsi@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	=?UTF-8?q?Roger=20Pau=20Monn=C3=A9?= <roger.pau@citrix.com>,
	R
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch series aims to use the memory terminologies described in
include/linux/mm.h [1] for Linux xen code.

Linux is using mistakenly MFN when GFN is meant, I suspect this is beca=
use the
first support of Xen was for PV. This has brought some misimplementatio=
n
of memory helpers on ARM and make the developper confused about the exp=
ected
behavior.

=46or instance, with pfn_to_mfn, we expect to get a MFN based on the na=
me.
Although, if we look at the implementation on x86, it's returning a GFN=
=2E
Most of the callers are also using it this way.

The first 2 patches of this series is ARM related in order to remove
PV specific helpers which should not be used and fixing the implementat=
ion of
pfn_to_mfn.

The rest of the series is here rename most of the usage in the common c=
ode
of MFN to GFN. I also took the opportunity to replace most of the call =
to
pfn_to_gfn in the common code by page_to_gfn avoid construction such
as pfn_to_gfn(page_to_pfn(...).

Note the one xen-blkfront will be dropped by 64K series [2], I can incl=
ude it
if necessary.

This series is based on Linux 4.2-rc4. A branch with all the patches
can be found here:
    git://xenbits.xen.org/people/julieng/linux-arm.git branch page-rena=
ming-v1

Sincerely yours,

[1] Xen tree: e758ed14f390342513405dd766e874934573e6cb
[2] https://lkml.org/lkml/2015/7/9/628

Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "James E.J. Bottomley" <JBottomley@odin.com>
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: Jiri Slaby <jslaby@suse.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-api@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-fbdev@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-scsi@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: "Roger Pau Monn=C3=A9" <roger.pau@citrix.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: x86@kernel.org

Julien Grall (8):
  arm/xen: Remove helpers which are PV specific
  xen: Make clear that swiotlb and biomerge are dealing with DMA addres=
s
  arm/xen: implement correctly pfn_to_mfn
  xen: Use the correctly the Xen memory terminologies
  xen/tmem: Use page_to_gfn rather than pfn_to_gfn
  video/xen-fbfront: Further s/MFN/GFN clean-up
  hvc/xen: Further s/MFN/GFN clean-up
  xen/privcmd: Further s/MFN/GFN/ clean-up

 arch/arm/include/asm/xen/page.h         | 44 +++++++++++++++----------=
-----
 arch/arm/xen/enlighten.c                | 18 ++++++-------
 arch/arm/xen/mm.c                       |  4 +--
 arch/x86/include/asm/xen/page.h         | 34 +++++++++++++----------
 arch/x86/xen/enlighten.c                |  4 +--
 arch/x86/xen/mmu.c                      | 48 ++++++++++++++++---------=
--------
 arch/x86/xen/p2m.c                      | 32 +++++++++++-----------
 arch/x86/xen/setup.c                    | 12 ++++-----
 arch/x86/xen/smp.c                      |  4 +--
 arch/x86/xen/suspend.c                  |  8 +++---
 drivers/block/xen-blkfront.c            |  6 ++---
 drivers/input/misc/xen-kbdfront.c       |  4 +--
 drivers/net/xen-netback/netback.c       |  4 +--
 drivers/net/xen-netfront.c              |  8 +++---
 drivers/scsi/xen-scsifront.c            |  8 +++---
 drivers/tty/hvc/hvc_xen.c               | 18 +++++--------
 drivers/video/fbdev/xen-fbfront.c       | 20 +++++++-------
 drivers/xen/balloon.c                   |  2 +-
 drivers/xen/biomerge.c                  |  6 ++---
 drivers/xen/events/events_base.c        |  2 +-
 drivers/xen/events/events_fifo.c        |  4 +--
 drivers/xen/gntalloc.c                  |  3 ++-
 drivers/xen/manage.c                    |  2 +-
 drivers/xen/privcmd.c                   | 44 +++++++++++++++----------=
-----
 drivers/xen/swiotlb-xen.c               | 16 +++++------
 drivers/xen/tmem.c                      | 21 +++++----------
 drivers/xen/xenbus/xenbus_client.c      |  2 +-
 drivers/xen/xenbus/xenbus_dev_backend.c |  2 +-
 drivers/xen/xenbus/xenbus_probe.c       |  8 +++---
 drivers/xen/xlate_mmu.c                 | 18 ++++++-------
 include/uapi/xen/privcmd.h              |  4 +++
 include/xen/page.h                      |  4 +--
 include/xen/xen-ops.h                   | 10 +++----
 33 files changed, 210 insertions(+), 214 deletions(-)

--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
