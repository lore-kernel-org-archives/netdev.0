From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] Tulip endianess fix
Date: Sun, 21 Mar 2004 00:20:25 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403202337010.20260@portland.hansa.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_t0Y6N16Ys+FUxlGu7UqDPg)"
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-id: <Pine.LNX.4.58.0403210020090.20260@portland.hansa.lan>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--Boundary_(ID_t0Y6N16Ys+FUxlGu7UqDPg)
Content-id: <Pine.LNX.4.58.0403210020091.20260@portland.hansa.lan>
Content-type: TEXT/PLAIN; CHARSET=US-ASCII
Content-transfer-encoding: 7BIT

Hello!

My tulip ethernet card doesn't work on Blue&White G3 PowerMac with Linux
2.6.5-rc2.  The card is shown by lspci as

01:03.0 Ethernet controller: Linksys Network Everywhere Fast Ethernet
10/100 model NC100 (rev 11)

The kernel detects it as "ADMtek Comet rev 17".

The MAC address reported by the kernel looked obviously wrong.  Also, I
could only ping the system successfully if the interface was in promiscuous
mode (running Ethereal).

Those two symptoms indicated two different problems - one for reading the
MAC address from the card on module load (tulip_init_one), and the other
for writing the address to the card when the interface was brought up
(tulip_up).  I have fixed both, and here's the explanation:

tulip_init_one:

When reading the first 4 bytes of the address, inl() returns the same data
to the CPU on all platforms, interpreting the data from the lowest port
address as the least significant byte.  In other words, I/O is little
endian on all platforms; it's the memory that differs across platforms.
We want to write the data to memory preserving little-endianness of the
PCI bus.  To force little endian write to the memory, the data should be
converted to the little endian format.

When reading the remaining 2 bytes, the CPU gets them in 2 least
significant bytes.  To write those 2 bytes to the memory in a 16-bit
operation, they should be byte-swapped for the 16-bit operation.

tulip_up:

The first 4 bytes are processed correctly, but the code is confusing.
Reading from memory needs conversion to CPU format, while writing to I/O
ports doesn't.  So I replaced cpu_to_le32() to le32_to_cpu().

The second 2 bytes are read in a 16-bit memory operation, so they should
be passed to le16_to_cpu() rather than cpu_to_le32() to make them CPU
independent and suitable for outl().


All those conversions do nothing on little-endian machines, so they should
not be affected.

The patch has been tested.  The driver is working fine.  ping is OK, ssh
is OK, X11 over ssh is OK.  Even netconsole is working fine.

-- 
Regards,
Pavel Roskin

--Boundary_(ID_t0Y6N16Ys+FUxlGu7UqDPg)
Content-id: <Pine.LNX.4.58.0403210019450.20260@portland.hansa.lan>
Content-type: TEXT/PLAIN; CHARSET=US-ASCII; NAME=tulip_mac.diff
Content-transfer-encoding: 7BIT
Content-disposition: ATTACHMENT; FILENAME=tulip_mac.diff
Content-description: 

--- linux.orig/drivers/net/tulip/tulip_core.c
+++ linux/drivers/net/tulip/tulip_core.c
@@ -308,8 +308,8 @@ static void tulip_up(struct net_device *
 	tp->dirty_rx = tp->dirty_tx = 0;
 
 	if (tp->flags & MC_HASH_ONLY) {
-		u32 addr_low = cpu_to_le32(get_unaligned((u32 *)dev->dev_addr));
-		u32 addr_high = cpu_to_le32(get_unaligned((u16 *)(dev->dev_addr+4)));
+		u32 addr_low = le32_to_cpu(get_unaligned((u32 *)dev->dev_addr));
+		u32 addr_high = le16_to_cpu(get_unaligned((u16 *)(dev->dev_addr+4)));
 		if (tp->chip_id == AX88140) {
 			outl(0, ioaddr + CSR13);
 			outl(addr_low,  ioaddr + CSR14);
@@ -1434,8 +1434,8 @@ static int __devinit tulip_init_one (str
 		}
 	} else if (chip_idx == COMET) {
 		/* No need to read the EEPROM. */
-		put_unaligned(inl(ioaddr + 0xA4), (u32 *)dev->dev_addr);
-		put_unaligned(inl(ioaddr + 0xA8), (u16 *)(dev->dev_addr + 4));
+		put_unaligned(cpu_to_le32(inl(ioaddr + 0xA4)), (u32 *)dev->dev_addr);
+		put_unaligned(cpu_to_le16(inl(ioaddr + 0xA8)), (u16 *)(dev->dev_addr + 4));
 		for (i = 0; i < 6; i ++)
 			sum += dev->dev_addr[i];
 	} else {

--Boundary_(ID_t0Y6N16Ys+FUxlGu7UqDPg)--
