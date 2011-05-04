From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] virtio-spec: 64 bit features, used/avail event
Date: Wed, 4 May 2011 23:32:56 +0300
Message-ID: <20110504203256.GA20819@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Carsten Otte <cotte@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Shirley Ma <xma@us.ibm.com>, lguest@lists.ozlabs.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, steved@us.ibm.com,
	habanero@linux.vnet.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm working on a patchset (to follow shortly)
that modified the notificatin hand-off in virtio to be basically
like Xen: each side published an index, the other side only triggers
an event when it crosses that index value
(Xen event indexes start at 1, ours start at 0 for
backward-compatiblity, but that's minor).

Especially for testing, it is very convenient to have
separate feature bits for this change in used and available
ring; since we've run out of bits in the 32 bit field,
I added another 32 bit and bit 31 enables that.

I started with using both flags and indexes in parallel,
but switched to doing either-or: this means we do
not need to tweak memory access ordering as index access just
replaces flags access.

A note on naming: the index replacing avail->flags is named
used_event, the index replacing used->flags is named
avail_event to stress the fact that these actually
point into the other side of the ring:
event is triggered when avail->idx == used->avail_event + 1
and when used->idx == avail->used_event + 1, respectively.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1:
	- minor wording changes to address comments
	- fill a couple of places I missed
	- add text about access ordering

 virtio-spec.lyx |  719 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 700 insertions(+), 19 deletions(-)

diff --git a/virtio-spec.lyx b/virtio-spec.lyx
index f7c9c38..95fd926 100644
--- a/virtio-spec.lyx
+++ b/virtio-spec.lyx
@@ -1,4 +1,4 @@
-#LyX 1.6.7 created this file. For more info see http://www.lyx.org/
+#LyX 1.6.8 created this file. For more info see http://www.lyx.org/
 \lyxformat 345
 \begin_document
 \begin_header
@@ -36,7 +36,7 @@
 \paperpagestyle default
 \tracking_changes true
 \output_changes true
-\author "" 
+\author "Michael S. Tsirkin" 
 \author "" 
 \end_header
 
@@ -953,6 +953,10 @@ ISR
 
 \size footnotesize
 Features
+\change_inserted 0 1304329091
+ bits 0:31
+\change_unchanged
+
 \end_layout
 
 \end_inset
@@ -964,6 +968,10 @@ Features
 
 \size footnotesize
 Features
+\change_inserted 0 1304329086
+ bits 0:31
+\change_unchanged
+
 \end_layout
 
 \end_inset
@@ -1186,6 +1194,177 @@ Vector
 \end_layout
 
 \begin_layout Standard
+
+\change_inserted 0 1304328924
+Finally, if feature bits (VIRTIO_F_FEATURES_HI) this is immediately followed
+ by two additional fields:
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 0 1304328925
+\begin_inset Tabular
+<lyxtabular version="3" rows="4" columns="3">
+<features>
+<column alignment="left" valignment="top" width="0">
+<column alignment="left" valignment="top" width="0">
+<column alignment="left" valignment="top" width="0">
+<row>
+<cell alignment="center" valignment="top" topline="true" leftline="true" rightline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+Bits
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" topline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+32
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" topline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+32
+\end_layout
+
+\end_inset
+</cell>
+</row>
+<row>
+<cell alignment="center" valignment="top" topline="true" leftline="true" rightline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+Read/Write
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" topline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+R
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" topline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+R+W
+\end_layout
+
+\end_inset
+</cell>
+</row>
+<row>
+<cell alignment="center" valignment="top" topline="true" leftline="true" rightline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+Purpose
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" topline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+
+\size footnotesize
+Device
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" topline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+
+\size footnotesize
+Guest
+\end_layout
+
+\end_inset
+</cell>
+</row>
+<row>
+<cell alignment="center" valignment="top" bottomline="true" leftline="true" rightline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304328925
+
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" bottomline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304329099
+
+\size footnotesize
+Features bits 32:63
+\end_layout
+
+\end_inset
+</cell>
+<cell alignment="center" valignment="top" bottomline="true" leftline="true" usebox="none">
+\begin_inset Text
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304329102
+
+\size footnotesize
+Features bits 32:63
+\end_layout
+
+\end_inset
+</cell>
+</row>
+</lyxtabular>
+
+\end_inset
+
+
+\end_layout
+
+\begin_layout Standard
 Immediately following these general headers, there may be device-specific
  headers:
 \end_layout
@@ -1348,7 +1527,20 @@ Feature Bits
 The least significant 31 bits of the first configuration field indicates
  the features that the device supports (the high bit is reserved, and will
  be used to indicate the presence of future feature bits elsewhere).
- The bits are allocated as follows:
+ 
+\change_inserted 0 1304331636
+If more than 31 feature bits are supported, the device indicates so by setting
+ feature bit 31 (see 
+\begin_inset CommandInset ref
+LatexCommand ref
+reference "cha:Reserved-Feature-Bits"
+
+\end_inset
+
+).
+ 
+\change_unchanged
+The bits are allocated as follows:
 \end_layout
 
 \begin_layout Description
@@ -1372,7 +1564,33 @@ to
 \begin_inset space ~
 \end_inset
 
-30 Feature bits reserved for extensions to the queue mechanism
+
+\change_inserted 0 1304329326
+4
+\change_deleted 0 1304329325
+3
+\change_unchanged
+0 Feature bits reserved for extensions to the queue 
+\change_inserted 0 1304540448
+and feature negotiation 
+\change_unchanged
+mechanism
+\change_inserted 0 1304540449
+s
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 0 1304329398
+41
+\begin_inset space ~
+\end_inset
+
+to
+\begin_inset space ~
+\end_inset
+
+63 Feature bits reserved for future extensions
 \end_layout
 
 \begin_layout Standard
@@ -1407,6 +1625,19 @@ This allows for forwards and backwards compatibility: if the device is enhanced
  support, it will not see that feature bit in the Device Features field
  and can go into backwards compatibility mode (or, for poor implementations,
  set the FAILED Device Status bit).
+\change_inserted 0 1304329423
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 0 1304331742
+Access to feature bits 32 to 63 is enabled by Guest by setting feature bit
+ 31.
+ If this bit is unset, Device must assume that all feature bits > 31 are
+ unset.
+\change_unchanged
+
 \end_layout
 
 \begin_layout Subsubsection
@@ -1891,7 +2122,38 @@ flags
 
  field is currently 0 or 1: 1 indicating that we do not need an interrupt
  when the device consumes a descriptor from the available ring.
- This interrupt suppression is merely an optimization; it may not suppress
+ 
+\change_inserted 0 1304540481
+Alternatively, the guest ask the device to delay interrupts until an entry
+ with an index specified by the 
+\begin_inset Quotes eld
+\end_inset
+
+used_event
+\begin_inset Quotes erd
+\end_inset
+
+ field is written in the used ring (equivalently, until the 
+\emph on
+idx
+\emph default
+ field in the used ring will reach the value 
+\emph on
+used_event + 1
+\emph default
+).
+ The method employed by the device is controlled by the VIRTIO_RING_F_USED_EVENT
+_IDX feature bit (see 
+\begin_inset CommandInset ref
+LatexCommand ref
+reference "cha:Reserved-Feature-Bits"
+
+\end_inset
+
+).
+ 
+\change_unchanged
+This interrupt suppression is merely an optimization; it may not suppress
  interrupts entirely.
 \end_layout
 
@@ -1940,6 +2202,17 @@ struct vring_avail {
 \begin_layout Plain Layout
 
    u16 ring[qsz]; /* qsz is the Queue Size field read from device */
+\change_inserted 0 1304329945
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304329957
+
+   u16 used_event;
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -1963,8 +2236,71 @@ The used ring is where the device returns buffers once it is done with them.
 \emph on
 available
 \emph default
- ring (the flag is kept here because this is the only part of the virtqueue
- written by the device).
+ ring
+\change_inserted 0 1304540575
+.
+ Alternatively, the 
+\begin_inset Quotes eld
+\end_inset
+
+avail_event
+\begin_inset Quotes erd
+\end_inset
+
+ field can be used by the device to hint that no notification is necessary
+ until an entry with an index specified by the 
+\begin_inset Quotes eld
+\end_inset
+
+avail_event
+\begin_inset Quotes erd
+\end_inset
+
+ is written in the available ring (equivalently, until the 
+\emph on
+idx
+\emph default
+ field in the available ring will reach the value 
+\emph on
+avail_event + 1
+\emph default
+).
+
+\change_unchanged
+ 
+\change_inserted 0 1304540614
+The method employed by the device is controlled by the guest through the
+ VIRTIO_RING_F_AVAIL_EVENT_IDX feature bit (see 
+\begin_inset CommandInset ref
+LatexCommand ref
+reference "cha:Reserved-Feature-Bits"
+
+\end_inset
+
+).
+ 
+\change_deleted 0 1304331235
+(the flag is kept here because this is the only part of the virtqueue written
+ by the device)
+\change_inserted 0 1304540560
+
+\begin_inset Foot
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304331235
+These fields are kept here because this is the only part of the virtqueue
+ written by the device
+\change_unchanged
+
+\end_layout
+
+\end_inset
+
+
+\change_unchanged
+.
 \end_layout
 
 \begin_layout Standard
@@ -2046,6 +2382,17 @@ struct vring_used {
 \begin_layout Plain Layout
 
     struct vring_used_elem ring[qsz];
+\change_inserted 0 1304330369
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304330380
+
+    u16 avail_event;
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -2065,9 +2412,13 @@ Helpers for Managing Virtqueues
 \begin_layout Standard
 The Linux Kernel Source code contains the definitions above and helper routines
  in a more usable form, in include/linux/virtio_ring.h.
- This was explicitly licensed by IBM under the (3-clause) BSD license so
- that it can be freely used by all other projects, and is reproduced (with
- slight variation to remove Linux assumptions) in Appendix A.
+ This was explicitly licensed by IBM 
+\change_inserted 0 1304342159
+and Red Hat 
+\change_unchanged
+under the (3-clause) BSD license so that it can be freely used by all other
+ projects, and is reproduced (with slight variation to remove Linux assumptions)
+ in Appendix A.
 \end_layout
 
 \begin_layout Section
@@ -2374,12 +2725,61 @@ before
 \emph default
  checking the suppression flag: it's OK to notify gratuitously, but not
  to omit a required notification.
- So again, we use a memory barrier here before reading the flags.
+ So again, we use a memory barrier here before reading the flags
+\change_inserted 0 1304336099
+ or the avail_event field
+\change_unchanged
+.
+\end_layout
+
+\begin_layout Standard
+If 
+\change_inserted 0 1304336234
+the VIRTIO_ F_RING_AVAIL_EVENT_IDX feature is not negotiated, and if 
+\change_unchanged
+the VRING_USED_F_NOTIFY flag is not set, we go ahead and write to the PCI
+ configuration space.
+\change_inserted 0 1304336255
+
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 0 1304336617
+If the VIRTIO_ F_RING_AVAIL_EVENT_IDX feature is negotiated, we read the
+ avail_event field in the available ring structure.
+ If the available index crossed_the 
+\emph on
+avail_event
+\emph default
+ field value since the last notification, we go ahead and write to the PCI
+ configuration space.
+ The 
+\emph on
+avail_event
+\emph default
+ field wraps naturally at 65536 as well:
 \end_layout
 
 \begin_layout Standard
-If the VRING_USED_F_NOTIFY flag is not set, we go ahead and write to the
- PCI configuration space.
+
+\change_inserted 0 1304336524
+\begin_inset listings
+inline false
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304336569
+
+(u16)(new_idx - avail_event - 1) < (u16)(new_idx - old_idx)
+\end_layout
+
+\end_inset
+
+
+\change_unchanged
+
 \end_layout
 
 \begin_layout Subsection
@@ -2408,8 +2808,66 @@ Update the used ring idx.
 \end_layout
 
 \begin_layout Enumerate
-If the VRING_AVAIL_F_NO_INTERRUPT flag is not set in avail\SpecialChar \nobreakdash-
->flags:
+
+\change_inserted 0 1304336736
+Determine whether an interrupt is necessary:
+\end_layout
+
+\begin_deeper
+\begin_layout Enumerate
+
+\change_inserted 0 1304336780
+If the VIRTIO_F_RING_USED_IDX is not negotiated: check if 
+\change_deleted 0 1304336781
+I
+\change_unchanged
+f the VRING_AVAIL_F_NO_INTERRUPT flag is not set in avail\SpecialChar \nobreakdash-
+>flags
+\change_inserted 0 1304336788
+
+\end_layout
+
+\begin_layout Enumerate
+
+\change_deleted 0 1304336785
+:
+\change_inserted 0 1304336896
+If the VIRTIO_F_RING_USED_IDX is negotiated: check whether the used index
+ crossed the 
+\emph on
+used_event
+\emph default
+ field value since the last update.
+ The 
+\emph on
+used_event
+\emph default
+ field wraps naturally at 65536 as well:
+\begin_inset listings
+inline false
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304336902
+
+(u16)(new_idx - used_event - 1) < (u16)(new_idx - old_idx)
+\end_layout
+
+\end_inset
+
+
+\change_unchanged
+
+\end_layout
+
+\end_deeper
+\begin_layout Enumerate
+
+\change_inserted 0 1304336714
+If an interrupt is necessary:
+\change_unchanged
+
 \end_layout
 
 \begin_deeper
@@ -2464,13 +2922,87 @@ If MSI-X capability is enabled: look through the used rings of each virtqueue
 \end_layout
 
 \begin_layout Standard
+
+\change_inserted 0 1304341856
+For each ring, guest should then disable interrupts by writing VRING_AVAIL_F_NO_
+INTERRUPT flag in avail structure, if required.
+ It can then process used ring entries finally enabling interrupts by clearing
+ the VRING_AVAIL_F_NO_INTERRUPT flag or updating the used_idx field in the
+ available structure, Guest should then execute a memory barrier, and then
+ recheck the ring empty condition.
+ This is necessary to handle the case where, after the last check and before
+ enabling interrupts, an interrupt has been suppressed by the device:
+\end_layout
+
+\begin_layout Standard
 \begin_inset listings
 inline false
 status open
 
 \begin_layout Plain Layout
 
-while (vq->last_seen_used != vring->used.idx) {
+\change_inserted 0 1304342051
+
+vring_disable_interrupts(vq);
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341878
+
+for (;;) {
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341880
+
+    if 
+\change_deleted 0 1304341882
+while 
+\change_unchanged
+(vq->last_seen_used != vring->used.idx) {
+\change_inserted 0 1304341888
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304342047
+
+		vring_enable_interrupts(vq);
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341986
+
+		mb();
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341964
+
+		if (vq->last_seen_used != vring->used.idx)
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341974
+
+			break;
+\change_unchanged
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341887
+
+    }
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -2721,6 +3253,15 @@ status open
 \begin_layout Plain Layout
 
  * Copyright 2007, 2009, IBM Corporation
+\change_inserted 0 1304341032
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304341075
+
+ * Copyright 2011, Red Hat, Inc
 \end_layout
 
 \begin_layout Plain Layout
@@ -3019,6 +3560,17 @@ struct vring_avail {
 \begin_layout Plain Layout
 
         uint16_t ring[];
+\change_inserted 0 1304340808
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304340816
+
+        uint16_t used_event;
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -3090,6 +3642,17 @@ struct vring_used {
 \begin_layout Plain Layout
 
         struct vring_used_elem ring[];
+\change_inserted 0 1304340824
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304340831
+
+        uint16_t avail_event;
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -3326,12 +3889,58 @@ static inline unsigned vring_size(unsigned int num, unsigned long align)
 
 \begin_layout Plain Layout
 
-                + sizeof(uint16_t)*2 + sizeof(struct vring_used_elem)*num;
+                + sizeof(uint16_t)*
+\change_deleted 0 1304340844
+2
+\change_inserted 0 1304340844
+3
+\change_unchanged
+ + sizeof(struct vring_used_elem)*num;
+\end_layout
+
+\begin_layout Plain Layout
+
+}
+\change_inserted 0 1304340918
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304340918
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304340987
+
+static inline int vring_need_event(uint16_t event_idx, uint16_t new_idx,
+ uint16_t old_idx)
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304340944
+
+{
 \end_layout
 
 \begin_layout Plain Layout
 
+\change_inserted 0 1304341001
+
+         return (uint16_t)(new_idx - event_idx - 1) < (uint16_t)(new_idx
+ - old_idx); 
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 0 1304340938
+
 }
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -3355,7 +3964,13 @@ Appendix B: Reserved Feature Bits
 \end_layout
 
 \begin_layout Standard
-Currently there are three device-independent feature bits defined:
+Currently there are 
+\change_inserted 0 1304540655
+six
+\change_deleted 0 1304330657
+three
+\change_unchanged
+ device-independent feature bits defined:
 \end_layout
 
 \begin_layout Description
@@ -3365,7 +3980,11 @@ VIRTIO_F_NOTIFY_ON_EMPTY
 
 (24) Negotiating this feature indicates that the driver wants an interrupt
  if the device runs out of available descriptors on a virtqueue, even though
- interrupts are suppressed using the VRING_AVAIL_F_NO_INTERRUPT flag.
+ interrupts are suppressed using the VRING_AVAIL_F_NO_INTERRUPT flag
+\change_inserted 0 1304341161
+ or the used_event field
+\change_unchanged
+.
  An example of this is the networking driver: it doesn't need to know every
  time a packet is transmitted, but it does need to free the transmitted
  packets a finite time after they are transmitted.
@@ -3390,6 +4009,31 @@ reference "sub:Indirect-Descriptors"
 \end_layout
 
 \begin_layout Description
+
+\change_inserted 0 1304331394
+VIRTIO_F_RING_USED_EVENT_IDX(29) This feature indicates that the device
+ should ignore the 
+\emph on
+flags
+\emph default
+ field in the available ring structure.
+ Instead, the
+\emph on
+ used_event
+\emph default
+ field in this structure is used by guest to suppress device interrupts.
+ If unset, the device should ignore the 
+\emph on
+used_event
+\emph default
+ field; the 
+\emph on
+flags
+\emph default
+ field is used
+\end_layout
+
+\begin_layout Description
 VIRTIO_F_BAD_FEATURE(30) This feature should never be negotiated by the
  guest; doing so is an indication that the guest is faulty
 \begin_inset Foot
@@ -3403,6 +4047,43 @@ An experimental virtio PCI driver contained in Linux version 2.6.25 had this
 \end_inset
 
 
+\change_inserted 0 1304330854
+
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 0 1304330961
+VIRTIO_F_FEATURES_HIGH(31) This feature indicates that the device supports
+ feature bits 32:63.
+ If unset, feature bits 32:63 are unset.
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 0 1304331390
+VIRTIO_F_RING_AVAIL_EVENT_IDX(32) This feature indicates that the driver
+ should ignore the 
+\emph on
+flags
+\emph default
+ field in the used ring structure.
+ Instead, the 
+\emph on
+avail_event
+\emph default
+ field in this structure is used by the device to suppress notifications.
+ If unset, the device should ignore the 
+\emph on
+avail_event
+\emph default
+ field; the 
+\emph on
+flags
+\emph default
+ field is used
+\change_unchanged
+
 \end_layout
 
 \begin_layout Chapter*
-- 
1.7.5.53.gc233e
