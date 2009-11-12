From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [patch] Fix: 'return -ENOMEM' instead of 'return ENOMEM'
Date: Thu, 12 Nov 2009 09:10:53 -0600
Message-ID: <4AFC257D.2050906@cs.wisc.edu>
References: <4AFB2C0B.50605@gmail.com>	
	<20091111134730.a0da9e38.akpm@linux-foundation.org>	
	<20091112081043.GA25345@elte.hu>
	<25e057c00911120131q577f18c5v479b9d6f5f8616a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080705040000070409050108"
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	"Stephen M. Cameron" <scameron@beardog.cca.cpqcorp.net>,
	David Airlie <airlied@linux.ie>, Jens Axboe <jens.axboe@oracle.com>,
	Evgeniy Polyakov <zbr@ioremap.net>, iss_storagedev@hp.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joel Becker <joel.becker@oracle.com>, Jeff Liu <jeff.liu@oracle.com>,
	Andy Whitcroft <apw@shadowen.org>,
	Dave Airlie <airlied@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	dri-devel@lists.sourceforge.net, Alexey Dobriyan <adobriyan@gmail.com>,
	Mike Miller <mike.miller@hp.com>, Mark Fasheh <mfasheh@suse.com>,
	Karsten Keil <isdn@linux-pingi.de>, rostedt@goodmis.org,
	Karen Xie <kxie@chelsio.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Hannes Reinecke <hare@suse.de>, Andreas Eversberg <andreas@eversberg.eu>,
	Hannes Eder <hannes@hanneseder.net>,
	Keith
To: roel kluin <roel.kluin@gmail.com>
Return-path: <dri-devel-bounces@lists.sourceforge.net>
In-Reply-To: <25e057c00911120131q577f18c5v479b9d6f5f8616a6@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080705040000070409050108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

roel kluin wrote:
>> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>>> Andy, can we have a checkpatch rule please?
>> Note, that will upset creative uses of error codes i guess, such as
>> fs/xfs/.
>>
>> But yeah, +1 from me too.
>>
>> Ob'post'mortem - looked for similar patterns in the kernel and there's
>> quite a few bugs there:
>>
>>  include/net/inet_hashtables.h:                  return ENOMEM;         # bug
>>  drivers/scsi/aic7xxx/aic7xxx_osm.c:             return ENOMEM;         # works but weird
>>  drivers/scsi/cxgb3i/cxgb3i_offload.c:           return ENOMEM;         # works but weird

I think cxgb3i is actually in the buggy category. cxgb3i_c3cn_send_pdus 
can propagate the positive EXYZ error value to other functions which 
assume that errors are negative.

Karen, I made the attached patch over James's scsi-rc-fixes tree while 
reviewing the code. Could you test, finish up and send upstream?

--------------080705040000070409050108
Content-Type: text/x-patch;
 name="cxgb3i-use-negative-errno.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cxgb3i-use-negative-errno.patch"

diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.c b/drivers/scsi/cxgb3i/cxgb3i_offload.c
index c1d5be4..f6a1fb9 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_offload.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.c
@@ -291,7 +291,7 @@ static void act_open_req_arp_failure(struct t3cdev *dev, struct sk_buff *skb)
 	c3cn_hold(c3cn);
 	spin_lock_bh(&c3cn->lock);
 	if (c3cn->state == C3CN_STATE_CONNECTING)
-		fail_act_open(c3cn, EHOSTUNREACH);
+		fail_act_open(c3cn, -EHOSTUNREACH);
 	spin_unlock_bh(&c3cn->lock);
 	c3cn_put(c3cn);
 	__kfree_skb(skb);
@@ -792,18 +792,18 @@ static int act_open_rpl_status_to_errno(int status)
 {
 	switch (status) {
 	case CPL_ERR_CONN_RESET:
-		return ECONNREFUSED;
+		return -ECONNREFUSED;
 	case CPL_ERR_ARP_MISS:
-		return EHOSTUNREACH;
+		return -EHOSTUNREACH;
 	case CPL_ERR_CONN_TIMEDOUT:
-		return ETIMEDOUT;
+		return -ETIMEDOUT;
 	case CPL_ERR_TCAM_FULL:
-		return ENOMEM;
+		return -ENOMEM;
 	case CPL_ERR_CONN_EXIST:
 		cxgb3i_log_error("ACTIVE_OPEN_RPL: 4-tuple in use\n");
-		return EADDRINUSE;
+		return -EADDRINUSE;
 	default:
-		return EIO;
+		return -EIO;
 	}
 }
 
@@ -817,7 +817,7 @@ static void act_open_retry_timer(unsigned long data)
 	spin_lock_bh(&c3cn->lock);
 	skb = alloc_skb(sizeof(struct cpl_act_open_req), GFP_ATOMIC);
 	if (!skb)
-		fail_act_open(c3cn, ENOMEM);
+		fail_act_open(c3cn, -ENOMEM);
 	else {
 		skb->sk = (struct sock *)c3cn;
 		set_arp_failure_handler(skb, act_open_req_arp_failure);
@@ -966,14 +966,14 @@ static int abort_status_to_errno(struct s3_conn *c3cn, int abort_reason,
 	case CPL_ERR_BAD_SYN: /* fall through */
 	case CPL_ERR_CONN_RESET:
 		return c3cn->state > C3CN_STATE_ESTABLISHED ?
-			EPIPE : ECONNRESET;
+			-EPIPE : -ECONNRESET;
 	case CPL_ERR_XMIT_TIMEDOUT:
 	case CPL_ERR_PERSIST_TIMEDOUT:
 	case CPL_ERR_FINWAIT2_TIMEDOUT:
 	case CPL_ERR_KEEPALIVE_TIMEDOUT:
-		return ETIMEDOUT;
+		return -ETIMEDOUT;
 	default:
-		return EIO;
+		return -EIO;
 	}
 }
 
diff --git a/drivers/scsi/cxgb3i/cxgb3i_pdu.c b/drivers/scsi/cxgb3i/cxgb3i_pdu.c
index 7091050..1fe3b0f 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_pdu.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_pdu.c
@@ -388,8 +388,8 @@ int cxgb3i_conn_xmit_pdu(struct iscsi_task *task)
 	if (err > 0) {
 		int pdulen = err;
 
-	cxgb3i_tx_debug("task 0x%p, skb 0x%p, len %u/%u, rv %d.\n",
-			task, skb, skb->len, skb->data_len, err);
+		cxgb3i_tx_debug("task 0x%p, skb 0x%p, len %u/%u, rv %d.\n",
+				task, skb, skb->len, skb->data_len, err);
 
 		if (task->conn->hdrdgst_en)
 			pdulen += ISCSI_DIGEST_SIZE;

--------------080705040000070409050108
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
--------------080705040000070409050108
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--
_______________________________________________
Dri-devel mailing list
Dri-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/dri-devel

--------------080705040000070409050108--
