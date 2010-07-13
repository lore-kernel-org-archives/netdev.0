From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Mon, 12 Jul 2010 20:06:28 -0700
Message-ID: <1278990388.32650.22.camel@eng-rhel5-64>
References: <20100504230225.GP8323@vmware.com>
	 <201005051029.42052.dtor@vmware.com>	<20100505173120.GA1752@infradead.org>
	 <201005051035.29831.dtor@vmware.com>	<20100505173951.GA8388@infradead.org>
	 <20100505105253.0a8bc465@nehalam>  <20100506202113.GC17922@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100506202113.GC17922@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2010-05-06 at 13:21 -0700, Christoph Hellwig wrote:
> On Wed, May 05, 2010 at 10:52:53AM -0700, Stephen Hemminger wrote:
> > Let me put it bluntly. Any design that allows external code to run
> > in the kernel is not going to be accepted.  Out of tree kernel modules are enough
> > of a pain already, why do you expect the developers to add another
> > interface.
> 
> Exactly.  Until our friends at VMware get this basic fact it's useless
> to continue arguing.
> 
> Pankaj and Dmitry: you're fine to waste your time on this, but it's not
> going to go anywhere until you address that fundamental problem.  The
> first thing you need to fix in your archicture is to integrate the VF
> function code into the kernel tree, and we can work from there.
> 
> Please post patches doing this if you want to resume the discussion.
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers


As discussed, following is the patch to give you an idea
about implementation of NPA for vmxnet3 driver. Although the
patch is big, I have verified it with checkpatch.pl. It gave
0 errors / warnings.

Signed-off-by: Matthieu Bucchaineri <matthieu@vmware.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
---

 drivers/net/vmxnet3/Makefile          |    2 
 drivers/net/vmxnet3/npa_defs.h        |   83 +
 drivers/net/vmxnet3/npa_plugin_api.h  |  473 ++++++++
 drivers/net/vmxnet3/npa_shell_api.h   |  234 ++++
 drivers/net/vmxnet3/vmxnet3_defs.h    |    2 
 drivers/net/vmxnet3/vmxnet3_drv.c     | 1845
+++++++++++++++++++--------------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |   66 +
 drivers/net/vmxnet3/vmxnet3_int.h     |  221 ++--
 drivers/net/vmxnet3/vmxnet3_plugin.c  | 1221 ++++++++++++++++++++++
 9 files changed, 3221 insertions(+), 926 deletions(-)
 create mode 100644 drivers/net/vmxnet3/npa_defs.h
 create mode 100644 drivers/net/vmxnet3/npa_plugin_api.h
 create mode 100644 drivers/net/vmxnet3/npa_shell_api.h
 create mode 100644 drivers/net/vmxnet3/vmxnet3_plugin.c

diff --git a/drivers/net/vmxnet3/Makefile b/drivers/net/vmxnet3/Makefile
index 880f509..af501d8 100644
--- a/drivers/net/vmxnet3/Makefile
+++ b/drivers/net/vmxnet3/Makefile
@@ -32,4 +32,4 @@
 
 obj-$(CONFIG_VMXNET3) += vmxnet3.o
 
-vmxnet3-objs := vmxnet3_drv.o vmxnet3_ethtool.o
+vmxnet3-objs := vmxnet3_drv.o vmxnet3_ethtool.o vmxnet3_plugin.o
diff --git a/drivers/net/vmxnet3/npa_defs.h
b/drivers/net/vmxnet3/npa_defs.h
new file mode 100644
index 0000000..74d28b8
--- /dev/null
+++ b/drivers/net/vmxnet3/npa_defs.h
@@ -0,0 +1,83 @@
+/*
+ * Network Plugin Architecture definitions.
+ *
+ * Copyright (C) 2008-2010, VMware, Inc. All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms of the GNU General Public License as published by
the
+ * Free Software Foundation; version 2 of the License and no later
version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT. See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
USA.
+ *
+ * The full GNU General Public License is included in this distribution
in
+ * the file called "COPYING".
+ *
+ * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ *
+ */
+
+#ifndef _NPA_DEFS_H
+#define _NPA_DEFS_H
+
+#define NPA_PLUGIN_NUMPAGES      64
+#define NPA_MEMIO_NUMPAGES       32
+#define NPA_SHARED_NUMPAGES      6
+#define NPA_MAX_PLUGINS_PER_VM   12
+#define VMXNET3_NPA_CMD_SUCCESS  1
+#define VMXNET3_NPA_CMD_FAILURE  0
+#define VMXNET3_PLUGIN_INFO_LEN  32
+
+/* these structure are versioned using the vmxnet3 version */
+
+struct NPA_PluginPages {
+	u64 vaddr;
+	u32 numPages;
+	u64  pages[NPA_PLUGIN_NUMPAGES];
+};
+
+struct NPA_MemioPages {
+	u64  startPPN;
+	u32 numPages;
+};
+
+
+struct NPA_SharedPages {
+	u64  startPPN;
+	u32 numPages;
+};
+
+struct NPA_PluginConf {
+	struct NPA_PluginPages   pluginPages;
+	struct NPA_MemioPages    memioPages;
+	struct NPA_SharedPages   sharedPages;
+	u64 entryVA;  /* address of entry function in the plugin */
+	u32 deviceInfo[VMXNET3_PLUGIN_INFO_LEN]; /* opaque data returned by
+						  * PF driver */
+};
+
+
+/* vmkernel and device backend shared definitions */
+
+#define VMXNET3_PLUGIN_NAME_LEN  256
+#define VMXNET3_PLUGIN_REPOSITORY "/usr/lib/vmware/npa_plugins"
+#define NPA_MEMIO_REGIONS_u64X    6
+
+typedef u32 VF_ID;
+
+struct Vmxnet3_VFInfo {
+	char     pluginName[VMXNET3_PLUGIN_NAME_LEN];
+	u32   deviceInfo[VMXNET3_PLUGIN_INFO_LEN];	/* opaque data returned
+							 * by PF driver */
+	u64       memioAddr;
+	u32   memioLen;
+};
+
+#endif /*  _NPA_DEFS_H */
diff --git a/drivers/net/vmxnet3/npa_plugin_api.h
b/drivers/net/vmxnet3/npa_plugin_api.h
new file mode 100644
index 0000000..11255c2
--- /dev/null
+++ b/drivers/net/vmxnet3/npa_plugin_api.h
@@ -0,0 +1,473 @@
+/*
+ * Network Plugin Architecture - Plugin API.
+ *
+ * Copyright (C) 2008-2010, VMware, Inc. All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms of the GNU General Public License as published by
the
+ * Free Software Foundation; version 2 of the License and no later
version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT. See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
USA.
+ *
+ * The full GNU General Public License is included in this distribution
in
+ * the file called "COPYING".
+ *
+ * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ *
+ */
+
+#ifndef _PLUGIN_API_H
+#define _PLUGIN_API_H
+
+#include "npa_defs.h"
+#include "npa_shell_api.h"
+
+struct Plugin_RxQueueState {
+	struct Shell_RxQueueHandle *handle;
+	u8   *ringBaseVA;
+	u64   ringBasePA;
+	u32   ringLength;   /* length in bytes */
+	u32   ringSize;     /* # of descriptors/pkts */
+};
+
+struct Plugin_TxQueueState {
+	struct Shell_TxQueueHandle *handle;
+	u8   *ringBaseVA;
+	u64   ringBasePA;
+	u32   ringLength;   /* length in bytes */
+	u32   ringSize;     /* # of descriptors/pkts */
+};
+
+#define PLUGIN_MAX_RX_QUEUES     16  /* from vmxnet3_defs.h */
+#define PLUGIN_MAX_TX_QUEUES     8
+#define PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE 4
+
+/* value 'ringOffset' range: [0, 4x the # descriptors) */
+#define PLUGIN_SHADOW_ALLOCATION_MULTIPLE  4
+
+/* 512-byte alignment for each ring */
+#define PLUGIN_SHADED_AREA_TX_ALLOCATION_ALIGN     512
+
+/* # of rings to allocate space for */
+#define PLUGIN_SHADED_AREA_TX_ALLOCATION_MULTIPLE    4
+
+/* bytes allocated per desciptor */
+#define PLUGIN_SHADED_AREA_TX_MAX_DESC_SIZE_BYTES   16
+
+/* add 4K extra bytes */
+#define PLUGIN_SHADED_AREA_TX_EXTRA_ALLOCATION    4096
+
+/* 512-byte alignment for each ring */
+#define PLUGIN_SHADED_AREA_RX_ALLOCATION_ALIGN     512
+
+/* # of rings to allocate space for */
+#define PLUGIN_SHADED_AREA_RX_ALLOCATION_MULTIPLE    4
+
+/* bytes allocated per desciptor */
+#define PLUGIN_SHADED_AREA_RX_MAX_DESC_SIZE_BYTES   16
+
+/* add 4K extra bytes */
+#define PLUGIN_SHADED_AREA_RX_EXTRA_ALLOCATION    4096
+
+#define PLUGIN_FEATURES_LRO   0x00000001
+
+struct Plugin_State {
+	u32               size;
+	u32               majorVersion;
+	u32               minorVersion;
+	u32               offsetToPrivateSpace;
+	u32               features;
+	u32               deviceInfo[VMXNET3_PLUGIN_INFO_LEN];
+	void              *memioAddr;
+	u32               memioAddrLen;
+	u32               mtu;
+	u32               numRxQueues;
+	u32               numTxQueues;
+	u8                updateRxProd;
+	struct Plugin_RxQueueState  rxQueues[PLUGIN_MAX_RX_QUEUES];
+	struct Plugin_TxQueueState  txQueues[PLUGIN_MAX_TX_QUEUES];
+	void              *shared;
+	u32               sharedLen;
+	struct Shell_Api  shellApi;
+	u64               privateSpace[512];
+};
+
+#ifndef INLINE
+#define INLINE inline
+#endif
+
+static INLINE void*
+PLUGIN_PRIVATE(struct Plugin_State *plugin)
+{
+	return (u8 *)plugin + plugin->offsetToPrivateSpace;
+}
+
+struct Plugin_SendInfo {
+	u32   ipHeaderOffset; /*  valid if 'ipv4' or 'ipv6' */
+	u32   l4HeaderOffset; /*  valid if 'ipv4' or 'ipv6' */
+	u32   l4DataOffset;   /*  valid if ('ipv4' or 'ipv6') and
+			       * ('tcp' or 'udp') */
+	bool     ipv4;
+	bool     ipv6;
+	bool     tcp;
+	bool     udp;
+
+	bool     tso;
+	u32   tsoMss;        /*  valid if 'tso' is set */
+
+	bool     xsumTcpOrUdp;  /*  valid if 'tcp' or 'udp' */
+
+	bool     vlan;
+	u16   vlanTag;       /* vlan id+priority bits; valid if 'vlan' is set
*/
+};
+
+struct Plugin_SgElement {
+	u64   pa;
+	u32   length;
+};
+
+/*
+ * If IPv4 or IPv6 then headers are contiguous in
+ * first SG, up to 128-bytes.  TSO frames, and only TSO frames,
+ * are contiguous beyond 128 bytes (on Linux model is TBD).
+ */
+
+struct Plugin_SgList {
+	u32 totalLength;
+	u32 numElements;
+	u8 *firstSgVA;
+	struct Plugin_SgElement *elements;
+};
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_SwInit --
+ *
+ *    Initialize the s/w state of the plugin. The h/w should not be
initialized
+ *    through this function. This function is called before any other
plugin API
+ *    is called by the shell (except for api exchange function).
+ *
+ *    called during: device/plugin init.
+ *    concurrent with: nothing
+ *    caller provides: info about configuration and environment
+ *    callee performs: verify data provided by shell
+ *              init private state (e.g. head/tail pointers, location
of rings)
+ *    callee can call: nothing.  callee should not touch hardware and
accesses
+ *		to shared memory should be avoided.
+ * Result:
+ *    0 for success; non-zero for failure
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_SwInit(struct Plugin_State *plugin);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_ReinitRxRing --
+ *
+ *    Initialize the rx ring data structures
+ *
+ *    called during: device/plugin init.
+ *                   device halt
+ *                   during a reset (e.g., RSS change, or OS request)
+ *    concurrent with: nothing.  Function is called only while device
is
+ *		quiesced and the queue is known to be empty.
+ *    caller provides: state and queue #
+ *    callee performs: bzero rings and reinit head/tail
pointers/registers
+ *              should not return any buffers that are found, and
assume have
+ *              already been garbage collected.
+ *    callee can call: nothing.  callee can write to, but not read
from,
+ *              registers and/or memory.
+ *
+ *  Result:
+ *    zero (essentially void)
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_ReinitRxRing(struct Plugin_State *plugin, u32
queue);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_ReinitTxRing --
+ *
+ *    Initialize the tx ring data structures
+ *
+ *    called during: device/plugin init.
+ *                   device halt
+ *                   during a reset (e.g., RSS change, or OS request)
+ *    concurrent with: nothing.  Function is called only while device
is
+ *		quiesced and the queue is known to be empty.
+ *    caller provides: state and queue #
+ *    callee performs: bzero rings and reinit head/tail
pointers/registers
+ *              should not complete any sends, and assume have
+ *              already been garbage collected.
+ *    callee can call: nothing.  callee can write to, but not read
from,
+ *              registers and/or memory.
+ *
+ *  Result:
+ *    zero (essentially void)
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_ReinitTxRing(struct Plugin_State *plugin, u32
queue);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_EnableInterrupt --
+ *
+ *    Enable the interrupt indicated by 'intrIdx'
+ *
+ *    called during: device/plugin init.
+ *                   ISR/DPC, to enable interrupts
+ *                   OS request (including PM)
+ *                   during a reset (e.g., RSS change, or OS request)
+ *    concurrent with: Plugin_AddBuffersToRxRing()
+ *                     Plugin_CheckRxRing()
+ *                     Plugin_AddFrameToTxRing()
+ *                     Plugin_CheckTxRing()
+ *                     Plugin_DisableInterrupt()
+ *    caller provides: state and vector # (note is not queue #)
+ *    callee performs: enable interrupt for vector
+ *    callee can call: nothing
+ *
+ * Result:
+ *    zero (essentially void)
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_EnableInterrupt(struct Plugin_State *plugin, u32
intrIdx);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_DisableInterrupt --
+ *
+ *    Disable the interrupt indicated by 'intrIdx'
+ *
+ *    called during: ISR to disable interrupts
+ *                   OS request (including PM)
+ *                   during a reset (e.g., RSS change, or OS request)
+ *                   halt / shutdown
+ *    concurrent with: Plugin_AddBuffersToRxRing()
+ *                     Plugin_CheckRxRing()
+ *                     Plugin_AddFrameToTxRing()
+ *                     Plugin_CheckTxRing()
+ *                     Plugin_EnableInterrupt()
+ *    caller provides: state and vector # (note is not queue #)
+ *    callee performs: disalbe interrupt for vector
+ *    callee can call: nothing
+ *
+ * Result:
+ *    zero (essentially void)
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_DisableInterrupt(struct Plugin_State *plugin, u32
intrIdx);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_AddFrameToTxRing --
+ *
+ *    Add the frame made up of buffers in the sg list 'frame' to the
hardware tx
+ *    ring of the given queue. The offload information is passed in
'info'.
+ *    'lastPktHint' is used to indicate that no more tx packets would
be passed
+ *    down in this context and the plugin should use this as a hint to
write to
+ *    the h/w doorbell.
+ *
+ *    called during: ISR/DPC, after ring check
+ *                   OS transmit issued for a frame
+ *    concurrent with: Plugin_CheckTxRing()
+ *                     Plugin_EnableInterrupt()
+ *                     Plugin_DisableInterrupt()
+ *    caller provides: state and queue #
+ *	       information about frame (including frame type and header
offsets)
+ *             SG array of frame buffers, all eth/ip/tcp/udp headers in
first SG
+ *    callee performs: attempt to add frame to tx ring
+ *    callee can call: nothing
+ *
+ * Result:
+ *    0 if successful, 1 to indicate no space in h/w tx ring
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_AddFrameToTxRing(struct Plugin_State *plugin, u32
queue,
+				    const struct Plugin_SendInfo *info,
+				    const struct Plugin_SgList *frame,
+				    bool lastPktHint);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_CheckTxRing --
+ *
+ *    Check the tx ring for the given queue for any tx completions.
+ *    This call is made by the shell either during the interrupt or
DPC/napi
+ *    context.
+ *
+ *    called during: ISR/DPC
+ *    concurrent with: Plugin_AddFrameToTxRing()
+ *                     Plugin_EnableInterrupt()
+ *                     Plugin_DisableInterrupt()
+ *    caller provides: state and queue #
+ *    callee performs: checks ring for any completed sends, and returns
them
+ *    callee can call: Shell_CompleteSend()
+ *
+ * Result:
+ *    zero (essentially void)
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_CheckTxRing(struct Plugin_State *plugin, u32 queue);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_CheckRxRing --
+ *
+ *    Check the rx ring for any incoming packets on the given queue.
+ *    'maxPkts' indicate the maximum number of packets the plugin can
indicate
+ *    upto the shell in this context. The shell calls this function
during the
+ *    interrupt or DPC/napi context.
+ *
+ *    called during: ISR/DPC
+ *    concurrent with: Plugin_AddBuffersToRxRing()
+ *                     Plugin_EnableInterrupt()
+ *                     Plugin_DisableInterrupt()
+ *    caller provides: state and queue #
+ *                     max # of frames to indicate in one call
+ *    callee performs: checks ring for any receives, and indicates them
up.
+ *                     Callee can/should indicate up frames with bad
checksums,
+ *                     but should not indicate runts, truncated frames,
bad CRCs
+ *                     or other types of bad frames.
+ *    callee can call: Shell_IndicateRecv()
+ *                     Shell_FreeBuffer()
+ *
+ * Result:
+ *    1 to indicate need for buffers, 0 for no need for buffers.
+ *
+ * Side-effects:
+ *    Packets are indicated up and delivered to the OS stack during
this call.
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_CheckRxRing(struct Plugin_State *plugin, u32 queue,
+			       u32 maxPkts);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Plugin_AddBuffersToRxRing --
+ *
+ *    The plugin can make calls to the shell to allocate more buffers.
This call
+ *    is made during the plugin initialization or after
Plugin_CheckRxRing or
+ *    when the OS stack returns buffers back to the shell. The plugin
should try
+ *    to allocate as many buffers as needed to fill the h/w rings.
+ *
+ *    called during: device/plugin init.
+ *                   ISR/DPC, after Plugin_CheckRxRing()
+ *                   OS returns buffers (if applicable for OS)
+ *    concurrent with: Plugin_CheckRxRing()
+ *                     Plugin_EnableInterrupt()
+ *                     Plugin_DisableInterrupt()
+ *    caller provides: state and queue #
+ *    callee performs: add empty buffers to rx ring(s), as much as
possible
+ *                     touch device registers, if applicable
+ *    callee can call: Shell_AllocSmallBuffer()
+ *                     Shell_AllocLargeBuffer()
+ *                     Shell_FreeBuffer()
+ *
+ * Result:
+ *    zero (essentially void)
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Plugin_AddBuffersToRxRing(struct Plugin_State *plugin, u32
queue);
+
+struct Plugin_Api {
+	Plugin_SwInit              *swInit;
+	Plugin_ReinitRxRing        *reinitRxRing;
+	Plugin_ReinitTxRing        *reinitTxRing;
+	Plugin_EnableInterrupt     *enableInterrupt;
+	Plugin_DisableInterrupt    *disableInterrupt;
+	Plugin_AddFrameToTxRing    *addFrameToTxRing;
+	Plugin_CheckTxRing         *checkTxRing;
+	Plugin_CheckRxRing         *checkRxRing;
+	Plugin_AddBuffersToRxRing  *addBuffersToRxRing;
+};
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * NPA_PluginMain --
+ *
+ *    This is the first function that the shell calls into the plugin
and is
+ *    used to obtain the plugin API function pointer for further
communication.
+ *
+ * Result:
+ *    Plugin_Api function table filled with the plugin api functions.
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 NPA_PluginMainFunc(struct Plugin_Api *pluginApi);
+NPA_PluginMainFunc NPA_PluginMain;
+
+#endif /*  _PLUGIN_API_H */
diff --git a/drivers/net/vmxnet3/npa_shell_api.h
b/drivers/net/vmxnet3/npa_shell_api.h
new file mode 100644
index 0000000..6f9e19c
--- /dev/null
+++ b/drivers/net/vmxnet3/npa_shell_api.h
@@ -0,0 +1,234 @@
+/*
+ * Network Plugin Architecture - Shell API.
+ *
+ * Copyright (C) 2008-2010, VMware, Inc. All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms of the GNU General Public License as published by
the
+ * Free Software Foundation; version 2 of the License and no later
version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT. See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
USA.
+ *
+ * The full GNU General Public License is included in this distribution
in
+ * the file called "COPYING".
+ *
+ * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ *
+ */
+
+#ifndef _SHELL_API_H
+#define _SHELL_API_H
+
+#define SHELL_SMALL_RECV_BUFFER_SIZE         2048
+#define SHELL_LARGE_RECV_BUFFER_SIZE         4096
+
+/*
+ * Plugin should never indicate more than 4 sg's in a rx packet.
+ */
+#define SHELL_MAX_RECV_SG_LEN                4
+
+/*
+ * Over allocate the sg array for future use
+ */
+#define SHELL_MAX_LRO_RECV_SG_LEN            18
+
+#define SHELL_RECV_HASH_FUNCTION_NONE        0
+#define SHELL_RECV_HASH_FUNCTION_TOEPLITZ    1
+
+#define SHELL_RECV_HASH_TYPE_NONE            0
+#define SHELL_RECV_HASH_TYPE_IPV4            1
+#define SHELL_RECV_HASH_TYPE_TCPIPV4         5 /* 1 | 4 */
+#define SHELL_RECV_HASH_TYPE_IPV6            2
+#define SHELL_RECV_HASH_TYPE_TCPIPV6         6 /* 2 | 4 */
+
+#define SHELL_XSUM_UNKNOWN                   0
+#define SHELL_XSUM_CORRECT                   1
+#define SHELL_XSUM_INCORRECT                 2
+
+struct Shell_RxQueueHandle;
+struct Shell_TxQueueHandle;
+
+struct Shell_RecvFrameSG {
+	u32   ringOffset;
+	u32   length;
+	u32   offset;
+};
+
+struct Shell_RecvFrame {
+	u32   sgLength;
+	u32   byteLength;
+	struct Shell_RecvFrameSG sg[SHELL_MAX_LRO_RECV_SG_LEN];
+	bool     perfectFiltered;  /*  indicate if packet exactly
+				    * matches RX filters */
+	bool     vlan;
+	u16   vlanTag;          /* valid if vlan == TRUE */
+	u32   rssHashFunction;
+	u32   rssHashType;      /* valid if rssHashFunction != 0 */
+	u32   rssHashValue;     /* valid if rssHashFunction and
+				 * rssHashType != 0 */
+	bool     ipv4;
+	bool     ipv6;
+	bool     nonIp;
+	bool     tcp;
+	bool     udp;
+	u8    ipXsum;           /*  UNKNOWN , CORRECT , INCORRECT */
+	u8    tcpXsum;          /*  UNKNOWN , CORRECT , INCORRECT */
+	u8    udpXsum;          /*  UNKNOWN , CORRECT , INCORRECT */
+};
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Shell_AllocSmallBuffer --
+ *
+ *    Allocate a 'small' buffer from the shell identified by the
ringOffset.
+ *    ringOffset can range from [0..#descs-for-all-rings] and is used
+ *    by the shell to identify the buffer in the shadow ring maintained
by
+ *    shell.
+ *
+ *    This call can only be made from Plugin_AddBuffersToRxRing
+ *
+ * Result:
+ *    PA of the buffer
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u64 Shell_AllocSmallBuffer(struct Shell_RxQueueHandle *handle,
+				   u32 ringOffset);
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Shell_AllocLargeBuffer --
+ *
+ *    Allocate a 'large' buffer from the shell identified by the
ringOffset.
+ *    ringOffset can range from [0..#descs-for-all-rings] and is used
+ *    by the shell to identify the buffer in the shadow ring maintained
by
+ *    shell.
+ *
+ *    This call can only be made from Plugin_AddBuffersToRxRing
+ *
+ * Result:
+ *    PA of the buffer
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u64 Shell_AllocLargeBuffer(struct Shell_RxQueueHandle *handle,
+				   u32 ringOffset);
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Shell_FreeBuffer --
+ *
+ *    Free the buffer allocated from Shell_Alloc{Small|Large}Buffer
identified
+ *    by the cookie 'ringOffset'
+ *
+ *    This call can be made from
Plugin_CheckRxRing(Plugin_AddBuffersToRxRing?)
+ *
+ * Result:
+ *    None.
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef void Shell_FreeBuffer(struct Shell_RxQueueHandle *handle,
+			      u32 ringOffset);
+
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Shell_CompleteSend --
+ *
+ *    Indicate # of pre-tso tx completion to the shell.
+ *
+ *    This call can only be made from Plugin_CheckTxRing
+ *
+ * Result:
+ *    None.
+ *
+ * Side-effects:
+ *    None
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef void Shell_CompleteSend(struct Shell_TxQueueHandle *handle,
+				u32 numPkts);
+
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Shell_IndicateRecv --
+ *
+ *    Indicate a receive frame to the shell. The buffer ownership is
transferred
+ *    to the shell and the rest of offload information is transferred
along with
+ *    in the RecvFrame
+ *
+ *    This call can only be made from Plugin_CheckRxRing
+ *
+ * Result:
+ *    0 for success, 1 for failure
+ *
+ * Side-effects:
+ *    The buffers are passed up to the OS stack.
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef u32 Shell_IndicateRecv(struct Shell_RxQueueHandle *handle,
+			       struct Shell_RecvFrame *frame);
+
+/*
+
*----------------------------------------------------------------------------
+ *
+ * Shell_Log --
+ *
+ *    Simple logging function.
+ *
+ *    This call can only be made from anyplace (except NPA_PluginMain)
+ *
+ * Result:
+ *    None.
+ *
+ * Side-effects:
+ *    None.
+ *
+
*----------------------------------------------------------------------------
+ */
+
+typedef void Shell_Log(size_t nargs, const char *fmt, ...);
+
+struct Shell_Api {
+	Shell_AllocSmallBuffer  *allocSmallBuffer;
+	Shell_AllocLargeBuffer  *allocLargeBuffer;
+	Shell_FreeBuffer        *freeBuffer;
+	Shell_CompleteSend      *completeSend;
+	Shell_IndicateRecv      *indicateRecv;
+	Shell_Log               *log;
+};
+
+#endif /*  _SHELL_API_H */
diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h
b/drivers/net/vmxnet3/vmxnet3_defs.h
index b4889e6..53341f0 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -76,7 +76,9 @@ enum {
 	VMXNET3_CMD_UPDATE_IML,
 	VMXNET3_CMD_UPDATE_PMCFG,
 	VMXNET3_CMD_UPDATE_FEATURE,
+	VMXNET3_CMD_STOP_EMULATION,
 	VMXNET3_CMD_LOAD_PLUGIN,
+	VMXNET3_CMD_ACTIVATE_VF,
 
 	VMXNET3_CMD_FIRST_GET = 0xF00D0000,
 	VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
b/drivers/net/vmxnet3/vmxnet3_drv.c
index 989b742..417581a 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -44,6 +44,23 @@ MODULE_DEVICE_TABLE(pci, vmxnet3_pciid_table);
 
 static atomic_t devices_found;
 
+#ifndef roundup
+#   define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
+#endif
+
+/*
+ * This is the text segment that'll be used to load HW plugins code.
+ */
+static u8 vmxnet3_plugin_code_mem[NPA_PLUGIN_NUMPAGES * PAGE_SIZE *
+				  NPA_MAX_PLUGINS_PER_VM]
+   __attribute__((aligned(PAGE_SIZE), section(".npatext")));
+/*
+ * The following array (and corresponding spinlock) is used to
+ * allocated code regions.
+ */
+static bool vmxnet3_plugin_code_used[NPA_MAX_PLUGINS_PER_VM];
+static spinlock_t vmxnet3_plugin_code_lock;
+
 
 /*
  *    Enable/Disable the given intr
@@ -51,14 +68,26 @@ static atomic_t devices_found;
 static void
 vmxnet3_enable_intr(struct vmxnet3_adapter *adapter, unsigned intr_idx)
 {
-	VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_IMR + intr_idx * 8, 0);
+	if (adapter->intr.event_intr_idx == intr_idx) {
+		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_IMR + intr_idx * 8,
+				       0);
+	} else {
+		Plugin_EnableInterrupt(adapter, intr_idx);
+	}
+
 }
 
 
 static void
 vmxnet3_disable_intr(struct vmxnet3_adapter *adapter, unsigned
intr_idx)
 {
-	VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_IMR + intr_idx * 8, 1);
+	if (adapter->intr.event_intr_idx == intr_idx) {
+		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_IMR + intr_idx * 8,
+				       1);
+	} else {
+		Plugin_DisableInterrupt(adapter, intr_idx);
+	}
+
 }
 
 
@@ -183,6 +212,19 @@ vmxnet3_process_events(struct vmxnet3_adapter
*adapter)
 
 		schedule_work(&adapter->work);
 	}
+	/* Check if passthru is requested */
+	if (events & VMXNET3_ECR_DIC) {
+		/* XXX: PR 496886, use DID_LO to determine what transition */
+		if (adapter->passthru) {
+			printk(KERN_ERR "%s: DIC: passthru -> emulation\n",
+					adapter->netdev->name);
+			schedule_work(&adapter->work);
+		} else {
+			printk(KERN_ERR "%s: DIC: emulation -> passthru\n",
+					adapter->netdev->name);
+			schedule_work(&adapter->passthru_work);
+		}
+	}
 }
 
 #ifdef __BIG_ENDIAN_BITFIELD
@@ -302,34 +344,31 @@ vmxnet3_unmap_tx_buf(struct vmxnet3_tx_buf_info
*tbi,
 	tbi->map_type = VMXNET3_MAP_NONE; /* to help debugging */
 }
 
-
 static int
-vmxnet3_unmap_pkt(u32 eop_idx, struct vmxnet3_tx_queue *tq,
-		  struct pci_dev *pdev,	struct vmxnet3_adapter *adapter)
+vmxnet3_unmap_pkt(struct vmxnet3_tx_queue *tq, struct pci_dev *pdev,
+		  struct vmxnet3_adapter *adapter)
 {
+	struct vmxnet3_tx_shadow_ring *ring = &tq->shadow_ring;
 	struct sk_buff *skb;
+	u32 eop_idx;
 	int entries = 0;
 
-	/* no out of order completion */
-	BUG_ON(tq->buf_info[eop_idx].sop_idx != tq->tx_ring.next2comp);
-	BUG_ON(VMXNET3_TXDESC_GET_EOP(&(tq->tx_ring.base[eop_idx].txd)) != 1);
-
-	skb = tq->buf_info[eop_idx].skb;
+	eop_idx = ring->base[ring->next2comp].eop_idx;
+	dev_dbg(&adapter->pdev->dev, "tx complete [%u %u]\n",
+		ring->next2comp, eop_idx);
+	skb = ring->base[ring->next2comp].skb;
 	BUG_ON(skb == NULL);
-	tq->buf_info[eop_idx].skb = NULL;
-
-	VMXNET3_INC_RING_IDX_ONLY(eop_idx, tq->tx_ring.size);
+	ring->base[ring->next2comp].skb = NULL;
 
-	while (tq->tx_ring.next2comp != eop_idx) {
-		vmxnet3_unmap_tx_buf(tq->buf_info + tq->tx_ring.next2comp,
-				     pdev);
+	while (ring->next2comp != eop_idx) {
+		vmxnet3_unmap_tx_buf(ring->base + ring->next2comp, pdev);
 
 		/* update next2comp w/o tx_lock. Since we are marking more,
 		 * instead of less, tx ring entries avail, the worst case is
 		 * that the tx routine incorrectly re-queues a pkt due to
 		 * insufficient tx ring entries.
 		 */
-		vmxnet3_cmd_ring_adv_next2comp(&tq->tx_ring);
+		vmxnet3_tx_shadow_ring_adv_next2comp(ring);
 		entries++;
 	}
 
@@ -337,125 +376,84 @@ vmxnet3_unmap_pkt(u32 eop_idx, struct
vmxnet3_tx_queue *tq,
 	return entries;
 }
 
-
-static int
-vmxnet3_tq_tx_complete(struct vmxnet3_tx_queue *tq,
-			struct vmxnet3_adapter *adapter)
-{
-	int completed = 0;
-	union Vmxnet3_GenericDesc *gdesc;
-
-	gdesc = tq->comp_ring.base + tq->comp_ring.next2proc;
-	while (VMXNET3_TCD_GET_GEN(&gdesc->tcd) == tq->comp_ring.gen) {
-		completed += vmxnet3_unmap_pkt(VMXNET3_TCD_GET_TXIDX(
-					       &gdesc->tcd), tq, adapter->pdev,
-					       adapter);
-
-		vmxnet3_comp_ring_adv_next2proc(&tq->comp_ring);
-		gdesc = tq->comp_ring.base + tq->comp_ring.next2proc;
-	}
-
-	if (completed) {
-		spin_lock(&tq->tx_lock);
-		if (unlikely(vmxnet3_tq_stopped(tq, adapter) &&
-			     vmxnet3_cmd_ring_desc_avail(&tq->tx_ring) >
-			     VMXNET3_WAKE_QUEUE_THRESHOLD(tq) &&
-			     netif_carrier_ok(adapter->netdev))) {
-			vmxnet3_tq_wake(tq, adapter);
-		}
-		spin_unlock(&tq->tx_lock);
-	}
-	return completed;
-}
-
-
 static void
 vmxnet3_tq_cleanup(struct vmxnet3_tx_queue *tq,
 		   struct vmxnet3_adapter *adapter)
 {
 	int i;
+	struct vmxnet3_tx_shadow_ring *ring = &tq->shadow_ring;
 
-	while (tq->tx_ring.next2comp != tq->tx_ring.next2fill) {
+	while (ring->next2comp != ring->next2fill) {
 		struct vmxnet3_tx_buf_info *tbi;
-		union Vmxnet3_GenericDesc *gdesc;
-
-		tbi = tq->buf_info + tq->tx_ring.next2comp;
-		gdesc = tq->tx_ring.base + tq->tx_ring.next2comp;
 
+		tbi = ring->base + ring->next2comp;
 		vmxnet3_unmap_tx_buf(tbi, adapter->pdev);
 		if (tbi->skb) {
 			dev_kfree_skb_any(tbi->skb);
 			tbi->skb = NULL;
 		}
-		vmxnet3_cmd_ring_adv_next2comp(&tq->tx_ring);
+		vmxnet3_tx_shadow_ring_adv_next2comp(ring);
 	}
 
 	/* sanity check, verify all buffers are indeed unmapped and freed */
-	for (i = 0; i < tq->tx_ring.size; i++) {
-		BUG_ON(tq->buf_info[i].skb != NULL ||
-		       tq->buf_info[i].map_type != VMXNET3_MAP_NONE);
+	for (i = 0; i < ring->size; i++) {
+		BUG_ON(ring->base[i].skb != NULL ||
+		       ring->base[i].map_type != VMXNET3_MAP_NONE);
 	}
 
-	tq->tx_ring.gen = VMXNET3_INIT_GEN;
-	tq->tx_ring.next2fill = tq->tx_ring.next2comp = 0;
-
-	tq->comp_ring.gen = VMXNET3_INIT_GEN;
-	tq->comp_ring.next2proc = 0;
+	ring->next2fill = ring->next2comp = 0;
 }
 
 
+
+
 void
 vmxnet3_tq_destroy(struct vmxnet3_tx_queue *tq,
 		   struct vmxnet3_adapter *adapter)
 {
-	if (tq->tx_ring.base) {
-		pci_free_consistent(adapter->pdev, tq->tx_ring.size *
-				    sizeof(struct Vmxnet3_TxDesc),
-				    tq->tx_ring.base, tq->tx_ring.basePA);
-		tq->tx_ring.base = NULL;
+	if (tq->plugin_tq->ringBaseVA) {
+		pci_free_consistent(adapter->pdev, tq->plugin_tq->ringLength,
+				    tq->plugin_tq->ringBaseVA,
+				    tq->plugin_tq->ringBasePA);
+		tq->plugin_tq->ringBaseVA = NULL;
+		tq->plugin_tq->ringBasePA = 0;
 	}
+
 	if (tq->data_ring.base) {
 		pci_free_consistent(adapter->pdev, tq->data_ring.size *
 				    sizeof(struct Vmxnet3_TxDataDesc),
 				    tq->data_ring.base, tq->data_ring.basePA);
 		tq->data_ring.base = NULL;
 	}
-	if (tq->comp_ring.base) {
-		pci_free_consistent(adapter->pdev, tq->comp_ring.size *
-				    sizeof(struct Vmxnet3_TxCompDesc),
-				    tq->comp_ring.base, tq->comp_ring.basePA);
-		tq->comp_ring.base = NULL;
+	if (tq->shadow_ring.base) {
+		vfree(tq->shadow_ring.base);
+		tq->shadow_ring.base = NULL;
 	}
-	kfree(tq->buf_info);
-	tq->buf_info = NULL;
+	kfree(tq->sg_list.elements);
+	tq->sg_list.elements = NULL;
 }
 
-
 static void
 vmxnet3_tq_init(struct vmxnet3_tx_queue *tq,
 		struct vmxnet3_adapter *adapter)
 {
 	int i;
 
-	/* reset the tx ring contents to 0 and reset the tx ring states */
-	memset(tq->tx_ring.base, 0, tq->tx_ring.size *
-	       sizeof(struct Vmxnet3_TxDesc));
-	tq->tx_ring.next2fill = tq->tx_ring.next2comp = 0;
-	tq->tx_ring.gen = VMXNET3_INIT_GEN;
-
+	/* reset the data ring contents to 0 and reset the data ring
+	 * states
+	 */
+	tq->data_ring.next2fill = 0;
+	tq->data_ring.next2comp = 0;
 	memset(tq->data_ring.base, 0, tq->data_ring.size *
-	       sizeof(struct Vmxnet3_TxDataDesc));
-
-	/* reset the tx comp ring contents to 0 and reset comp ring states */
-	memset(tq->comp_ring.base, 0, tq->comp_ring.size *
-	       sizeof(struct Vmxnet3_TxCompDesc));
-	tq->comp_ring.next2proc = 0;
-	tq->comp_ring.gen = VMXNET3_INIT_GEN;
+			sizeof(struct Vmxnet3_TxDataDesc));
 
 	/* reset the bookkeeping data */
-	memset(tq->buf_info, 0, sizeof(tq->buf_info[0]) * tq->tx_ring.size);
-	for (i = 0; i < tq->tx_ring.size; i++)
-		tq->buf_info[i].map_type = VMXNET3_MAP_NONE;
+	tq->shadow_ring.next2fill = 0;
+	tq->shadow_ring.next2comp = 0;
+	memset(tq->shadow_ring.base, 0, tq->shadow_ring.size *
+			sizeof(struct vmxnet3_tx_shadow_ring));
+	for (i = 0; i < tq->shadow_ring.size; i++)
+		tq->shadow_ring.base[i].map_type = VMXNET3_MAP_NONE;
 
 	/* stats are not reset */
 }
@@ -465,18 +463,35 @@ static int
 vmxnet3_tq_create(struct vmxnet3_tx_queue *tq,
 		  struct vmxnet3_adapter *adapter)
 {
-	BUG_ON(tq->tx_ring.base || tq->data_ring.base ||
-	       tq->comp_ring.base || tq->buf_info);
+	u32 ring_length;
+
+	BUG_ON(tq->plugin_tq->ringBaseVA || tq->data_ring.base ||
+	       tq->shadow_ring.base || tq->sg_list.elements);
 
-	tq->tx_ring.base = pci_alloc_consistent(adapter->pdev,
tq->tx_ring.size
-			   * sizeof(struct Vmxnet3_TxDesc),
-			   &tq->tx_ring.basePA);
-	if (!tq->tx_ring.base) {
+	/*
+	 * We don't know the underlying hardware's descriptor size,
+	 * thus use the maximum allowed descriptor size.
+	 */
+	ring_length = tq->plugin_tq->ringSize *
+		PLUGIN_SHADED_AREA_TX_MAX_DESC_SIZE_BYTES;
+	/* Add room for potential alignment */
+	ring_length += PLUGIN_SHADED_AREA_TX_ALLOCATION_ALIGN - 1;
+	/*
+	 * Again, we don't know the underlying hardware's mode of
+	 * operation, so let's give room for multiple rings.
+	 */
+	tq->plugin_tq->ringLength = PLUGIN_SHADED_AREA_TX_ALLOCATION_MULTIPLE
*
+		ring_length + PLUGIN_SHADED_AREA_TX_EXTRA_ALLOCATION;
+	tq->plugin_tq->ringBaseVA = pci_alloc_consistent(adapter->pdev,
+				      tq->plugin_tq->ringLength,
+				      (dma_addr_t *)&tq->plugin_tq->ringBasePA);
+	if (!tq->plugin_tq->ringBaseVA) {
 		printk(KERN_ERR "%s: failed to allocate tx ring\n",
 		       adapter->netdev->name);
 		goto err;
 	}
 
+
 	tq->data_ring.base = pci_alloc_consistent(adapter->pdev,
 			     tq->data_ring.size *
 			     sizeof(struct Vmxnet3_TxDataDesc),
@@ -487,20 +502,22 @@ vmxnet3_tq_create(struct vmxnet3_tx_queue *tq,
 		goto err;
 	}
 
-	tq->comp_ring.base = pci_alloc_consistent(adapter->pdev,
-			     tq->comp_ring.size *
-			     sizeof(struct Vmxnet3_TxCompDesc),
-			     &tq->comp_ring.basePA);
-	if (!tq->comp_ring.base) {
-		printk(KERN_ERR "%s: failed to allocate tx comp ring\n",
+	tq->shadow_ring.size =
+		VMXNET3_TX_SHADOW_RING_SIZE(tq->plugin_tq->ringSize);
+	tq->shadow_ring.base = vmalloc(tq->shadow_ring.size *
+				       sizeof(struct vmxnet3_tx_buf_info));
+	if (!tq->shadow_ring.base) {
+		printk(KERN_ERR "%s: failed to allocate tx shadow ring\n",
+
 		       adapter->netdev->name);
 		goto err;
 	}
 
-	tq->buf_info = kcalloc(tq->tx_ring.size, sizeof(tq->buf_info[0]),
-			       GFP_KERNEL);
-	if (!tq->buf_info) {
-		printk(KERN_ERR "%s: failed to allocate tx bufinfo\n",
+	tq->sg_list.elements = kcalloc(VMXNET3_SGLIST_MAX,
+				       sizeof(struct Plugin_SgElement),
+				       GFP_KERNEL);
+	if (!tq->sg_list.elements) {
+		printk(KERN_ERR "%s: failed to allocate tx sglist\n",
 		       adapter->netdev->name);
 		goto err;
 	}
@@ -513,89 +530,8 @@ err:
 }
 
 
-/*
- *    starting from ring->next2fill, allocate rx buffers for the given
ring
- *    of the rx queue and update the rx desc. stop after @num_to_alloc
buffers
- *    are allocated or allocation fails
- */
-
-static int
-vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
-			int num_to_alloc, struct vmxnet3_adapter *adapter)
-{
-	int num_allocated = 0;
-	struct vmxnet3_rx_buf_info *rbi_base = rq->buf_info[ring_idx];
-	struct vmxnet3_cmd_ring *ring = &rq->rx_ring[ring_idx];
-	u32 val;
-
-	while (num_allocated < num_to_alloc) {
-		struct vmxnet3_rx_buf_info *rbi;
-		union Vmxnet3_GenericDesc *gd;
-
-		rbi = rbi_base + ring->next2fill;
-		gd = ring->base + ring->next2fill;
-
-		if (rbi->buf_type == VMXNET3_RX_BUF_SKB) {
-			if (rbi->skb == NULL) {
-				rbi->skb = dev_alloc_skb(rbi->len +
-							 NET_IP_ALIGN);
-				if (unlikely(rbi->skb == NULL)) {
-					rq->stats.rx_buf_alloc_failure++;
-					break;
-				}
-				rbi->skb->dev = adapter->netdev;
-
-				skb_reserve(rbi->skb, NET_IP_ALIGN);
-				rbi->dma_addr = pci_map_single(adapter->pdev,
-						rbi->skb->data, rbi->len,
-						PCI_DMA_FROMDEVICE);
-			} else {
-				/* rx buffer skipped by the device */
-			}
-			val = VMXNET3_RXD_BTYPE_HEAD << VMXNET3_RXD_BTYPE_SHIFT;
-		} else {
-			BUG_ON(rbi->buf_type != VMXNET3_RX_BUF_PAGE ||
-			       rbi->len  != PAGE_SIZE);
-
-			if (rbi->page == NULL) {
-				rbi->page = alloc_page(GFP_ATOMIC);
-				if (unlikely(rbi->page == NULL)) {
-					rq->stats.rx_buf_alloc_failure++;
-					break;
-				}
-				rbi->dma_addr = pci_map_page(adapter->pdev,
-						rbi->page, 0, PAGE_SIZE,
-						PCI_DMA_FROMDEVICE);
-			} else {
-				/* rx buffers skipped by the device */
-			}
-			val = VMXNET3_RXD_BTYPE_BODY << VMXNET3_RXD_BTYPE_SHIFT;
-		}
-
-		BUG_ON(rbi->dma_addr == 0);
-		gd->rxd.addr = cpu_to_le64(rbi->dma_addr);
-		gd->dword[2] = cpu_to_le32((ring->gen << VMXNET3_RXD_GEN_SHIFT)
-					   | val | rbi->len);
-
-		num_allocated++;
-		vmxnet3_cmd_ring_adv_next2fill(ring);
-	}
-	rq->uncommitted[ring_idx] += num_allocated;
-
-	dev_dbg(&adapter->netdev->dev,
-		"alloc_rx_buf: %d allocated, next2fill %u, next2comp "
-		"%u, uncommited %u\n", num_allocated, ring->next2fill,
-		ring->next2comp, rq->uncommitted[ring_idx]);
-
-	/* so that the device can distinguish a full ring and an empty ring */
-	BUG_ON(num_allocated != 0 && ring->next2fill == ring->next2comp);
-
-	return num_allocated;
-}
-
-
 static void
-vmxnet3_append_frag(struct sk_buff *skb, struct Vmxnet3_RxCompDesc
*rcd,
+vmxnet3_append_frag(struct sk_buff *skb, struct Shell_RecvFrameSG *sg,
 		    struct vmxnet3_rx_buf_info *rbi)
 {
 	struct skb_frag_struct *frag = skb_shinfo(skb)->frags +
@@ -604,120 +540,88 @@ vmxnet3_append_frag(struct sk_buff *skb, struct
Vmxnet3_RxCompDesc *rcd,
 	BUG_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS);
 
 	frag->page = rbi->page;
-	frag->page_offset = 0;
-	frag->size = rcd->len;
+	frag->page_offset = sg->offset;
+	if (sg->offset != 0)
+		printk(KERN_INFO "sg->offset:%d\n", sg->offset);
+	frag->size = sg->length;
+
 	skb->data_len += frag->size;
 	skb_shinfo(skb)->nr_frags++;
 }
 
-
 static void
-vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
-		struct vmxnet3_tx_queue *tq, struct pci_dev *pdev,
-		struct vmxnet3_adapter *adapter)
+vmxnet3_map_pkt(struct sk_buff *skb, u32 copy_size,
+		struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
 {
-	u32 dw2, len;
-	unsigned long buf_offset;
-	int i;
-	union Vmxnet3_GenericDesc *gdesc;
 	struct vmxnet3_tx_buf_info *tbi = NULL;
+	struct vmxnet3_tx_buf_info *sop_tbi = NULL;
+	struct Plugin_SgList *sg_list = &tq->sg_list;
+	u32 idx = 0;
+	int i;
 
-	BUG_ON(ctx->copy_size > skb_headlen(skb));
-
-	/* use the previous gen bit for the SOP desc */
-	dw2 = (tq->tx_ring.gen ^ 0x1) << VMXNET3_TXD_GEN_SHIFT;
-
-	ctx->sop_txd = tq->tx_ring.base + tq->tx_ring.next2fill;
-	gdesc = ctx->sop_txd; /* both loops below can be skipped */
+	BUG_ON(copy_size > skb_headlen(skb));
+	sop_tbi = tq->shadow_ring.base + tq->shadow_ring.next2fill;
 
 	/* no need to map the buffer if headers are copied */
-	if (ctx->copy_size) {
-		ctx->sop_txd->txd.addr = cpu_to_le64(tq->data_ring.basePA +
-					tq->tx_ring.next2fill *
-					sizeof(struct Vmxnet3_TxDataDesc));
-		ctx->sop_txd->dword[2] = cpu_to_le32(dw2 | ctx->copy_size);
-		ctx->sop_txd->dword[3] = 0;
-
-		tbi = tq->buf_info + tq->tx_ring.next2fill;
+	if (copy_size) {
+		tbi = tq->shadow_ring.base + tq->shadow_ring.next2fill;
+		tbi->skb = NULL;
 		tbi->map_type = VMXNET3_MAP_NONE;
-
-		dev_dbg(&adapter->netdev->dev,
-			"txd[%u]: 0x%Lx 0x%x 0x%x\n",
-			tq->tx_ring.next2fill,
-			le64_to_cpu(ctx->sop_txd->txd.addr),
-			ctx->sop_txd->dword[2], ctx->sop_txd->dword[3]);
-		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
-
-		/* use the right gen for non-SOP desc */
-		dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
+		tbi->len = 0;
+		tbi->dma_addr = 0;
+		sg_list->elements[idx].pa = tq->data_ring.basePA +
+					    tq->data_ring.next2fill *
+					    sizeof(struct Vmxnet3_TxDataDesc);
+		sg_list->elements[idx].length = copy_size;
+		idx++;
+		vmxnet3_tx_shadow_ring_adv_next2fill(&tq->shadow_ring);
 	}
 
-	/* linear part can use multiple tx desc if it's big */
-	len = skb_headlen(skb) - ctx->copy_size;
-	buf_offset = ctx->copy_size;
-	while (len) {
-		u32 buf_size;
 
-		buf_size = len > VMXNET3_MAX_TX_BUF_SIZE ?
-			   VMXNET3_MAX_TX_BUF_SIZE : len;
-
-		tbi = tq->buf_info + tq->tx_ring.next2fill;
+	/*
+	 * linear part can use multiple tx desc in the plugin if it's
+	 * big, but only one in the shadow/data ring
+	 */
+	if (skb_headlen(skb) > copy_size) {
+		tbi = tq->shadow_ring.base + tq->shadow_ring.next2fill;
+		tbi->skb = NULL;
 		tbi->map_type = VMXNET3_MAP_SINGLE;
+		tbi->len = skb_headlen(skb) - copy_size;
 		tbi->dma_addr = pci_map_single(adapter->pdev,
-				skb->data + buf_offset, buf_size,
+				skb->data + copy_size, tbi->len,
 				PCI_DMA_TODEVICE);
 
-		tbi->len = buf_size; /* this automatically convert 2^14 to 0 */
+		sg_list->elements[idx].pa = tbi->dma_addr;
+		sg_list->elements[idx].length = tbi->len;
+		idx++;
 
-		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
-		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
-
-		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
-		gdesc->dword[2] = cpu_to_le32(dw2 | buf_size);
-		gdesc->dword[3] = 0;
-
-		dev_dbg(&adapter->netdev->dev,
-			"txd[%u]: 0x%Lx 0x%x 0x%x\n",
-			tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
-			le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
-		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
-		dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
-
-		len -= buf_size;
-		buf_offset += buf_size;
+		vmxnet3_tx_shadow_ring_adv_next2fill(&tq->shadow_ring);
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
 
-		tbi = tq->buf_info + tq->tx_ring.next2fill;
+		tbi = tq->shadow_ring.base + tq->shadow_ring.next2fill;
+		tbi->skb = NULL;
 		tbi->map_type = VMXNET3_MAP_PAGE;
+		tbi->len = frag->size;
 		tbi->dma_addr = pci_map_page(adapter->pdev, frag->page,
 					     frag->page_offset, frag->size,
 					     PCI_DMA_TODEVICE);
 
-		tbi->len = frag->size;
-
-		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
-		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
+		sg_list->elements[idx].pa = tbi->dma_addr;
+		sg_list->elements[idx].length = tbi->len;
+		idx++;
 
-		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
-		gdesc->dword[2] = cpu_to_le32(dw2 | frag->size);
-		gdesc->dword[3] = 0;
-
-		dev_dbg(&adapter->netdev->dev,
-			"txd[%u]: 0x%llu %u %u\n",
-			tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
-			le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
-		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
-		dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
+		vmxnet3_tx_shadow_ring_adv_next2fill(&tq->shadow_ring);
 	}
 
-	ctx->eop_txd = gdesc;
-
 	/* set the last buf_info for the pkt */
-	tbi->skb = skb;
-	tbi->sop_idx = ctx->sop_txd - tq->tx_ring.base;
+	sop_tbi->skb = skb;
+	sop_tbi->eop_idx = tq->shadow_ring.next2fill;
+	BUG_ON(idx >= VMXNET3_SGLIST_MAX);
+	sg_list->numElements = idx;
+	sg_list->totalLength = skb->len;
 }
 
 
@@ -730,95 +634,118 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct
vmxnet3_tx_ctx *ctx,
  * Returns:
  *    -1:  error happens during parsing
  *     0:  protocol headers parsed, but too big to be copied
- *     1:  protocol headers parsed and copied
+ *     n:  protocol headers parsed and copied; n is # of bytes copied
  *
  * Other effects:
- *    1. related *ctx fields are updated.
- *    2. ctx->copy_size is # of bytes copied
- *    3. the portion copied is guaranteed to be in the linear part
+ *    1. related *info fields are updated.
+ *    2. the portion copied is guaranteed to be in the linear part
  *
  */
 static int
 vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue
*tq,
-			   struct vmxnet3_tx_ctx *ctx,
+			   struct Plugin_SendInfo *info,
 			   struct vmxnet3_adapter *adapter)
 {
 	struct Vmxnet3_TxDataDesc *tdd;
-
-	if (ctx->mss) {
-		ctx->eth_ip_hdr_size = skb_transport_offset(skb);
-		ctx->l4_hdr_size = ((struct tcphdr *)
-				   skb_transport_header(skb))->doff * 4;
-		ctx->copy_size = ctx->eth_ip_hdr_size + ctx->l4_hdr_size;
+	unsigned int copy_size;
+
+	if (info->tsoMss) {
+		info->tcp = true;
+		info->tso = true;
+		info->xsumTcpOrUdp = true;
+		info->ipHeaderOffset = skb_network_offset(skb);
+		info->l4HeaderOffset = skb_transport_offset(skb);
+		info->l4DataOffset = info->l4HeaderOffset +
+			((struct tcphdr *)skb_transport_header(skb))->doff * 4;
+
+		copy_size = info->l4DataOffset;
 	} else {
 		unsigned int pull_size;
+		info->tcp = false;
+		info->udp = false;
+		info->tso = false;
+		if (info->ipv4) {
+			struct iphdr *iph = (struct iphdr *)
+					    skb_network_header(skb);
+			if (iph->protocol == IPPROTO_TCP)
+				info->tcp = true;
+			else if (iph->protocol == IPPROTO_UDP)
+				info->udp = true;
+		} else if (info->ipv6) {
+			/* XXX what about option headers */
+			struct ipv6hdr *iph = (struct ipv6hdr *)
+						skb_network_header(skb);
+			if (iph->nexthdr == IPPROTO_TCP)
+				info->tcp = true;
+			else if (iph->nexthdr == IPPROTO_UDP)
+				info->udp = true;
+		}
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			ctx->eth_ip_hdr_size = skb_transport_offset(skb);
-
-			if (ctx->ipv4) {
-				struct iphdr *iph = (struct iphdr *)
-						    skb_network_header(skb);
-				if (iph->protocol == IPPROTO_TCP) {
-					pull_size = ctx->eth_ip_hdr_size +
+			info->ipHeaderOffset = skb_network_offset(skb);
+			info->l4HeaderOffset = skb_transport_offset(skb);
+			if (info->ipv4 || info->ipv6) {
+				if (info->tcp) {
+					info->xsumTcpOrUdp = true;
+					pull_size = info->l4HeaderOffset +
 						    sizeof(struct tcphdr);
 
 					if (unlikely(!pskb_may_pull(skb,
 								pull_size))) {
 						goto err;
 					}
-					ctx->l4_hdr_size = ((struct tcphdr *)
+					info->l4DataOffset =
+						info->l4HeaderOffset +
+						((struct tcphdr *)
 					   skb_transport_header(skb))->doff * 4;
-				} else if (iph->protocol == IPPROTO_UDP) {
-					ctx->l4_hdr_size =
-							sizeof(struct udphdr);
+					copy_size = info->l4DataOffset;
+				} else if (info->udp) {
+					info->xsumTcpOrUdp = true;
+					info->l4DataOffset =
+						info->l4HeaderOffset +
+						sizeof(struct udphdr);
+					copy_size = info->l4DataOffset;
 				} else {
-					ctx->l4_hdr_size = 0;
+					info->xsumTcpOrUdp = false;
+					copy_size = info->l4HeaderOffset;
 				}
 			} else {
+				info->xsumTcpOrUdp = false;
 				/* for simplicity, don't copy L4 headers */
-				ctx->l4_hdr_size = 0;
+				copy_size = info->l4HeaderOffset;
 			}
-			ctx->copy_size = ctx->eth_ip_hdr_size +
-					 ctx->l4_hdr_size;
 		} else {
-			ctx->eth_ip_hdr_size = 0;
-			ctx->l4_hdr_size = 0;
+			info->xsumTcpOrUdp = false;
 			/* copy as much as allowed */
-			ctx->copy_size = min((unsigned int)VMXNET3_HDR_COPY_SIZE
-					     , skb_headlen(skb));
+			copy_size = min((unsigned int)VMXNET3_HDR_COPY_SIZE,
+					skb_headlen(skb));
 		}
-
 		/* make sure headers are accessible directly */
-		if (unlikely(!pskb_may_pull(skb, ctx->copy_size)))
+		if (unlikely(!pskb_may_pull(skb, copy_size)))
 			goto err;
 	}
 
-	if (unlikely(ctx->copy_size > VMXNET3_HDR_COPY_SIZE)) {
+	if (unlikely(copy_size > VMXNET3_HDR_COPY_SIZE)) {
 		tq->stats.oversized_hdr++;
-		ctx->copy_size = 0;
 		return 0;
 	}
 
-	tdd = tq->data_ring.base + tq->tx_ring.next2fill;
+	tdd = tq->data_ring.base + tq->data_ring.next2fill;
+	BUG_ON(copy_size > skb_headlen(skb));
 
-	memcpy(tdd->data, skb->data, ctx->copy_size);
-	dev_dbg(&adapter->netdev->dev,
-		"copy %u bytes to dataRing[%u]\n",
-		ctx->copy_size, tq->tx_ring.next2fill);
-	return 1;
+	memcpy(tdd->data, skb->data, copy_size);
 
+	return copy_size;
 err:
 	return -1;
 }
 
 
 static void
-vmxnet3_prepare_tso(struct sk_buff *skb,
-		    struct vmxnet3_tx_ctx *ctx)
+vmxnet3_prepare_tso(struct sk_buff *skb, struct Plugin_SendInfo *info)
 {
 	struct tcphdr *tcph = (struct tcphdr *)skb_transport_header(skb);
-	if (ctx->ipv4) {
+	if (info->ipv4) {
 		struct iphdr *iph = (struct iphdr *)skb_network_header(skb);
 		iph->check = 0;
 		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, 0,
@@ -848,24 +775,20 @@ static int
 vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		struct vmxnet3_adapter *adapter, struct net_device *netdev)
 {
-	int ret;
+	int copy_size;
 	u32 count;
 	unsigned long flags;
-	struct vmxnet3_tx_ctx ctx;
-	union Vmxnet3_GenericDesc *gdesc;
-#ifdef __BIG_ENDIAN_BITFIELD
-	/* Use temporary descriptor to avoid touching bits multiple times */
-	union Vmxnet3_GenericDesc tempTxDesc;
-#endif
+	u32 shadow_idx;
+	bool lastPktHint;
+	int i;
 
 	/* conservatively estimate # of descriptors to use */
 	count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) +
 		skb_shinfo(skb)->nr_frags + 1;
-
-	ctx.ipv4 = (skb->protocol == __constant_ntohs(ETH_P_IP));
-
-	ctx.mss = skb_shinfo(skb)->gso_size;
-	if (ctx.mss) {
+	tq->info.ipv4 = (skb->protocol == __constant_ntohs(ETH_P_IP));
+	tq->info.ipv6 = (skb->protocol == __constant_ntohs(ETH_P_IPV6));
+	tq->info.tsoMss = skb_shinfo(skb)->gso_size;
+	if (tq->info.tsoMss) {
 		if (skb_header_cloned(skb)) {
 			if (unlikely(pskb_expand_head(skb, 0, 0,
 						      GFP_ATOMIC) != 0)) {
@@ -874,7 +797,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct
vmxnet3_tx_queue *tq,
 			}
 			tq->stats.copy_skb_header++;
 		}
-		vmxnet3_prepare_tso(skb, &ctx);
+		vmxnet3_prepare_tso(skb, &tq->info);
 	} else {
 		if (unlikely(count > VMXNET3_MAX_TXD_PER_PKT)) {
 
@@ -892,18 +815,17 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct
vmxnet3_tx_queue *tq,
 		}
 	}
 
-	ret = vmxnet3_parse_and_copy_hdr(skb, tq, &ctx, adapter);
-	if (ret >= 0) {
-		BUG_ON(ret <= 0 && ctx.copy_size != 0);
+	copy_size = vmxnet3_parse_and_copy_hdr(skb, tq, &tq->info, adapter);
+	if (copy_size >= 0) {
 		/* hdrs parsed, check against other limits */
-		if (ctx.mss) {
-			if (unlikely(ctx.eth_ip_hdr_size + ctx.l4_hdr_size >
+		if (tq->info.tsoMss) {
+			if (unlikely(tq->info.l4DataOffset >
 				     VMXNET3_MAX_TX_BUF_SIZE)) {
 				goto hdr_too_big;
 			}
 		} else {
 			if (skb->ip_summed == CHECKSUM_PARTIAL) {
-				if (unlikely(ctx.eth_ip_hdr_size +
+				if (unlikely(tq->info.l4HeaderOffset +
 					     skb->csum_offset >
 					     VMXNET3_MAX_CSUM_OFFSET)) {
 					goto hdr_too_big;
@@ -916,82 +838,83 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct
vmxnet3_tx_queue *tq,
 	}
 
 	spin_lock_irqsave(&tq->tx_lock, flags);
-
-	if (count > vmxnet3_cmd_ring_desc_avail(&tq->tx_ring)) {
+	/* Convert all deb_dbg to dprink */
+	if (vmxnet3_tx_data_ring_desc_avail(&tq->data_ring) < 1) {
 		tq->stats.tx_ring_full++;
-		dev_dbg(&adapter->netdev->dev,
-			"tx queue stopped on %s, next2comp %u"
-			" next2fill %u\n", adapter->netdev->name,
-			tq->tx_ring.next2comp, tq->tx_ring.next2fill);
+		dev_dbg(&adapter->pdev->dev, "tx queue stopped on %s, data ring"
+			" next2comp %u next2fill %u\n", adapter->netdev->name,
+			tq->data_ring.next2comp, tq->data_ring.next2fill);
 
 		vmxnet3_tq_stop(tq, adapter);
 		spin_unlock_irqrestore(&tq->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
-	/* fill tx descs related to addr & len */
-	vmxnet3_map_pkt(skb, &ctx, tq, adapter->pdev, adapter);
+	if (count > vmxnet3_tx_shadow_ring_desc_avail(&tq->shadow_ring)) {
+		tq->stats.tx_ring_full++;
+		dev_dbg(&adapter->pdev->dev, "tx queue stopped on %s, shadow "
+			" ring next2comp %u next2fill %u\n",
+			adapter->netdev->name,
+			tq->shadow_ring.next2comp, tq->shadow_ring.next2fill);
 
-	/* setup the EOP desc */
-	ctx.eop_txd->dword[3] = cpu_to_le32(VMXNET3_TXD_CQ | VMXNET3_TXD_EOP);
+		vmxnet3_tq_stop(tq, adapter);
+		spin_unlock_irqrestore(&tq->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
 
-	/* setup the SOP desc */
-#ifdef __BIG_ENDIAN_BITFIELD
-	gdesc = &tempTxDesc;
-	gdesc->dword[2] = ctx.sop_txd->dword[2];
-	gdesc->dword[3] = ctx.sop_txd->dword[3];
-#else
-	gdesc = ctx.sop_txd;
-#endif
-	if (ctx.mss) {
-		gdesc->txd.hlen = ctx.eth_ip_hdr_size + ctx.l4_hdr_size;
-		gdesc->txd.om = VMXNET3_OM_TSO;
-		gdesc->txd.msscof = ctx.mss;
-		le32_add_cpu(&tq->shared->txNumDeferred, (skb->len -
-			     gdesc->txd.hlen + ctx.mss - 1) / ctx.mss);
-	} else {
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			gdesc->txd.hlen = ctx.eth_ip_hdr_size;
-			gdesc->txd.om = VMXNET3_OM_CSUM;
-			gdesc->txd.msscof = ctx.eth_ip_hdr_size +
-					    skb->csum_offset;
+	/* fill shadow ring and populate sg_list with addr & len */
+	shadow_idx = tq->shadow_ring.next2fill;
+	vmxnet3_map_pkt(skb, copy_size, tq, adapter);
+	if (tq->info.tsoMss)
+		tq->shared->txNumDeferred += (skb->len - copy_size +
+					tq->info.tsoMss - 1) / tq->info.tsoMss;
+	else
+		tq->shared->txNumDeferred += 1;
+
+	if (!adapter->passthru) {
+		if (le32_to_cpu(tq->shared->txNumDeferred) >=
+		    le32_to_cpu(tq->shared->txThreshold)) {
+			tq->shared->txNumDeferred = 0;
+			lastPktHint = true;
 		} else {
-			gdesc->txd.om = 0;
-			gdesc->txd.msscof = 0;
+			lastPktHint = false;
 		}
-		le32_add_cpu(&tq->shared->txNumDeferred, 1);
+	} else {
+		lastPktHint = true;
 	}
 
 	if (vlan_tx_tag_present(skb)) {
-		gdesc->txd.ti = 1;
-		gdesc->txd.tci = vlan_tx_tag_get(skb);
+		tq->info.vlan = true;
+		tq->info.vlanTag = vlan_tx_tag_get(skb);
 	}
 
-	/* finally flips the GEN bit of the SOP desc. */
-	gdesc->dword[2] = cpu_to_le32(le32_to_cpu(gdesc->dword[2]) ^
-						  VMXNET3_TXD_GEN);
-#ifdef __BIG_ENDIAN_BITFIELD
-	/* Finished updating in bitfields of Tx Desc, so write them in
original
-	 * place.
-	 */
-	vmxnet3_TxDescToLe((struct Vmxnet3_TxDesc *)gdesc,
-			   (struct Vmxnet3_TxDesc *)ctx.sop_txd);
-	gdesc = ctx.sop_txd;
-#endif
-	dev_dbg(&adapter->netdev->dev,
-		"txd[%u]: SOP 0x%Lx 0x%x 0x%x\n",
-		(u32)((union Vmxnet3_GenericDesc *)ctx.sop_txd -
-		tq->tx_ring.base), le64_to_cpu(gdesc->txd.addr),
-		le32_to_cpu(gdesc->dword[2]), le32_to_cpu(gdesc->dword[3]));
+	if (Plugin_AddFrameToTxRing(adapter, tq->qid, &tq->info, &tq->sg_list,
+				    lastPktHint) != 0) {
+		tq->stats.tx_ring_full++;
+		dev_dbg(&adapter->pdev->dev, "tx queue stopped on %s, plugin "
+			"ring: full\n", adapter->netdev->name);
+
+		/* roll back shadow ring and unmap pkt */
+		for (i = shadow_idx; i < tq->shadow_ring.next2fill; i++) {
+			vmxnet3_unmap_tx_buf(tq->shadow_ring.base + i,
+					     adapter->pdev);
+			tq->shadow_ring.base[i].skb = NULL;
+		}
+		tq->shadow_ring.next2fill = shadow_idx;
+		tq->sg_list.numElements = 0;
+		tq->sg_list.totalLength = 0;
+
+		vmxnet3_tq_stop(tq, adapter);
+		spin_unlock_irqrestore(&tq->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
 
+	wmb();
+
+	vmxnet3_tx_data_ring_adv_next2fill(&tq->data_ring);
 	spin_unlock_irqrestore(&tq->tx_lock, flags);
 
-	if (le32_to_cpu(tq->shared->txNumDeferred) >=
-					le32_to_cpu(tq->shared->txThreshold)) {
-		tq->shared->txNumDeferred = 0;
-		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_TXPROD,
-				       tq->tx_ring.next2fill);
-	}
+	netdev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
 
@@ -1008,331 +931,68 @@ static netdev_tx_t
 vmxnet3_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-
 	return vmxnet3_tq_xmit(skb, &adapter->tx_queue, adapter, netdev);
 }
 
 
-static void
-vmxnet3_rx_csum(struct vmxnet3_adapter *adapter,
-		struct sk_buff *skb,
-		union Vmxnet3_GenericDesc *gdesc)
-{
-	if (!gdesc->rcd.cnc && adapter->rxcsum) {
-		/* typical case: TCP/UDP over IP and both csums are correct */
-		if ((le32_to_cpu(gdesc->dword[3]) & VMXNET3_RCD_CSUM_OK) ==
-							VMXNET3_RCD_CSUM_OK) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			BUG_ON(!(gdesc->rcd.tcp || gdesc->rcd.udp));
-			BUG_ON(!(gdesc->rcd.v4  || gdesc->rcd.v6));
-			BUG_ON(gdesc->rcd.frg);
-		} else {
-			if (gdesc->rcd.csum) {
-				skb->csum = htons(gdesc->rcd.csum);
-				skb->ip_summed = CHECKSUM_PARTIAL;
-			} else {
-				skb->ip_summed = CHECKSUM_NONE;
-			}
-		}
-	} else {
-		skb->ip_summed = CHECKSUM_NONE;
-	}
-}
-
-
-static void
-vmxnet3_rx_error(struct vmxnet3_rx_queue *rq, struct Vmxnet3_RxCompDesc
*rcd,
-		 struct vmxnet3_rx_ctx *ctx,  struct vmxnet3_adapter *adapter)
-{
-	rq->stats.drop_err++;
-	if (!rcd->fcs)
-		rq->stats.drop_fcs++;
-
-	rq->stats.drop_total++;
-
-	/*
-	 * We do not unmap and chain the rx buffer to the skb.
-	 * We basically pretend this buffer is not used and will be recycled
-	 * by vmxnet3_rq_alloc_rx_buf()
-	 */
-
-	/*
-	 * ctx->skb may be NULL if this is the first and the only one
-	 * desc for the pkt
-	 */
-	if (ctx->skb)
-		dev_kfree_skb_irq(ctx->skb);
-
-	ctx->skb = NULL;
-}
-
-
-static int
-vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
-		       struct vmxnet3_adapter *adapter, int quota)
-{
-	static u32 rxprod_reg[2] = {VMXNET3_REG_RXPROD, VMXNET3_REG_RXPROD2};
-	u32 num_rxd = 0;
-	struct Vmxnet3_RxCompDesc *rcd;
-	struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
-#ifdef __BIG_ENDIAN_BITFIELD
-	struct Vmxnet3_RxDesc rxCmdDesc;
-	struct Vmxnet3_RxCompDesc rxComp;
-#endif
-	vmxnet3_getRxComp(rcd,
&rq->comp_ring.base[rq->comp_ring.next2proc].rcd,
-			  &rxComp);
-	while (rcd->gen == rq->comp_ring.gen) {
-		struct vmxnet3_rx_buf_info *rbi;
-		struct sk_buff *skb;
-		int num_to_alloc;
-		struct Vmxnet3_RxDesc *rxd;
-		u32 idx, ring_idx;
-
-		if (num_rxd >= quota) {
-			/* we may stop even before we see the EOP desc of
-			 * the current pkt
-			 */
-			break;
-		}
-		num_rxd++;
-
-		idx = rcd->rxdIdx;
-		ring_idx = rcd->rqID == rq->qid ? 0 : 1;
-		vmxnet3_getRxDesc(rxd, &rq->rx_ring[ring_idx].base[idx].rxd,
-				  &rxCmdDesc);
-		rbi = rq->buf_info[ring_idx] + idx;
-
-		BUG_ON(rxd->addr != rbi->dma_addr ||
-		       rxd->len != rbi->len);
-
-		if (unlikely(rcd->eop && rcd->err)) {
-			vmxnet3_rx_error(rq, rcd, ctx, adapter);
-			goto rcd_done;
-		}
-
-		if (rcd->sop) { /* first buf of the pkt */
-			BUG_ON(rxd->btype != VMXNET3_RXD_BTYPE_HEAD ||
-			       rcd->rqID != rq->qid);
-
-			BUG_ON(rbi->buf_type != VMXNET3_RX_BUF_SKB);
-			BUG_ON(ctx->skb != NULL || rbi->skb == NULL);
-
-			if (unlikely(rcd->len == 0)) {
-				/* Pretend the rx buffer is skipped. */
-				BUG_ON(!(rcd->sop && rcd->eop));
-				dev_dbg(&adapter->netdev->dev,
-					"rxRing[%u][%u] 0 length\n",
-					ring_idx, idx);
-				goto rcd_done;
-			}
-
-			ctx->skb = rbi->skb;
-			rbi->skb = NULL;
-
-			pci_unmap_single(adapter->pdev, rbi->dma_addr, rbi->len,
-					 PCI_DMA_FROMDEVICE);
-
-			skb_put(ctx->skb, rcd->len);
-		} else {
-			BUG_ON(ctx->skb == NULL);
-			/* non SOP buffer must be type 1 in most cases */
-			if (rbi->buf_type == VMXNET3_RX_BUF_PAGE) {
-				BUG_ON(rxd->btype != VMXNET3_RXD_BTYPE_BODY);
-
-				if (rcd->len) {
-					pci_unmap_page(adapter->pdev,
-						       rbi->dma_addr, rbi->len,
-						       PCI_DMA_FROMDEVICE);
-
-					vmxnet3_append_frag(ctx->skb, rcd, rbi);
-					rbi->page = NULL;
-				}
-			} else {
-				/*
-				 * The only time a non-SOP buffer is type 0 is
-				 * when it's EOP and error flag is raised, which
-				 * has already been handled.
-				 */
-				BUG_ON(true);
-			}
-		}
-
-		skb = ctx->skb;
-		if (rcd->eop) {
-			skb->len += skb->data_len;
-			skb->truesize += skb->data_len;
-
-			vmxnet3_rx_csum(adapter, skb,
-					(union Vmxnet3_GenericDesc *)rcd);
-			skb->protocol = eth_type_trans(skb, adapter->netdev);
-
-			if (unlikely(adapter->vlan_grp && rcd->ts)) {
-				vlan_hwaccel_receive_skb(skb,
-						adapter->vlan_grp, rcd->tci);
-			} else {
-				netif_receive_skb(skb);
-			}
-
-			ctx->skb = NULL;
-		}
-
-rcd_done:
-		/* device may skip some rx descs */
-		rq->rx_ring[ring_idx].next2comp = idx;
-		VMXNET3_INC_RING_IDX_ONLY(rq->rx_ring[ring_idx].next2comp,
-					  rq->rx_ring[ring_idx].size);
-
-		/* refill rx buffers frequently to avoid starving the h/w */
-		num_to_alloc = vmxnet3_cmd_ring_desc_avail(rq->rx_ring +
-							   ring_idx);
-		if (unlikely(num_to_alloc > VMXNET3_RX_ALLOC_THRESHOLD(rq,
-							ring_idx, adapter))) {
-			vmxnet3_rq_alloc_rx_buf(rq, ring_idx, num_to_alloc,
-						adapter);
-
-			/* if needed, update the register */
-			if (unlikely(rq->shared->updateRxProd)) {
-				VMXNET3_WRITE_BAR0_REG(adapter,
-					rxprod_reg[ring_idx] + rq->qid * 8,
-					rq->rx_ring[ring_idx].next2fill);
-				rq->uncommitted[ring_idx] = 0;
-			}
-		}
-
-		vmxnet3_comp_ring_adv_next2proc(&rq->comp_ring);
-		vmxnet3_getRxComp(rcd,
-		     &rq->comp_ring.base[rq->comp_ring.next2proc].rcd, &rxComp);
-	}
-
-	return num_rxd;
-}
-
+static void vmxnet3_shell_free_buffer(struct Shell_RxQueueHandle
*handle,
+				      u32 ringOffset);
 
 static void
 vmxnet3_rq_cleanup(struct vmxnet3_rx_queue *rq,
 		   struct vmxnet3_adapter *adapter)
 {
-	u32 i, ring_idx;
-	struct Vmxnet3_RxDesc *rxd;
-
-	for (ring_idx = 0; ring_idx < 2; ring_idx++) {
-		for (i = 0; i < rq->rx_ring[ring_idx].size; i++) {
-#ifdef __BIG_ENDIAN_BITFIELD
-			struct Vmxnet3_RxDesc rxDesc;
-#endif
-			vmxnet3_getRxDesc(rxd,
-				&rq->rx_ring[ring_idx].base[i].rxd, &rxDesc);
-
-			if (rxd->btype == VMXNET3_RXD_BTYPE_HEAD &&
-					rq->buf_info[ring_idx][i].skb) {
-				pci_unmap_single(adapter->pdev, rxd->addr,
-						 rxd->len, PCI_DMA_FROMDEVICE);
-				dev_kfree_skb(rq->buf_info[ring_idx][i].skb);
-				rq->buf_info[ring_idx][i].skb = NULL;
-			} else if (rxd->btype == VMXNET3_RXD_BTYPE_BODY &&
-					rq->buf_info[ring_idx][i].page) {
-				pci_unmap_page(adapter->pdev, rxd->addr,
-					       rxd->len, PCI_DMA_FROMDEVICE);
-				put_page(rq->buf_info[ring_idx][i].page);
-				rq->buf_info[ring_idx][i].page = NULL;
-			}
-		}
+	struct vmxnet3_rx_buf_info *rbi;
+	u32 i;
 
-		rq->rx_ring[ring_idx].gen = VMXNET3_INIT_GEN;
-		rq->rx_ring[ring_idx].next2fill =
-					rq->rx_ring[ring_idx].next2comp = 0;
-		rq->uncommitted[ring_idx] = 0;
+	for (i = 0; i < rq->plugin_rq->ringSize *
+			PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE; i++) {
+		rbi = rq->buf_info + i;
+		if (rbi->buf_type != VMXNET3_RX_BUF_NONE)
+			vmxnet3_shell_free_buffer((struct Shell_RxQueueHandle *)
+					rq, i);
 	}
-
-	rq->comp_ring.gen = VMXNET3_INIT_GEN;
-	rq->comp_ring.next2proc = 0;
+	BUG_ON(rq->avail_skbs != 0);
 }
 
-
-void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
-			struct vmxnet3_adapter *adapter)
+void
+vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
+		struct vmxnet3_adapter *adapter)
 {
-	int i;
-	int j;
-
-	/* all rx buffers must have already been freed */
-	for (i = 0; i < 2; i++) {
-		if (rq->buf_info[i]) {
-			for (j = 0; j < rq->rx_ring[i].size; j++)
-				BUG_ON(rq->buf_info[i][j].page != NULL);
-		}
+	if (rq->plugin_rq->ringBaseVA) {
+		pci_free_consistent(adapter->pdev, rq->plugin_rq->ringLength,
+				rq->plugin_rq->ringBaseVA,
+				rq->plugin_rq->ringBasePA);
+		rq->plugin_rq->ringBaseVA = NULL;
+		rq->plugin_rq->ringBasePA = 0;
 	}
 
-
-	kfree(rq->buf_info[0]);
-
-	for (i = 0; i < 2; i++) {
-		if (rq->rx_ring[i].base) {
-			pci_free_consistent(adapter->pdev, rq->rx_ring[i].size
-					    * sizeof(struct Vmxnet3_RxDesc),
-					    rq->rx_ring[i].base,
-					    rq->rx_ring[i].basePA);
-			rq->rx_ring[i].base = NULL;
-		}
-		rq->buf_info[i] = NULL;
-	}
-
-	if (rq->comp_ring.base) {
-		pci_free_consistent(adapter->pdev, rq->comp_ring.size *
-				    sizeof(struct Vmxnet3_RxCompDesc),
-				    rq->comp_ring.base, rq->comp_ring.basePA);
-		rq->comp_ring.base = NULL;
+	if (rq->buf_info) {
+		vfree(rq->buf_info);
+		rq->buf_info = NULL;
 	}
 }
 
-
 static int
 vmxnet3_rq_init(struct vmxnet3_rx_queue *rq,
 		struct vmxnet3_adapter  *adapter)
 {
+	struct vmxnet3_rx_buf_info *rbi;
 	int i;
 
-	/* initialize buf_info */
-	for (i = 0; i < rq->rx_ring[0].size; i++) {
-
-		/* 1st buf for a pkt is skbuff */
-		if (i % adapter->rx_buf_per_pkt == 0) {
-			rq->buf_info[0][i].buf_type = VMXNET3_RX_BUF_SKB;
-			rq->buf_info[0][i].len = adapter->skb_buf_size;
-		} else { /* subsequent bufs for a pkt is frag */
-			rq->buf_info[0][i].buf_type = VMXNET3_RX_BUF_PAGE;
-			rq->buf_info[0][i].len = PAGE_SIZE;
-		}
-	}
-	for (i = 0; i < rq->rx_ring[1].size; i++) {
-		rq->buf_info[1][i].buf_type = VMXNET3_RX_BUF_PAGE;
-		rq->buf_info[1][i].len = PAGE_SIZE;
-	}
-
-	/* reset internal state and allocate buffers for both rings */
-	for (i = 0; i < 2; i++) {
-		rq->rx_ring[i].next2fill = rq->rx_ring[i].next2comp = 0;
-		rq->uncommitted[i] = 0;
+	BUG_ON(adapter->rx_buf_per_pkt <= 0 ||
+			rq->plugin_rq->ringSize % adapter->rx_buf_per_pkt != 0);
 
-		memset(rq->rx_ring[i].base, 0, rq->rx_ring[i].size *
-		       sizeof(struct Vmxnet3_RxDesc));
-		rq->rx_ring[i].gen = VMXNET3_INIT_GEN;
-	}
-	if (vmxnet3_rq_alloc_rx_buf(rq, 0, rq->rx_ring[0].size - 1,
-				    adapter) == 0) {
-		/* at least has 1 rx buffer for the 1st ring */
-		return -ENOMEM;
+	/* initialize buf_info */
+	for (i = 0; i < rq->plugin_rq->ringSize *
+			PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE; i++) {
+		rbi = rq->buf_info + i;
+		rbi->buf_type = VMXNET3_RX_BUF_NONE;
+		rbi->skb = NULL;
+		rbi->page = NULL;
 	}
-	vmxnet3_rq_alloc_rx_buf(rq, 1, rq->rx_ring[1].size - 1, adapter);
-
-	/* reset the comp ring */
-	rq->comp_ring.next2proc = 0;
-	memset(rq->comp_ring.base, 0, rq->comp_ring.size *
-	       sizeof(struct Vmxnet3_RxCompDesc));
-	rq->comp_ring.gen = VMXNET3_INIT_GEN;
 
-	/* reset rxctx */
-	rq->rx_ctx.skb = NULL;
+	rq->avail_skbs = 0;
 
 	/* stats are not reset */
 	return 0;
@@ -1342,41 +1002,45 @@ vmxnet3_rq_init(struct vmxnet3_rx_queue *rq,
 static int
 vmxnet3_rq_create(struct vmxnet3_rx_queue *rq, struct vmxnet3_adapter
*adapter)
 {
-	int i;
-	size_t sz;
-	struct vmxnet3_rx_buf_info *bi;
+	u32 ring_length;
 
-	for (i = 0; i < 2; i++) {
 
-		sz = rq->rx_ring[i].size * sizeof(struct Vmxnet3_RxDesc);
-		rq->rx_ring[i].base = pci_alloc_consistent(adapter->pdev, sz,
-							&rq->rx_ring[i].basePA);
-		if (!rq->rx_ring[i].base) {
-			printk(KERN_ERR "%s: failed to allocate rx ring %d\n",
-			       adapter->netdev->name, i);
-			goto err;
-		}
-	}
+	BUG_ON(rq->plugin_rq->ringSize == 0);
+	BUG_ON((rq->plugin_rq->ringSize & VMXNET3_RING_SIZE_MASK) != 0);
+	BUG_ON(rq->plugin_rq->ringBaseVA || rq->buf_info);
+	BUG_ON(rq->plugin_rq->ringSize % adapter->rx_buf_per_pkt != 0);
 
-	sz = rq->comp_ring.size * sizeof(struct Vmxnet3_RxCompDesc);
-	rq->comp_ring.base = pci_alloc_consistent(adapter->pdev, sz,
-						  &rq->comp_ring.basePA);
-	if (!rq->comp_ring.base) {
-		printk(KERN_ERR "%s: failed to allocate rx comp ring\n",
+	/*
+	 * We don't know the underlying hardware's descriptor size,
+	 * thus use the maximum allowed descriptor size.
+	 */
+	ring_length = rq->plugin_rq->ringSize *
+		PLUGIN_SHADED_AREA_RX_MAX_DESC_SIZE_BYTES;
+	/* Add room for potential alignment */
+	ring_length += PLUGIN_SHADED_AREA_RX_ALLOCATION_ALIGN - 1;
+	/*
+	 * Again, we don't know the underlying hardware's mode of
+	 * operation, so let's give room for multiple rings.
+	 */
+	rq->plugin_rq->ringLength = PLUGIN_SHADED_AREA_RX_ALLOCATION_MULTIPLE
*
+		ring_length + PLUGIN_SHADED_AREA_RX_EXTRA_ALLOCATION;
+	rq->plugin_rq->ringBaseVA = pci_alloc_consistent(adapter->pdev,
+				    rq->plugin_rq->ringLength,
+				    (dma_addr_t *)&rq->plugin_rq->ringBasePA);
+	if (!rq->plugin_rq->ringBaseVA) {
+		printk(KERN_ERR "%s: failed to allocate rx ring\n",
 		       adapter->netdev->name);
 		goto err;
 	}
 
-	sz = sizeof(struct vmxnet3_rx_buf_info) * (rq->rx_ring[0].size +
-						   rq->rx_ring[1].size);
-	bi = kzalloc(sz, GFP_KERNEL);
-	if (!bi) {
+	rq->buf_info = vmalloc(rq->plugin_rq->ringSize *
+			       PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE *
+			       sizeof(struct vmxnet3_rx_buf_info));
+	if (!rq->buf_info) {
 		printk(KERN_ERR "%s: failed to allocate rx bufinfo\n",
 		       adapter->netdev->name);
 		goto err;
 	}
-	rq->buf_info[0] = bi;
-	rq->buf_info[1] = bi + rq->rx_ring[0].size;
 
 	return 0;
 
@@ -1392,8 +1056,11 @@ vmxnet3_do_poll(struct vmxnet3_adapter *adapter,
int budget)
 	if (unlikely(adapter->shared->ecr))
 		vmxnet3_process_events(adapter);
 
-	vmxnet3_tq_tx_complete(&adapter->tx_queue, adapter);
-	return vmxnet3_rq_rx_complete(&adapter->rx_queue, adapter, budget);
+	Plugin_CheckTxRing(adapter, 0);
+	adapter->rx_queue.rxd_done = 0;
+	if (Plugin_CheckRxRing(adapter, 0, budget))
+		Plugin_AddBuffersToRxRing(adapter, 0);
+	return adapter->rx_queue.rxd_done;
 }
 
 
@@ -1495,8 +1162,8 @@ vmxnet3_request_irqs(struct vmxnet3_adapter
*adapter)
 			adapter->intr.mod_levels[i] = UPT1_IML_ADAPTIVE;
 
 		/* next setup intr index for all intr sources */
-		adapter->tx_queue.comp_ring.intr_idx = 0;
-		adapter->rx_queue.comp_ring.intr_idx = 0;
+		adapter->tx_queue.intr_idx = 0;
+		adapter->rx_queue.intr_idx = 0;
 		adapter->intr.event_intr_idx = 0;
 
 		printk(KERN_INFO "%s: intr type %u, mode %u, %u vectors "
@@ -1747,7 +1414,10 @@ vmxnet3_setup_driver_shared(struct
vmxnet3_adapter *adapter)
 	struct Vmxnet3_DSDevRead *devRead = &shared->devRead;
 	struct Vmxnet3_TxQueueConf *tqc;
 	struct Vmxnet3_RxQueueConf *rqc;
-	int i;
+	struct vmxnet3_tx_queue	*tq;
+	struct vmxnet3_rx_queue *rq;
+	dma_addr_t pa;
+	int i, ring1_size;
 
 	memset(shared, 0, sizeof(*shared));
 
@@ -1785,37 +1455,52 @@ vmxnet3_setup_driver_shared(struct
vmxnet3_adapter *adapter)
 				     sizeof(struct Vmxnet3_TxQueueDesc) +
 				     sizeof(struct Vmxnet3_RxQueueDesc));
 
-	/* tx queue settings */
-	BUG_ON(adapter->tx_queue.tx_ring.base == NULL);
-
 	devRead->misc.numTxQueues = 1;
 	tqc = &adapter->tqd_start->conf;
-	tqc->txRingBasePA   = cpu_to_le64(adapter->tx_queue.tx_ring.basePA);
-	tqc->dataRingBasePA = cpu_to_le64(adapter->tx_queue.data_ring.basePA);
-	tqc->compRingBasePA = cpu_to_le64(adapter->tx_queue.comp_ring.basePA);
-	tqc->ddPA           = cpu_to_le64(virt_to_phys(
-						adapter->tx_queue.buf_info));
-	tqc->txRingSize     = cpu_to_le32(adapter->tx_queue.tx_ring.size);
-	tqc->dataRingSize   = cpu_to_le32(adapter->tx_queue.data_ring.size);
-	tqc->compRingSize   = cpu_to_le32(adapter->tx_queue.comp_ring.size);
-	tqc->ddLen          = cpu_to_le32(sizeof(struct vmxnet3_tx_buf_info) *
-			      tqc->txRingSize);
-	tqc->intrIdx        = adapter->tx_queue.comp_ring.intr_idx;
+	tq = &adapter->tx_queue;
+	BUG_ON(tq->plugin_tq->ringBaseVA == NULL);
+	BUG_ON(tq->plugin_tq->ringBasePA == 0);
+	pa = tq->plugin_tq->ringBasePA;
+	tqc->txRingBasePA   = ALIGN(pa, VMXNET3_RING_BA_ALIGN);
+	tqc->dataRingBasePA = tq->data_ring.basePA;
+	pa += tq->plugin_tq->ringSize * sizeof(struct Vmxnet3_TxDesc);
+	tqc->compRingBasePA = ALIGN(pa, VMXNET3_RING_BA_ALIGN);
+	tqc->ddPA           = virt_to_phys(tq->shadow_ring.base);
+	tqc->txRingSize     = tq->plugin_tq->ringSize;
+	tqc->dataRingSize   = tq->data_ring.size;
+	tqc->compRingSize   = tq->plugin_tq->ringSize;
+	tqc->ddLen          = sizeof(struct vmxnet3_tx_buf_info) *
+			      tq->shadow_ring.size;
+	tqc->intrIdx        = tq->intr_idx;
 
 	/* rx queue settings */
+	if (adapter->lro ||
+			adapter->netdev->mtu > SHELL_SMALL_RECV_BUFFER_SIZE) {
+		ring1_size = adapter->rx_queue.plugin_rq->ringSize;
+	} else {
+		/* same as in plugin and windows shell */
+		ring1_size = 32;
+	}
+
 	devRead->misc.numRxQueues = 1;
+	rq = &adapter->rx_queue;
+
+	BUG_ON(rq->plugin_rq->ringBaseVA == NULL);
+	BUG_ON(rq->plugin_rq->ringBasePA == 0);
 	rqc = &adapter->rqd_start->conf;
-	rqc->rxRingBasePA[0] =
cpu_to_le64(adapter->rx_queue.rx_ring[0].basePA);
-	rqc->rxRingBasePA[1] =
cpu_to_le64(adapter->rx_queue.rx_ring[1].basePA);
-	rqc->compRingBasePA  =
cpu_to_le64(adapter->rx_queue.comp_ring.basePA);
-	rqc->ddPA            = cpu_to_le64(virt_to_phys(
-						adapter->rx_queue.buf_info));
-	rqc->rxRingSize[0]   = cpu_to_le32(adapter->rx_queue.rx_ring[0].size);
-	rqc->rxRingSize[1]   = cpu_to_le32(adapter->rx_queue.rx_ring[1].size);
-	rqc->compRingSize    = cpu_to_le32(adapter->rx_queue.comp_ring.size);
-	rqc->ddLen           = cpu_to_le32(sizeof(struct vmxnet3_rx_buf_info)
*
-			       (rqc->rxRingSize[0] + rqc->rxRingSize[1]));
-	rqc->intrIdx         = adapter->rx_queue.comp_ring.intr_idx;
+	pa = rq->plugin_rq->ringBasePA;
+	rqc->rxRingBasePA[0] = ALIGN(pa, VMXNET3_RING_BA_ALIGN);
+	pa += rq->plugin_rq->ringSize * sizeof(struct Vmxnet3_RxDesc);
+	rqc->rxRingBasePA[1] = ALIGN(pa, VMXNET3_RING_BA_ALIGN);
+	pa += ring1_size * sizeof(struct Vmxnet3_RxDesc);
+	rqc->compRingBasePA  = ALIGN(pa, VMXNET3_RING_BA_ALIGN);
+	rqc->ddPA            = virt_to_phys(rq->buf_info);
+	rqc->rxRingSize[0]   = rq->plugin_rq->ringSize;
+	rqc->rxRingSize[1]   = ring1_size;
+	rqc->compRingSize    = rq->plugin_rq->ringSize + ring1_size;
+	rqc->ddLen           = sizeof(struct vmxnet3_rx_buf_info) *
+			       (rq->plugin_rq->ringSize + ring1_size);
+	rqc->intrIdx         = rq->intr_idx;
 
 	/* intr settings */
 	devRead->intrConf.autoMask = adapter->intr.mask_mode ==
@@ -1832,55 +1517,214 @@ vmxnet3_setup_driver_shared(struct
vmxnet3_adapter *adapter)
 	/* the rest are already zeroed */
 }
 
+/*
+ * This function asks the Hypervisor to load the HW plugin inside the
guest.
+ *
+ * First we look for an available region to load the code, then we
+ * populate the NPA_PluginConf before issuing the CMD_LOAD_PLUGIN.
+ * After this, we set the MMIO address, copy the init opaque data and
+ * retrieve the entry poinf of the plugin.
+ */
 
-int
-vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
+static NPA_PluginMainFunc *
+vmxnet3_load_plugin(struct vmxnet3_adapter *adapter)
+{
+	struct NPA_PluginConf *plugin_conf = adapter->plugin_conf;
+	u8 *plugin_code_region;
+	int ret;
+	int i;
+
+	/* look for an available code region */
+	spin_lock(&vmxnet3_plugin_code_lock);
+	for (i = 0; i < NPA_MAX_PLUGINS_PER_VM; i++)
+		if (!vmxnet3_plugin_code_used[i])
+			break;
+	if (i == NPA_MAX_PLUGINS_PER_VM) {
+		spin_unlock(&vmxnet3_plugin_code_lock);
+		printk(KERN_ERR "Failed to allocated code section on %s\n",
+		       adapter->netdev->name);
+		return NULL;
+	}
+	vmxnet3_plugin_code_used[i] = true;
+	spin_unlock(&vmxnet3_plugin_code_lock);
+	adapter->plugin_region_idx = i;
+	plugin_code_region = &vmxnet3_plugin_code_mem[NPA_PLUGIN_NUMPAGES *
+		PAGE_SIZE * i];
+
+	/* construct the plugin_conf */
+	memset(plugin_conf, 0, sizeof(*plugin_conf));
+	BUG_ON(((uintptr_t)plugin_code_region & ~PAGE_MASK));
+	plugin_conf->pluginPages.vaddr = (uintptr_t)plugin_code_region;
+	plugin_conf->pluginPages.numPages = NPA_PLUGIN_NUMPAGES;
+	for (i = 0; i < NPA_PLUGIN_NUMPAGES; i++) {
+		plugin_conf->pluginPages.pages[i] =
+			page_to_pfn(vmalloc_to_page(plugin_code_region +
+						i * PAGE_SIZE));
+	}
+
+	plugin_conf->memioPages.startPPN = ALIGN(adapter->plugin_memio_pa,
+			PAGE_SIZE) / PAGE_SIZE;
+	plugin_conf->memioPages.numPages = NPA_MEMIO_NUMPAGES;
+	plugin_conf->sharedPages.startPPN = ALIGN(adapter->plugin_shared_pa,
+			PAGE_SIZE) / PAGE_SIZE;
+	plugin_conf->sharedPages.numPages = NPA_SHARED_NUMPAGES;
+
+	adapter->shared->devRead.pluginConfDesc.confVer = 1;
+	adapter->shared->devRead.pluginConfDesc.confLen =
sizeof(*plugin_conf);
+	adapter->shared->devRead.pluginConfDesc.confPA  =
+		virt_to_phys(plugin_conf);
+
+	dev_dbg(&adapter->pdev->dev, "%s: pluginConf: %d 0x%llx 0x%llx"
+		" 0x%llx\n", adapter->netdev->name,
+		adapter->shared->devRead.pluginConfDesc.confLen,
+		adapter->shared->devRead.pluginConfDesc.confPA,
+		plugin_conf->pluginPages.vaddr,
+		plugin_conf->pluginPages.pages[0]);
+
+	/* issue command to load the plugin */
+	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+			VMXNET3_CMD_LOAD_PLUGIN);
+	ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+	if (ret == VMXNET3_NPA_CMD_SUCCESS) {
+		adapter->plugin.memioAddr =
+			(void *)ALIGN((uintptr_t)adapter->plugin_memio,
+					PAGE_SIZE);
+		memcpy(adapter->plugin.deviceInfo, plugin_conf->deviceInfo,
+				sizeof(adapter->plugin.deviceInfo));
+		return (NPA_PluginMainFunc *)(uintptr_t)plugin_conf->entryVA;
+	} else {
+		spin_lock(&vmxnet3_plugin_code_lock);
+		vmxnet3_plugin_code_used[adapter->plugin_region_idx] = false;
+		spin_unlock(&vmxnet3_plugin_code_lock);
+		return NULL;
+	}
+}
+
+
+	int
+vmxnet3_activate_dev(struct vmxnet3_adapter *adapter, bool load_plugin)
 {
 	int err;
 	u32 ret;
 
 	dev_dbg(&adapter->netdev->dev,
 		"%s: skb_buf_size %d, rx_buf_per_pkt %d, ring sizes"
-		" %u %u %u\n", adapter->netdev->name, adapter->skb_buf_size,
-		adapter->rx_buf_per_pkt, adapter->tx_queue.tx_ring.size,
-		adapter->rx_queue.rx_ring[0].size,
-		adapter->rx_queue.rx_ring[1].size);
+		" %u %u %u\n", adapter->netdev->name,
+		adapter->skb_buf_size, adapter->rx_buf_per_pkt,
+		adapter->tx_queue.plugin_tq->ringSize,
+		adapter->tx_queue.shadow_ring.size,
+		adapter->rx_queue.plugin_rq->ringSize);
 
 	vmxnet3_tq_init(&adapter->tx_queue, adapter);
 	err = vmxnet3_rq_init(&adapter->rx_queue, adapter);
 	if (err) {
 		printk(KERN_ERR "Failed to init rx queue for %s: error %d\n",
-		       adapter->netdev->name, err);
+				adapter->netdev->name, err);
 		goto rq_err;
 	}
 
 	err = vmxnet3_request_irqs(adapter);
 	if (err) {
 		printk(KERN_ERR "Failed to setup irq for %s: error %d\n",
-		       adapter->netdev->name, err);
+				adapter->netdev->name, err);
 		goto irq_err;
 	}
 
 	vmxnet3_setup_driver_shared(adapter);
 
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAL, VMXNET3_GET_ADDR_LO(
-			       adapter->shared_pa));
+				adapter->shared_pa));
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAH, VMXNET3_GET_ADDR_HI(
-			       adapter->shared_pa));
-	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-			       VMXNET3_CMD_ACTIVATE_DEV);
-	ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
-
-	if (ret != 0) {
-		printk(KERN_ERR "Failed to activate dev %s: error %u\n",
-		       adapter->netdev->name, ret);
-		err = -EINVAL;
-		goto activate_err;
+				adapter->shared_pa));
+	if (!load_plugin) {
+		NPA_PluginMain(&adapter->plugin_api);
+		adapter->plugin.memioAddr = adapter->hw_addr0;
+		memset(adapter->plugin.deviceInfo, 0,
+				sizeof(adapter->plugin.deviceInfo));
+		adapter->plugin.shared = NULL;
+		adapter->plugin.sharedLen = 0;
+		printk(KERN_ERR "Using s/w api for %s\n",
+				adapter->netdev->name);
+	} else {
+		NPA_PluginMainFunc *plugin_main;
+		plugin_main = vmxnet3_load_plugin(adapter);
+		/* plugin memioAddr and deviceInfo are set in load_plugin */
+		adapter->plugin.shared =
+			(void *)ALIGN((uintptr_t)adapter->plugin_shared,
+					PAGE_SIZE);
+		adapter->plugin.sharedLen = NPA_SHARED_NUMPAGES * PAGE_SIZE;
+		if (plugin_main == NULL) {
+			printk(KERN_ERR "Failed to load plugin for %s\n",
+					adapter->netdev->name);
+			err = -EINVAL;
+			goto load_plugin_err;
+		}
+		printk(KERN_ERR "Using h/w api %p for %s\n", plugin_main,
+				adapter->netdev->name);
+		plugin_main(&adapter->plugin_api);
+	}
+
+	dev_dbg(&adapter->pdev->dev,
+		"%s: Plugin API:\n"
+		"swInit: %p\n"
+		"reinitTxRing: %p\n"
+		"reinitRxRing: %p\n"
+		"enableInterrupt: %p\n"
+		"disableInterrupt: %p\n"
+		"addFrameToTxRing: %p\n"
+		"checkTxRing: %p\n"
+		"checkRxRing: %p\n"
+		"addBuffersToRxRing: %p\n",
+		adapter->netdev->name,
+		adapter->plugin_api.swInit,
+		adapter->plugin_api.reinitTxRing,
+		adapter->plugin_api.reinitRxRing,
+		adapter->plugin_api.enableInterrupt,
+		adapter->plugin_api.disableInterrupt,
+		adapter->plugin_api.addFrameToTxRing,
+		adapter->plugin_api.checkTxRing,
+		adapter->plugin_api.checkRxRing,
+		adapter->plugin_api.addBuffersToRxRing);
+
+	BUG_ON(!adapter->plugin_api.swInit);
+	BUG_ON(!adapter->plugin_api.reinitTxRing);
+	BUG_ON(!adapter->plugin_api.reinitRxRing);
+	BUG_ON(!adapter->plugin_api.enableInterrupt);
+	BUG_ON(!adapter->plugin_api.disableInterrupt);
+	BUG_ON(!adapter->plugin_api.addFrameToTxRing);
+	BUG_ON(!adapter->plugin_api.checkTxRing);
+	BUG_ON(!adapter->plugin_api.checkRxRing);
+	BUG_ON(!adapter->plugin_api.addBuffersToRxRing);
+
+	Plugin_SwInit(adapter);
+
+	Plugin_ReinitTxRing(adapter, 0);
+	Plugin_ReinitRxRing(adapter, 0);
+
+	if (!load_plugin) {
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				VMXNET3_CMD_ACTIVATE_DEV);
+		ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+		if (ret != 0) {
+			printk(KERN_ERR "Failed to activate dev %s: error %u\n",
+					adapter->netdev->name, ret);
+			err = -EINVAL;
+			goto activate_err;
+		}
+	} else {
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				VMXNET3_CMD_ACTIVATE_VF);
+		ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+		if (ret != VMXNET3_NPA_CMD_SUCCESS) {
+			printk(KERN_ERR "Failed to activate vf %s: error %u\n",
+					adapter->netdev->name, ret);
+			err = -EINVAL;
+			goto activate_err;
+		}
 	}
-	VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_RXPROD,
-			       adapter->rx_queue.rx_ring[0].next2fill);
-	VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_RXPROD2,
-			       adapter->rx_queue.rx_ring[1].next2fill);
+
+	adapter->passthru = load_plugin;
+	Plugin_AddBuffersToRxRing(adapter, 0);
 
 	/* Apply the rx filter settins last. */
 	vmxnet3_set_mc(adapter->netdev);
@@ -1897,6 +1741,12 @@ vmxnet3_activate_dev(struct vmxnet3_adapter
*adapter)
 	return 0;
 
 activate_err:
+	if (load_plugin) {
+		spin_lock(&vmxnet3_plugin_code_lock);
+		vmxnet3_plugin_code_used[adapter->plugin_region_idx] = false;
+		spin_unlock(&vmxnet3_plugin_code_lock);
+	}
+load_plugin_err:
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAL, 0);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAH, 0);
 	vmxnet3_free_irqs(adapter);
@@ -1914,18 +1764,41 @@ vmxnet3_reset_dev(struct vmxnet3_adapter
*adapter)
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
VMXNET3_CMD_RESET_DEV);
 }
 
+/*
+ * soft_quiesce indicates to quiesce the software (emulated)
+ * device. It doesn't completely stop the vmxnet3 backend. It has to
+ * be used when switching to passthrough.
+ */
 
 int
-vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter)
+vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter, bool soft_quiesce)
 {
 	if (test_and_set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state))
 		return 0;
+	if (soft_quiesce) {
+		u32 result;
 
-
-	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-			       VMXNET3_CMD_QUIESCE_DEV);
+		BUG_ON(adapter->passthru);
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_STOP_EMULATION);
+		result = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+		if (result != VMXNET3_NPA_CMD_SUCCESS) {
+			printk(KERN_INFO "%s: failed to stop emulation 0x%x\n",
+			       adapter->netdev->name, result);
+			clear_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
+			return 1;
+		}
+	} else {
+		if (adapter->passthru) {
+			spin_lock(&vmxnet3_plugin_code_lock);
+			vmxnet3_plugin_code_used[adapter->plugin_region_idx] =
+				false;
+			spin_unlock(&vmxnet3_plugin_code_lock);
+		}
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_QUIESCE_DEV);
+	}
 	vmxnet3_disable_all_intrs(adapter);
-
 	napi_disable(&adapter->napi);
 	netif_tx_disable(adapter->netdev);
 	adapter->link_speed = 0;
@@ -2056,54 +1929,63 @@ vmxnet3_adjust_rx_ring_size(struct
vmxnet3_adapter *adapter)
 {
 	size_t sz;
 
-	if (adapter->netdev->mtu <= VMXNET3_MAX_SKB_BUF_SIZE -
-				    VMXNET3_MAX_ETH_HDR_SIZE) {
-		adapter->skb_buf_size = adapter->netdev->mtu +
-					VMXNET3_MAX_ETH_HDR_SIZE;
+	if (adapter->netdev->mtu <= SHELL_SMALL_RECV_BUFFER_SIZE) {
+		if (!adapter->lro) {
+			adapter->skb_buf_size = adapter->netdev->mtu +
+				VMXNET3_MAX_ETH_HDR_SIZE;
+		} else {
+			adapter->skb_buf_size = SHELL_SMALL_RECV_BUFFER_SIZE +
+				VMXNET3_MAX_ETH_HDR_SIZE;
+		}
 		if (adapter->skb_buf_size < VMXNET3_MIN_T0_BUF_SIZE)
 			adapter->skb_buf_size = VMXNET3_MIN_T0_BUF_SIZE;
 
 		adapter->rx_buf_per_pkt = 1;
 	} else {
-		adapter->skb_buf_size = VMXNET3_MAX_SKB_BUF_SIZE;
-		sz = adapter->netdev->mtu - VMXNET3_MAX_SKB_BUF_SIZE +
-					    VMXNET3_MAX_ETH_HDR_SIZE;
-		adapter->rx_buf_per_pkt = 1 + (sz + PAGE_SIZE - 1) / PAGE_SIZE;
+		adapter->skb_buf_size = SHELL_SMALL_RECV_BUFFER_SIZE +
+			VMXNET3_MAX_ETH_HDR_SIZE;
+		sz = adapter->netdev->mtu - adapter->skb_buf_size;
+		adapter->rx_buf_per_pkt =
+			1 + (sz + SHELL_LARGE_RECV_BUFFER_SIZE - 1) /
+			SHELL_LARGE_RECV_BUFFER_SIZE;
 	}
 
 	/*
-	 * for simplicity, force the ring0 size to be a multiple of
+	 * for simplicity, force the ring size to be a multiple of
 	 * rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN
 	 */
 	sz = adapter->rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN;
-	adapter->rx_queue.rx_ring[0].size = (adapter->rx_queue.rx_ring[0].size
+
-					     sz - 1) / sz * sz;
-	adapter->rx_queue.rx_ring[0].size = min_t(u32,
-					    adapter->rx_queue.rx_ring[0].size,
-					    VMXNET3_RX_RING_MAX_SIZE / sz * sz);
+	adapter->rx_queue.plugin_rq->ringSize =
+				(adapter->rx_queue.plugin_rq->ringSize + sz - 1)
+				/ sz * sz;
+	adapter->rx_queue.plugin_rq->ringSize = min_t(u32,
+					adapter->rx_queue.plugin_rq->ringSize,
+					VMXNET3_RX_RING_MAX_SIZE / sz * sz);
 }
 
 
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32
tx_ring_size,
-		      u32 rx_ring_size, u32 rx_ring2_size)
+		      u32 rx_ring_size)
 {
-	int err;
+	int err = 0;
 
-	adapter->tx_queue.tx_ring.size   = tx_ring_size;
+	adapter->tx_queue.adapter = adapter;
+	adapter->tx_queue.plugin_tq = adapter->plugin.txQueues;
+	adapter->tx_queue.plugin_tq->ringSize = tx_ring_size;
 	adapter->tx_queue.data_ring.size = tx_ring_size;
-	adapter->tx_queue.comp_ring.size = tx_ring_size;
 	adapter->tx_queue.shared = &adapter->tqd_start->ctrl;
 	adapter->tx_queue.stopped = true;
+	adapter->tx_queue.qid = 0;
 	err = vmxnet3_tq_create(&adapter->tx_queue, adapter);
 	if (err)
 		return err;
 
-	adapter->rx_queue.rx_ring[0].size = rx_ring_size;
-	adapter->rx_queue.rx_ring[1].size = rx_ring2_size;
+	adapter->rx_queue.adapter = adapter;
+	adapter->rx_queue.plugin_rq = &adapter->plugin.rxQueues[0];
+
+	adapter->rx_queue.plugin_rq->ringSize = rx_ring_size;
 	vmxnet3_adjust_rx_ring_size(adapter);
-	adapter->rx_queue.comp_ring.size  = adapter->rx_queue.rx_ring[0].size
+
-					    adapter->rx_queue.rx_ring[1].size;
 	adapter->rx_queue.qid  = 0;
 	adapter->rx_queue.qid2 = 1;
 	adapter->rx_queue.shared = &adapter->rqd_start->ctrl;
@@ -2114,23 +1996,273 @@ vmxnet3_create_queues(struct vmxnet3_adapter
*adapter, u32 tx_ring_size,
 	return err;
 }
 
+
+/*
+ *	Vmxnet3 Shell APIs
+ */
+
+static void
+vmxnet3_shell_log(size_t nargs, const char *str, ...)
+{
+	va_list va;
+
+	va_start(va, str);
+	printk(str, va);
+	va_end(va);
+}
+
+
+static void
+vmxnet3_shell_complete_send(struct Shell_TxQueueHandle *handle, u32
numPkts)
+{
+	struct vmxnet3_tx_queue *tq = (struct vmxnet3_tx_queue *)handle;
+	struct vmxnet3_adapter *adapter = tq->adapter;
+	int i;
+
+	/* do in-order completion only */
+	for (i = 0; i < numPkts; i++) {
+		vmxnet3_unmap_pkt(tq, adapter->pdev, adapter);
+		vmxnet3_tx_data_ring_adv_next2comp(&tq->data_ring);
+	}
+
+	spin_lock(&tq->tx_lock);
+	/*
+	 * XXX: PR 531329, we should wake the queue based on plugin
+	 * ring and not shadow ring
+	 */
+	if (unlikely(vmxnet3_tq_stopped(tq, adapter) &&
+		     (vmxnet3_tx_shadow_ring_desc_avail(&tq->shadow_ring) >
+		      VMXNET3_WAKE_QUEUE_SHADOW_THRESHOLD(tq) &&
+		      vmxnet3_tx_data_ring_desc_avail(&tq->data_ring) >
+		      VMXNET3_WAKE_QUEUE_DATA_THRESHOLD(tq)) &&
+		     netif_carrier_ok(adapter->netdev))) {
+		vmxnet3_tq_wake(tq, adapter);
+	}
+	spin_unlock(&tq->tx_lock);
+}
+
+
+static u64
+vmxnet3_shell_alloc_small_buffer(struct Shell_RxQueueHandle *handle,
+				 u32 ringOffset)
+{
+	struct vmxnet3_rx_queue *rq = (struct vmxnet3_rx_queue *)handle;
+	struct vmxnet3_adapter *adapter = rq->adapter;
+	struct vmxnet3_rx_buf_info *rbi = rq->buf_info + ringOffset;
+
+	BUG_ON(ringOffset >= rq->plugin_rq->ringSize *
+			PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE);
+
+	if (rbi->buf_type != VMXNET3_RX_BUF_NONE) {
+		dev_dbg(&adapter->pdev->dev, "%s: alloc_small_buffer:[%u] %u\n",
+			adapter->netdev->name, ringOffset, rbi->buf_type);
+		rq->stats.rx_buf_cookie_error++;
+		return 0;
+	}
+
+	rbi->len = adapter->skb_buf_size;
+	rbi->skb = dev_alloc_skb(rbi->len + NET_IP_ALIGN);
+	if (unlikely(rbi->skb == NULL)) {
+		rq->stats.rx_buf_alloc_failure++;
+		return 0;
+	}
+	skb_reserve(rbi->skb, NET_IP_ALIGN);
+
+	rbi->skb->dev = adapter->netdev;
+	rbi->dma_addr = pci_map_single(adapter->pdev, rbi->skb->data,
rbi->len,
+			PCI_DMA_FROMDEVICE);
+	rbi->buf_type = VMXNET3_RX_BUF_SKB;
+
+	rq->avail_skbs++;
+	return rbi->dma_addr;
+}
+
+
+static u64
+vmxnet3_shell_alloc_large_buffer(struct Shell_RxQueueHandle *handle,
+		u32 ringOffset)
+{
+	struct vmxnet3_rx_queue *rq = (struct vmxnet3_rx_queue *)handle;
+	struct vmxnet3_adapter *adapter = rq->adapter;
+	struct vmxnet3_rx_buf_info *rbi = rq->buf_info + ringOffset;
+
+
+	BUG_ON(ringOffset >= rq->plugin_rq->ringSize *
+	       PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE);
+
+	if (rbi->buf_type != VMXNET3_RX_BUF_NONE) {
+		dev_dbg(&adapter->pdev->dev, "%s:alloc_large_buffer: [%u] %u\n",
+			adapter->netdev->name, ringOffset, rbi->buf_type);
+		rq->stats.rx_buf_cookie_error++;
+		return 0;
+	}
+
+	BUILD_BUG_ON(SHELL_LARGE_RECV_BUFFER_SIZE != PAGE_SIZE);
+	rbi->len = SHELL_LARGE_RECV_BUFFER_SIZE;
+	rbi->page = alloc_page(GFP_ATOMIC);
+
+	if (unlikely(rbi->page == NULL)) {
+		rq->stats.rx_buf_alloc_failure++;
+		return 0;
+	}
+	rbi->dma_addr = pci_map_page(adapter->pdev, rbi->page, 0, PAGE_SIZE,
+			PCI_DMA_FROMDEVICE);
+	rbi->buf_type = VMXNET3_RX_BUF_PAGE;
+
+	return rbi->dma_addr;
+}
+
+
+	static void
+vmxnet3_shell_free_buffer(struct Shell_RxQueueHandle *handle,
+		u32 ringOffset)
+{
+	struct vmxnet3_rx_queue *rq = (struct vmxnet3_rx_queue *)handle;
+	struct vmxnet3_adapter *adapter = rq->adapter;
+	struct vmxnet3_rx_buf_info *rbi = rq->buf_info + ringOffset;
+
+	BUG_ON(ringOffset >= rq->plugin_rq->ringSize *
+	       PLUGIN_SHARED_AREA_RX_ALLOCATION_MULTIPLE);
+	BUG_ON(rbi->buf_type == VMXNET3_RX_BUF_NONE);
+
+	if (rbi->buf_type == VMXNET3_RX_BUF_SKB) {
+		pci_unmap_single(adapter->pdev, rbi->dma_addr, rbi->len,
+				 PCI_DMA_FROMDEVICE);
+		dev_kfree_skb(rbi->skb);
+		rq->avail_skbs--;
+		rbi->skb = NULL;
+	} else if (rbi->buf_type == VMXNET3_RX_BUF_PAGE) {
+		pci_unmap_page(adapter->pdev, rbi->dma_addr, rbi->len,
+			       PCI_DMA_FROMDEVICE);
+		put_page(rbi->page);
+		rbi->page = NULL;
+	}
+	rbi->buf_type = VMXNET3_RX_BUF_NONE;
+}
+
+
+static u32
+vmxnet3_shell_indicate_recv(struct Shell_RxQueueHandle *handle,
+			    struct Shell_RecvFrame *frame)
+{
+	struct vmxnet3_rx_queue *rq = (struct vmxnet3_rx_queue *)handle;
+	struct vmxnet3_adapter *adapter = rq->adapter;
+	struct vmxnet3_rx_buf_info *rbi;
+	struct sk_buff *skb;
+	int i;
+
+	rbi = rq->buf_info + frame->sg[0].ringOffset;
+	BUG_ON(rbi->buf_type != VMXNET3_RX_BUF_SKB);
+	skb = rbi->skb;
+	BUG_ON(frame->sgLength == 0);
+	rq->avail_skbs--;
+	rbi->skb = NULL;
+	pci_unmap_single(adapter->pdev, rbi->dma_addr, rbi->len,
+			 PCI_DMA_FROMDEVICE);
+
+	skb_reserve(skb, 0);
+	skb_put(skb, frame->sg[0].length);
+	rbi->buf_type = VMXNET3_RX_BUF_NONE;
+
+	for (i = 1; i < frame->sgLength; i++) {
+		rbi = rq->buf_info + frame->sg[i].ringOffset;
+		BUG_ON(rbi->buf_type != VMXNET3_RX_BUF_PAGE);
+
+		pci_unmap_page(rq->adapter->pdev, rbi->dma_addr,
+			       rbi->len, PCI_DMA_FROMDEVICE);
+		vmxnet3_append_frag(skb, frame->sg + i, rbi);
+		rbi->page = NULL;
+		rbi->buf_type = VMXNET3_RX_BUF_NONE;
+	}
+
+	skb->len += skb->data_len;
+	skb->truesize += skb->data_len;
+
+	skb->ip_summed = CHECKSUM_NONE;
+	if (adapter->rxcsum && (frame->ipv4 || frame->ipv6)) {
+		if (frame->ipXsum != SHELL_XSUM_CORRECT)
+			skb->ip_summed = CHECKSUM_NONE;
+		else if ((frame->tcp &&
+			  frame->tcpXsum != SHELL_XSUM_CORRECT) ||
+			 (frame->udp &&
+			  frame->udpXsum != SHELL_XSUM_CORRECT))
+			skb->ip_summed = CHECKSUM_NONE;
+		else {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		}
+	}
+
+	skb->protocol = eth_type_trans(skb, adapter->netdev);
+
+	if (unlikely(adapter->vlan_grp && frame->vlan)) {
+		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
+					 frame->vlanTag);
+	} else {
+		netif_receive_skb(skb);
+	}
+
+	rq->rxd_done++;
+	adapter->netdev->last_rx = jiffies;
+
+	return 0;
+}
+
+
+
+
 static int
 vmxnet3_open(struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter;
 	int err;
+	struct Plugin_State *plugin;
 
 	adapter = netdev_priv(netdev);
-
+	plugin = &adapter->plugin;
+
+	plugin->size = sizeof(*plugin);
+	plugin->majorVersion = 1;
+	plugin->minorVersion = 0;
+	plugin->offsetToPrivateSpace = offsetof(struct Plugin_State,
+						privateSpace);
+
+	plugin->shellApi.allocSmallBuffer = vmxnet3_shell_alloc_small_buffer;
+	plugin->shellApi.allocLargeBuffer = vmxnet3_shell_alloc_large_buffer;
+	plugin->shellApi.freeBuffer = vmxnet3_shell_free_buffer;
+	plugin->shellApi.completeSend = vmxnet3_shell_complete_send;
+	plugin->shellApi.indicateRecv = vmxnet3_shell_indicate_recv;
+	plugin->shellApi.log = vmxnet3_shell_log;
+
+	plugin->mtu = adapter->netdev->mtu;
+
+	plugin->numTxQueues = 1;
+	plugin->txQueues->handle = (struct Shell_TxQueueHandle *)
+							&adapter->tx_queue;
 	spin_lock_init(&adapter->tx_queue.tx_lock);
 
+	plugin->numRxQueues = 1;
+	plugin->rxQueues->handle = (struct Shell_RxQueueHandle *)
+							&adapter->rx_queue;
+
+	if (adapter->lro)
+		plugin->features = PLUGIN_FEATURES_LRO;
+
 	err = vmxnet3_create_queues(adapter, VMXNET3_DEF_TX_RING_SIZE,
-				    VMXNET3_DEF_RX_RING_SIZE,
 				    VMXNET3_DEF_RX_RING_SIZE);
 	if (err)
 		goto queue_err;
-
-	err = vmxnet3_activate_dev(adapter);
+	dev_dbg(&adapter->pdev->dev, "rxQueues[0] %p %llu %u %u\n",
+		plugin->rxQueues[0].ringBaseVA,
+		plugin->rxQueues[0].ringBasePA,
+		plugin->rxQueues[0].ringLength,
+		plugin->rxQueues[0].ringSize);
+	dev_dbg(&adapter->pdev->dev, "txQueues[0] %p %llu %u %u\n",
+		plugin->txQueues[0].ringBaseVA,
+		plugin->txQueues[0].ringBasePA,
+		plugin->txQueues[0].ringLength,
+		plugin->txQueues[0].ringSize);
+
+	err = vmxnet3_activate_dev(adapter, false);
 	if (err)
 		goto activate_err;
 
@@ -2156,7 +2288,7 @@ vmxnet3_close(struct net_device *netdev)
 	while (test_and_set_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state))
 		msleep(1);
 
-	vmxnet3_quiesce_dev(adapter);
+	vmxnet3_quiesce_dev(adapter, false);
 
 	vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
 	vmxnet3_tq_destroy(&adapter->tx_queue, adapter);
@@ -2205,15 +2337,12 @@ vmxnet3_change_mtu(struct net_device *netdev,
int new_mtu)
 		msleep(1);
 
 	if (netif_running(netdev)) {
-		vmxnet3_quiesce_dev(adapter);
+		vmxnet3_quiesce_dev(adapter, false);
 		vmxnet3_reset_dev(adapter);
 
 		/* we need to re-create the rx queue based on the new mtu */
 		vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
 		vmxnet3_adjust_rx_ring_size(adapter);
-		adapter->rx_queue.comp_ring.size  =
-					adapter->rx_queue.rx_ring[0].size +
-					adapter->rx_queue.rx_ring[1].size;
 		err = vmxnet3_rq_create(&adapter->rx_queue, adapter);
 		if (err) {
 			printk(KERN_ERR "%s: failed to re-create rx queue,"
@@ -2221,7 +2350,7 @@ vmxnet3_change_mtu(struct net_device *netdev, int
new_mtu)
 			goto out;
 		}
 
-		err = vmxnet3_activate_dev(adapter);
+		err = vmxnet3_activate_dev(adapter, false);
 		if (err) {
 			printk(KERN_ERR "%s: failed to re-activate, error %d. "
 				"Closing it\n", netdev->name, err);
@@ -2249,7 +2378,6 @@ vmxnet3_declare_features(struct vmxnet3_adapter
*adapter, bool dma64)
 		NETIF_F_HW_VLAN_RX |
 		NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_TSO |
-		NETIF_F_TSO6 |
 		NETIF_F_LRO;
 
 	printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6 lro");
@@ -2258,6 +2386,11 @@ vmxnet3_declare_features(struct vmxnet3_adapter
*adapter, bool dma64)
 	adapter->jumbo_frame = true;
 	adapter->lro = true;
 
+#ifdef NETIF_F_TSO6
+	netdev->features |= NETIF_F_TSO6;
+	printk(KERN_INFO " tsoIPv6");
+#endif
+
 	if (dma64) {
 		netdev->features |= NETIF_F_HIGHDMA;
 		printk(" highDMA");
@@ -2294,6 +2427,7 @@ vmxnet3_alloc_intr_resources(struct
vmxnet3_adapter *adapter)
 	adapter->intr.type = cfg & 0x3;
 	adapter->intr.mask_mode = (cfg >> 2) & 0x3;
 
+#ifdef CONFIG_PCI_MSI
 	if (adapter->intr.type == VMXNET3_IT_AUTO) {
 		int err;
 
@@ -2316,6 +2450,7 @@ vmxnet3_alloc_intr_resources(struct
vmxnet3_adapter *adapter)
 		}
 	}
 
+#endif
 	adapter->intr.type = VMXNET3_IT_INTX;
 
 	/* INT-X related setting */
@@ -2358,11 +2493,12 @@ vmxnet3_reset_work(struct work_struct *data)
 		return;
 
 	/* if the device is closed, we must leave it alone */
-	if (netif_running(adapter->netdev)) {
+	if (netif_running(adapter->netdev) &&
+	    (adapter->netdev->flags & IFF_UP)) {
 		printk(KERN_INFO "%s: resetting\n", adapter->netdev->name);
-		vmxnet3_quiesce_dev(adapter);
+		vmxnet3_quiesce_dev(adapter, false);
 		vmxnet3_reset_dev(adapter);
-		vmxnet3_activate_dev(adapter);
+		vmxnet3_activate_dev(adapter, false);
 	} else {
 		printk(KERN_INFO "%s: already closed\n", adapter->netdev->name);
 	}
@@ -2370,6 +2506,53 @@ vmxnet3_reset_work(struct work_struct *data)
 	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
 }
 
+static void
+vmxnet3_passthru_work(struct work_struct *data)
+{
+	struct vmxnet3_adapter *adapter;
+
+	adapter = container_of(data, struct vmxnet3_adapter, passthru_work);
+
+	/* if another thread is resetting the device, wait for it to complete
*/
+	while (test_and_set_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state))
+		msleep(1);
+
+	/* if the device is closed, we must leave it alone */
+	if (netif_running(adapter->netdev)) {
+		if (vmxnet3_quiesce_dev(adapter, true) == 0) {
+			if (vmxnet3_activate_dev(adapter, true) == 0) {
+				printk(KERN_ERR "%s: passthru mode\n",
+				       adapter->netdev->name);
+			} else {
+				printk(KERN_INFO "%s: activate dev failed\n",
+				       adapter->netdev->name);
+				/*
+				 * We already have quiesced the
+				 * adapter in the guest; tell the
+				 * device BE to do a hard quiesce
+				 */
+				VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+						       VMXNET3_CMD_QUIESCE_DEV);
+				vmxnet3_reset_dev(adapter);
+				vmxnet3_activate_dev(adapter, false);
+				printk(KERN_ERR "%s: emulation mode\n",
+				      adapter->netdev->name);
+			}
+		} else {
+			printk(KERN_INFO "%s: soft quiesce failed\n",
+			       adapter->netdev->name);
+			vmxnet3_quiesce_dev(adapter, false);
+			vmxnet3_reset_dev(adapter);
+			vmxnet3_activate_dev(adapter, false);
+			printk(KERN_ERR "%s: emulation mode\n",
+			       adapter->netdev->name);
+		}
+	} else {
+		printk(KERN_INFO "%s: already closed\n", adapter->netdev->name);
+	}
+	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
+}
+
 
 static int __devinit
 vmxnet3_probe_device(struct pci_dev *pdev,
@@ -2442,6 +2625,33 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_pm;
 	}
 
+	adapter->plugin_conf = kmalloc(sizeof(struct NPA_PluginConf),
+				       GFP_KERNEL);
+	if (adapter->plugin_conf == NULL) {
+		printk(KERN_ERR "Failed to allocate memory for %s\n",
+		       pci_name(pdev));
+		err = -ENOMEM;
+		goto err_alloc_plugin_conf;
+	}
+
+	adapter->plugin_memio =
+		pci_alloc_consistent(adapter->pdev,
+				     (NPA_MEMIO_NUMPAGES + 1) * PAGE_SIZE,
+				     &adapter->plugin_memio_pa);
+	if (!adapter->plugin_memio) {
+		err = -ENOMEM;
+		goto err_alloc_plugin_mmio;
+	}
+
+	adapter->plugin_shared =
+		pci_alloc_consistent(adapter->pdev,
+				     (NPA_SHARED_NUMPAGES + 1) * PAGE_SIZE,
+				     &adapter->plugin_shared_pa);
+	if (!adapter->plugin_shared) {
+		err = -ENOMEM;
+		goto err_alloc_plugin_shared;
+	}
+
 	err = vmxnet3_alloc_pci_resources(adapter, &dma64);
 	if (err < 0)
 		goto err_alloc_pci;
@@ -2479,8 +2689,10 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	vmxnet3_set_ethtool_ops(netdev);
 
 	INIT_WORK(&adapter->work, vmxnet3_reset_work);
+	INIT_WORK(&adapter->passthru_work, vmxnet3_passthru_work);
 
 	netif_napi_add(netdev, &adapter->napi, vmxnet3_poll, 64);
+
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	err = register_netdev(netdev);
 
@@ -2499,6 +2711,16 @@ err_register:
 err_ver:
 	vmxnet3_free_pci_resources(adapter);
 err_alloc_pci:
+	pci_free_consistent(adapter->pdev,
+			    (NPA_SHARED_NUMPAGES + 1) * PAGE_SIZE,
+			    adapter->plugin_shared, adapter->plugin_shared_pa);
+err_alloc_plugin_shared:
+	pci_free_consistent(adapter->pdev,
+			    (NPA_MEMIO_NUMPAGES + 1) * PAGE_SIZE,
+			    adapter->plugin_memio, adapter->plugin_memio_pa);
+err_alloc_plugin_mmio:
+	kfree(adapter->plugin_conf);
+err_alloc_plugin_conf:
 	kfree(adapter->pm_conf);
 err_alloc_pm:
 	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_TxQueueDesc)
+
@@ -2526,6 +2748,13 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 
 	vmxnet3_free_intr_resources(adapter);
 	vmxnet3_free_pci_resources(adapter);
+	pci_free_consistent(adapter->pdev,
+			    (NPA_SHARED_NUMPAGES + 1) * PAGE_SIZE,
+			    adapter->plugin_shared, adapter->plugin_shared_pa);
+	pci_free_consistent(adapter->pdev,
+			    (NPA_MEMIO_NUMPAGES + 1) * PAGE_SIZE,
+			    adapter->plugin_memio, adapter->plugin_memio_pa);
+	kfree(adapter->plugin_conf);
 	kfree(adapter->pm_conf);
 	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_TxQueueDesc)
+
 			    sizeof(struct Vmxnet3_RxQueueDesc),
@@ -2703,8 +2932,14 @@ static struct pci_driver vmxnet3_driver = {
 static int __init
 vmxnet3_init_module(void)
 {
+	int i;
+
 	printk(KERN_INFO "%s - version %s\n", VMXNET3_DRIVER_DESC,
 		VMXNET3_DRIVER_VERSION_REPORT);
+	spin_lock_init(&vmxnet3_plugin_code_lock);
+	for (i = 0; i < NPA_MAX_PLUGINS_PER_VM; i++)
+		vmxnet3_plugin_code_used[i] = false;
+
 	return pci_register_driver(&vmxnet3_driver);
 }
 
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c
b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 3935c44..236ca88 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -127,12 +127,10 @@ vmxnet3_rq_driver_stats[] = {
 	/* description,         offset */
 	{ "drv dropped rx total", offsetof(struct vmxnet3_rq_driver_stats,
 					   drop_total) },
-	{ "   err",            offsetof(struct vmxnet3_rq_driver_stats,
-					drop_err) },
-	{ "   fcs",            offsetof(struct vmxnet3_rq_driver_stats,
-					drop_fcs) },
 	{ "rx buf alloc fail", offsetof(struct vmxnet3_rq_driver_stats,
 					rx_buf_alloc_failure) },
+	{ "rx buf bad cookie", offsetof(struct vmxnet3_rq_driver_stats,
+					rx_buf_cookie_error) },
 };
 
 /* gloabl stats maintained by the driver */
@@ -213,7 +211,7 @@ vmxnet3_get_sset_count(struct net_device *netdev,
int sset)
 static int
 vmxnet3_get_regs_len(struct net_device *netdev)
 {
-	return 20 * sizeof(u32);
+	return 16 * sizeof(u32);
 }
 
 
@@ -347,32 +345,26 @@ vmxnet3_get_regs(struct net_device *netdev, struct
ethtool_regs *regs, void *p)
 	regs->version = 1;
 
 	/* Update vmxnet3_get_regs_len if we want to dump more registers */
-
 	/* make each ring use multiple of 16 bytes */
-	buf[0] = adapter->tx_queue.tx_ring.next2fill;
-	buf[1] = adapter->tx_queue.tx_ring.next2comp;
-	buf[2] = adapter->tx_queue.tx_ring.gen;
+	buf[0] = adapter->tx_queue.plugin_tq->ringSize;
+	buf[1] = 0;
+	buf[2] = adapter->tx_queue.stopped;
 	buf[3] = 0;
 
-	buf[4] = adapter->tx_queue.comp_ring.next2proc;
-	buf[5] = adapter->tx_queue.comp_ring.gen;
-	buf[6] = adapter->tx_queue.stopped;
-	buf[7] = 0;
+	buf[4] = adapter->tx_queue.shadow_ring.next2fill;
+	buf[5] = adapter->tx_queue.shadow_ring.next2comp;
+	buf[6] = adapter->tx_queue.data_ring.next2fill;
+	buf[7] = adapter->tx_queue.data_ring.next2comp;
 
-	buf[8] = adapter->rx_queue.rx_ring[0].next2fill;
-	buf[9] = adapter->rx_queue.rx_ring[0].next2comp;
-	buf[10] = adapter->rx_queue.rx_ring[0].gen;
+	buf[8] = adapter->rx_queue.plugin_rq->ringSize;
+	buf[9] = 0;
+	buf[10] = adapter->rx_queue.avail_skbs;
 	buf[11] = 0;
 
-	buf[12] = adapter->rx_queue.rx_ring[1].next2fill;
-	buf[13] = adapter->rx_queue.rx_ring[1].next2comp;
-	buf[14] = adapter->rx_queue.rx_ring[1].gen;
+	buf[12] = adapter->passthru;
+	buf[13] = adapter->passthru ? adapter->plugin_region_idx : 0;
+	buf[14] = 0;
 	buf[15] = 0;
-
-	buf[16] = adapter->rx_queue.comp_ring.next2proc;
-	buf[17] = adapter->rx_queue.comp_ring.gen;
-	buf[18] = 0;
-	buf[19] = 0;
 }
 
 
@@ -437,8 +429,8 @@ vmxnet3_get_ringparam(struct net_device *netdev,
 	param->rx_mini_max_pending = 0;
 	param->rx_jumbo_max_pending = 0;
 
-	param->rx_pending = adapter->rx_queue.rx_ring[0].size;
-	param->tx_pending = adapter->tx_queue.tx_ring.size;
+	param->rx_pending = adapter->rx_queue.plugin_rq->ringSize;
+	param->tx_pending = adapter->tx_queue.plugin_tq->ringSize;
 	param->rx_mini_pending = 0;
 	param->rx_jumbo_pending = 0;
 }
@@ -467,9 +459,16 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 							~VMXNET3_RING_SIZE_MASK;
 	new_tx_ring_size = min_t(u32, new_tx_ring_size,
 				 VMXNET3_TX_RING_MAX_SIZE);
-	if (new_tx_ring_size > VMXNET3_TX_RING_MAX_SIZE || (new_tx_ring_size %
-						VMXNET3_RING_SIZE_ALIGN) != 0)
+
+	sz = adapter->rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN;
+	new_rx_ring_size = (param->rx_pending + sz - 1) / sz * sz;
+	new_rx_ring_size = min_t(u32, new_rx_ring_size,
+				 VMXNET3_RX_RING_MAX_SIZE / sz * sz);
+
+	if (new_tx_ring_size == adapter->tx_queue.plugin_tq->ringSize &&
+	    new_rx_ring_size == adapter->rx_queue.plugin_rq->ringSize) {
 		return -EINVAL;
+	}
 
 	/* ring0 has to be a multiple of
 	 * rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN
@@ -482,8 +481,8 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 							   sz) != 0)
 		return -EINVAL;
 
-	if (new_tx_ring_size == adapter->tx_queue.tx_ring.size &&
-			new_rx_ring_size == adapter->rx_queue.rx_ring[0].size) {
+	if (new_tx_ring_size == adapter->tx_queue.plugin_tq->ringSize &&
+	    new_rx_ring_size == adapter->rx_queue.plugin_rq->ringSize) {
 		return 0;
 	}
 
@@ -495,7 +494,7 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 		msleep(1);
 
 	if (netif_running(netdev)) {
-		vmxnet3_quiesce_dev(adapter);
+		vmxnet3_quiesce_dev(adapter, false);
 		vmxnet3_reset_dev(adapter);
 
 		/* recreate the rx queue and the tx queue based on the
@@ -504,7 +503,7 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 		vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
 
 		err = vmxnet3_create_queues(adapter, new_tx_ring_size,
-			new_rx_ring_size, VMXNET3_DEF_RX_RING_SIZE);
+			new_rx_ring_size);
 		if (err) {
 			/* failed, most likely because of OOM, try default
 			 * size */
@@ -512,7 +511,6 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 				" default ones\n", netdev->name);
 			err = vmxnet3_create_queues(adapter,
 						    VMXNET3_DEF_TX_RING_SIZE,
-						    VMXNET3_DEF_RX_RING_SIZE,
 						    VMXNET3_DEF_RX_RING_SIZE);
 			if (err) {
 				printk(KERN_ERR "%s: failed to create queues "
@@ -522,7 +520,7 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 			}
 		}
 
-		err = vmxnet3_activate_dev(adapter);
+		err = vmxnet3_activate_dev(adapter, false);
 		if (err)
 			printk(KERN_ERR "%s: failed to re-activate, error %d."
 				" Closing it\n", netdev->name, err);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h
b/drivers/net/vmxnet3/vmxnet3_int.h
index 34f392f..d14bff1 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -29,6 +29,7 @@
 
 #include <linux/ethtool.h>
 #include <linux/delay.h>
+#include <linux/if_link.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
 #include <linux/compiler.h>
@@ -55,8 +56,10 @@
 #include <linux/if_vlan.h>
 #include <linux/if_arp.h>
 #include <linux/inetdevice.h>
+#include <net/dst.h>
 
 #include "vmxnet3_defs.h"
+#include "npa_plugin_api.h"
 
 #ifdef DEBUG
 # define VMXNET3_DRIVER_VERSION_REPORT
VMXNET3_DRIVER_VERSION_STRING"-NAPI(debug)"
@@ -117,77 +120,82 @@ enum {
 #define MAX_ETHERNET_CARDS		10
 #define MAX_PCI_PASSTHRU_DEVICE		6
 
-struct vmxnet3_cmd_ring {
-	union Vmxnet3_GenericDesc *base;
-	u32		size;
-	u32		next2fill;
-	u32		next2comp;
-	u8		gen;
-	dma_addr_t	basePA;
+
+struct vmxnet3_tx_data_ring {
+	struct Vmxnet3_TxDataDesc  *base;
+	u32                 size;
+	u32		    next2fill;
+	u32		    next2comp;
+	dma_addr_t          basePA;
+};
+
+enum vmxnet3_buf_map_type {
+	VMXNET3_MAP_INVALID = 0,
+	VMXNET3_MAP_NONE,
+	VMXNET3_MAP_SINGLE,
+	VMXNET3_MAP_PAGE,
+};
+
+struct vmxnet3_tx_buf_info {
+	u32      map_type;
+	u16      len;
+	u16      eop_idx;
+	dma_addr_t  dma_addr;
+	struct sk_buff *skb;
+};
+
+/*
+ * we have no idea how much data we can put in a TXD, so for the
+ * bookkeeping let's allocate 8 times more descriptors
+ */
+#define VMXNET3_TX_SHADOW_RING_SIZE(_ringSize) ((_ringSize) * 8)
+
+struct vmxnet3_tx_shadow_ring {
+	struct vmxnet3_tx_buf_info	*base;
+	u32			size;
+	u32			next2fill;
+	u32			next2comp;
 };
 
 static inline void
-vmxnet3_cmd_ring_adv_next2fill(struct vmxnet3_cmd_ring *ring)
+vmxnet3_tx_shadow_ring_adv_next2comp(struct vmxnet3_tx_shadow_ring
*ring)
 {
-	ring->next2fill++;
-	if (unlikely(ring->next2fill == ring->size)) {
-		ring->next2fill = 0;
-		VMXNET3_FLIP_RING_GEN(ring->gen);
-	}
+	VMXNET3_INC_RING_IDX_ONLY(ring->next2comp, ring->size);
 }
 
 static inline void
-vmxnet3_cmd_ring_adv_next2comp(struct vmxnet3_cmd_ring *ring)
+vmxnet3_tx_shadow_ring_adv_next2fill(struct vmxnet3_tx_shadow_ring
*ring)
 {
-	VMXNET3_INC_RING_IDX_ONLY(ring->next2comp, ring->size);
+	VMXNET3_INC_RING_IDX_ONLY(ring->next2fill, ring->size);
 }
 
 static inline int
-vmxnet3_cmd_ring_desc_avail(struct vmxnet3_cmd_ring *ring)
+vmxnet3_tx_shadow_ring_desc_avail(struct vmxnet3_tx_shadow_ring *ring)
 {
 	return (ring->next2comp > ring->next2fill ? 0 : ring->size) +
 		ring->next2comp - ring->next2fill - 1;
 }
 
-struct vmxnet3_comp_ring {
-	union Vmxnet3_GenericDesc *base;
-	u32               size;
-	u32               next2proc;
-	u8                gen;
-	u8                intr_idx;
-	dma_addr_t           basePA;
-};
-
 static inline void
-vmxnet3_comp_ring_adv_next2proc(struct vmxnet3_comp_ring *ring)
+vmxnet3_tx_data_ring_adv_next2comp(struct vmxnet3_tx_data_ring *ring)
 {
-	ring->next2proc++;
-	if (unlikely(ring->next2proc == ring->size)) {
-		ring->next2proc = 0;
-		VMXNET3_FLIP_RING_GEN(ring->gen);
-	}
+	VMXNET3_INC_RING_IDX_ONLY(ring->next2comp, ring->size);
 }
 
-struct vmxnet3_tx_data_ring {
-	struct Vmxnet3_TxDataDesc *base;
-	u32              size;
-	dma_addr_t          basePA;
-};
 
-enum vmxnet3_buf_map_type {
-	VMXNET3_MAP_INVALID = 0,
-	VMXNET3_MAP_NONE,
-	VMXNET3_MAP_SINGLE,
-	VMXNET3_MAP_PAGE,
-};
+static inline void
+vmxnet3_tx_data_ring_adv_next2fill(struct vmxnet3_tx_data_ring *ring)
+{
+	VMXNET3_INC_RING_IDX_ONLY(ring->next2fill, ring->size);
+}
+
+static inline int
+vmxnet3_tx_data_ring_desc_avail(struct vmxnet3_tx_data_ring *ring)
+{
+	return (ring->next2comp > ring->next2fill ? 0 : ring->size) +
+		ring->next2comp - ring->next2fill - 1;
+}
 
-struct vmxnet3_tx_buf_info {
-	u32      map_type;
-	u16      len;
-	u16      sop_idx;
-	dma_addr_t  dma_addr;
-	struct sk_buff *skb;
-};
 
 struct vmxnet3_tq_driver_stats {
 	u64 drop_total;     /* # of pkts dropped by the driver, the
@@ -205,29 +213,23 @@ struct vmxnet3_tq_driver_stats {
 	u64 oversized_hdr;
 };
 
-struct vmxnet3_tx_ctx {
-	bool   ipv4;
-	u16 mss;
-	u32 eth_ip_hdr_size; /* only valid for pkts requesting tso or csum
-				 * offloading
-				 */
-	u32 l4_hdr_size;     /* only valid if mss != 0 */
-	u32 copy_size;       /* # of bytes copied into the data ring */
-	union Vmxnet3_GenericDesc *sop_txd;
-	union Vmxnet3_GenericDesc *eop_txd;
-};
+struct vmxnet3_adapter;
 
 struct vmxnet3_tx_queue {
+	struct vmxnet3_adapter	       *adapter;
 	spinlock_t                      tx_lock;
-	struct vmxnet3_cmd_ring         tx_ring;
-	struct vmxnet3_tx_buf_info     *buf_info;
+	struct Plugin_SendInfo          info;
+	struct Plugin_SgList            sg_list;
+	struct Plugin_TxQueueState     *plugin_tq;
+	struct vmxnet3_tx_shadow_ring   shadow_ring;
 	struct vmxnet3_tx_data_ring     data_ring;
-	struct vmxnet3_comp_ring        comp_ring;
-	struct Vmxnet3_TxQueueCtrl            *shared;
+	u8				intr_idx;
+	struct Vmxnet3_TxQueueCtrl      *shared;
 	struct vmxnet3_tq_driver_stats  stats;
 	bool                            stopped;
 	int                             num_stop;  /* # of times the queue is
 						    * stopped */
+	int				qid;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 enum vmxnet3_rx_buf_type {
@@ -246,29 +248,26 @@ struct vmxnet3_rx_buf_info {
 	dma_addr_t dma_addr;
 };
 
-struct vmxnet3_rx_ctx {
-	struct sk_buff *skb;
-	u32 sop_idx;
-};
-
 struct vmxnet3_rq_driver_stats {
 	u64 drop_total;
-	u64 drop_err;
-	u64 drop_fcs;
 	u64 rx_buf_alloc_failure;
+	u64 rx_buf_cookie_error;
 };
 
 struct vmxnet3_rx_queue {
-	struct vmxnet3_cmd_ring   rx_ring[2];
-	struct vmxnet3_comp_ring  comp_ring;
-	struct vmxnet3_rx_ctx     rx_ctx;
-	u32 qid;            /* rqID in RCD for buffer from 1st ring */
-	u32 qid2;           /* rqID in RCD for buffer from 2nd ring */
-	u32 uncommitted[2]; /* # of buffers allocated since last RXPROD
-				* update */
-	struct vmxnet3_rx_buf_info     *buf_info[2];
-	struct Vmxnet3_RxQueueCtrl            *shared;
+	struct vmxnet3_adapter	       *adapter;
+#ifdef VMXNET3_NAPI
+	struct napi_struct		napi;
+#endif
+	struct Plugin_RxQueueState     *plugin_rq;
+	struct vmxnet3_rx_buf_info     *buf_info;
+	struct Vmxnet3_RxQueueCtrl     *shared;
 	struct vmxnet3_rq_driver_stats  stats;
+	u8				intr_idx;
+	u8				qid;
+	u8				qid2;
+	u32				avail_skbs;
+	u32				rxd_done;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 #define VMXNET3_LINUX_MAX_MSIX_VECT     1
@@ -296,6 +295,10 @@ struct vmxnet3_adapter {
 
 	struct Vmxnet3_DriverShared    *shared;
 	struct Vmxnet3_PMConf          *pm_conf;
+	struct Plugin_State	       plugin;
+	struct Plugin_Api	       plugin_api;
+
+	struct NPA_PluginConf           *plugin_conf;
 	struct Vmxnet3_TxQueueDesc     *tqd_start;     /* first tx queue desc
*/
 	struct Vmxnet3_RxQueueDesc     *rqd_start;     /* first rx queue desc
*/
 	struct net_device              *netdev;
@@ -304,6 +307,14 @@ struct vmxnet3_adapter {
 	u8				*hw_addr0; /* for BAR 0 */
 	u8				*hw_addr1; /* for BAR 1 */
 
+	u8				*plugin_memio;
+	dma_addr_t			plugin_memio_pa;
+
+	u8				*plugin_shared;
+	dma_addr_t			plugin_shared_pa;
+
+	int				plugin_region_idx;
+
 	/* feature control */
 	bool				rxcsum;
 	bool				lro;
@@ -323,10 +334,12 @@ struct vmxnet3_adapter {
 
 	u64     tx_timeout_count;
 	struct work_struct work;
+	struct work_struct passthru_work;
 
 	unsigned long  state;    /* VMXNET3_STATE_BIT_xxx */
 
 	int dev_number;
+	bool passthru;
 };
 
 #define VMXNET3_WRITE_BAR0_REG(adapter, reg, val)  \
@@ -339,13 +352,20 @@ struct vmxnet3_adapter {
 #define VMXNET3_READ_BAR1_REG(adapter, reg)        \
 	le32_to_cpu(readl((adapter)->hw_addr1 + (reg)))
 
-#define VMXNET3_WAKE_QUEUE_THRESHOLD(tq)  (5)
-#define VMXNET3_RX_ALLOC_THRESHOLD(rq, ring_idx, adapter) \
-	((rq)->rx_ring[ring_idx].size >> 3)
+
+#define VMXNET3_WAKE_QUEUE_SHADOW_THRESHOLD(tq)  (5)
+#define VMXNET3_WAKE_QUEUE_DATA_THRESHOLD(tq)  (5)
 
 #define VMXNET3_GET_ADDR_LO(dma)   ((u32)(dma))
 #define VMXNET3_GET_ADDR_HI(dma)   ((u32)(((u64)(dma)) >> 32))
 
+/*
+ * the way we process packet is: 1 SG for header, 1 SG for linear part
+ * and 1 SG per frag
+ */
+#define VMXNET3_SGLIST_MAX          (2 + MAX_SKB_FRAGS)
+
+
 /* must be a multiple of VMXNET3_RING_SIZE_ALIGN */
 #define VMXNET3_DEF_TX_RING_SIZE    512
 #define VMXNET3_DEF_RX_RING_SIZE    256
@@ -357,11 +377,40 @@ void set_flag_le16(__le16 *data, u16 flag);
 void set_flag_le64(__le64 *data, u64 flag);
 void reset_flag_le64(__le64 *data, u64 flag);
 
+#define Plugin_SwInit(_adapter)						\
+	((_adapter)->plugin_api.swInit(&(_adapter)->plugin))
+#define Plugin_ReinitTxRing(_adapter, _queue)				\
+	((_adapter)->plugin_api.reinitTxRing(&(_adapter)->plugin,	\
+					    (_queue)))
+#define Plugin_ReinitRxRing(_adapter, _queue)				\
+	((_adapter)->plugin_api.reinitRxRing(&(_adapter)->plugin,	\
+					    (_queue)))
+#define Plugin_EnableInterrupt(_adapter, _idx)				\
+	((_adapter)->plugin_api.enableInterrupt(&(_adapter)->plugin,	\
+					       (_idx)))
+#define Plugin_DisableInterrupt(_adapter, _idx)				\
+	((_adapter)->plugin_api.disableInterrupt(&(_adapter)->plugin,	\
+						(_idx)))
+#define Plugin_AddFrameToTxRing(_adapter, _queue, _info, _frame,
_lastPkt)\
+	((_adapter)->plugin_api.addFrameToTxRing(&(_adapter)->plugin,	\
+						(_queue), (_info),	\
+						(_frame), (_lastPkt)))
+#define Plugin_CheckTxRing(_adapter, _queue)				\
+	((_adapter)->plugin_api.checkTxRing(&(_adapter)->plugin,	\
+					   (_queue)))
+#define Plugin_CheckRxRing(_adapter, _queue, _budget)			\
+	((_adapter)->plugin_api.checkRxRing(&(_adapter)->plugin,	\
+					   (_queue), (_budget)))
+#define Plugin_AddBuffersToRxRing(_adapter, _queue)			\
+	((_adapter)->plugin_api.addBuffersToRxRing(&(_adapter)->plugin,	\
+						  (_queue)))
+
+
 int
-vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
+vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter, bool soft);
 
 int
-vmxnet3_activate_dev(struct vmxnet3_adapter *adapter);
+vmxnet3_activate_dev(struct vmxnet3_adapter *adapter, bool
load_plugin);
 
 void
 vmxnet3_force_close(struct vmxnet3_adapter *adapter);
@@ -379,7 +428,7 @@ vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
-		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size);
+		      u32 tx_ring_size, u32 rx_ring_size);
 
 extern void vmxnet3_set_ethtool_ops(struct net_device *netdev);
 extern struct net_device_stats *vmxnet3_get_stats(struct net_device
*netdev);
diff --git a/drivers/net/vmxnet3/vmxnet3_plugin.c
b/drivers/net/vmxnet3/vmxnet3_plugin.c
new file mode 100644
index 0000000..49b5bf2
--- /dev/null
+++ b/drivers/net/vmxnet3/vmxnet3_plugin.c
@@ -0,0 +1,1221 @@
+/*
+ * NPA plugin for vmxnet3 driver.
+ *
+ * Copyright (C) 2008-2010, VMware, Inc. All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms of the GNU General Public License as published by
the
+ * Free Software Foundation; version 2 of the License and no later
version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT. See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
USA.
+ *
+ * The full GNU General Public License is included in this distribution
in
+ * the file called "COPYING".
+ *
+ * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ *
+ */
+
+/*
+ * vmxnet3Plugin.c --
+ *
+ *	Implements a plugin for vmxnet3 rings.
+ */
+
+#include <linux/types.h>
+#include "vmxnet3_int.h"
+#include "vmxnet3_defs.h"
+#include "npa_plugin_api.h"
+
+/*
+ * Log & loglevel. Can change at runtime via debugger.
+ */
+static u32 logLevel;
+static int logEnabled;
+
+
+/*
+ * Easy shell API calling macros.
+ */
+#define Shell_AllocSmallBuffer(_state, _handle, _ringOffset)		\
+	((_state)->shellApi.allocSmallBuffer((_handle), (_ringOffset)))
+#define Shell_AllocLargeBuffer(_state, _handle, _ringOffset)		\
+	((_state)->shellApi.allocLargeBuffer((_handle), (_ringOffset)))
+#define Shell_FreeBuffer(_state, _handle, _ringOffset)			\
+	((_state)->shellApi.freeBuffer((_handle), (_ringOffset)))
+#define Shell_CompleteSend(_state, _handle, _numPkt)			\
+	((_state)->shellApi.completeSend((_handle), (_numPkt)))
+#define Shell_IndicateRecv(_state, _handle, _frame)			\
+	((_state)->shellApi.indicateRecv((_handle), (_frame)))
+#define Shell_Log(_state, _loglevel, _n, _fmt, ...)			\
+	do {								\
+		if (logEnabled && (_loglevel) <= (u32)logLevel) {	\
+			(_state)->shellApi.log((_n) + 1,		\
+					"%s: " _fmt,		\
+					__func__,		\
+##__VA_ARGS__);		\
+		}							\
+	} while (0)
+
+
+/*
+ * Some standard definitions
+ */
+#ifndef NULL
+#define NULL (void *)0
+#endif
+
+
+/*
+ * Utility macro to write a register's value (BAR0)
+ */
+#define VMXNET3_WRITE_REG(_state, _offset, _value)		\
+	(*(u32 *)((u8 *)(_state)->memioAddr + (_offset)) =	\
+	(_value))
+
+
+/*
+ * Utility macro to align a virtual address
+ */
+#define ALIGN_VA(_ptr, _align) ((void *)(((uintptr_t)(_ptr) + ((_align)
- 1)) &\
+			~((_align) - 1)))
+
+
+/*
+ * TCP and UDP checksum offset
+ */
+#define TCP_CSUM_OFFSET		(16)
+#define UDP_CSUM_OFFSET		(6)
+
+
+/*
+ * Vmxnet3 TX queue
+ */
+struct Vmxnet3PluginTxQueue {
+	u32	txProdOffset;	    /* offset of txProd register */
+	u32	ringSize;	    /* size in desc, aligned correctly */
+
+	u32	hwCmdInsert;	    /* last cmd insert we told hardware */
+	u32	nextCmdInsert;	    /* index of next txd to fill */
+	u32	nextCmdRemove;      /* index of next txd to clean */
+	u32	nextCompleteRemove; /* index of next to complete */
+	u8	genCmd;             /* current value for gen bit on tx ring */
+	u8	genComplete;        /* current value for gen bit on comp ring */
+
+	struct Vmxnet3_TxDesc     *txCmdVirt;
+	struct Vmxnet3_TxCompDesc *txCompleteVirt;
+};
+
+
+/*
+ * Vmxnet3 RX ring
+ */
+struct Vmxnet3PluginRxCmdRing {
+	u32 rxProdOffset; /* offset of register */
+	u32 cookieOffset; /* 1st ring = 0, 2nd ring = (size of 1st ring) */
+	u32 ringSize;     /* size in desc, copied from adapter->rxRingLength
*/
+
+	u32 nextCmdInsert;
+	u32 nextCmdRemove;
+
+	u8  genBit;
+
+	struct Vmxnet3_RxDesc *ring;
+};
+
+
+/*
+ * Vmxnet3 RX queue
+ */
+struct Vmxnet3PluginRxQueue {
+	struct Vmxnet3PluginRxCmdRing cmdRing[2];
+
+	u32 ringCompleteSize;
+	struct Vmxnet3_RxCompDesc *rxCompleteVirt;
+
+	struct Shell_RecvFrame frame;
+
+	u32 nextCompleteRemove;
+	u8  genComplete;
+};
+
+/*
+ * Vmxnet3 Plugin state
+ */
+struct Vmxnet3PluginCustomState {
+	struct Vmxnet3PluginTxQueue txQueues[PLUGIN_MAX_TX_QUEUES];
+	struct Vmxnet3PluginRxQueue rxQueues[PLUGIN_MAX_RX_QUEUES];
+	u32 maxSgLength;
+};
+
+#define VMXNET3_PLUGIN_STATE(state)				\
+	((struct Vmxnet3PluginCustomState *)PLUGIN_PRIVATE((state)))
+
+
+static INLINE void
+MoveMemory(void *dst,
+		void *src,
+		size_t length)
+{
+	size_t i;
+	for (i = 0; i < length; ++i)
+		((u8 *)dst)[i] = ((u8 *)src)[i];
+}
+
+static INLINE void
+ZeroMemory(void *memory,
+		size_t length)
+{
+	size_t i;
+	for (i = 0; i < length; ++i)
+		((u8 *)memory)[i] = 0;
+}
+
+
+/*
+ * Init any private software state. Returns 0 on success and 1
otherwise.
+ */
+
+static u32
+Vmxnet3Plugin_SwInit(struct Plugin_State *state)
+{
+	struct Vmxnet3PluginCustomState *customState = VMXNET3_PLUGIN_STATE(
+									state);
+	u32 i;
+
+	if (state->majorVersion != 1 || state->size < sizeof(*state))
+		return 1;
+
+	for (i = 0; i < state->numRxQueues; ++i) {
+		struct Vmxnet3PluginRxQueue *rxQueue =
+						&(customState->rxQueues[i]);
+		u32 j;
+
+		/* check ring size & adjust 2nd ring size */
+		rxQueue->cmdRing[0].ringSize = state->rxQueues[i].ringSize;
+		if ((state->features & PLUGIN_FEATURES_LRO) ||
+				state->mtu > SHELL_SMALL_RECV_BUFFER_SIZE) {
+			rxQueue->cmdRing[1].ringSize =
+				state->rxQueues[i].ringSize;
+		} else {
+			rxQueue->cmdRing[1].ringSize = 32;
+		}
+		rxQueue->cmdRing[0].cookieOffset = 0;
+		rxQueue->cmdRing[1].cookieOffset = rxQueue->cmdRing[0].ringSize;
+		BUG_ON(rxQueue->cmdRing[0].ringSize == 0);
+		BUG_ON((rxQueue->cmdRing[0].ringSize &
+					VMXNET3_RING_SIZE_MASK) != 0);
+		BUG_ON(rxQueue->cmdRing[1].ringSize == 0);
+		BUG_ON((rxQueue->cmdRing[1].ringSize &
+					VMXNET3_RING_SIZE_MASK) != 0);
+
+		for (j = 0; j < 2; ++j) {
+			struct Vmxnet3PluginRxCmdRing *cmdRing =
+							rxQueue->cmdRing + j;
+
+			/* initialize command ring management & gen values */
+			cmdRing->nextCmdInsert = 0;
+			cmdRing->nextCmdRemove = 0;
+			cmdRing->genBit = VMXNET3_INIT_GEN;
+		}
+		/* setup the two command rings */
+		rxQueue->cmdRing[0].ring =
+			ALIGN_VA(state->rxQueues[i].ringBaseVA,
+					VMXNET3_RING_BA_ALIGN);
+		rxQueue->cmdRing[1].ring =
+			ALIGN_VA((u8 *)rxQueue->cmdRing[0].ring +
+					rxQueue->cmdRing[0].ringSize *
+					sizeof(struct Vmxnet3_RxDesc),
+					VMXNET3_RING_BA_ALIGN);
+
+		/* RX completion ring follows second RX command ring */
+		rxQueue->ringCompleteSize = rxQueue->cmdRing[0].ringSize +
+			rxQueue->cmdRing[1].ringSize;
+		rxQueue->rxCompleteVirt =
+			ALIGN_VA((u8 *)rxQueue->cmdRing[1].ring +
+					rxQueue->cmdRing[1].ringSize *
+					sizeof(struct Vmxnet3_RxDesc),
+					VMXNET3_RING_BA_ALIGN);
+
+		/* check for overflow */
+		if (((u8 *)rxQueue->rxCompleteVirt) +
+		    sizeof(struct Vmxnet3_RxCompDesc) *
+		    rxQueue->ringCompleteSize > state->rxQueues[i].ringBaseVA +
+		    state->rxQueues[i].ringLength) {
+			Shell_Log(state, 1, 0,
+				  "rx shared area size is too small\n");
+			return 1;
+		}
+
+		/* initialize completion ring management & gen values */
+		rxQueue->nextCompleteRemove = 0;
+		rxQueue->genComplete = VMXNET3_INIT_GEN;
+
+		rxQueue->cmdRing[0].rxProdOffset = VMXNET3_REG_RXPROD  +
+			(VMXNET3_REG_ALIGN * i);
+		rxQueue->cmdRing[1].rxProdOffset = VMXNET3_REG_RXPROD2 +
+			(VMXNET3_REG_ALIGN * i);
+
+		ZeroMemory(&rxQueue->frame, sizeof(struct Shell_RecvFrame));
+
+		Shell_Log(state, 1, 8, "rxQueue[%u] %p cmdRing[0] %p %u "
+				"cmdRing[1] %p %u compRing %p %u\n", i, rxQueue,
+				rxQueue->cmdRing[0].ring,
+				rxQueue->cmdRing[0].ringSize,
+				rxQueue->cmdRing[1].ring,
+				rxQueue->cmdRing[1].ringSize,
+				rxQueue->rxCompleteVirt,
+				rxQueue->ringCompleteSize);
+	}
+
+	for (i = 0; i < state->numTxQueues; i++) {
+		struct Vmxnet3PluginTxQueue *txQueue =
+						&customState->txQueues[i];
+
+		/* check ring size */
+		txQueue->ringSize = state->txQueues[i].ringSize;
+		BUG_ON(txQueue->ringSize == 0);
+		BUG_ON((txQueue->ringSize & VMXNET3_RING_SIZE_MASK) != 0);
+
+		txQueue->txCmdVirt = ALIGN_VA(state->txQueues[i].ringBaseVA,
+				VMXNET3_RING_BA_ALIGN);
+
+		/* TX completion ring follows the TX command ring */
+		txQueue->txCompleteVirt = ALIGN_VA((u8 *)txQueue->txCmdVirt +
+				txQueue->ringSize *
+				sizeof(struct Vmxnet3_TxDesc),
+				VMXNET3_RING_BA_ALIGN);
+
+		/* check for overflow */
+		if (((u8 *)txQueue->txCompleteVirt) +
+		    sizeof(struct Vmxnet3_TxCompDesc) * txQueue->ringSize >
+		    state->txQueues[i].ringBaseVA +
+		    state->txQueues[i].ringLength) {
+			Shell_Log(state, 1, 0,
+					"tx shared area size is too small\n");
+			return 1;
+		}
+
+		/* initialize ring management & gen values */
+		txQueue->hwCmdInsert = 0;
+		txQueue->nextCmdInsert = 0;
+		txQueue->nextCmdRemove = 0;
+		txQueue->nextCompleteRemove = 0;
+		txQueue->genCmd = VMXNET3_INIT_GEN;
+		txQueue->genComplete = VMXNET3_INIT_GEN;
+
+		txQueue->txProdOffset = VMXNET3_REG_TXPROD +
+			(VMXNET3_REG_ALIGN * i);
+
+		Shell_Log(state, 1, 5,
+			  "txQueue[%u] %p cmdRing %p %u compRing %p\n",
+			  i, txQueue, txQueue->txCmdVirt, txQueue->ringSize,
+			  txQueue->txCompleteVirt);
+	}
+
+	/* setup max number of SGs per received frame */
+	if (state->features & PLUGIN_FEATURES_LRO)
+		customState->maxSgLength = SHELL_MAX_LRO_RECV_SG_LEN;
+	else
+		customState->maxSgLength = SHELL_MAX_RECV_SG_LEN;
+
+	return 0;
+}
+
+
+/*
+ * Reset and clear RX ring(s) for the specified queue.
+ */
+
+static u32
+Vmxnet3Plugin_ReinitRxRing(struct Plugin_State *state,
+		u32 queueNum)
+{
+	struct Vmxnet3PluginCustomState *customState =
+						VMXNET3_PLUGIN_STATE(state);
+	struct Vmxnet3PluginRxQueue *rxQueue =
&customState->rxQueues[queueNum];
+	u32 i;
+
+	for (i = 0; i < 2; ++i) {
+		struct Vmxnet3PluginRxCmdRing *cmdRing = rxQueue->cmdRing + i;
+
+		/*
+		 * Can't BUG_ON(nextCmdInsert != nextCmdRemove) since these
+		 * aren't updated when we garbage collected the buffers from
+		 * the ring.
+		 */
+#ifdef VMX86_DEBUG
+		if (cmdRing->nextCmdInsert != cmdRing->nextCmdRemove) {
+			Shell_Log(state, 2, 2, "cmdInsert %u != cmdRemove %u\n",
+					cmdRing->nextCmdInsert,
+					cmdRing->nextCmdRemove);
+		}
+#endif
+		cmdRing->nextCmdInsert = 0;
+		cmdRing->nextCmdRemove = 0;
+		cmdRing->genBit = VMXNET3_INIT_GEN;
+
+		Shell_Log(state, 1, 3, "cmdRing[%u] %p %u\n", i, cmdRing,
+				cmdRing->ringSize);
+		BUG_ON(!cmdRing->ringSize);
+		BUG_ON(!cmdRing->ring);
+		ZeroMemory(cmdRing->ring, sizeof(struct Vmxnet3_RxDesc) *
+					  cmdRing->ringSize);
+	}
+	BUG_ON(!rxQueue->rxCompleteVirt);
+	BUG_ON(!rxQueue->ringCompleteSize);
+	ZeroMemory(rxQueue->rxCompleteVirt,
+		   sizeof(struct Vmxnet3_RxCompDesc) *
+		   rxQueue->ringCompleteSize);
+	rxQueue->nextCompleteRemove = 0;
+	rxQueue->genComplete = VMXNET3_INIT_GEN;
+
+	return 0;
+}
+
+
+/*
+ * Reset and clear TX ring for the specified queue.
+ */
+
+static u32
+Vmxnet3Plugin_ReinitTxRing(struct Plugin_State *state,
+		u32 queueNum)
+{
+	struct Vmxnet3PluginCustomState *customState =
+						VMXNET3_PLUGIN_STATE(state);
+	struct Vmxnet3PluginTxQueue *txQueue =
&customState->txQueues[queueNum];
+
+	txQueue->hwCmdInsert = 0;
+	txQueue->nextCmdInsert = 0;
+	txQueue->nextCmdRemove = 0;
+	txQueue->nextCompleteRemove = 0;
+	txQueue->genCmd = VMXNET3_INIT_GEN;
+	txQueue->genComplete = VMXNET3_INIT_GEN;
+
+	ZeroMemory(txQueue->txCmdVirt,
+			sizeof(struct Vmxnet3_TxDesc) * txQueue->ringSize);
+	ZeroMemory(txQueue->txCompleteVirt,
+			sizeof(struct Vmxnet3_TxCompDesc) * txQueue->ringSize);
+	return 0;
+}
+
+
+/*
+ * Adds a offset to a ring index value, taking into account the
potential for
+ * wrapping around to the beginning of the rx ring. Returns index in
the ring.
+ */
+
+static u32
+ComputeRingIndex(struct Vmxnet3PluginRxCmdRing *ring, u32 base, u32
offset)
+{
+	u32 result = base + offset;
+
+	BUG_ON(offset >= ring->ringSize);
+	if (result >= ring->ringSize)
+		result -= ring->ringSize;
+	return result;
+}
+
+
+static u32
+Vmxnet3Plugin_AddBuffersToRxRing(struct Plugin_State *state,
+		u32 queueNum)
+{
+	struct Vmxnet3PluginCustomState *customState =
+						VMXNET3_PLUGIN_STATE(state);
+	struct Shell_RxQueueHandle *handle = state->rxQueues[queueNum].handle;
+	struct Vmxnet3PluginRxQueue *rxQueue =
&customState->rxQueues[queueNum];
+	struct Vmxnet3PluginRxCmdRing *cmdRing0 = &rxQueue->cmdRing[0];
+	struct Vmxnet3PluginRxCmdRing *cmdRing1 = &rxQueue->cmdRing[1];
+	u32 oldInsert1;
+	u32 oldInsert2;
+
+	oldInsert1 = rxQueue->cmdRing[0].nextCmdInsert;
+	oldInsert2 = rxQueue->cmdRing[1].nextCmdInsert;
+
+	if (state->mtu <= SHELL_SMALL_RECV_BUFFER_SIZE) {
+		u32 nextCmd;
+
+		nextCmd = ComputeRingIndex(cmdRing0, cmdRing0->nextCmdInsert,
+					   1);
+		Shell_Log(state, 2, 2, "nextCmd %u, nextCmdRemove %u\n",
+				nextCmd, cmdRing0->nextCmdRemove);
+
+		/* fill the ring with 2k skb buffers */
+		while (nextCmd != cmdRing0->nextCmdRemove) {
+			u64 buffer;
+			struct Vmxnet3_RxDesc *desc0 = cmdRing0->ring +
+				cmdRing0->nextCmdInsert;
+
+			BUG_ON(cmdRing0->cookieOffset != 0);
+			buffer = Shell_AllocSmallBuffer(state, handle,
+						cmdRing0->nextCmdInsert);
+			if (buffer == 0)
+				break;
+
+			desc0->addr  = buffer;
+			desc0->len   = SHELL_SMALL_RECV_BUFFER_SIZE;
+			desc0->btype = VMXNET3_RXD_BTYPE_HEAD;
+			desc0->dtype = 0;
+			desc0->rsvd  = 0;
+			desc0->ext1  = 0;
+			desc0->gen = cmdRing0->genBit;
+
+			Shell_Log(state, 2, 4, "desc0[%u] addr:%lu len:%u "
+					"gen:%u\n", cmdRing0->nextCmdInsert,
+					desc0->addr, desc0->len, desc0->gen);
+
+			cmdRing0->nextCmdInsert = nextCmd;
+			if (cmdRing0->nextCmdInsert == 0) { /* we've wrapped */
+				VMXNET3_FLIP_RING_GEN(cmdRing0->genBit);
+			}
+			nextCmd = ComputeRingIndex(cmdRing0,
+					cmdRing0->nextCmdInsert, 1);
+		}
+
+		/*
+		 * We're not using the large buffer queue or the
+		 * second ring unless LPD is enabled
+		 */
+		BUG_ON(!(state->features & PLUGIN_FEATURES_LRO) &&
+				cmdRing1->nextCmdInsert != 0);
+		BUG_ON(!(state->features & PLUGIN_FEATURES_LRO) &&
+				cmdRing1->nextCmdRemove != 0);
+	} else {
+		/*
+		 * When jumbo frames are used, nextCmdRemove might
+		 * point to the 2k buffer or either of the 4k buffers,
+		 * depending on whether one or both of the 4k buffers
+		 * were needed to receive a frame.  So, this loop
+		 * needs to check for +1, +2, and +3 when it comes to
+		 * buffer occupancy.  The alternative is to have the
+		 * code that walks the completion ring detect when the
+		 * 4k buffer(s) weren't used and skip it, but offhand
+		 * I think that approach would be more overhead
+		 * compared to having an additional check in this
+		 * function (simpler, and this function ideally won't
+		 * run as often).
+		 */
+
+		Shell_Log(state, 2, 3, "nextCmd %u-%u, nextCmdRemove %u\n",
+			ComputeRingIndex(cmdRing0, cmdRing0->nextCmdInsert, 1),
+			ComputeRingIndex(cmdRing0, cmdRing0->nextCmdInsert, 3),
+			cmdRing0->nextCmdRemove);
+
+		while (ComputeRingIndex(cmdRing0, cmdRing0->nextCmdInsert, 1) !=
+		       cmdRing0->nextCmdRemove &&
+		       ComputeRingIndex(cmdRing0, cmdRing0->nextCmdInsert, 2) !=
+		       cmdRing0->nextCmdRemove &&
+		       ComputeRingIndex(cmdRing0, cmdRing0->nextCmdInsert, 3) !=
+		       cmdRing0->nextCmdRemove) {
+			struct Vmxnet3_RxDesc *desc[3];
+			u32 bufferOffset[3];
+			u8  genBit[3];
+			u64 bufferPA[3];
+
+			genBit[0] = cmdRing0->genBit;
+			genBit[1] = cmdRing0->genBit;
+			genBit[2] = cmdRing0->genBit;
+
+			BUG_ON(cmdRing0->cookieOffset != 0);
+			/*
+			 * Compute next ring entries and gen values
+			 * for these entries
+			 */
+			bufferOffset[0] = cmdRing0->nextCmdInsert;
+			bufferOffset[1] = bufferOffset[0] + 1;
+			if (bufferOffset[1] >= cmdRing0->ringSize) {
+				bufferOffset[1] = 0;
+				bufferOffset[2] = 1;
+				VMXNET3_FLIP_RING_GEN(genBit[1]);
+				VMXNET3_FLIP_RING_GEN(genBit[2]);
+			} else {
+				bufferOffset[2] = bufferOffset[1] + 1;
+				if (bufferOffset[2] >= cmdRing0->ringSize) {
+					bufferOffset[2] = 0;
+					VMXNET3_FLIP_RING_GEN(genBit[2]);
+				}
+			}
+
+			desc[0] = cmdRing0->ring + bufferOffset[0];
+			desc[1] = cmdRing0->ring + bufferOffset[1];
+			desc[2] = cmdRing0->ring + bufferOffset[2];
+
+			/* allocate 2k + 4k + 4k buffers */
+			bufferPA[0] = Shell_AllocSmallBuffer(state, handle,
+					bufferOffset[0]);
+			if (!bufferPA[0])
+				break;
+
+			bufferPA[1] = Shell_AllocLargeBuffer(state, handle,
+					bufferOffset[1]);
+			if (!bufferPA[1]) {
+				Shell_FreeBuffer(state, handle,
+						bufferOffset[0]);
+				break;
+			}
+
+			bufferPA[2] = Shell_AllocLargeBuffer(state, handle,
+					bufferOffset[2]);
+			if (!bufferPA[2]) {
+				Shell_FreeBuffer(state, handle,
+						bufferOffset[0]);
+				Shell_FreeBuffer(state, handle,
+						bufferOffset[1]);
+				break;
+			}
+
+			/* setup the descriptors */
+			desc[0]->addr  = bufferPA[0];
+			desc[0]->len   = SHELL_SMALL_RECV_BUFFER_SIZE;
+			desc[0]->btype = VMXNET3_RXD_BTYPE_HEAD;
+			desc[0]->dtype = 0;
+			desc[0]->rsvd  = 0;
+			desc[0]->ext1  = 0;
+
+			desc[1]->addr  = bufferPA[1];
+			desc[1]->len   = SHELL_LARGE_RECV_BUFFER_SIZE;
+			desc[1]->btype = VMXNET3_RXD_BTYPE_BODY;
+			desc[1]->dtype = 0;
+			desc[1]->rsvd  = 0;
+			desc[1]->ext1  = 0;
+
+			desc[2]->addr  = bufferPA[2];
+			desc[2]->len   = SHELL_LARGE_RECV_BUFFER_SIZE;
+			desc[2]->btype = VMXNET3_RXD_BTYPE_BODY;
+			desc[2]->dtype = 0;
+			desc[2]->rsvd  = 0;
+			desc[2]->ext1  = 0;
+
+			desc[2]->gen = genBit[2];
+			desc[1]->gen = genBit[1];
+			desc[0]->gen = genBit[0];
+
+#ifdef VMX86_DEBUG
+			{
+				int i;
+				for (i = 0; i < 3; i++) {
+					Shell_Log(state, 2, 5, "desc%d[%u] "
+						"addr:%lu len:%u gen:%u\n", i,
+						(cmdRing0->nextCmdInsert + i)%
+						cmdRing0->ringSize,
+						desc[i]->addr, desc[i]->len,
+						desc[i]->gen);
+				}
+			}
+#endif
+
+			cmdRing0->nextCmdInsert += 3;
+			if (cmdRing0->nextCmdInsert >= cmdRing0->ringSize) {
+				cmdRing0->nextCmdInsert -= cmdRing0->ringSize;
+				VMXNET3_FLIP_RING_GEN(cmdRing0->genBit);
+			}
+		}
+	}
+
+	if ((state->features & PLUGIN_FEATURES_LRO) ||
+			state->mtu > SHELL_SMALL_RECV_BUFFER_SIZE) {
+
+		Shell_Log(state, 2, 2, "nextCmd %u, nextCmdRemove %u\n",
+			ComputeRingIndex(cmdRing1, cmdRing1->nextCmdInsert, 1),
+			cmdRing1->nextCmdRemove);
+
+		/* fill the 2nd ring with 4k buffers */
+		while (ComputeRingIndex(cmdRing1, cmdRing1->nextCmdInsert, 1) !=
+				cmdRing1->nextCmdRemove) {
+			u64 bufferPA;
+
+			struct Vmxnet3_RxDesc *desc = cmdRing1->ring +
+				cmdRing1->nextCmdInsert;
+
+			bufferPA = Shell_AllocLargeBuffer(state, handle,
+					cmdRing1->cookieOffset +
+					cmdRing1->nextCmdInsert);
+			if (!bufferPA)
+				break;
+
+			desc->addr  = bufferPA;
+			desc->len   = SHELL_LARGE_RECV_BUFFER_SIZE;
+			desc->btype = VMXNET3_RXD_BTYPE_BODY;
+			desc->dtype = 0;
+			desc->rsvd  = 0;
+			desc->ext1  = 0;
+
+			desc->gen = cmdRing1->genBit;
+
+			Shell_Log(state, 2, 4, "desc[%u] addr:%lu len:%u"
+					" gen:%u\n", cmdRing1->nextCmdInsert,
+					desc->addr, desc->len, desc->gen);
+
+			++cmdRing1->nextCmdInsert;
+			if (cmdRing1->nextCmdInsert >= cmdRing1->ringSize) {
+				cmdRing1->nextCmdInsert = 0;
+				VMXNET3_FLIP_RING_GEN(cmdRing1->genBit);
+			}
+		}
+	}
+
+	if (state->updateRxProd) {
+		if (oldInsert1 != rxQueue->cmdRing[0].nextCmdInsert) {
+			VMXNET3_WRITE_REG(state,
+					rxQueue->cmdRing[0].rxProdOffset,
+					rxQueue->cmdRing[0].nextCmdInsert);
+		}
+
+		if (oldInsert2 != rxQueue->cmdRing[1].nextCmdInsert) {
+			VMXNET3_WRITE_REG(state,
+					rxQueue->cmdRing[1].rxProdOffset,
+					rxQueue->cmdRing[1].nextCmdInsert);
+		}
+	}
+	return 0;
+}
+
+
+/*
+ * Checks rx ring(s) for received frame, returns non-zero if we need to
+ * feed the ring with buffers.
+ */
+
+static u32
+Vmxnet3Plugin_CheckRxRing(struct Plugin_State *state,
+			u32 queueNum,
+			u32 maxPackets)
+{
+	struct Vmxnet3PluginCustomState *customState =
+						VMXNET3_PLUGIN_STATE(state);
+	struct Shell_RxQueueHandle *handle = state->rxQueues[queueNum].handle;
+	struct Vmxnet3PluginRxQueue *rxQueue =
&customState->rxQueues[queueNum];
+	struct Shell_RecvFrame *frame = &rxQueue->frame;
+	u8 rxBufferWasCompleted = false;
+	u32 packetsFound = 0;
+
+	ZeroMemory(frame, sizeof *frame);
+
+	Shell_Log(state, 1, 3, "desc[%u].gen %u q.gen %u\n",
+		  rxQueue->nextCompleteRemove,
+		  rxQueue->rxCompleteVirt[rxQueue->nextCompleteRemove].gen,
+		  rxQueue->genComplete);
+	/* while we have descriptors to process */
+	while (rxQueue->rxCompleteVirt[rxQueue->nextCompleteRemove].gen ==
+	       rxQueue->genComplete && packetsFound < maxPackets) {
+		struct Vmxnet3_RxCompDesc *currDesc;
+		u32 index;
+		u32 queueID;
+		u8 firstRing; /* first ring vs. second ring */
+		struct Vmxnet3PluginRxCmdRing *cmdRing;
+		u8 discardStoredMDLs = false;
+		u8 discardCurrentDesc = false;
+		u32 currDescCookie;
+
+		rxBufferWasCompleted = true;
+
+		currDesc = rxQueue->rxCompleteVirt +
+			rxQueue->nextCompleteRemove;
+		index = currDesc->rxdIdx;
+		queueID = currDesc->rqID;
+		Shell_Log(state, 1, 2, "got queue %u index %u\n", queueID,
+				index);
+		BUG_ON(queueID != queueNum &&
+				queueID != queueNum + state->numRxQueues);
+		firstRing = (queueID < state->numRxQueues) ? true : false;
+
+		cmdRing = rxQueue->cmdRing + (firstRing ? 0 : 1);
+		currDescCookie = cmdRing->cookieOffset + index;
+
+		/* reclaim any buffers that were skipped by device */
+		while (cmdRing->nextCmdRemove != index) {
+
+			Shell_FreeBuffer(state, handle, cmdRing->cookieOffset +
+					cmdRing->nextCmdRemove);
+
+			cmdRing->nextCmdRemove =
+				ComputeRingIndex(cmdRing,
+						cmdRing->nextCmdRemove, 1);
+		}
+		/*
+		 * If we got an SOP but have buffers from prior descriptors,
+		 * then free them
+		 */
+		if (currDesc->sop && frame->sgLength > 0)
+			discardStoredMDLs = true;
+
+		/*
+		 * if we got non-sop, but we don't have prior MDLs, then skip
+		 * this descriptor
+		 */
+		if (!currDesc->sop && frame->sgLength == 0)
+			discardCurrentDesc = true;
+
+		/*
+		 * if ran out of room to store frame, then discard prior and
+		 * current desc
+		 */
+		if (frame->sgLength >= customState->maxSgLength) {
+			state->shellApi.log(2, "sgLength exceeded: %u %u\n",
+					    frame->sgLength,
+					    customState->maxSgLength);
+			Shell_Log(state, 1, 2, "sgLength exceeded: %u %u\n",
+				  frame->sgLength, customState->maxSgLength);
+			discardStoredMDLs = true;
+			discardCurrentDesc = true;
+		}
+
+		/* Make sure that err isn't set on non-eop frame */
+		BUG_ON(!currDesc->eop && currDesc->err);
+
+		if (currDesc->eop && currDesc->err) {
+			state->shellApi.log(1, "Got error on EOP descriptor: "
+					"fcs %u\n", currDesc->fcs);
+			Shell_Log(state, 1, 1, "Got error on EOP descriptor: "
+					"fcs %u\n", currDesc->fcs);
+			discardStoredMDLs = true;
+			discardCurrentDesc = true;
+		}
+
+		/*
+		 * if no length, then don't need to bother to add descriptor
+		 * to frame
+		 */
+		if (currDesc->len == 0)
+			discardCurrentDesc = true;
+
+		if (discardStoredMDLs) {
+			u32 i;
+			state->shellApi.log(0, "Discarding stored MDLs\n");
+			Shell_Log(state, 1, 0, "Discarding stored MDLs\n");
+			for (i = 0; i < frame->sgLength; ++i) {
+				Shell_FreeBuffer(state, handle,
+						frame->sg[i].ringOffset);
+			}
+			frame->sgLength = 0;
+			frame->byteLength = 0;
+		}
+
+		if (discardCurrentDesc) {
+			Shell_FreeBuffer(state, handle, currDescCookie);
+			goto nextEntry;
+		}
+
+		BUG_ON(frame->sgLength >= customState->maxSgLength);
+
+		/* add MDL to list and set/increment the length */
+		BUG_ON(currDesc->len <= 0);
+		frame->sg[frame->sgLength].ringOffset = currDescCookie;
+		frame->sg[frame->sgLength].length = currDesc->len;
+		frame->byteLength += currDesc->len;
+		++frame->sgLength;
+
+		if (currDesc->eop) {
+			if (currDesc->ts) {
+				frame->vlan = true;
+				frame->vlanTag = (u16)currDesc->tci;
+			} else {
+				frame->vlan = false;
+				frame->vlanTag = 0;
+			}
+
+			if (currDesc->rssType != VMXNET3_RCD_RSS_TYPE_NONE) {
+
+				frame->rssHashFunction =
+					SHELL_RECV_HASH_FUNCTION_TOEPLITZ;
+				frame->rssHashValue = currDesc->rssHash;
+
+				switch (currDesc->rssType) {
+				case VMXNET3_RCD_RSS_TYPE_IPV4:
+					frame->rssHashType =
+					SHELL_RECV_HASH_TYPE_IPV4;
+					break;
+				case VMXNET3_RCD_RSS_TYPE_TCPIPV4:
+					frame->rssHashType =
+					SHELL_RECV_HASH_TYPE_TCPIPV4;
+					break;
+				case VMXNET3_RCD_RSS_TYPE_IPV6:
+					frame->rssHashType =
+					SHELL_RECV_HASH_TYPE_IPV6;
+					break;
+				case VMXNET3_RCD_RSS_TYPE_TCPIPV6:
+					frame->rssHashType =
+					SHELL_RECV_HASH_TYPE_TCPIPV6;
+					break;
+				default:
+					BUG_ON(1);
+					frame->rssHashType =
+					SHELL_RECV_HASH_TYPE_NONE;
+					break;
+				}
+			} else {
+				frame->rssHashFunction =
+					SHELL_RECV_HASH_FUNCTION_NONE;
+				frame->rssHashValue = 0;
+				frame->rssHashType = SHELL_RECV_HASH_TYPE_NONE;
+			}
+
+			/*
+			 * check on V4 vs V6.  Validity of bits is not based
+			 * on CNC.
+			 */
+			if (currDesc->v4) {
+				frame->ipv4 = true;
+				frame->ipv6 = false;
+				frame->nonIp = false;
+			} else if (currDesc->v6) {
+				frame->ipv4 = false;
+				frame->ipv6 = true;
+				frame->nonIp = false;
+			} else {
+				frame->ipv4 = false;
+				frame->ipv6 = false;
+				frame->nonIp = true;
+			}
+
+			/*
+			 * check on TCP vs UDP.  Validity of bits is not based
+			 * on CNC, but on v4 or v6.
+			 */
+			if (currDesc->v4 || currDesc->v6) {
+				if (currDesc->tcp) {
+					frame->tcp = true;
+					frame->udp = false;
+				} else if (currDesc->udp) {
+					frame->tcp = false;
+					frame->udp = true;
+				} else {
+					frame->tcp = false;
+					frame->udp = false;
+				}
+			} else {
+				frame->tcp = false;
+				frame->udp = false;
+			}
+
+			/* if checksum calculated */
+			if (!currDesc->cnc) {
+				/* ignore csum and frg */
+				if (currDesc->v4) {
+					if (currDesc->ipc) {
+						frame->ipXsum =
+							SHELL_XSUM_CORRECT;
+					} else {
+						frame->ipXsum =
+							SHELL_XSUM_INCORRECT;
+					}
+				} else {
+					frame->ipXsum = SHELL_XSUM_UNKNOWN;
+				}
+
+				if (!currDesc->frg &&
+				    (currDesc->v4 || currDesc->v6)) {
+					if (currDesc->tcp) {
+						if (currDesc->tuc) {
+							frame->tcpXsum =
+							     SHELL_XSUM_CORRECT;
+						} else {
+							frame->tcpXsum =
+							   SHELL_XSUM_INCORRECT;
+						}
+						frame->udpXsum =
+							SHELL_XSUM_UNKNOWN;
+					} else if (currDesc->udp) {
+						if (currDesc->tuc) {
+							frame->udpXsum =
+							     SHELL_XSUM_CORRECT;
+						} else {
+							frame->udpXsum =
+							   SHELL_XSUM_INCORRECT;
+						}
+						frame->tcpXsum =
+							SHELL_XSUM_UNKNOWN;
+					} else {
+						frame->tcpXsum =
+							SHELL_XSUM_UNKNOWN;
+						frame->udpXsum =
+							SHELL_XSUM_UNKNOWN;
+					}
+				} else { /* ipv4 or ipv6 */
+					frame->tcpXsum = SHELL_XSUM_UNKNOWN;
+					frame->udpXsum = SHELL_XSUM_UNKNOWN;
+				}
+			} else { /* cnc */
+				frame->tcpXsum = SHELL_XSUM_UNKNOWN;
+				frame->udpXsum = SHELL_XSUM_UNKNOWN;
+				frame->ipXsum = SHELL_XSUM_UNKNOWN;
+			}
+
+			++packetsFound;
+			if (Shell_IndicateRecv(state, handle, frame) != 0) {
+				/*
+				 * for now free buffers, since would
+				 * need to handle case where the EOP
+				 * descriptor is processed again the
+				 * next time this poll function is
+				 * called.
+				 */
+				u32 i;
+				for (i = 0; i < frame->sgLength; ++i) {
+					Shell_FreeBuffer(state, handle,
+						       frame->sg[i].ringOffset);
+				}
+				/* breaks the loop cleanly */
+				packetsFound = maxPackets;
+			}
+			frame->sgLength = 0;
+			frame->byteLength = 0;
+		}
+
+nextEntry:
+
+		/* we processed this command descriptor, so move to the next */
+		BUG_ON(index != cmdRing->nextCmdRemove);
+		cmdRing->nextCmdRemove = ComputeRingIndex(cmdRing,
+				cmdRing->nextCmdRemove, 1);
+
+		/* we processed this completion desc, so move to the next */
+		if (++rxQueue->nextCompleteRemove >=
+				rxQueue->ringCompleteSize) {
+			rxQueue->nextCompleteRemove = 0;
+			VMXNET3_FLIP_RING_GEN(rxQueue->genComplete);
+		}
+	}
+
+	return rxBufferWasCompleted == true ? 1 : 0;
+}
+
+
+
+static u32
+Vmxnet3Plugin_CheckTxRing(struct Plugin_State *state,
+		u32 queueNum)
+{
+	struct Vmxnet3PluginCustomState *customState =
+						VMXNET3_PLUGIN_STATE(state);
+	struct Shell_TxQueueHandle *handle = state->txQueues[queueNum].handle;
+	struct Vmxnet3PluginTxQueue *txQueue =
&customState->txQueues[queueNum];
+	u32 numCompleted = 0;
+	u32 index;
+	u32 nextRemove;
+
+	while (txQueue->txCompleteVirt[txQueue->nextCompleteRemove].gen ==
+			txQueue->genComplete) {
+		BUG_ON(txQueue->txCompleteVirt[txQueue->nextCompleteRemove].rsvd
+				!= 0);
+		BUG_ON(txQueue->txCompleteVirt[txQueue->nextCompleteRemove].type
+				!= 0);
+
+		index = txQueue->txCompleteVirt[
+			txQueue->nextCompleteRemove].txdIdx;
+		BUG_ON(!txQueue->txCmdVirt[index].eop);
+
+		++numCompleted;
+
+		nextRemove = index + 1;
+		if (nextRemove >= txQueue->ringSize)
+			nextRemove = 0;
+
+		txQueue->nextCmdRemove = nextRemove;
+
+		txQueue->nextCompleteRemove++;
+		if (txQueue->nextCompleteRemove >= txQueue->ringSize) {
+			txQueue->nextCompleteRemove = 0;
+			VMXNET3_FLIP_RING_GEN(txQueue->genComplete);
+		}
+	}
+
+	if (numCompleted > 0) {
+		Shell_Log(state, 1, 1, "numCompleted: %u\n", numCompleted);
+		Shell_CompleteSend(state, handle, numCompleted);
+	}
+
+	return 0;
+}
+
+static u32
+Vmxnet3Plugin_AddFrameToTxRing(struct Plugin_State *state,
+		u32 queueNum,
+		const struct Plugin_SendInfo *info,
+		const struct Plugin_SgList *frame,
+		bool lastFrame)
+{
+	struct Vmxnet3PluginCustomState *customState =
+						VMXNET3_PLUGIN_STATE(state);
+	struct Vmxnet3PluginTxQueue *txQueue =
&customState->txQueues[queueNum];
+	u32 bytesRemainInFrame = frame->totalLength;
+	struct Vmxnet3_TxDesc descTemplate = {0};
+	/* can't update nextCmdInsert until success */
+	u32 insertOffset = txQueue->nextCmdInsert;
+	/* firstDesc[GenBit] used to set the gen bit as the last operation */
+	struct Vmxnet3_TxDesc *firstDesc = txQueue->txCmdVirt + insertOffset;
+	u8 firstDescGenBit = txQueue->genCmd;
+	const struct Plugin_SgElement *currSg = frame->elements;
+	u32 currSgOffset = 0;
+	/* can't update genCmd until success */
+	u8 currentGen = txQueue->genCmd;
+
+	/* set up a template descriptor used for all entries for the frame */
+	descTemplate.gen = !currentGen; /* start with "wrong" generation */
+	if (info->vlan) {
+		descTemplate.ti = 1;
+		descTemplate.tci = info->vlanTag;
+	}
+
+	if (info->tso) {
+		descTemplate.msscof = info->tsoMss;
+		descTemplate.om = VMXNET3_OM_TSO;
+		/* end of tcp header */
+		descTemplate.hlen = (u16)info->l4DataOffset;
+	} else if (info->xsumTcpOrUdp) {
+		descTemplate.msscof = info->l4HeaderOffset + (info->tcp ?
+				TCP_CSUM_OFFSET :
+				UDP_CSUM_OFFSET);
+		descTemplate.om = VMXNET3_OM_CSUM;
+		/* end of ip header */
+		descTemplate.hlen = (u16)info->l4HeaderOffset;
+	}
+
+	/* loop to stick buffers in the ring */
+	while (bytesRemainInFrame) {
+		struct Vmxnet3_TxDesc *currDesc = txQueue->txCmdVirt +
+			insertOffset;
+		u32 nextOffset;
+		u32 bytesInSg;
+
+		/* make sure we always leave at least one empty
+		   descriptor when the ring get full */
+		nextOffset = insertOffset + 1;
+		if (nextOffset >= txQueue->ringSize)
+			nextOffset = 0;
+
+		if (nextOffset == txQueue->nextCmdRemove) {
+			Shell_Log(state, 4, 2,
+					"full ring since nextOffset %u == "
+					"txQueue->nextCmdRemove %u\n",
+					nextOffset, txQueue->nextCmdRemove);
+			break;
+		}
+
+		/* copy the template and patch in the address/length info */
+		MoveMemory(currDesc, &descTemplate, sizeof descTemplate);
+
+		currDesc->addr = currSg->pa + currSgOffset;
+		bytesInSg = currSg->length - currSgOffset;
+
+		if (bytesInSg < VMXNET3_MAX_TX_BUF_SIZE) {
+			currDesc->len = bytesInSg;
+			++currSg;
+			currSgOffset = 0;
+		} else {
+			currDesc->len = 0;
+			if (bytesInSg == VMXNET3_MAX_TX_BUF_SIZE) {
+				++currSg;
+				currSgOffset = 0;
+			} else {
+				/* don't advance to next SG element */
+				currSgOffset += VMXNET3_MAX_TX_BUF_SIZE;
+			}
+			bytesRemainInFrame -= VMXNET3_MAX_TX_BUF_SIZE;
+		}
+
+		bytesRemainInFrame -= currDesc->len;
+
+		/* set EOP/CQ in the last descriptor */
+		if (bytesRemainInFrame == 0) {
+			currDesc->eop = 1;
+			currDesc->cq = 1;
+		}
+
+		/* write gen in all descriptors but the first one */
+		if (currDesc != firstDesc)
+			currDesc->gen = currentGen;
+
+		Shell_Log(state, 4, 4,
+				"txdesc[%u] sgOffset: %u len: %u gen: %u\n",
+				insertOffset, currSgOffset,
+				currDesc->len, currDesc->gen);
+
+		/* advance to the next desc */
+		++insertOffset;
+		if (insertOffset >= txQueue->ringSize) {
+			insertOffset = 0;
+			/* update with new "wrong" generation */
+			descTemplate.gen = currentGen;
+			VMXNET3_FLIP_RING_GEN(currentGen);
+		}
+	}
+
+	/* if frame successfully added, then update locations */
+	if (bytesRemainInFrame == 0) {
+		/* set the correct gen bit of the first descriptor */
+		firstDesc->gen = firstDescGenBit;
+
+		/* update state stored in tx queue */
+		txQueue->nextCmdInsert = insertOffset;
+		txQueue->genCmd = currentGen;
+	}
+
+	/*
+	 * Update the device register when we're told it's the
+	 * last frame.  The assumption/expectation is that for
+	 * non-vmxnet3 plugs 'lastFrame' will really be based
+	 * on the last frame, whereas for the vmxnet3 plugin the
+	 * shell will use the usual vmxnet3 logic/interaction
+	 * with the shared memory and use 'lastFrame' to tell
+	 * us if we should touch the device register.
+	 * It might be more strightforward for the shell to
+	 * just touch it for for plugin.
+	 *
+	 * Also update the register when we run out of
+	 * descriptor. This may force the device to process packets.
+	 */
+
+	if ((lastFrame || bytesRemainInFrame != 0) &&
+			txQueue->hwCmdInsert != txQueue->nextCmdInsert) {
+		VMXNET3_WRITE_REG(state, txQueue->txProdOffset,
+				txQueue->nextCmdInsert);
+		txQueue->hwCmdInsert = txQueue->nextCmdInsert;
+	}
+
+	return (bytesRemainInFrame == 0) ? 0 : 1;
+}
+
+
+static u32
+Vmxnet3Plugin_EnableInterrupt(struct Plugin_State *state,
+		u32 messageIndex)
+{
+	VMXNET3_WRITE_REG(state, VMXNET3_REG_IMR + messageIndex * 8, 0);
+	return 0;
+}
+
+
+static u32
+Vmxnet3Plugin_DisableInterrupt(struct Plugin_State *state,
+		u32 messageIndex)
+{
+	VMXNET3_WRITE_REG(state, VMXNET3_REG_IMR + messageIndex * 8, 1);
+	return 0;
+}
+
+
+u32
+NPA_PluginMain(struct Plugin_Api *pluginApi)
+{
+	pluginApi->swInit = Vmxnet3Plugin_SwInit;
+	pluginApi->reinitRxRing = Vmxnet3Plugin_ReinitRxRing;
+	pluginApi->reinitTxRing = Vmxnet3Plugin_ReinitTxRing;
+	pluginApi->addBuffersToRxRing = Vmxnet3Plugin_AddBuffersToRxRing;
+	pluginApi->addFrameToTxRing = Vmxnet3Plugin_AddFrameToTxRing;
+	pluginApi->checkRxRing = Vmxnet3Plugin_CheckRxRing;
+	pluginApi->checkTxRing = Vmxnet3Plugin_CheckTxRing;
+	pluginApi->enableInterrupt = Vmxnet3Plugin_EnableInterrupt;
+	pluginApi->disableInterrupt = Vmxnet3Plugin_DisableInterrupt;
+	return 0;
+}
