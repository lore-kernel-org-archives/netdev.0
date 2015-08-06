From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Thu, 6 Aug 2015 17:10:17 +0100
Message-ID: <55C386E9.6060806@citrix.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	<55C0F291.7060806@citrix.com>
	<CAHmME9r6yYyiRXD7hyyvZnk9CvNAxgG5MSb=F=smSV6+j_U_FQ@mail.gmail.com>
	<55C330C7.6050204@citrix.com>
 <CAHmME9r1Ugk65OWgATh-aqW9s9QDpC8zckgP180vTAFj32wP9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xen.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Ian Campbell <ian.campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9r1Ugk65OWgATh-aqW9s9QDpC8zckgP180vTAFj32wP9w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/08/15 16:58, Jason A. Donenfeld wrote:
> On Thu, Aug 6, 2015 at 12:02 PM, David Vrabel <david.vrabel@citrix.com> wrote:
>> Linux PV guests must use the "Xen PV" APIC driver.  You need to
>> investigate why your PV guest is not using this (although I'm surprised
>> it works at all with the wrong one).
> 
> Actually it appears this PV Guest is using the "flat" APIC driver
> instead of the Xen APIC driver.
> 
> But upon further investigation into why:
> 
> arch/x86/xen/Makefile:
>     obj-$(CONFIG_XEN_DOM0)          += apic.o vga.o
> 
> It would appear that only dom0 gets to use the Xen APIC driver.
> 
> What gives?

Looks like the Makefile is wrong.

Try this:

8<------------------
x86/xen: build "Xen PV" APIC driver for domU as well

A PV domU also needs the Xen PV APIC driver but it was only built for
CONFIG_XEN_DOM0=y.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: <stable@vger.kernel.org>
---
 arch/x86/xen/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/xen/Makefile b/arch/x86/xen/Makefile
index 7322755..4b6e29a 100644
--- a/arch/x86/xen/Makefile
+++ b/arch/x86/xen/Makefile
@@ -13,13 +13,13 @@ CFLAGS_mmu.o			:= $(nostackp)
 obj-y		:= enlighten.o setup.o multicalls.o mmu.o irq.o \
 			time.o xen-asm.o xen-asm_$(BITS).o \
 			grant-table.o suspend.o platform-pci-unplug.o \
-			p2m.o
+			p2m.o apic.o

 obj-$(CONFIG_EVENT_TRACING) += trace.o

 obj-$(CONFIG_SMP)		+= smp.o
 obj-$(CONFIG_PARAVIRT_SPINLOCKS)+= spinlock.o
 obj-$(CONFIG_XEN_DEBUG_FS)	+= debugfs.o
-obj-$(CONFIG_XEN_DOM0)		+= apic.o vga.o
+obj-$(CONFIG_XEN_DOM0)		+= vga.o
 obj-$(CONFIG_SWIOTLB_XEN)	+= pci-swiotlb-xen.o
 obj-$(CONFIG_XEN_EFI)		+= efi.o
-- 
2.1.4
