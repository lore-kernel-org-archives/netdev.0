From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next 3/9] ipv4: remove static flush_delay variable
Date: Mon, 07 Jul 2008 15:26:14 +0400
Message-ID: <1215429974.29879.84.camel@iris.sw.ru>
References: <1215177360.27873.50.camel@iris.sw.ru>
	 <1215177432-25934-3-git-send-email-den@openvz.org>
	 <m1k5fyytid.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-BY8IV6h+nQazIbo4f0we"
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35470 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbYGGL0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 07:26:21 -0400
In-Reply-To: <m1k5fyytid.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BY8IV6h+nQazIbo4f0we
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2008-07-07 at 01:43 -0700, Eric W. Biederman wrote:
> "Denis V. Lunev" <den@openvz.org> writes:
> 
> > flush delay is used as an external storage for net.ipv4.route.flush sysctl
> > entry. It is write-only.
> >
> > The ctl_table->data for this entry is used once. Fix this case to point
> > to the stack to remove global variable. Do this to avoid additional
> > variable on struct net in the next patch.
> >
> > Possible race (as it was before) accessing this local variable is removed
> > using flush_mutex.
> 
> FYI.  You can avoid the locking entirely by defining a local struct ctl_table variable
> on the stack.

Dave, could you consider the patch attached?

--=-BY8IV6h+nQazIbo4f0we
Content-Disposition: attachment; filename*0=0001-ipv4-remove-flush_mutex-from-ipv4_sysctl_rtcache_fl.patc; filename*1=h
Content-Type: application/mbox; name=0001-ipv4-remove-flush_mutex-from-ipv4_sysctl_rtcache_fl.patch
Content-Transfer-Encoding: 7bit

>From 4a2fe8cb052d25218df712a779523d43c284190c Mon Sep 17 00:00:00 2001
From: Denis V. Lunev <den@openvz.org>
Date: Mon, 7 Jul 2008 19:17:56 +0400
Subject: [PATCH net-next 1/1] ipv4: remove flush_mutex from ipv4_sysctl_rtcache_flush

It is possible to avoid locking at all in ipv4_sysctl_rtcache_flush by
defining local ctl_table on the stack.

The patch is based on the suggestion from Eric W. Biederman.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 113cd25..79c1e74 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2873,22 +2873,20 @@ void ip_rt_multicast_event(struct in_device *in_dev)
 }
 
 #ifdef CONFIG_SYSCTL
-static int ipv4_sysctl_rtcache_flush(ctl_table *ctl, int write,
+static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 					struct file *filp, void __user *buffer,
 					size_t *lenp, loff_t *ppos)
 {
 	if (write) {
 		int flush_delay;
+		ctl_table ctl;
 		struct net *net;
-		static DEFINE_MUTEX(flush_mutex);
 
-		mutex_lock(&flush_mutex);
-		ctl->data = &flush_delay;
-		proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
-		ctl->data = NULL;
-		mutex_unlock(&flush_mutex);
+		memcpy(&ctl, __ctl, sizeof(ctl));
+		ctl.data = &flush_delay;
+		proc_dointvec(&ctl, write, filp, buffer, lenp, ppos);
 
-		net = (struct net *)ctl->extra1;
+		net = (struct net *)__ctl->extra1;
 		rt_cache_flush(net, flush_delay);
 		return 0;
 	}
-- 
1.5.3.rc5


--=-BY8IV6h+nQazIbo4f0we--

