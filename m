From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/6] IrDA: Lockdep annotation for hashbin locks
Date: Wed, 14 Mar 2007 21:25:19 +0200
Message-ID: <20070314192519.GH3397@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Rmmoding irda triggers a lockdep false positive. We can fix that by assigning
each hashbin lock to a separate class.

Reported-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 include/net/irda/irqueue.h |    1 +
 net/irda/irqueue.c         |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/irda/irqueue.h b/include/net/irda/irqueue.h
index 335b0ac..67cb434 100644
--- a/include/net/irda/irqueue.h
+++ b/include/net/irda/irqueue.h
@@ -71,6 +71,7 @@ typedef struct hashbin_t {
 	int        hb_size;
 	spinlock_t hb_spinlock;		/* HB_LOCK - Can be used by the user */
 
+	struct lock_class_key hb_lock_key;
 	irda_queue_t* hb_queue[HASHBIN_SIZE] IRDA_ALIGN;
 
 	irda_queue_t* hb_current;
diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index 9266233..2871a8a 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -370,6 +370,7 @@ hashbin_t *hashbin_new(int type)
 	/* Make sure all spinlock's are unlocked */
 	if ( hashbin->hb_type & HB_LOCK ) {
 		spin_lock_init(&hashbin->hb_spinlock);
+		lockdep_set_class(&hashbin->hb_spinlock, &hashbin->hb_lock_key);
 	}
 
 	return hashbin;
-- 
1.5.0.2


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
