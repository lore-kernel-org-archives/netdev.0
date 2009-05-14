From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 12:22:35 +0100
Message-ID: <1242300155.17366.20.camel@blaa>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, Gregory Haskins <ghaskins@novell.com>,
	qemu-devel <qemu-devel@nongnu.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37567 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758635AbZENLWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 07:22:44 -0400
In-Reply-To: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-05-14 at 13:07 +0300, Or Gerlitz wrote:
> Hi,
> 
> When running with jumbo frames (i.e set tap0 and guest nic mtu to 9k)
> and using 8k sized packets with iperf, the qemu process exits with
> "virtio-net truncating packet" which I see in the code of qemu/hw/virtio-net.c
> :: virtio_net_receive(). This happens only when the VM is receiving, if I
> send 8K packets from the VM things go fine.
> 
> I use virtio based NIC in the VM and Linux 2.6.29.1 in both the VM and the host.
> Qemu is the one provided by kvm release 84

That sounds like a bug in qemu's mergeable receive buffers
implementation - the host is running out of buffers for the packet, even
though it supposedly has already checked that there is enough buffers
available on the ring.

Hmm, I think I see the bug - does the patch below work? Please try
several mtu values around the 9k mark to be sure

Cheers,
Mark.

diff --git a/hw/virtio-net.c b/hw/virtio-net.c
index f125edc..3ffd2c0 100644
--- a/hw/virtio-net.c
+++ b/hw/virtio-net.c
@@ -438,16 +438,16 @@ static void virtio_net_receive(void *opaque, const uint8_t *buf, int size)
     struct virtio_net_hdr_mrg_rxbuf *mhdr = NULL;
     size_t hdr_len, offset, i;
 
-    if (!do_virtio_net_can_receive(n, size))
+    /* hdr_len refers to the header we supply to the guest */
+    hdr_len = n->mergeable_rx_bufs ?
+        sizeof(struct virtio_net_hdr_mrg_rxbuf) : sizeof(struct virtio_net_hdr);
+
+    if (!do_virtio_net_can_receive(n, size + hdr_len))
         return;
 
     if (!receive_filter(n, buf, size))
         return;
 
-    /* hdr_len refers to the header we supply to the guest */
-    hdr_len = n->mergeable_rx_bufs ?
-        sizeof(struct virtio_net_hdr_mrg_rxbuf) : sizeof(struct virtio_net_hdr);
-
     offset = i = 0;
 
     while (offset < size) {


