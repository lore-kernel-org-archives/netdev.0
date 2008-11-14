From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 01/13] async_tx,
	dmaengine: document channel allocation and api rework
Date: Fri, 14 Nov 2008 14:34:21 -0700
Message-ID: <20081114213421.32354.55126.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35033 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504AbYKNVec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:32 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Wouldn't it be better if the dmaengine layer made sure it didn't pass
the same channel several times to a client?

I mean, you seem concerned that the memcpy() API should be transparent
and easy to use, but the whole registration interface is just
ridiculously complicated..."
	- Haavard

The dmaengine and async_tx registration/allocation interface is indeed
needlessly complicated.  This redesign has the following goals:

1/ Simplify reference counting: dma channels are not something one would
   expect to be hotplugged, it should be an exceptional event handled by
   drivers not something clients should be mandated to handle in a
   callback.  The common case channel removal event is 'rmmod <dma driver>',
   which for simplicity should be disallowed if the channel is in use.
2/ Add an interface for requesting exclusive access to a channel
   suitable to device-to-memory users.
3/ Convert all memory-to-memory users over to a common allocator, the goal
   here is to not have competing channel allocation schemes.  The only
   competition should be between device-to-memory exclusive allocations and
   the memory-to-memory usage case where channels are shared between
   multiple "clients".

Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 Documentation/crypto/async-tx-api.txt |  135 ++++++++++++++++-----------------
 Documentation/dmaengine.txt           |    1 
 2 files changed, 68 insertions(+), 68 deletions(-)
 create mode 100644 Documentation/dmaengine.txt

diff --git a/Documentation/crypto/async-tx-api.txt b/Documentation/crypto/async-tx-api.txt
index c1e9545..48e7b35 100644
--- a/Documentation/crypto/async-tx-api.txt
+++ b/Documentation/crypto/async-tx-api.txt
@@ -13,9 +13,9 @@
 3.6 Constraints
 3.7 Example
 
-4 DRIVER DEVELOPER NOTES
+4 DMAENGINE DRIVER DEVELOPER NOTES
 4.1 Conformance points
-4.2 "My application needs finer control of hardware channels"
+4.2 "My application needs exclusive control of hardware channels"
 
 5 SOURCE
 
@@ -80,9 +80,7 @@ acknowledged by the application before the offload engine driver is allowed to
 recycle (or free) the descriptor.  A descriptor can be acked by one of the
 following methods:
 1/ setting the ASYNC_TX_ACK flag if no child operations are to be submitted
-2/ setting the ASYNC_TX_DEP_ACK flag to acknowledge the parent
-   descriptor of a new operation.
-3/ calling async_tx_ack() on the descriptor.
+2/ calling async_tx_ack() on the descriptor.
 
 3.4 When does the operation execute?
 Operations do not immediately issue after return from the
@@ -101,12 +99,15 @@ of an operation.
    it polls for the completion of the operation.  It handles dependency
    chains and issuing pending operations.
 2/ Specify a completion callback.  The callback routine runs in tasklet
-   context if the offload engine driver supports interrupts, or it is
-   called in application context if the operation is carried out
-   synchronously in software.  The callback can be set in the call to
-   async_<operation>, or when the application needs to submit a chain of
-   unknown length it can use the async_trigger_callback() routine to set a
-   completion interrupt/callback at the end of the chain.
+   context if an offload engine performs the operation, or it is called
+   in process context if the operation is carried out synchronously in
+   software.  The callback can by specified by using the
+   async_trigger_callback() interface.
+   Note: if the application knows ahead of time that it wants a
+   completion callback on a particular operation it should specify
+   ASYNC_TX_DELAY_SUBMIT to the flags.  Otherwise, async_trigger_callback
+   will be required to allocate and queue a separate 'interrupt'
+   descriptor.
 
 3.6 Constraints:
 1/ Calls to async_<operation> are not permitted in IRQ context.  Other
@@ -133,14 +134,20 @@ int run_xor_copy_xor(struct page **xor_srcs,
 		     size_t copy_len)
 {
 	struct dma_async_tx_descriptor *tx;
+	/* async_xor overwrites input parameters to save stack space */
+	struct page *srcs[xor_src_cnt];
 
-	tx = async_xor(xor_dest, xor_srcs, 0, xor_src_cnt, xor_len,
-		       ASYNC_TX_XOR_DROP_DST, NULL, NULL, NULL);
-	tx = async_memcpy(copy_dest, copy_src, 0, 0, copy_len,
-			  ASYNC_TX_DEP_ACK, tx, NULL, NULL);
-	tx = async_xor(xor_dest, xor_srcs, 0, xor_src_cnt, xor_len,
-		       ASYNC_TX_XOR_DROP_DST | ASYNC_TX_DEP_ACK | ASYNC_TX_ACK,
-		       tx, complete_xor_copy_xor, NULL);
+	memcpy(srcs, xor_srcs, sizeof(struct page *) * xor_src_cnt));
+	tx = async_xor(xor_dest, srcs, 0, xor_src_cnt, xor_len,
+		       ASYNC_TX_XOR_DROP_DST, NULL);
+
+	tx = async_memcpy(copy_dest, copy_src, 0, 0, copy_len, 0, tx);
+
+	memcpy(srcs, xor_srcs, sizeof(struct page *) * xor_src_cnt));
+	tx = async_xor(xor_dest, srcs, 0, xor_src_cnt, xor_len,
+		       ASYNC_TX_XOR_DROP_DST | ASYNC_TX_DELAY_SUBMIT, tx);
+
+	tx = async_trigger_callback(tx, complete_xor_copy_xor, NULL);
 
 	async_tx_issue_pending_all();
 }
@@ -150,6 +157,7 @@ ops_run_* and ops_complete_* routines in drivers/md/raid5.c for more
 implementation examples.
 
 4 DRIVER DEVELOPMENT NOTES
+
 4.1 Conformance points:
 There are a few conformance points required in dmaengine drivers to
 accommodate assumptions made by applications using the async_tx API:
@@ -158,58 +166,49 @@ accommodate assumptions made by applications using the async_tx API:
 3/ Use async_tx_run_dependencies() in the descriptor clean up path to
    handle submission of dependent operations
 
-4.2 "My application needs finer control of hardware channels"
-This requirement seems to arise from cases where a DMA engine driver is
-trying to support device-to-memory DMA.  The dmaengine and async_tx
-implementations were designed for offloading memory-to-memory
-operations; however, there are some capabilities of the dmaengine layer
-that can be used for platform-specific channel management.
-Platform-specific constraints can be handled by registering the
-application as a 'dma_client' and implementing a 'dma_event_callback' to
-apply a filter to the available channels in the system.  Before showing
-how to implement a custom dma_event callback some background of
-dmaengine's client support is required.
-
-The following routines in dmaengine support multiple clients requesting
-use of a channel:
-- dma_async_client_register(struct dma_client *client)
-- dma_async_client_chan_request(struct dma_client *client)
-
-dma_async_client_register takes a pointer to an initialized dma_client
-structure.  It expects that the 'event_callback' and 'cap_mask' fields
-are already initialized.
-
-dma_async_client_chan_request triggers dmaengine to notify the client of
-all channels that satisfy the capability mask.  It is up to the client's
-event_callback routine to track how many channels the client needs and
-how many it is currently using.  The dma_event_callback routine returns a
-dma_state_client code to let dmaengine know the status of the
-allocation.
-
-Below is the example of how to extend this functionality for
-platform-specific filtering of the available channels beyond the
-standard capability mask:
-
-static enum dma_state_client
-my_dma_client_callback(struct dma_client *client,
-			struct dma_chan *chan, enum dma_state state)
-{
-	struct dma_device *dma_dev;
-	struct my_platform_specific_dma *plat_dma_dev;
-	
-	dma_dev = chan->device;
-	plat_dma_dev = container_of(dma_dev,
-				    struct my_platform_specific_dma,
-				    dma_dev);
-
-	if (!plat_dma_dev->platform_specific_capability)
-		return DMA_DUP;
-
-	. . .
-}
+4.2 "My application needs exclusive control of hardware channels"
+Primarily this requirement arises from cases where a DMA engine driver
+is being used to support device-to-memory operations.  A channel that is
+performing these operations cannot, for many platform specific reasons,
+be shared.  For these cases the dma_request_channel() interface is
+provided.
+
+The interface is:
+struct dma_chan *dma_request_channel(dma_cap_mask_t mask,
+				     dma_filter_fn filter_fn,
+				     void *filter_param);
+
+Where dma_filter_fn is defined as:
+typedef bool (*dma_filter_fn)(struct dma_chan *chan, void *filter_param);
+
+When the optional 'filter_fn' parameter is set to NULL
+dma_request_channel simply returns the first channel that satisfies the
+capability mask.  Otherwise, when the mask parameter is insufficient for
+specifying the necessary channel, the filter_fn routine can be used to
+disposition the available channels in the system. The filter_fn routine
+is called once for each free channel in the system.  Upon seeing a
+suitable channel filter_fn returns DMA_ACK which flags that channel to
+be the return value from dma_request_channel.  A channel allocated via
+this interface is exclusive to the caller, until dma_release_channel()
+is called.
+
+The DMA_PRIVATE capability flag is used to tag dma devices that should
+not be used by the general-purpose allocator.  It can be set at
+initialization time if it is known that a channel will always be
+private.  Alternatively, it is set when dma_request_channel() finds an
+unused "public" channel.
+
+A couple caveats to note when implementing a driver and consumer:
+1/ Once a channel has been privately allocated it will no longer be
+   considered by the general-purpose allocator even after a call to
+   dma_release_channel().
+2/ Since capabilities are specified at the device level a dma_device
+   with multiple channels will either have all channels public, or all
+   channels private.
 
 5 SOURCE
-include/linux/dmaengine.h: core header file for DMA drivers and clients
+
+include/linux/dmaengine.h: core header file for DMA drivers and api users
 drivers/dma/dmaengine.c: offload engine channel management routines
 drivers/dma/: location for offload engine drivers
 include/linux/async_tx.h: core header file for the async_tx api
diff --git a/Documentation/dmaengine.txt b/Documentation/dmaengine.txt
new file mode 100644
index 0000000..0c1c2f6
--- /dev/null
+++ b/Documentation/dmaengine.txt
@@ -0,0 +1 @@
+See Documentation/crypto/async-tx-api.txt

