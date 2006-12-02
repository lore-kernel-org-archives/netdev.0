From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] amd8111e use standard CRC lib
Date: Fri, 1 Dec 2006 16:10:50 -0800
Message-ID: <20061201161050.4fdd15cf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:15832 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161807AbWLBAK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:10:59 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed this driver (and several others) reinvent their own copy of the
existing CRC library. Don't have the hardware, but tested by extracting
code and comparing result.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/amd8111e.c |   27 +--------------------------
 drivers/net/amd8111e.h |    4 ----
 2 files changed, 1 insertion(+), 30 deletions(-)

--- old/drivers/net/amd8111e.c
+++ new/drivers/net/amd8111e.c
@@ -1490,32 +1490,7 @@ static void amd8111e_read_regs(struct am
 	buf[12] = readl(mmio + STAT0);
 }
 
-/*
-amd8111e crc generator implementation is different from the kernel
-ether_crc() function.
-*/
-static int amd8111e_ether_crc(int len, char* mac_addr)
-{
-	int i,byte;
-	unsigned char octet;
-	u32 crc= INITCRC;
-
-	for(byte=0; byte < len; byte++){
-		octet = mac_addr[byte];
-		for( i=0;i < 8; i++){
-			/*If the next bit form the input stream is 1,subtract				 the divisor (CRC32) from the dividend(crc).*/
-			if( (octet & 0x1) ^ (crc & 0x1) ){
-				crc >>= 1;
-				crc ^= CRC32;
-			}
-			else
-				crc >>= 1;
 
-			octet >>= 1;
-		}
-	}
-	return crc;
-}
 /*
 This function sets promiscuos mode, all-multi mode or the multicast address
 list to the device.
@@ -1556,7 +1531,7 @@ static void amd8111e_set_multicast_list(
 	mc_filter[1] = mc_filter[0] = 0;
 	for (i = 0, mc_ptr = dev->mc_list; mc_ptr && i < dev->mc_count;
 		     i++, mc_ptr = mc_ptr->next) {
-		bit_num = ( amd8111e_ether_crc(ETH_ALEN,mc_ptr->dmi_addr)							 >> 26 ) & 0x3f;
+		bit_num = (ether_crc_le(ETH_ALEN, mc_ptr->dmi_addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
 	}
 	amd8111e_writeq(*(u64*)mc_filter,lp->mmio+ LADRF);
--- chelsio-t2.orig/drivers/net/amd8111e.h
+++ chelsio-t2/drivers/net/amd8111e.h
@@ -651,10 +651,6 @@ typedef enum {
 /* driver ioctl parameters */
 #define AMD8111E_REG_DUMP_LEN	 13*sizeof(u32)
 
-/* crc generator constants */
-#define CRC32 0xedb88320
-#define INITCRC 0xFFFFFFFF
-
 /* amd8111e desriptor format */
 
 struct amd8111e_tx_dr{
