From: Christian Borntraeger <borntrae@de.ibm.com>
Subject: [RFC] changing value of NETDEV_ALIGN to cacheline size
Date: Mon, 15 May 2006 14:08:29 +0200
Message-ID: <200605151408.29688.borntrae@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:50518 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751406AbWEOMIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 08:08:31 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k4FC8ULc124726
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 13:08:30 +0100
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4FC9RfE133422
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 13:09:27 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11/8.13.3) with ESMTP id k4FC8UrE031033
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 13:08:30 +0100
Received: from dyn-9-152-230-40.boeblingen.de.ibm.com (dyn-9-152-230-40.boeblingen.de.ibm.com [9.152.230.40])
	by d06av03.portsmouth.uk.ibm.com (8.12.11/8.12.11) with ESMTP id k4FC8UCL031023
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 13:08:30 +0100
Content-Disposition: inline
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

while digging through the alloc_netdev function I asked myself why there is a
fixed alignment for netdevices. Is there a special reason for choosing 32? If
yes, I suggest to add a comment to the definition. 

If not, I suspect cacheline alignment might be beneficial:
struct net_device contains several variables which are cache aligned 
(poll_list, queue_lock .....). As far as I can see, the compiler tries to 
increase the size of the structure to make that possible, but expects the
whole structure to be aligned to cache line size as well. With the current
value for NETDEV_ALIGN we dont align "struct net_device" to the cache line,
instead we align it to 32 bytes. That means that poll_list, queue_lock and 
friends are not always cache aligned, but 32 bytes aligned.

The only reason why everything worked so far is the slab allocator design, 
which gives us a page aligned struct net_device in most cases. I think we 
should not rely on the behaviour of the memory allocator and use a different 
value for NETDEV_ALIGN instead. Any comments or corrections?

cheers Christian



The patch below is compile and boot tested on s390 and x86.

Signed-off-by: Christian Borntraeger <borntrae@de.ibm.com>

include/linux/netdevice.h |    2 +-
net/core/dev.c            |    2 +-
2 files changed, 2 insertions(+), 2 deletions(-)
----------

--- a/include/linux/netdevice.h	4 Apr 2006 07:25:47 -0000
+++ b/include/linux/netdevice.h	15 May 2006 11:06:05 -0000
@@ -504,7 +504,7 @@
 	struct class_device	class_dev;
 };
 
-#define	NETDEV_ALIGN		32
+#define	NETDEV_ALIGN		L1_CACHE_BYTES
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
 static inline void *netdev_priv(struct net_device *dev)
--- a/net/core/dev.c	4 Apr 2006 07:25:50 -0000
+++ b/net/core/dev.c	15 May 2006 11:06:05 -0000
@@ -2986,7 +2986,7 @@
 	struct net_device *dev;
 	int alloc_size;
 
-	/* ensure 32-byte alignment of both the device and private area */
+	/* ensure cacheline alignment of both the device and private area */
 	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
