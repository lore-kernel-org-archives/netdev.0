From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 02/10] bnx2x: Removing indirect register
 access
Date: Fri, 27 Jan 2012 09:19:56 +0200
Message-ID: <1327648796.9270.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
 <1327593714-18358-3-git-send-email-ariele@broadcom.com>
 <1327614608.2482.12.camel@bwh-desktop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-pci <linux-pci@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1327614608.2482.12.camel@bwh-desktop>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-26 at 21:50 +0000, Ben Hutchings wrote:
> On Thu, 2012-01-26 at 18:01 +0200, Ariel Elior wrote:
> > In virtualized environments indirect access to the device may not be supported
> > (depending on the Hypervisor type). Indirect device access was used since in
> > some harware contexts (i.e. certain chipset and BIOS) every access the driver
> > makes across the pci is followed by a BIOS initiated Zero Length Read to the
> > same address.
> [...]
> 
> This is intriguing.  Isn't that a general problem that can affect many
> devices?  Can you be more specific about which systems have this
> behaviour?

This is with regards to some AMD chipsets that translate the HT
protocol, which is usually used between the AMD CPUs, to the PCI address
space. The BIOS marks some areas as requiring acknowledgment - and that
is implemented by issuing a Zero Length Read (ZLR) over the PCI after
every PIO write to that address space. According to the PCI spec, the
masked addresses should have no effect and in ZLR, everything is masked
- so this read should be returned right away with no impact which makes
it safe to be used as acknowledgment that the write has reached the
device (since the read that followed just returned). Unfortunately, on
the 57710 this ZLR actually reached all the way down to the specific HW
block without the mask. This is causing a problem when a "wide bus" (the
bus size is greater than 32bits) was written to - the HW assumed that
the SW will guarantee that the write will be consecutive and without any
other access to that bus in the middle of writing or reading a line. So
for the 57710, the ZLR is causing real problems and can be worked around
by indirect access (using the PCI config space) or DMAE (where the
device reads the data). For other devices, the worst case scenario is
performance impact due to this extra read on the PCI bus that takes some
PCI BW and slow down consecutive writes.

Regards,
Eilon
