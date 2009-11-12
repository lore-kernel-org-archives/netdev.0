From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] Fix: 'return -ENOMEM' instead of 'return ENOMEM'
Date: Thu, 12 Nov 2009 09:10:43 +0100
Message-ID: <20091112081043.GA25345@elte.hu>
References: <4AFB2C0B.50605@gmail.com>
	<20091111134730.a0da9e38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	"Stephen M. Cameron" <scameron@beardog.cca.cpqcorp.net>,
	Mike Christie <michaelc@cs.wisc.edu>, David Airlie <airlied@linux.ie>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Evgeniy Polyakov <zbr@ioremap.net>, iss_storagedev@hp.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joel Becker <joel.becker@oracle.com>, Jeff Liu <jeff.liu@oracle.com>,
	Andy Whitcroft <apw@shadowen.org>, Dave Airlie <airlied@redhat.com>,
	Hannes Eder <hannes@hanneseder.net>, dri-devel@lists.sourceforge.net,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mike Miller <mike.miller@hp.com>, Mark Fasheh <mfasheh@suse.com>,
	Karsten Keil <isdn@linux-pingi.de>, rostedt@goodmis.org,
	Karen Xie <kxie@chelsio.com>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Hannes Reinecke <hare@suse.de>, Andreas Eversberg <andreas@eversberg.eu
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <dri-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20091111134730.a0da9e38.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > @@ -3730,7 +3730,7 @@ tracing_stats_read(struct file *filp, char __user *ubuf,
> >  
> >  	s = kmalloc(sizeof(*s), GFP_KERNEL);
> >  	if (!s)
> > -		return ENOMEM;
> > +		return -ENOMEM;
> >  
> >  	trace_seq_init(s);
> >  
> 
> lol, there we go again.
> 
> Andy, can we have a checkpatch rule please?

Note, that will upset creative uses of error codes i guess, such as 
fs/xfs/.

But yeah, +1 from me too.

Ob'post'mortem - looked for similar patterns in the kernel and there's 
quite a few bugs there:

 include/net/inet_hashtables.h:                  return ENOMEM;         # bug
 drivers/scsi/aic7xxx/aic7xxx_osm.c:             return ENOMEM;         # works but weird
 drivers/scsi/cxgb3i/cxgb3i_offload.c:           return ENOMEM;         # works but weird
 fs/ocfs2/dlm/dlmrecovery.c:		return EAGAIN;                  # bug
 drivers/block/cciss_scsi.c:             return ENXIO;                  # works but weird
 drivers/gpu/drm/radeon/radeon_irq.c:                    return EINVAL; # bug
 drivers/gpu/drm/radeon/radeon_irq.c:                    return EINVAL; # bug
 drivers/isdn/hardware/mISDN/hfcmulti.c:         return EINVAL;         # bug

5 out of 8 places look buggy - i.e. more than 60% - a checkpatch warning 
would avoid real bugs here. (even ignoring the cleanliness effects of 
using proper error propagation)

Cc:-ed affected maintainers. The rightmost column are my observations. 
Below is the patch fixing these.

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/gpu/drm/radeon/radeon_irq.c    |    4 ++--
 drivers/isdn/hardware/mISDN/hfcmulti.c |    2 +-
 fs/ocfs2/dlm/dlmrecovery.c             |    2 +-
 include/net/inet_hashtables.h          |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/radeon/radeon_irq.c b/drivers/gpu/drm/radeon/radeon_irq.c
index b79ecc4..fbbc0a1 100644
--- a/drivers/gpu/drm/radeon/radeon_irq.c
+++ b/drivers/gpu/drm/radeon/radeon_irq.c
@@ -76,7 +76,7 @@ int radeon_enable_vblank(struct drm_device *dev, int crtc)
 		default:
 			DRM_ERROR("tried to enable vblank on non-existent crtc %d\n",
 				  crtc);
-			return EINVAL;
+			return -EINVAL;
 		}
 	} else {
 		switch (crtc) {
@@ -89,7 +89,7 @@ int radeon_enable_vblank(struct drm_device *dev, int crtc)
 		default:
 			DRM_ERROR("tried to enable vblank on non-existent crtc %d\n",
 				  crtc);
-			return EINVAL;
+			return -EINVAL;
 		}
 	}
 
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index faed794..cfb45c9 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2846,7 +2846,7 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 	int conf;
 
 	if (ch < 0 || ch > 31)
-		return EINVAL;
+		return -EINVAL;
 	oslot_tx = hc->chan[ch].slot_tx;
 	oslot_rx = hc->chan[ch].slot_rx;
 	conf = hc->chan[ch].conf;
diff --git a/fs/ocfs2/dlm/dlmrecovery.c b/fs/ocfs2/dlm/dlmrecovery.c
index d9fa3d2..0a8a6a4 100644
--- a/fs/ocfs2/dlm/dlmrecovery.c
+++ b/fs/ocfs2/dlm/dlmrecovery.c
@@ -2639,7 +2639,7 @@ int dlm_begin_reco_handler(struct o2net_msg *msg, u32 len, void *data,
 		     dlm->name, br->node_idx, br->dead_node,
 		     dlm->reco.dead_node, dlm->reco.new_master);
 		spin_unlock(&dlm->spinlock);
-		return EAGAIN;
+		return -EAGAIN;
 	}
 	spin_unlock(&dlm->spinlock);
 
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d522dcf..5e31447 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -193,7 +193,7 @@ static inline int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 		hashinfo->ehash_locks =	kmalloc(size * sizeof(spinlock_t),
 						GFP_KERNEL);
 		if (!hashinfo->ehash_locks)
-			return ENOMEM;
+			return -ENOMEM;
 		for (i = 0; i < size; i++)
 			spin_lock_init(&hashinfo->ehash_locks[i]);
 	}

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
--
