From: cndougla@linux.vnet.ibm.com
Subject: [PATCH] AF_PACKET: Fix PACKET_MMAP on 64-bit kernel/32-bit user
	systems
Date: Mon, 10 Aug 2009 13:03:59 -0400
Message-ID: <20090810130359.p2hixk2eoow8kwg8@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:42904 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350AbZHJREQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 13:04:16 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7AH2MYC004811
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 11:02:22 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7AH470U168866
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 11:04:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7AH4238015238
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 11:04:02 -0600
Received: from linux.ibm.com (imap.raleigh.ibm.com [9.37.253.145])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n7AH41u0015006
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 11:04:02 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PACKET_MMAP sets up a ring buffer at a memory location so that kernel  
and user space can read from it without extra overhead. However, the  
data is written with a header, struct tpacket_hdr, which begins with  
an unsigned long field, tp_status. This means in a split 64-bit/32-bit  
environment the kernel- and user-space reads from the mmap'd region  
will be different, since in kernel-space the field is 64-bit while in  
user-space the field is 32-bit.

The following patch makes the size of the structure constant by  
changing the tp_status field to 32-bits. It does not appear to need  
64-bits, since only 4-bits are actually used throughout the AF_PACKET  
code.

Signed-off-by: Chase Douglas <cndougla@linux.vnet.ibm.com>
--- a/include/linux/if_packet.h   2009-08-10 16:53:11.000000000 +0000
+++ b/include/linux/if_packet.h   2009-08-10 16:53:28.000000000 +0000
@@ -65,7 +65,7 @@ struct tpacket_auxdata

  struct tpacket_hdr
  {
-       unsigned long   tp_status;
+       unsigned int    tp_status;
  #define TP_STATUS_KERNEL       0
  #define TP_STATUS_USER         1
  #define TP_STATUS_COPY         2

