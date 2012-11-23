From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4] virtio-spec: virtio network device RFS support
Date: Fri, 23 Nov 2012 12:10:02 +0200
Message-ID: <20121123101001.GA7051@redhat.com>
References: <20121122144645.GA28284@redhat.com> <50AF06F0.1030604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <50AF06F0.1030604@redhat.com>
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

On Fri, Nov 23, 2012 at 01:17:36PM +0800, Jason Wang wrote:
...

> "specifying the number of the last transmit and receive queue that
> is going to be used; thus out of transmitq0..transmitqn and
> receiveq0..receiveqn where n=virtqueue_pairs will be used."
> 
> In this description, looks like n+1 virtqueue pairs (include
> receiveq0 and transmitq0) could be used in RFS mode.

The intent was not to reserve any virt queue pairs.
I hope I clarified this below.



Thanks for the comments. Here's an incremental patch to address
them.


diff --git a/virtio-spec.lyx b/virtio-spec.lyx
index e562335..53ddeec 100644
--- a/virtio-spec.lyx
+++ b/virtio-spec.lyx
@@ -4384,7 +4384,7 @@ VIRTIO_NET_F_GUEST_ANNOUNCE(21) Guest can send gratuitous packets.
 \begin_layout Description
 
 \change_inserted 1986246365 1352742808
-VIRTIO_NET_F_RFS(2) Device supports Receive Flow Steering.
+VIRTIO_NET_F_RFS(22) Device supports Receive Flow Steering.
 \change_unchanged
 
 \end_layout
@@ -4432,9 +4432,10 @@ N
 \emph default
 =
 \emph on
-max_virtqueue_pairs
+max_virtqueue_pairs - 1
 \emph default
 ) that can be configured once VIRTIO_NET_F_RFS is negotiated.
+Legal values for this field are 1 to 8000h.
 
 \change_unchanged
  
@@ -4496,7 +4497,7 @@ The initialization routine should identify the receive and transmission
 \change_inserted 1986246365 1352743942
  If VIRTIO_NET_F_RFS feature bit is negotiated, 
 \emph on
-N=max_virtqueue_pairs
+N=max_virtqueue_pairs-1
 \emph default
 , otherwise identify 
 \emph on
@@ -5464,7 +5465,7 @@ struct virtio_net_ctrl_rfs {
 
 \change_inserted 1986246365 1353594263
 
-#define VIRTIO_NET_CTRL_RFC    1
+#define VIRTIO_NET_CTRL_RFS    1
 \end_layout
 
 \begin_layout Plain Layout
@@ -5474,6 +5475,19 @@ struct virtio_net_ctrl_rfs {
  #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_SET        0 
 \end_layout
 
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594273
+
+ #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_MIN        1 
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 1986246365 1353594273
+
+ #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_MAX        0x8000
+\end_layout
 \end_inset
 
 
@@ -5484,14 +5498,19 @@ struct virtio_net_ctrl_rfs {
 \change_inserted 1986246365 1353594884
 RFS acceleration is disabled by default.
  Driver enables RFS by executing the VIRTIO_NET_CTRL_RFS_VQ_PAIRS_SET command,
- specifying the number of the last transmit and receive queue that is going
+ specifying the number of the transmit and receive queues that is going
  to be used; thus out of transmitq0..transmitqn and receiveq0..receiveqn where
  
 \emph on
-n=virtqueue
+n=virtqueue_pairs-1
 \emph default
-_pairs will be used.
+ will be used.
  All these virtqueues must have been pre-configured in advance.
+ The range of legal values for the
+\emph on
+ virtqueue_pairs
+\emph off
+ field is between 1 and 8000h.
 \end_layout
 
 \begin_layout Standard
@@ -5512,7 +5531,7 @@ Programming of the receive flow classificator is implicit.
 \change_inserted 1986246365 1353595040
 RFS acceleration is disabled by setting 
 \emph on
-virtqueue_pairs = 0
+virtqueue_pairs = 1
 \emph default
  (this is the default).
  Following this, driver should not transmit new packets on virtqueues other
