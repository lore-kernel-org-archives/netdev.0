From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 4/4] cxgb4: drop __GFP_NOFAIL allocation
Date: Tue, 3 Mar 2015 14:18:26 +0100
Message-ID: <20150303131826.GB2409@dhcp22.suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
 <1425304483-7987-5-git-send-email-mhocko@suse.cz>
 <201503032122.HJD73998.OFFMQFLHtJOSOV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org,
	hannes@cmpxchg.org, rientjes@google.com, david@fromorbit.com,
	tytso@mit.edu, mgorman@suse.de, sparclinux@vger.kernel.org,
	vipul@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201503032122.HJD73998.OFFMQFLHtJOSOV@I-love.SAKURA.ne.jp>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 03-03-15 21:22:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > index ccf3436024bc..f351920fc293 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > @@ -1220,6 +1220,10 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
> >  	struct fw_filter_wr *fwr;
> >  	unsigned int ftid;
> >  
> > +	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL);
> > +	if (!skb)
> > +		return -ENOMEM;
> > +
> >  	/* If the new filter requires loopback Destination MAC and/or VLAN
> >  	 * rewriting then we need to allocate a Layer 2 Table (L2T) entry for
> >  	 * the filter.
> > @@ -1227,19 +1231,21 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
> >  	if (f->fs.newdmac || f->fs.newvlan) {
> >  		/* allocate L2T entry for new filter */
> >  		f->l2t = t4_l2t_alloc_switching(adapter->l2t);
> > -		if (f->l2t == NULL)
> > +		if (f->l2t == NULL) {
> > +			kfree(skb);
> 
> I think we need to use kfree_skb() than kfree() for memory allocated by alloc_skb().

Definitely! Good point, thanks!

Andrew, I've noticed you have picked up the patch. Should I resend or
the below incremental one is good enough?
---
>From eee05867dd55efa236ba065a3e7b7eb6e6ea511d Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.cz>
Date: Tue, 3 Mar 2015 14:16:30 +0100
Subject: [PATCH] mmotm: cxgb4-drop-__gfp_nofail-allocation-fix

Use kfree_skb instead of kfree because the allocation is done by
alloc_skb.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f351920fc293..e1e5028a714c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1232,14 +1232,14 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
 		/* allocate L2T entry for new filter */
 		f->l2t = t4_l2t_alloc_switching(adapter->l2t);
 		if (f->l2t == NULL) {
-			kfree(skb);
+			kfree_skb(skb);
 			return -EAGAIN;
 		}
 		if (t4_l2t_set_switching(adapter, f->l2t, f->fs.vlan,
 					f->fs.eport, f->fs.dmac)) {
 			cxgb4_l2t_release(f->l2t);
 			f->l2t = NULL;
-			kfree(skb);
+			kfree_skb(skb);
 			return -ENOMEM;
 		}
 	}
-- 
2.1.4


-- 
Michal Hocko
SUSE Labs
