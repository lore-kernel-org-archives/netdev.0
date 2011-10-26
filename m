From: Jason Wang <jasowang@redhat.com>
Subject: [virtio-spec: RFC PATCH] virtio-spec:
	introduce	VIRTIO_NET_F_GUEST_ANNOUNCE
Date: Wed, 26 Oct 2011 16:49:12 +0800
Message-ID: <20111026084912.19391.26534.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, mst@redhat.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Network connections in guest need to be kept after migration. This is done by
sending gratuitous packet and let switch learn new port of the mac
address. As hypervisor does not have the knowledge of guest network
configurations such as tagged vlan or ipv6, it may require guest to send
gratuitous packet.

This patch introduces a new feature bit of virtio network adapter -
VIRTIO_NET_F_GUEST_ANNOUNCE which is used to indicate the ability to send
gratuitous packets by guest. A new status bit - VIRTIO_NET_S_ANNOUNCE is also
introduced to notify the guest the need for sending gratuitous packet. When
guest notice this, it should clear it and send the gratuitous packet.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 virtio-spec.lyx |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/virtio-spec.lyx b/virtio-spec.lyx
index 6426f8f..87733b9 100644
--- a/virtio-spec.lyx
+++ b/virtio-spec.lyx
@@ -4133,6 +4133,14 @@ VIRTIO_NET_F_CTRL_VLAN
 (19) Control channel VLAN filtering.
 \end_layout
 
+\begin_layout Description
+VIRTIO_NET_F_GUEST_ANNOUNCE
+\begin_inset space ~
+\end_inset
+
+(21) Guest can send gratuitous packets.
+\end_layout
+
 \end_deeper
 \begin_layout Description
 Device
@@ -4146,7 +4154,8 @@ configuration
 layout Two configuration fields are currently defined.
  The mac address field always exists (though is only valid if VIRTIO_NET_F_MAC
  is set), and the status field only exists if VIRTIO_NET_F_STATUS is set.
- Only one bit is currently defined for the status field: VIRTIO_NET_S_LINK_UP.
+ Two bits are currently defined for the status field: VIRTIO_NET_S_LINK_UP
+ and VIRTIO_NET_S_ANOUNCE.
  
 \begin_inset listings
 inline false
@@ -4159,6 +4168,11 @@ status open
 
 \begin_layout Plain Layout
 
+#define VIRTIO_NET_S_ANNOUNCE	2
+\end_layout
+
+\begin_layout Plain Layout
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -5015,6 +5029,35 @@ Both the VIRTIO_NET_CTRL_VLAN_ADD and VIRTIO_NET_CTRL_VLAN_DEL command take
  a 16-bit VLAN id as the command-specific-data.
 \end_layout
 
+\begin_layout Subsection*
+Gratuitous Packet Sending
+\end_layout
+
+\begin_layout Standard
+If the driver negotiates the VIRTIO_NET_F_GUEST_ANNOUNCE, it can send gratuitous
+ packet.
+ Gratuitous packet were used to notify the change of physical link and it
+ is usually sent after migration.
+ As hypervisor does not have the knowledge of guest network configuration
+ (ie.
+ tagged vlan), it would demand guest to send gratuitous packet by setting
+ VIRTIO_NET_S_ANNOUNCE bit in status field.
+ Guest needs to check VIRTIO_NET_S_ANNOUNCE bit in status field when it
+ notices the changes of device configuration.
+\end_layout
+
+\begin_layout Standard
+Processing this notification invloves:
+\end_layout
+
+\begin_layout Enumerate
+Clear VIRTIO_NET_S_ANNOUNCE bit in the status field.
+\end_layout
+
+\begin_layout Enumerate
+Send the gratuitous packets.
+\end_layout
+
 \begin_layout Chapter*
 Appendix D: Block Device
 \end_layout
