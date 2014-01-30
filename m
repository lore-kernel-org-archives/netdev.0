From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 16:00:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B5486@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43124 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753209AbaA3QBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 11:01:08 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22461-05 for <netdev@vger.kernel.org>;
 Thu, 30 Jan 2014 16:01:02 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some xhci (USB3) controllers have a constraint on the offset within a
bulk transfer of the end of the transfer ring.

The xhci documentation (v1.00, but not the earlier versions) states that
the offset (from the beginning of the transfer) at end of the transfer
ring must be a multiple of the burst size (this is actually 16k for USB3
since the controller is configured for 16 message bursts).
However the effect is probably that the transfer is split at the ring end,
so the target will see correct messages provided the data is 1k aligned.

This mostly affects scatter-gather transfer requests, but can potentially
affect other requests as they must be split on 64k address boundaries.
(It might even affect non-bulk transfers.)

The only known current source of such misaligned transfers is the
ax88179_178a ethernet driver. The hardware stops transmitting ethernet
frames when the host controller (presumably) spilts a 1k message.

Not all host controllers behave this way.
The Intel Panther Point used on recent motherboards is affected.

A fix has been applied to the xhci driver (and backported), however this
has a side effect of limiting the number of fragments that can be sent.
(It works by putting all the buffer fragments in one ring segment.)

The SCSI system generates more fragments than was originally thought, and
code using libusb can generate arbitrarily long transfers that usually
get split into 8k fragments.

We've had reports of 4MB libusb requests failing. A 16MB request would
require 256 fragments (because of the requirement to not cross a 64k
address boundary) so could not be fitted into the 255 ring slots regarless
of the number and alignment of any fragments.

In fact libusb always uses 8k fragments. Anything over 1M can't be
split with the current limit of 128 fragments and is sent unfragmented.
This leads to kmalloc() failures.

This all means that the xhci driver needs to accept unlimited numbers
of 'aligned' fragments and only restrict the number of misaligned ones.

None of the other USB controllers allow buffer fragments that cross
USB message boundaries (512 bytes for USB2), so almost all the code
uses aligned buffers. Potentially these might cross 64k boundaries
at unaligned offsets, but I suspect that really doesn't happen.

So rather than change all the code that generates urbs, this patch
modifies the only code that generates misaligned transfares to tell
the host controller that the buffer might have alignment issues.

The patch:
- Adds the flag URB_UNCONSTRAINED_XFER to urb->transfer_flags.
  This reuses the value of URB_ASYNC_UNLINK (removed in 2005).
- Sets the flag in usbnet.c for all transmit requests.
  Since the buffer offsets aren't aligned an unfragmented message might
  need splitting on a 64k boundary.
- Pass the transfer_flags down to prepare_ring() and only check for
  the end of ring segments (filling with NOPs) if the flag is set.
- Remove the advertised restriction on the number fragments xhci supports.

This doesn't actually define what a 'constrained' transfer is - but
that wasn't defined when no_sg_constraint was added to struct usb_bus.
Possibly there should also be separate limits of the number of 'constrained'
and 'unconstrained' scatter-gather lists. But and the moment the former
is (more or less) required to be infinite, and the limit of the latter
won't be reached by any code that sets the flag.

Signed-off-by: David Laight <david.laight@aculab.com>
---
 drivers/net/usb/usbnet.c     |  1 +
 drivers/usb/host/xhci-ring.c | 12 ++++++++----
 drivers/usb/host/xhci.c      |  8 ++++++--
 include/linux/usb.h          |  1 +
 4 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4671da7..504be5b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1303,6 +1303,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		if (build_dma_sg(skb, urb) < 0)
 			goto drop;
 	}
+	urb->transfer_flags |= URB_UNCONSTRAINED_XFER;
 	length = urb->transfer_buffer_length;
 
 	/* don't assume the hardware handles USB_ZERO_PACKET
diff --git a/drivers/usb/host/xhci-ring.c b/drivers/usb/host/xhci-ring.c
index a0b248c..5860874 100644
--- a/drivers/usb/host/xhci-ring.c
+++ b/drivers/usb/host/xhci-ring.c
@@ -2932,7 +2932,8 @@ static void queue_trb(struct xhci_hcd *xhci, struct xhci_ring *ring,
  * FIXME allocate segments if the ring is full.
  */
 static int prepare_ring(struct xhci_hcd *xhci, struct xhci_ring *ep_ring,
-		u32 ep_state, unsigned int num_trbs, gfp_t mem_flags)
+		u32 ep_state, unsigned int num_trbs, gfp_t mem_flags,
+		unsigned int transfer_flags)
 {
 	unsigned int num_trbs_needed;
 
@@ -2980,6 +2981,9 @@ static int prepare_ring(struct xhci_hcd *xhci, struct xhci_ring *ep_ring,
 			 * Simplest solution is to fill the trb before the
 			 * LINK with nop commands.
 			 */
+			if (!(transfer_flags & URB_UNCONSTRAINED_XFER))
+				/* Caller says buffer is aligned */
+				break;
 			if (num_trbs == 1 || num_trbs <= usable || usable == 0)
 				break;
 
@@ -3090,7 +3094,7 @@ static int prepare_transfer(struct xhci_hcd *xhci,
 
 	ret = prepare_ring(xhci, ep_ring,
 			   le32_to_cpu(ep_ctx->ep_info) & EP_STATE_MASK,
-			   num_trbs, mem_flags);
+			   num_trbs, mem_flags, urb->transfer_flags);
 	if (ret)
 		return ret;
 
@@ -3969,7 +3973,7 @@ int xhci_queue_isoc_tx_prepare(struct xhci_hcd *xhci, gfp_t mem_flags,
 	 * Do not insert any td of the urb to the ring if the check failed.
 	 */
 	ret = prepare_ring(xhci, ep_ring, le32_to_cpu(ep_ctx->ep_info) & EP_STATE_MASK,
-			   num_trbs, mem_flags);
+			   num_trbs, mem_flags, 0);
 	if (ret)
 		return ret;
 
@@ -4026,7 +4030,7 @@ static int queue_command(struct xhci_hcd *xhci, u32 field1, u32 field2,
 		reserved_trbs++;
 
 	ret = prepare_ring(xhci, xhci->cmd_ring, EP_STATE_RUNNING,
-			reserved_trbs, GFP_ATOMIC);
+			reserved_trbs, GFP_ATOMIC, 0);
 	if (ret < 0) {
 		xhci_err(xhci, "ERR: No room for command on command ring\n");
 		if (command_must_succeed)
diff --git a/drivers/usb/host/xhci.c b/drivers/usb/host/xhci.c
index ad36439..eab1c5c 100644
--- a/drivers/usb/host/xhci.c
+++ b/drivers/usb/host/xhci.c
@@ -4730,8 +4730,12 @@ int xhci_gen_setup(struct usb_hcd *hcd, xhci_get_quirks_t get_quirks)
 	struct device		*dev = hcd->self.controller;
 	int			retval;
 
-	/* Limit the block layer scatter-gather lists to half a segment. */
-	hcd->self.sg_tablesize = TRBS_PER_SEGMENT / 2;
+	/* The length of scatter-gather lists needs to be unlimited for
+	 * aligned lists (URB_UNCONSTRAINED_XFER unset).
+	 * There is currently no way of specifying the limit for
+	 * misaligned transfers.
+	 */
+	hcd->self.sg_tablesize = ~0u;
 
 	/* support to build packet from discontinuous buffers */
 	hcd->self.no_sg_constraint = 1;
diff --git a/include/linux/usb.h b/include/linux/usb.h
index c716da1..7f53034 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -1179,6 +1179,7 @@ extern int usb_disabled(void);
 #define URB_ISO_ASAP		0x0002	/* iso-only; use the first unexpired
 					 * slot in the schedule */
 #define URB_NO_TRANSFER_DMA_MAP	0x0004	/* urb->transfer_dma valid on submit */
+#define URB_UNCONSTRAINED_XFER	0x0010	/* data may not be aligned */
 #define URB_NO_FSBR		0x0020	/* UHCI-specific */
 #define URB_ZERO_PACKET		0x0040	/* Finish bulk OUT with short packet */
 #define URB_NO_INTERRUPT	0x0080	/* HINT: no non-error interrupt
-- 
1.8.1.2
