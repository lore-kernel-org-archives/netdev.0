From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH] fix BUG in tg3_tx
Date: Tue, 25 May 2004 13:04:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>, "Greg Banks" <gnb@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Greg, did you see Micahel Chan's response?  A Broadcom 
> engineer is telling us "the hardware does not ACK partial TX packets."
> 
That's right. The hw is designed to always complete tx packets on packet
boundaries and not BD boundaries. The send data completion state machine
will create 1 single dma descriptor and 1 host coalescing descriptor for
the entire packet. All of our drivers do not handle individual BD
completions and I'm not aware of any problems caused by this. Actually
we did see some partial packet completions during the early
implementions of TSO/LSO. But those were firmware issues and have been
fixed long time ago. tg3 is not using those early TSO firmware.

> I don't argue that you aren't seeing something strange, but 
> perhaps that is due to corruption occuring elsewhere, or 
> perhaps something peculiar about your system hardware 
> (perhaps the PCI controller mis-orders PCI transactions or 
> something silly like that)?
Good point. A few years ago we saw cases where there were tx completions
on BDs that had not been sent. It turned out that on that machine, the
chipset was re-ordering the posted mmio writes to the send mailbox
register from 2 CPUs. For example, CPU 1 wrote index 1 and CPU wrote
index 2 a little later. On the PCI bus, we saw memory write of 2
followed by 1. When the chip saw 2, it would send both packets. When it
later saw 1, it thought that there were 512 new tx BDs and went ahead to
send them. The only effective workaround for this chipset problem was a
read of the send mailbox after the write to flush it.

Michael
