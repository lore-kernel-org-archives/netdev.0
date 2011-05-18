From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost: fix enable notify: write out last avail value we
 saw
Date: Thu, 19 May 2011 00:13:39 +0300
Message-ID: <20110518211339.GA26122@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au, habanero@linux.vnet.ibm.com,
	Shirley Ma <mashirle@us.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, kvm@vger.kernel.org,
	steved@us.ibm.com, Tom Lendacky <tahm@linux.vnet.ibm.com>,
	borntraeger@de.ibm.com, avi@redhat.com
To: virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With RX ring and mergeable buffers, vhost-net sometimes
enables notifications when ring is not empty - just
doesn't have enough entries for the incoming packet.

To get event when entries are added in this case,
we should always write out the last index value
we saw into event index field, which is ahead
of the index we have consumed.

Otherwise we get a kick, see that there are not enough
entries in the ring, reenable notifications
but since last used index was not updated
we don't get any more events.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This bugfix is on top of my patchset, I'm working on addressing
Rusty's comments for that now.

Will push to my git tree event idx branch for everyone's testing pleasure
shortly.


 drivers/vhost/vhost.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2aea4cb..1267a3d 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1438,7 +1438,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 			return false;
 		}
 	} else {
-		r = put_user(vq->last_avail_idx, vhost_avail_event(vq));
+		r = put_user(vq->avail_idx, vhost_avail_event(vq));
 		if (r) {
 			vq_err(vq, "Failed to update avail event index at %p: %d\n",
 			       vhost_avail_event(vq), r);
-- 
1.7.5.53.gc233e
