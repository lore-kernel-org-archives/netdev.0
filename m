From: Marc Bevand <m.bevand@gmail.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Fri, 25 Aug 2006 22:33:09 +0000 (UTC)
Message-ID: <loom.20060825T235849-675@post.gmane.org>
References: <20060805202603.GA9740@thunk.org> <1551EAE59135BE47B544934E30FC4FC093FA21@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42151 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751544AbWHYWkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 18:40:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GGkLK-00089Z-0r
	for netdev@vger.kernel.org; Sat, 26 Aug 2006 00:40:04 +0200
Received: from 216.239.132.34 ([216.239.132.34])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 00:40:02 +0200
Received: from m.bevand by 216.239.132.34 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 00:40:02 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan <mchan <at> broadcom.com> writes:
>
> Turning off ASF is just a matter of changing some bits in NVRAM
> and recalculating the checksum.  If you need the tool to do this,
> I'll have someone send it to you.
>
> Note that on some of the blade servers, I believe ASF is vital
> and should not be disabled.

Still, it would be great if ASF could be disabled, because I have
noticed that when ASF is enabled, the tg3 driver automatically disables
TSO (TCP Segmentation Offloading). Here is a dmesg output from a server
where I am seeing that behavior:

  eth0: Tigon3 [partno(BCM95704A6) rev 2100 PHY(5704)] (PCIX:133MHz:64-bit) \
    10/100/1000BaseT Ethernet 00:30:48:59:c4:94
  eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0]
  [...]
  eth1: Tigon3 [partno(BCM95704A6) rev 2100 PHY(5704)] (PCIX:133MHz:64-bit) \
    10/100/1000BaseT Ethernet 00:30:48:59:c4:95
  eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]

Both interfaces are fundamentally TSO-capable, but since ASF is enabled
on eth0, tg3 disables TSO on this interface. Of course at this point it
is not even possible to use ethtool to re-enable it because the driver
considers eth0 as not TSO-capable at all.

As far as I know, the tg3 driver has been doing that since one of your
patches shipped with 2.6.11-rc2-bk3, Michael, see [1]. Here is the relevant
code snippet (line numbers are for 2.6.16):

  10835   if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
  10836           tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
  10837   }
  10838   else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
  10839       GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
  10840       tp->pci_chip_rev_id == CHIPREV_ID_5705_A0 ||
  10841       (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0) {
  10842           tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
  10843   } else {
  10844           tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
  10845   }

The culprit is line 10841. Why is that done ?

[1] ftp://ftp.us.kernel.org:/pub/linux/kernel/v2.6/snapshots/old/
    patch-2.6.11-rc2-bk3.log, patch-2.6.11-rc2-bk3.bz2

--
Marc Bevand


