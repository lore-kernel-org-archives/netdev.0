From: Paul Collins <paul@briny.ondioline.org>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Thu, 29 Jun 2006 18:24:22 +1000
Message-ID: <871wt8xtc9.fsf@briny.internal.ondioline.org>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org>
	<200606261443.47341.mb@bu3sch.de> <200606261727.24266.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:2564 "EHLO
	jenny.ondioline.org") by vger.kernel.org with ESMTP
	id S1751758AbWF2IaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 04:30:14 -0400
To: Michael Buesch <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb@bu3sch.de> writes:

> On Monday 26 June 2006 14:43, Michael Buesch wrote:
>> Try to get more logs.
>> I suggest to do a netconsole for logging.
>
> Also note that current softmac trees have a patch missing.
> It seems it got lost somewhere after my merge request.
> I already contacted John in private for this, but no reply, yet.
> The patch is attached. Maybe it fixes your issue.

On a preempt kernel I can trigger the hang easily, but alas nothing
further is printed on the console.

The "suspend MAC" patch does not help.  I also added the mac_suspended
patch, which does fix the assertion failures, but it still hangs after
some up/down-ing of the interface and an attempt to get an IP address
via DHCP as I normally do.

I still get the hang if I revert the preemptible periodic work patch
(91769e7dd9cef7988dc4280f74ed168351beb5b8) but if I revert the locking
pre-work too (78ff56a06edc3407996173daf63e48f6b90c7062) then it's
robust again.  I do get a TX timeout after I bounce the interface a
few times and then do DHCP, but it reinitialises the card and succeeds
in getting an IP address.


Below is what happens running Linus's current tree with the
mac-suspend and refcount patches applied.

(module loads)
  Jun 29 17:32:30 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
  Jun 29 17:32:30 briny kernel: bcm43xx: Number of cores: 5
  Jun 29 17:32:30 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
  Jun 29 17:32:30 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
  Jun 29 17:32:30 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
  Jun 29 17:32:30 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
  Jun 29 17:32:30 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
  Jun 29 17:32:30 briny kernel: bcm43xx: PHY connected
  Jun 29 17:32:30 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
  Jun 29 17:32:31 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
  Jun 29 17:32:31 briny kernel: bcm43xx: Radio turned off
  Jun 29 17:32:31 briny kernel: bcm43xx: Radio turned off

$ ip set link eth1 up

  Jun 29 17:32:48 briny kernel: bcm43xx: PHY connected
  Jun 29 17:32:49 briny kernel: bcm43xx: Radio turned on
  Jun 29 17:32:49 briny kernel: bcm43xx: Chip initialized
  Jun 29 17:32:49 briny kernel: bcm43xx: DMA initialized
  Jun 29 17:32:49 briny kernel: bcm43xx: 80211 cores initialized
  Jun 29 17:32:49 briny kernel: bcm43xx: Keys cleared
  Jun 29 17:32:49 briny kernel: SoftMAC: Open Authentication completed with XX:XX:XX:XX:XX:XX

$ ip set link eth1 down

  Jun 29 17:32:55 briny kernel: bcm43xx: Radio turned off
  Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0200 (RX) max used slots: 1/64
  Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0260 (TX) max used slots: 0/512
  Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0240 (TX) max used slots: 0/512
  Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0220 (TX) max used slots: 1/512
  Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0200 (TX) max used slots: 0/512
  Jun 29 17:32:56 briny kernel: bcm43xx: PHY connected
  Jun 29 17:32:56 briny kernel: bcm43xx: Radio turned on
  Jun 29 17:32:56 briny kernel: bcm43xx: Chip initialized
  Jun 29 17:32:56 briny kernel: bcm43xx: DMA initialized
  Jun 29 17:32:56 briny kernel: bcm43xx: 80211 cores initialized
  Jun 29 17:32:56 briny kernel: bcm43xx: Keys cleared

(hmm, it didn't associate this time)
$ iwconfig eth1 essid wlan-ap enc off

  Jun 29 17:33:14 briny kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
  Jun 29 17:33:14 briny kernel: SoftMAC: Open Authentication completed with XX:XX:XX:XX:XX:XX

$ ip set link eth1 down

  Jun 29 17:33:22 briny kernel: bcm43xx: Radio turned off
  Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0200 (RX) max used slots: 1/64
  Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0260 (TX) max used slots: 0/512
  Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0240 (TX) max used slots: 0/512
  Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0220 (TX) max used slots: 1/512
  Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0200 (TX) max used slots: 0/512

$ ip set link eth1 up

  Jun 29 17:33:27 briny kernel: bcm43xx: PHY connected
  Jun 29 17:33:27 briny kernel: bcm43xx: Radio turned on
  Jun 29 17:33:27 briny kernel: bcm43xx: Chip initialized
  Jun 29 17:33:27 briny kernel: bcm43xx: DMA initialized
  Jun 29 17:33:27 briny kernel: bcm43xx: 80211 cores initialized
  Jun 29 17:33:27 briny kernel: bcm43xx: Keys cleared

$ iwconfig eth1 essid wlan-ap enc off

  Jun 29 17:33:31 briny kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
  Jun 29 17:33:31 briny kernel: SoftMAC: Open Authentication completed with XX:XX:XX:XX:XX:XX

$ dhclient eth1

  Jun 29 17:33:41 briny kernel: NETDEV WATCHDOG: eth1: transmit timed out
  Jun 29 17:33:41 briny kernel: bcm43xx: Controller RESET (TX timeout) ...
  Jun 29 17:33:41 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
  Jun 29 17:33:41 briny kernel: bcm43xx: Number of cores: 5
  Jun 29 17:33:41 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
  Jun 29 17:33:41 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
  Jun 29 17:33:41 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
  Jun 29 17:33:41 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
  Jun 29 17:33:41 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
  Jun 29 17:33:41 briny kernel: bcm43xx: PHY connected
  Jun 29 17:33:41 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
  Jun 29 17:33:41 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
  Jun 29 17:33:41 briny kernel: bcm43xx: Radio turned off
  Jun 29 17:33:41 briny kernel: bcm43xx: Radio turned off
  Jun 29 17:33:41 briny kernel: bcm43xx: Controller restarted

And here it hangs.

-- 
Paul Collins
Melbourne, Australia

Dag vijandelijk luchtschip de huismeester is dood
