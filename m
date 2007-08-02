From: "Joachim Deguara" <joachim.deguara@amd.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Thu, 2 Aug 2007 11:15:05 +0200
Message-ID: <200708021115.10812.joachim.deguara@amd.com>
References: <20070731174522.b141178a.akpm@linux-foundation.org>
 <1186002023.18322.7.camel@dell>
 <200708021005.45773.joachim.deguara@amd.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"lkml List" <linux-kernel@vger.kernel.org>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200708021005.45773.joachim.deguara@amd.com>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 August 2007 10:05:44 Joachim Deguara wrote:
> On Wednesday 01 August 2007 23:00:23 Michael Chan wrote:
> > On Wed, 2007-08-01 at 10:47 -0700, Michael Chan wrote:
> > The problem is that memory enable and bus master were not set in PCI
> > register 4 after resume.  This also explains the register access
> > failures.

Found it! I did the instrumentation and found pci_restore was not being 
called. Why, because this code failed:

	printk(KERN_INFO "tg3_resume: entered\n");
	if (!netif_running(dev))
		return 0;
	printk(KERN_INFO "tg3_resume: before restore\n");

Bad dmesg:
[    0.581236] PM: Writing back config space on device 0000:07:00.0 at offset 
4
(was 4, writing d0200004)
[    0.581259] tg3_resume: entered
[    0.581276] PM: Writing back config space on device 0000:08:09.0 at offset 
f
(was c001ff, writing 1c0010b)

why is this, oh damn it is because I was calling openSUSE's "powersave -u" and 
not s2ram directly.  powersave is disabling the network and the tg3 will not 
restore the pci device like this! right?

here is a good dmesg with by calling s2ram:
[    0.577085] PM: Writing back config space on device 0000:07:00.0 at offset 
4
(was 4, writing d0200004)
[    0.577108] tg3_resume: entered
[    0.577109] tg3_resume: before restore
[    0.577140] PM: Writing back config space on device 0000:08:04.0 at offset 
c
(was 0, writing ffff0000)
[    0.577171] PM: Writing back config space on device 0000:08:04.0 at offset 
1
(was 2b00000, writing 2b00006)
[    0.577304] tg3_resume: after set_power_state
[    0.579119] tg3: eth0: Link is down.
[    0.786266] ata2: SATA link down (SStatus 0 SControl 310)
[    0.848176] tg3_resume: after tg3_restart_hw
[    0.848265] PM: Writing back config space on device 0000:08:09.0 at offset 
f
(was c001ff, writing 1c0010b)

Seams like even if powersave shuts down the network that the device should 
still work after a suspend to ram, so who is at fault here?

-Joachim


