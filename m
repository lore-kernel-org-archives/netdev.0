From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv7] virtio-spec: virtio network device multiqueue support
Date: Mon, 10 Dec 2012 12:40:25 +0200
Message-ID: <20121210104025.GA26640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Add multiqueue support to virtio network device.
Add a new feature flag VIRTIO_NET_F_MQ for this feature, a new
configuration field max_virtqueue_pairs to detect supported number of
virtqueues as well as a new command VIRTIO_NET_CTRL_MQ to program
packet steering for unidirectional protocols.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

Changes in v7:
- 8000h -> 0x8000 at Rusty's request

Changes in v6:
- rename RFS -> multiqueue to avoid confusion with RFS in linux
  mention automatic receive steering as Rusty suggested

Changes in v5:
- Address Rusty's comments.
  Changes are only in the text, not the ideas.
- Some minor formatting changes.

Changes in v4:
- address Jason's comments
- have configuration specify the number of VQ pairs and not pairs - 1

Changes in v3:
- rename multiqueue -> rfs this is what we support
- Be more explicit about what driver should do.
- Simplify layout making VQs functionality depend on feature.
- Remove unused commands, only leave in programming # of queues

Changes in v2:
Address Jason's comments on v2:
- Changed STEERING_HOST to STEERING_RX_FOLLOWS_TX:
   this is both clearer and easier to support.
   It does not look like we need a separate steering command
   since host can just watch tx packets as they go.
- Moved RX and TX steering sections near each other.
- Add motivation for other changes in v2

Changes in v1 (from Jason's rfc):
- reserved vq 3: this makes all rx vqs even and tx vqs odd, which
   looks nicer to me.
- documented packet steering, added a generalized steering programming
   command. Current modes are single queue and host driven multiqueue,
   but I envision support for guest driven multiqueue in the future.
- make default vqs unused when in mq mode - this wastes some memory
   but makes it more efficient to switch between modes as
   we can avoid this causing packet reordering.


diff --git a/virtio-spec.lyx b/virtio-spec.lyx
index 83f2771..6c09180 100644
--- a/virtio-spec.lyx
+++ b/virtio-spec.lyx
@@ -59,6 +59,7 @@
 \author -608949062 "Rusty Russell,,," 
 \author -385801441 "Cornelia Huck" cornelia.huck@de.ibm.com
 \author 1531152142 "Paolo Bonzini,,," 
+\author 1986246365 "Michael S. Tsirkin" 
 \end_header
 
 \begin_body
@@ -4170,9 +4171,46 @@ ID 1
 \end_layout
 
 \begin_layout Description
-Virtqueues 0:receiveq.
- 1:transmitq.
- 2:controlq
+Virtqueues 0:receiveq
+\change_inserted 1986246365 1352742829
+0
+\change_unchanged
+.
+ 1:transmitq
+\change_inserted 1986246365 1352742832
+0
+\change_deleted 1986246365 1352742947
+.
+ 
+\change_inserted 1986246365 1352742952
+.
+ ....
+ 2N
+\begin_inset Foot
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1354531595
+N=0 if VIRTIO_NET_F_MQ is not negotiated, otherwise N is derived from 
+\emph on
+max_virtqueue_pairs
+\emph default
+ control
+\emph on
+ 
+\emph default
+field.
+ 
+\end_layout
+
+\end_inset
+
+: receivqN.
+ 2N+1: transmitqN.
+ 2N+
+\change_unchanged
+2:controlq
 \begin_inset Foot
 status open
 
@@ -4343,6 +4381,16 @@ VIRTIO_NET_F_CTRL_VLAN
 
 \begin_layout Description
 VIRTIO_NET_F_GUEST_ANNOUNCE(21) Guest can send gratuitous packets.
+\change_inserted 1986246365 1352742767
+
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 1986246365 1352742808
+VIRTIO_NET_F_MQ(22) Device supports multiqueue with automatic receive steering.
+\change_unchanged
+
 \end_layout
 
 \end_deeper
@@ -4355,11 +4403,45 @@ configuration
 \begin_inset space ~
 \end_inset
 
-layout Two configuration fields are currently defined.
+layout 
+\change_deleted 1986246365 1352743300
+Two
+\change_inserted 1986246365 1354531413
+Three
+\change_unchanged
+ configuration fields are currently defined.
  The mac address field always exists (though is only valid if VIRTIO_NET_F_MAC
  is set), and the status field only exists if VIRTIO_NET_F_STATUS is set.
  Two read-only bits are currently defined for the status field: VIRTIO_NET_S_LIN
 K_UP and VIRTIO_NET_S_ANNOUNCE.
+
+\change_inserted 1986246365 1354531470
+ The following read-only field, 
+\emph on
+max_virtqueue_pairs
+\emph default
+ only exists if VIRTIO_NET_F_MQ is set.
+ This field specifies the maximum number of each of transmit and receive
+ virtqueues (receiveq0..receiveq
+\emph on
+N
+\emph default
+ and transmitq0..transmitq
+\emph on
+N
+\emph default
+ respectively; 
+\emph on
+N
+\emph default
+=
+\emph on
+max_virtqueue_pairs - 1
+\emph default
+) that can be configured once VIRTIO_NET_F_MQ is negotiated.
+ Legal values for this field are 1 to 0x8000.
+
+\change_unchanged
  
 \begin_inset listings
 inline false
@@ -4392,6 +4474,17 @@ struct virtio_net_config {
 \begin_layout Plain Layout
 
     u16 status;
+\change_inserted 1986246365 1354531427
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1354531437
+
+    u16 max_virtqueue_pairs;
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -4410,7 +4503,24 @@ Device Initialization
 
 \begin_layout Enumerate
 The initialization routine should identify the receive and transmission
- virtqueues.
+ virtqueues
+\change_inserted 1986246365 1352744077
+, up to N+1 of each kind
+\change_unchanged
+.
+
+\change_inserted 1986246365 1352743942
+ If VIRTIO_NET_F_MQ feature bit is negotiated, 
+\emph on
+N=max_virtqueue_pairs-1
+\emph default
+, otherwise identify 
+\emph on
+N=0
+\emph default
+.
+\change_unchanged
+
 \end_layout
 
 \begin_layout Enumerate
@@ -4452,10 +4562,33 @@ status
 
  config field.
  Otherwise, the link should be assumed active.
+\change_inserted 1986246365 1354529306
+
 \end_layout
 
 \begin_layout Enumerate
-The receive virtqueue should be filled with receive buffers.
+
+\change_inserted 1986246365 1354531717
+Only receiveq0, transmitq0 and controlq are used by default.
+ To use more queues driver must negotiate the VIRTIO_NET_F_MQ feature;
+ initialize up to 
+\emph on
+max_virtqueue_pairs
+\emph default
+ of each of transmit and receive queues; execute_VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SE
+T command specifying the number of the transmit and receive queues that
+ is going to be used and wait until the device consumes the controlq buffer
+ and acks this command.
+\change_unchanged
+
+\end_layout
+
+\begin_layout Enumerate
+The receive virtqueue
+\change_inserted 1986246365 1352743953
+s
+\change_unchanged
+ should be filled with receive buffers.
  This is described in detail below in 
 \begin_inset Quotes eld
 \end_inset
@@ -4550,8 +4683,15 @@ Device Operation
 \end_layout
 
 \begin_layout Standard
-Packets are transmitted by placing them in the transmitq, and buffers for
- incoming packets are placed in the receiveq.
+Packets are transmitted by placing them in the transmitq
+\change_inserted 1986246365 1353593685
+0..transmitqN
+\change_unchanged
+, and buffers for incoming packets are placed in the receiveq
+\change_inserted 1986246365 1353593692
+0..receiveqN
+\change_unchanged
+.
  In each case, the packet itself is preceeded by a header:
 \end_layout
 
@@ -4861,6 +5001,17 @@ If VIRTIO_NET_F_MRG_RXBUF is negotiated, each buffer must be at least the
 struct virtio_net_hdr
 \family default
 .
+\change_inserted 1986246365 1353594518
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1353594638
+If VIRTIO_NET_F_MQ is negotiated, each of receiveq0...receiveqN that will
+ be used should be populated with receive buffers.
+\change_unchanged
+
 \end_layout
 
 \begin_layout Subsection*
@@ -5293,8 +5444,151 @@ Sending VIRTIO_NET_CTRL_ANNOUNCE_ACK command through control vq.
  
 \end_layout
 
-\begin_layout Enumerate
+\begin_layout Subsection*
+
+\change_inserted 1986246365 1353593879
+Automatic receive steering in multiqueue mode
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1354528882
+If the driver negotiates the VIRTIO_NET_F_MQ feature bit (depends on VIRTIO_NET
+_F_CTRL_VQ), it can transmit outgoing packets on one of the multiple transmitq0..t
+ransmitqN and ask the device to queue incoming packets into one the multiple
+ receiveq0..receiveqN depending on the packet flow.
+\change_unchanged
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1353594292
+\begin_inset listings
+inline false
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594178
+
+struct virtio_net_ctrl_mq {
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594212
+
+	u16 virtqueue_pairs;
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594172
+
+};
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594172
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594263
+
+#define VIRTIO_NET_CTRL_MQ    1
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594273
+
+ #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET        0 
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594273
+
+ #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN        1 
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594273
+
+ #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MAX        0x8000
+\end_layout
+
+\end_inset
+
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1354531492
+Multiqueue is disabled by default.
+ Driver enables multiqueue by executing the VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET command,
+ specifying the number of the transmit and receive queues that will be used;
+ thus transmitq0..transmitqn and receiveq0..receiveqn where 
+\emph on
+n=virtqueue_pairs-1
+\emph default
+ will be used.
+ All these virtqueues must have been pre-configured in advance.
+ The range of legal values for the
+\emph on
+ virtqueue_pairs
+\emph off
+ field is between 1 and 
+\emph on
+max_virtqueue_pairs
+\emph off
+.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1353595328
+When multiqueue is enabled, device uses automatic receive
+steering based on packet flow.
+Programming of the receive steering classificator is implicit.
+ Transmitting a packet of a specific flow on transmitqX will cause incoming
+ packets for this flow to be steered to receiveqX.
+ For uni-directional protocols, or where no packets have been transmitted
+ yet, device will steer a packet to a random queue out of the specified
+ receiveq0..receiveqn.
+\change_unchanged
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1354528710
+Multiqueue is disabled by setting 
+\emph on
+virtqueue_pairs = 1
+\emph default
+ (this is the default).
+ After the command is consumed by the device, the device will not steer
+ new packets on virtqueues receveq1..receiveqN (i.e.
+ other than receiveq0) nor read from transmitq1..transmitqN (i.e.
+ other than transmitq0); accordingly, driver should not transmit new packets
+ on virtqueues other than transmitq0.
+\change_unchanged
+
+\end_layout
+
+\begin_layout Standard
+
+\change_deleted 1986246365 1353593873
 .
+
+\change_unchanged
  
 \end_layout
