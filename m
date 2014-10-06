From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 3/3] net: packet: Document
 PACKET_DEV_QPAIR_SPLIT and friends
Date: Sun, 05 Oct 2014 17:07:36 -0700
Message-ID: <20141006000735.32055.98724.stgit@nitbit.x32>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com
To: dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36496 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbaJFAH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 20:07:59 -0400
Received: by mail-oi0-f53.google.com with SMTP id v63so2837341oia.26
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 17:07:58 -0700 (PDT)
In-Reply-To: <20141006000629.32055.2295.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a section to the packet interface kernel documentation
describing the set of socket options to get direct queue
assignment working.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 Documentation/networking/packet_mmap.txt |   44 ++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index a6d7cb9..ad26194 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -1047,6 +1047,50 @@ See include/linux/net_tstamp.h and Documentation/networking/timestamping
 for more information on hardware timestamps.
 
 -------------------------------------------------------------------------------
++ PACKET_RXTX_QPAIRS_SPLIT and friends
+-------------------------------------------------------------------------------
+
+The PACKET_RXTX_QPAIRS_SLIT setting allows direct access to the hardware
+packet rings. If your NIC is capable of supporting hardware packet steering
+and the driver has this feature enabled you can use the hardware to steer
+packets directly to user mapped memory and use user space descriptor rings.
+
+The user space flow should be,
+
+	bind(fd, &sockaddr, sizeof(sockaddr));
+
+	/* Get the device type and info */
+	getsockopt(fd, SOL_PACKET, PACKET_DEV_DESC_INFO, &def_info,
+		   &optlen);
+
+	/* With device info we can look up descriptor format */
+
+	/* Get the layout of ring space offset, page_sz, cnt */
+	getsockopt(fd, SOL_PACKET, PACKET_DEV_QPAIR_MAP_REGION_INFO,
+                   &info, &optlen);
+
+        /* request some queues from the driver */
+	setsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
+		   &qpairs_info, sizeof(qpairs_info));
+
+	/* if we let the driver pick us queues learn which queues
+	 * we were given
+	 */
+	getsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
+		   &qpairs_info, sizeof(qpairs_info));
+
+	/* And mmap queue pairs to user space */
+	mmap(NULL, info.tp_dev_bar_sz, PROT_READ | PROT_WRITE,
+	     MAP_SHARED, fd, 0);
+
+	/* Now we have some user space queues to read/write to*/
+
+After this user space can directly manipulate the drivers descriptor rings.
+The descriptor rings use the native descriptor format of the hardware device.
+The device specifics are returned from the PACKET_DEV_DESC_INFO call which
+allows user space to determine the correct descriptor format to use.
+
+-------------------------------------------------------------------------------
 + Miscellaneous bits
 -------------------------------------------------------------------------------
 
