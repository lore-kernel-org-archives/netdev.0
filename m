From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Tue, 03 Nov 2015 20:58:40 -0800
Message-ID: <1446613120.4184.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
	 <CAHA+R7MNxEkMfyQa56d0HRk2HxeqsduUfM3BkBh=Oxm2yNBVaA@mail.gmail.com>
	 <0705e2b76150c28341d7e1915433450d@visp.net.lb>
	 <1446612381.4184.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36228 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057AbbKDE6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 23:58:42 -0500
In-Reply-To: <1446612381.4184.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 20:46 -0800, Eric Dumazet wrote:
> On Wed, 2015-11-04 at 06:25 +0200, Denys Fedoryshchenko wrote:
> > On 2015-11-04 00:06, Cong Wang wrote:
> > > On Mon, Nov 2, 2015 at 6:11 AM, Denys Fedoryshchenko
> > > <nuclearcat@nuclearcat.com> wrote:
> > >> Hi!
> > >> 
> > >> Actually seems i was getting this panic for a while (once per week) on
> > >> loaded pppoe server, but just now was able to get full panic message.
> > >> After checking commit logs on sch_fq.c i didnt seen any fixes, so 
> > >> probably
> > >> upgrading to newer kernel wont help?
> > > 
> > > 
> > > Can you share your `tc qdisc show dev xxxx` with us? And how to 
> > > reproduce
> > > it? I tried to setup htb+fq and then flip the interface back and forth
> > > but I don't
> > > see any crash.
> > My guess it wont be easy to reproduce, it is happening on box with 4.5k 
> > interfaces, that constantly create/delete interfaces,
> > and even with that this problem may happen once per day, or may not 
> > happen for 1 week.
> > 
> > Here is script that is being fired after new ppp interface detected. But 
> > pppoe process are independent from
> > process that are "establishing" shapers.
> 
> 
> It is probably a generic bug. sch_fq seems OK to me.
> 
> Somehow nobody tries to change qdisc hundred times per second ;)
> 
> Could you try following patch ?
> 
> It seems to 'fix' the issue for me.

Following patch would be more appropriate.
Prior one was meant to 'show' the issue.

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cb5d4ad32946..7f5f3e8a10f5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -706,9 +706,11 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 	spin_lock_bh(root_lock);
 
 	/* Prune old scheduler */
-	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-		qdisc_reset(oqdisc);
-
+	if (oqdisc) {
+		if (atomic_read(&oqdisc->refcnt) <= 1)
+			qdisc_reset(oqdisc);
+		set_bit(__QDISC_STATE_DEACTIVATED, &oqdisc->state);
+	}
 	/* ... and graft new one */
 	if (qdisc == NULL)
 		qdisc = &noop_qdisc;
