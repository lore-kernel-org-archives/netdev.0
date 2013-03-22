From: Frank Rowand <frank.rowand@am.sony.com>
Subject: Re: [BUG] bisected: PandaBoard smsc95xx ethernet driver error from
 USB timeout
Date: Thu, 21 Mar 2013 19:45:23 -0700
Message-ID: <514BC5C3.9080808@am.sony.com>
References: <Pine.LNX.4.44L0.1303211037070.1899-100000@iolanthe.rowland.org>
Reply-To: <frank.rowand@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"balbi@ti.com" <balbi@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1303211037070.1899-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/13 07:41, Alan Stern wrote:
> On Wed, 20 Mar 2013, Frank Rowand wrote:
> 
>> Hi All,
>>
>> Not quite sure quite where the problem is (USB, OMAP, smsc95xx driver, other???),
>> so casting the nets wide...
>>
>> The PandaBoard frequently fails to boot with an eth0 error when mounting
>> the root file system via NFS (ethernet driver fails due to a USB timeout;
>> no ethernet means NFS won't work).  A typical set of error messages is:
>>
>> [    3.264373] smsc95xx 1-1.1:1.0: usb_probe_interface
>> [    3.269500] smsc95xx 1-1.1:1.0: usb_probe_interface - got id
>> [    3.275543] smsc95xx v1.0.4
>> [    8.078674] smsc95xx 1-1.1:1.0: eth0: register 'smsc95xx' at usb-ehci-omap.0-1.1, smsc95xx USB 2.0 Ethernet, 82:b9:1d:fa:67:0d
>> [    8.091003] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0002
>> [   13.509918] usb 1-1.1: swapper/0 timed out on ep0out len=0/4
>> [   13.515869] smsc95xx 1-1.1:1.0: eth0: Failed to write register index 0x00000108
>> [   13.523559] smsc95xx 1-1.1:1.0: eth0: Failed to write ADDRL: -110
>> [   13.529998] IP-Config: Failed to open eth0
>>
>> I have bisected this to:
>>
>>   commit 18aafe64d75d0e27dae206cacf4171e4e485d285
>>   Author: Alan Stern <stern@rowland.harvard.edu>
>>   Date:   Wed Jul 11 11:23:04 2012 -0400
>>
>>      USB: EHCI: use hrtimer for the I/O watchdog
> 
> I don't understand how that commit could cause a timeout unless there 
> are at least two other bugs present in your system.
> 
>> Note that to compile this version of the kernel, an additional fix must
>> also be applied:
>>
>>   commit ba5952e0711b14d8d4fe172671f8aa6091ace3ee
>>   Author: Ming Lei <ming.lei@canonical.com>
>>   Date:   Fri Jul 13 17:25:24 2012 +0800
>>
>>      USB: ehci-omap: fix compile failure(v1)
>>
>> The symptom can be worked around by retrying the USB access if a timeout
>> occurs.  This is clearly _not_ the fix, just a hack that I used to
>> investigate the problem:
>>
>>   http://article.gmane.org/gmane.linux.rt.user/9773
>>
>> My kernel configuration is:
>>
>>   arch/arm/configs/omap2plus_defconfig
>>
>>   plus to get the ethernet driver I add:
>>
>>     CONFIG_USB_EHCI_HCD
>>     CONFIG_USB_NET_SMSC95XX
>>
>> I found the problem on 3.6.11, but have not replicated it on 3.9-rcX
>> yet because my config fails to build on 3.9-rc1 and 3.9-rc2.  I'll try
>> to work on that issue tomorrow.
> 
> Let me know how it works out.

My PandaBoard builds fail on 3.9-rcX due to ARM multiplatform issues.
Either there is something I need to change about the way I build it,
or it is broken (that is a side issue).  My simple expedient was to
hack around multiplatform, and just make it build (patch below if
anyone else wants a _temporary_ hack).

The problem appears to not be present in 3.9-rc3.  In older kernel versions,
the worst case to see the problem was 18 boots.  For 3.9-rc3 I booted 42
times without seeing the problem.

The problem occurs at least up through 3.8.  I'll try to reverse bisect
between 3.8 and 3.9-rc3 to see when the problem disappeared (I'm running
short of time, so no promises for a near term result).

-Frank


This patch is a _temporary_ hack, not fit for man or beast.  Avert
your eyes, do not apply to any respectable repository!

---
 arch/arm/Kconfig  |    2 	1 +	1 -	0 !
 arch/arm/Makefile |    2 	2 +	0 -	0 !
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: b/arch/arm/Kconfig
===================================================================
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1013,7 +1013,7 @@ config ARCH_MULTI_V7
 	bool "ARMv7 based platforms (Cortex-A, PJ4, Krait)"
 	default y
 	select ARCH_MULTI_V6_V7
-	select ARCH_VEXPRESS
+	select ARCH_VEXPRESS if !ARCH_OMAP2PLUS
 	select CPU_V7
 
 config ARCH_MULTI_V6_V7
Index: b/arch/arm/Makefile
===================================================================
--- a/arch/arm/Makefile
+++ b/arch/arm/Makefile
@@ -227,8 +227,10 @@ else
 MACHINE  :=
 endif
 ifeq ($(CONFIG_ARCH_MULTIPLATFORM),y)
+ifneq ($(CONFIG_ARCH_OMAP2PLUS),y)
 MACHINE  :=
 endif
+endif
 
 machdirs := $(patsubst %,arch/arm/mach-%/,$(machine-y))
 platdirs := $(patsubst %,arch/arm/plat-%/,$(plat-y))
