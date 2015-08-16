From: Victor Kaplansky <victork@redhat.com>
Subject: [PATCH v2 2/2] virtio-net: add default_mtu configuration field
Date: Sun, 16 Aug 2015 16:42:25 +0300
Message-ID: <1439732494-29765-3-git-send-email-victork@redhat.com>
References: <1439732494-29765-1-git-send-email-victork@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, jasowang@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: virtio-dev@lists.oasis-open.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51015 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbbHPNm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:42:27 -0400
Content-Disposition: inline
In-Reply-To: <1439732494-29765-1-git-send-email-victork@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes it is essential for libvirt to be able to configure MTU
on guest's NICs to a value different from 1500.

The change adds a new field to configuration area of network
devices. It will be used to pass initial MTU from the device to
the driver, and to pass modified MTU from driver to the device
when a new MTU is assigned by the guest OS.

In addition, in order to support backward and forward
compatibility, we introduce a new feature bit called
VIRTIO_NET_F_DEFAULT_MTU.

Added conformance statements for a device and a driver.

Signed-off-by: Victor Kaplansky <victork@redhat.com>

    Signed-off-by: Victor Kaplansky <victork@redhat.com>
---
 content.tex | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/content.tex b/content.tex
index 342183b..439d005 100644
--- a/content.tex
+++ b/content.tex
@@ -3078,6 +3078,12 @@ features.
 
 \item[VIRTIO_NET_F_CTRL_MAC_ADDR(23)] Set MAC address through control
     channel.
+
+\item[VIRTIO_NET_F_DEFAULT_MTU(24)] Default MTU is supported.  If
+    offered by the device, device advises driver about initial MTU to
+    be used. If negotiated, the driver uses \field{default_mtu} as
+    an initial value and reports MTU changes to the device.
+
 \end{description}
 
 \subsubsection{Feature bit requirements}\label{sec:Device Types / Network Device / Feature bits / Feature bit requirements}
@@ -3128,6 +3134,7 @@ struct virtio_net_config {
         u8 mac[6];
         le16 status;
         le16 max_virtqueue_pairs;
+        le16 default_mtu;
 };
 \end{lstlisting}
 
@@ -3158,6 +3165,15 @@ by the driver after negotiation.
     \field{max_virtqueue_pairs} is valid only if VIRTIO_NET_F_MQ is
     set and can be read by the driver.
 
+\item [\field{default_mtu}] is a hint to the driver set by the
+    device. It is valid during feature negotiation only if
+    VIRTIO_NET_F_DEFAULT_MTU is offered and holds the initial value
+    of MTU to be used by the driver. If VIRTIO_NET_F_DEFAULT_MTU is
+    negotiated, the driver uses the \field{default_mtu} as an initial
+    value, and also reports MTU changes to the device by writes to
+    \field{default_mtu}.  Such reporting can be used for debugging,
+    or it can be used for tunning MTU along the network.
+
 \end{description}
 
 \devicenormative{\subsubsection}{Device configuration layout}{Device Types / Network Device / Device configuration layout}
@@ -3165,6 +3181,9 @@ by the driver after negotiation.
 The device MUST set \field{max_virtqueue_pairs} to between 1 and 0x8000 inclusive,
 if it offers VIRTIO_NET_F_MQ.
 
+The device MUST set \field{default_mtu} to between 68 and 65535
+inclusive, if it offers VIRTIO_NET_F_DEFAULT_MTU.
+
 \drivernormative{\subsubsection}{Device configuration layout}{Device Types / Network Device / Device configuration layout}
 
 A driver SHOULD negotiate VIRTIO_NET_F_MAC if the device offers it.
@@ -3177,6 +3196,12 @@ If the driver does not negotiate the VIRTIO_NET_F_STATUS feature, it SHOULD
 assume the link is active, otherwise it SHOULD read the link status from
 the bottom bit of \field{status}.
 
+A driver SHOULD negotiate VIRTIO_NET_F_DEFAULT_MTU if the device
+offers it.  If the driver negotiates the VIRTIO_NET_F_DEFAULT_MTU
+feature, the driver MUST use \field{default_mtu} as an initial value
+for MTU and the driver MUST report the value of MTU to
+\field{default_mtu} when MTU is modified by the guest.
+
 \subsubsection{Legacy Interface: Device configuration layout}\label{sec:Device Types / Network Device / Device configuration layout / Legacy Interface: Device configuration layout}
 \label{sec:Device Types / Block Device / Feature bits / Device configuration layout / Legacy Interface: Device configuration layout}
 When using the legacy interface, transitional devices and drivers
-- 
--Victor
