From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Sun, 9 Sep 2012 16:03:08 +0300
Message-ID: <20120909130308.GA3471@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, pbonzini@redhat.com, levinsasha928@gmail.com
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
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

Add multiqueue support to virtio network device.  Add a new feature flag
VIRTIO_NET_F_MULTIQUEUE for this feature, a +new configuration field
max_virtqueue_pairs to detect supported number +of virtqueues as well as
a new command VIRTIO_NET_CTRL_STEERING to +program packet steering.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Changes from v3:
Address Sasha's comments
- drop debug fields - less fields less to debug :)
- clarify max_virtqueue_pairs field and steering param field
- misc typos
Address Paolo's comments
- Fixed old rule name left over from v2
Address Rick's comment
- Tweaked wording

Changes from v2:
Address Jason's comments on v2:
- Changed STEERING_HOST to STEERING_RX_FOLLOWS_TX:
  this is both clearer and easier to support.
  It does not look like we need a separate steering command
  since host can just watch tx packets as they go.
- Moved RX and TX steering sections near each other.
- Add motivation for other changes in v2

Changes from Jason's rfc:
- reserved vq 3: this makes all rx vqs even and tx vqs odd, which
  looks nicer to me.
- documented packet steering, added a generalized steering programming
  command. Current modes are single queue and host driven multiqueue,
  but I envision support for guest driven multiqueue in the future.
- make default vqs unused when in mq mode - this wastes some memory
  but makes it more efficient to switch between modes as
  we can avoid this causing packet reordering.

If this looks OK to everyone, we can proceed with finalizing the
implementation.  This patch is against
eb9fc84d0d3c46438aaab190e2401a9e5409a052 in virtio-spec git tree.

---
 virtio-spec.lyx | 453 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 446 insertions(+), 7 deletions(-)

diff --git a/virtio-spec.lyx b/virtio-spec.lyx
index fb6a4e3..2c2490e 100644
--- a/virtio-spec.lyx
+++ b/virtio-spec.lyx
@@ -58,6 +58,7 @@
 \html_be_strict false
 \author -608949062 "Rusty Russell,,," 
 \author 1531152142 "Paolo Bonzini,,," 
+\author 1986246365 "Michael S. Tsirkin" 
 \end_header
 
 \begin_body
@@ -3896,6 +3897,61 @@ Only if VIRTIO_NET_F_CTRL_VQ set
 \end_inset
 
 
+\change_inserted 1986246365 1346663522
+ 3: reserved
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 1986246365 1346663550
+4: receiveq1.
+ 5: transmitq1.
+ 6: receiveq2.
+ 7.
+ transmitq2.
+ ...
+ 2
+\emph on
+N
+\emph default
++2:receivq
+\emph on
+N
+\emph default
+, 2
+\emph on
+N
+\emph default
++3:transmitq
+\emph on
+N
+\emph default
+
+\begin_inset Foot
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346663558
+Only if VIRTIO_NET_F_CTRL_VQ set.
+ 
+\emph on
+N
+\emph default
+ is indicated by 
+\emph on
+max_virtqueue_pairs
+\emph default
+ field.
+\change_unchanged
+
+\end_layout
+
+\end_inset
+
+
+\change_unchanged
+
 \end_layout
 
 \begin_layout Description
@@ -4056,6 +4112,17 @@ VIRTIO_NET_F_CTRL_VLAN
 
 \begin_layout Description
 VIRTIO_NET_F_GUEST_ANNOUNCE(21) Guest can send gratuitous packets.
+\change_inserted 1986246365 1346617842
+
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 1986246365 1346618103
+VIRTIO_NET_F_MULTIQUEUE(22) Device has multiple receive and transmission
+ queues.
+\change_unchanged
+
 \end_layout
 
 \end_deeper
@@ -4068,11 +4135,45 @@ configuration
 \begin_inset space ~
 \end_inset
 
-layout Two configuration fields are currently defined.
+layout 
+\change_deleted 1986246365 1346671560
+Two
+\change_inserted 1986246365 1346671647
+Six
+\change_unchanged
+ configuration fields are currently defined.
  The mac address field always exists (though is only valid if VIRTIO_NET_F_MAC
  is set), and the status field only exists if VIRTIO_NET_F_STATUS is set.
  Two read-only bits are currently defined for the status field: VIRTIO_NET_S_LIN
 K_UP and VIRTIO_NET_S_ANNOUNCE.
+
+\change_inserted 1986246365 1347194909
+ The following read-only field, 
+\emph on
+max_virtqueue_pairs
+\emph default
+ only exists if VIRTIO_NET_F_MULTIQUEUE is set.
+ This field specifies the maximum number of each of transmit and receive
+ virtqueues (receiveq1..receiveq
+\emph on
+N
+\emph default
+ and transmitq1..transmitq
+\emph on
+N
+\emph default
+ respectively; 
+\emph on
+N
+\emph default
+=
+\emph on
+max_virtqueue_pairs
+\emph default
+) that can be used for multiqueue operation, excluding the default receiveq(0)
+ and transmitq(1) virtqueues.
+
+\change_unchanged
  
 \begin_inset listings
 inline false
@@ -4105,6 +4206,15 @@ struct virtio_net_config {
 \begin_layout Plain Layout
 
     u16 status;
+\change_inserted 1986246365 1346671221
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346671532
+
+    u16 max_virtqueue_pairs;
 \end_layout
 
 \begin_layout Plain Layout
@@ -4151,6 +4261,18 @@ physical
 \begin_layout Enumerate
 If the VIRTIO_NET_F_CTRL_VQ feature bit is negotiated, identify the control
  virtqueue.
+\change_inserted 1986246365 1346618052
+
+\end_layout
+
+\begin_layout Enumerate
+
+\change_inserted 1986246365 1346618175
+If VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, identify the receive
+ and transmission queues that are going to be used in multiqueue mode.
+ Only queues that are going to be used need to be initialized.
+\change_unchanged
+
 \end_layout
 
 \begin_layout Enumerate
@@ -4168,7 +4290,11 @@ status
 \end_layout
 
 \begin_layout Enumerate
-The receive virtqueue should be filled with receive buffers.
+The receive virtqueue
+\change_inserted 1986246365 1346618180
+(s)
+\change_unchanged
+ should be filled with receive buffers.
  This is described in detail below in 
 \begin_inset Quotes eld
 \end_inset
@@ -4513,6 +4639,8 @@ Note that the header will be two bytes longer for the VIRTIO_NET_F_MRG_RXBUF
 \end_inset
 
 
+\change_deleted 1986246365 1346932640
+
 \end_layout
 
 \begin_layout Subsection*
@@ -4988,8 +5116,24 @@ status open
 The Guest needs to check VIRTIO_NET_S_ANNOUNCE bit in status field when
  it notices the changes of device configuration.
  The command VIRTIO_NET_CTRL_ANNOUNCE_ACK is used to indicate that driver
- has recevied the notification and device would clear the VIRTIO_NET_S_ANNOUNCE
- bit in the status filed after it received this command.
+ has rece
+\change_inserted 1986246365 1346663932
+i
+\change_unchanged
+v
+\change_deleted 1986246365 1346663934
+i
+\change_unchanged
+ed the notification and device would clear the VIRTIO_NET_S_ANNOUNCE bit
+ in the status fi
+\change_inserted 1986246365 1346663942
+e
+\change_unchanged
+l
+\change_deleted 1986246365 1346663943
+e
+\change_unchanged
+d after it received this command.
 \end_layout
 
 \begin_layout Standard
@@ -5004,10 +5148,306 @@ Sending the gratuitous packets or marking there are pending gratuitous packets
 \begin_layout Enumerate
 Sending VIRTIO_NET_CTRL_ANNOUNCE_ACK command through control vq.
  
+\change_deleted 1986246365 1346662247
+
 \end_layout
 
-\begin_layout Enumerate
+\begin_layout Subsection*
+
+\change_inserted 1986246365 1346932658
+\begin_inset CommandInset label
+LatexCommand label
+name "sub:Transmit-Packet-Steering"
+
+\end_inset
+
+Transmit Packet Steering
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932658
+When VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, guest can use any
+ of multiple configured transmit queues to transmit a given packet.
+ To avoid packet reordering by device (which generally leads to performance
+ degradation) driver should attempt to utilize the same transmit virtqueue
+ for all packets of a given transmit flow.
+ For bi-directional protocols (in practice, TCP), a given network connection
+ can utilize both transmit and receive queues.
+ For best performance, packets from a single connection should utilize the
+ paired transmit and receive queues from the same virtqueue pair; for example
+ both transmitqN and receiveqN.
+ This rule makes it possible to optimize processing on the device side,
+ but this is not a hard requirement: devices should function correctly even
+ when this rule is not followed.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932658
+Driver selects an active steering rule using VIRTIO_NET_CTRL_STEERING command
+ (this controls both which virtqueue is selected for a given packet for
+ receive and notifies the device which virtqueues are about to be used for
+ transmit).
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932658
+This command accepts a single out argument in the following format:
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932658
+\begin_inset listings
+inline false
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1347192845
+
+#define VIRTIO_NET_CTRL_STEERING               4
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346932658
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346932658
+
+struct virtio_net_ctrl_steering {
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346932658
+
+	u8 current_steering_rule;
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346932658
+
+    u8 reserved;
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346932658
+
+	u16 current_steering_param;
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1346932658
+
+};
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1347192841
+
+#define VIRTIO_NET_CTRL_STEERING_SINGLE        0
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1347192840
+
+#define VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX 1
+\end_layout
+
+\end_inset
+
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1347193028
+The field 
+\emph on
+rule
+\emph default
+ specifies the function used to select transmit virtqueue for a given packet;
+ the field 
+\emph on
+param
+\emph default
+ makes it possible to pass an extra parameter if appropriate.
+ When 
+\emph on
+rule
+\emph default
+ is set to VIRTIO_NET_CTRL_STEERING_SINGLE (this is the default) all packets
+ are steered to the default virtqueue transmitq (1); param is unused; this
+ is the default.
+ With any other rule, When 
+\emph on
+rule
+\emph default
+ is set to VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX packets are steered by
+ driver to the first 
+\emph on
+N
+\emph default
+=(
+\emph on
+param
+\emph default
++1) multiqueue virtqueues transmitq1...transmitqN; the default transmitq is
+ unused.
+ Driver must have configured all these (
+\emph on
+param
+\emph default
++1) virtqueues beforehand.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1347193114
+Supported steering rules can be added and removed in the future.
+ Driver should check that the request to change the steering rule was successful
+ by checking ack values of the command.
+ As selecting a specific steering is an optimization feature, drivers should
+ avoid hard failure and fall back on using a supported steering rule if
+ this command fails.
+ The default steering rule is VIRTIO_NET_CTRL_STEERING_SINGLE.
+ It will not be removed.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932658
+When the steering rule is modified, some packets can still be outstanding
+ in one or more of the transmit virtqueues.
+ Since drivers might choose to modify the current steering rule at a high
+ rate (e.g.
+ adaptively in response to changes in the workload) to avoid reordering
+ packets, device is recommended to complete processing of the transmit queue(s)
+ utilized by the original steering before processing any packets delivered
+ by the modified steering rule.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932658
+For debugging, the current steering rule can also be read from the configuration
+ space.
+\end_layout
+
+\begin_layout Subsection*
+
+\change_inserted 1986246365 1346670357
+\begin_inset CommandInset label
+LatexCommand label
+name "sub:Receive-Packet-Steering"
+
+\end_inset
+
+Receive Packet Steering
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346671046
+When VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, device can use any
+ of multiple configured receive queues to pass a given packet to driver.
+ Driver controls which virtqueue is selected in practice by configuring
+ packet steering rule using VIRTIO_NET_CTRL_STEERING command, as described
+ above
+\begin_inset CommandInset ref
+LatexCommand ref
+reference "sub:Transmit-Packet-Steering"
+
+\end_inset
+
 .
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1347193175
+The field 
+\emph on
+rule
+\emph default
+ specifies the function used to select receive virtqueue for a given packet;
+ the field 
+\emph on
+param
+\emph default
+ makes it possible to pass an extra parameter if appropriate.
+ When 
+\emph on
+rule
+\emph default
+ is set to VIRTIO_NET_CTRL_STEERING_SINGLE all packets are steered to the
+ default virtqueue receiveq (0); param is unused; this is the default.
+ When 
+\emph on
+rule
+\emph default
+ is set to VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX packets are steered by
+ host to the first 
+\emph on
+N
+\emph default
+=(
+\emph on
+param
+\emph default
++1) multiqueue virtqueues receiveq1...receiveqN; the default receiveq is unused.
+ Driver must have configured all these (
+\emph on
+param
+\emph default
++1) virtqueues beforehand.
+ For best performance for bi-directional flows (such as TCP) device should
+ detect the flow to virtqueue pair mapping on transmit and select the receive
+ virtqueue from the same virtqueue pair.
+ For uni-directional flows, or when this mapping information is missing,
+ a device-specific steering function is used.
+\change_unchanged
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346669564
+Supported steering rules can be added and removed in the future.
+ Driver should probe for supported rules by checking ack values of the command.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 1986246365 1346932135
+When the steering rule is modified, some packets can still be outstanding
+ in one or more of the virtqueues.
+ Device is not required to wait for these packets to be consumed before
+ delivering packets using the new streering rule.
+ Drivers modifying the steering rule at a high rate (e.g.
+ adaptively in response to changes in the workload) are recommended to complete
+ processing of the receive queue(s) utilized by the original steering before
+ processing any packets delivered by the modified steering rule.
+\end_layout
+
+\begin_layout Standard
+
+\change_deleted 1986246365 1346664095
+.
+
+\change_unchanged
  
 \end_layout
 
@@ -5973,8 +6413,7 @@ If the VIRTIO_CONSOLE_F_MULTIPORT feature is negotiated, the driver can
  spawn multiple ports, not all of which may be attached to a console.
  Some could be generic ports.
  In this case, the control virtqueues are enabled and according to the max_nr_po
-rts configuration-space value, an appropriate number of virtqueues are
- created.
+rts configuration-space value, an appropriate number of virtqueues are created.
  A control message indicating the driver is ready is sent to the host.
  The host can then send control messages for adding new ports to the device.
  After creating and initializing each port, a VIRTIO_CONSOLE_PORT_READY
-- 
MST
