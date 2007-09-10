From: Pierre-Yves Ritschard <pyritschard@echo.fr>
Subject: sky2.c: length mismatch errors with vlan frames
Date: Mon, 10 Sep 2007 16:35:38 +0200
Message-ID: <20070910163538.3b23e842@gamma.echo-net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout02s1.x-echo.com ([193.252.149.38]:37938 "EHLO
	smtpout02s1.x-echo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756353AbXIJOqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 10:46:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi list,

I have been running recent linux kernel on nexcom NSA 1086's equipped
with sysconnect NICs.

Like some people previously have on this list I am running into
problems with these NICs and seeing frequent errors in my dmesg:

sky2 eth4: rx error, status 0x402300 length 60
printk: 17 messages suppressed.
sky2 eth4: rx error, status 0x402300 length 60
printk: 32 messages suppressed.
sky2 eth4: rx error, status 0x602300 length 92
printk: 25 messages suppressed.
sky2 eth4: rx error, status 0x6e2300 length 106
printk: 16 messages suppressed.
sky2 eth4: rx error, status 0x402300 length 60
printk: 10 messages suppressed.
sky2 eth4: rx error, status 0x402300 length 60
printk: 17 messages suppressed.
sky2 eth4: rx error, status 0x402300 length 60


I have investigated a bit and status doesn't match any of the errors in
GMR_FS_ANY_ERR.
The block generating the error is now len_mismatch, due to the fact
that on packets having the GMR_FS_VLAN bit set, the length argument to
sky2_receive is 4 bytes shorter that the 16 bit value in status (status
``right shift'' 16).

Since both these values are read from the card I don't know how to
solve this other than by incrementing the length arg by 4 when
GMR_FS_VLAN is set in status. So here's a diff that does this, although
I'm not sure its an elegant solution:

--- sky2.c.orig	2007-09-10 15:34:15.000000000 +0200
+++ sky2.c	2007-09-10 16:20:28.000000000 +0200
@@ -2059,13 +2059,16 @@ static struct sk_buff *sky2_receive(stru
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
+	if (status & GMR_FS_VLAN)
+		length += 4;
+
 	if (status & GMR_FS_ANY_ERR)
 		goto error;
 
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (status >> 16 != length)
+	if ((status >> 16) != length)
 		goto len_mismatch;
 
 	if (length < copybreak)
@@ -2081,6 +2084,8 @@ len_mismatch:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
+	printk(KERN_INFO PFX "%s: rx length mismatch: length %d != %d\n",
+	       dev->name, length, status >> 16);
 
 error:
 	++sky2->net_stats.rx_errors;

Any thoughts on how to solve this ?
Further testing shows that sometimes there are packets without the
GMR_FS_VLAN bit set which have a 4 bytes length difference, has shown
by this log excerpt:

sky2 eth4: rx length mismatch: length 243 != 247
sky2 eth4: rx error, status 0xf70300 length 243

For debugging purposes, I here is the little program with
excerpts from sky2.c I use to see what bits are set in the status field:

#include <sys/types.h>
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>

enum {
        GMR_FS_LEN      = 0xffff<<16, /* Bit 31..16:    Rx Frame Length */
        GMR_FS_VLAN     = 1<<13, /* VLAN Packet */
        GMR_FS_JABBER   = 1<<12, /* Jabber Packet */
        GMR_FS_UN_SIZE  = 1<<11, /* Undersize Packet */
        GMR_FS_MC       = 1<<10, /* Multicast Packet */
        GMR_FS_BC       = 1<<9,  /* Broadcast Packet */
        GMR_FS_RX_OK    = 1<<8,  /* Receive OK (Good Packet) */
        GMR_FS_GOOD_FC  = 1<<7,  /* Good Flow-Control Packet */
        GMR_FS_BAD_FC   = 1<<6,  /* Bad  Flow-Control Packet */
        GMR_FS_MII_ERR  = 1<<5,  /* MII Error */
        GMR_FS_LONG_ERR = 1<<4,  /* Too Long Packet */
        GMR_FS_FRAGMENT = 1<<3,  /* Fragment */

        GMR_FS_CRC_ERR  = 1<<1,  /* CRC Error */
        GMR_FS_RX_FF_OV = 1<<0,  /* Rx FIFO Overflow */

        GMR_FS_ANY_ERR  = GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
                          GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
                          GMR_FS_MII_ERR | GMR_FS_BAD_FC |
                          GMR_FS_UN_SIZE | GMR_FS_JABBER,
};

struct bitdesc {
	const char 	*name;
	u_int32_t 	 field;
};

struct bitdesc bits[] = {
        { "GMR_FS_VLAN", 1 << 13 },
        { "GMR_FS_JABBER", 1 << 12 },
        { "GMR_FS_UN_SIZE", 1 << 11 },
        { "GMR_FS_MC", 1 << 10 },
        { "GMR_FS_BC", 1 << 9 },
        { "GMR_FS_RX_OK", 1 << 8 },
        { "GMR_FS_GOOD_FC", 1 << 7 },
        { "GMR_FS_BAD_FC", 1 << 6 },
        { "GMR_FS_MII_ERR", 1 << 5 },
        { "GMR_FS_LONG_ERR", 1 << 4 },
        { "GMR_FS_FRAGMENT", 1 << 3 },
        { "GMR_FS_CRC_ERR", 1 << 1 },
        { "GMR_FS_RX_FF_OV", 1 << 0 }
};

int
main(int argc, const char *argv[])
{
	int	status;
	int	i;

	if (argc < 2)
		return (1);

	status = strtol(argv[1], NULL, 16);
	printf("status: 0x%08x\n", status);
	if (status & GMR_FS_ANY_ERR)
		printf("packet has an error\n");
	printf("length: %u\n", status >> 16);

	for (i = 0; i < (sizeof(bits) / sizeof(bits[0])); i++) {
		if (status & bits[i].field) {
			printf("has bit %s\n", bits[i].name);
		}
	}
	return (0);
}
