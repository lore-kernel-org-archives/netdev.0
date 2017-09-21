From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: [PATCH net-next 2/4] cxgb4: add basic tc flower offload support
Date: Thu, 21 Sep 2017 08:31:54 -0700
Message-ID: <20170921153153.GB14071@banjo.asicdesigners.com>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
 <dc5f8e6419ad3439b14f39306245d98537be3306.1505977744.git.rahul.lakkireddy@chelsio.com>
 <cf99ae13-6ae1-2a1f-80cb-9390ab9e3af0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        netdev@vger.kernel.org, davem@davemloft.net, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:50532 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdIUPcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:32:08 -0400
Content-Disposition: inline
In-Reply-To: <cf99ae13-6ae1-2a1f-80cb-9390ab9e3af0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yunsheng,

On Thursday, September 09/21/17, 2017 at 18:55:26 +0800, Yunsheng Lin wrote:
> Hi, Kumar
> 
> On 2017/9/21 15:33, Rahul Lakkireddy wrote:
> > From: Kumar Sanghvi <kumaras@chelsio.com>
> > 
> > Add support to add/remove flows for offload.  Following match
> > and action are supported for offloading a flow:
> > 
> > Match: ether-protocol, IPv4/IPv6 addresses, L4 ports (TCP/UDP)
> > Action: drop, redirect to another port on the device.
> > 
> > The qualifying flows can have accompanying mask information.
> > 
> > Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
> > Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> > Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> > ---

[...]

> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
> > index 45b5853ca2f1..07a4619e2164 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
> > @@ -148,6 +148,32 @@ static int get_filter_steerq(struct net_device *dev,
> >  	return iq;
> >  }
> >  
> > +int cxgb4_get_free_ftid(struct net_device *dev, int family)
> > +{
> > +	struct adapter *adap = netdev2adap(dev);
> > +	struct tid_info *t = &adap->tids;
> > +	int ftid;
> > +
> > +	spin_lock_bh(&t->ftid_lock);
> > +	if (family == PF_INET) {
> > +		ftid = find_first_zero_bit(t->ftid_bmap, t->nftids);
> > +		if (ftid >= t->nftids)
> > +			ftid = -1;
> > +	} else {
> > +		ftid = bitmap_find_free_region(t->ftid_bmap, t->nftids, 2);
> > +		if (ftid < 0) {
> > +			ftid = -1;
> 
> ftid = -1 is not needed?

You are right, its not needed. Thank you for pointing this.
I will take care of this in V2.


> 
> > +			goto out_unlock;
> > +		}
> > +
> > +		/* this is only a lookup, keep the found region unallocated */
> > +		bitmap_release_region(t->ftid_bmap, ftid, 2);
> > +	}
> > +out_unlock:
> > +	spin_unlock_bh(&t->ftid_lock);
> > +	return ftid;
> > +}

[...]

> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
> > index 16dff71e4d02..1af01101faaf 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
> > @@ -38,16 +38,292 @@
> >  #include "cxgb4.h"
> >  #include "cxgb4_tc_flower.h"
> > 

[...]

> >  int cxgb4_tc_flower_replace(struct net_device *dev,
> >  			    struct tc_cls_flower_offload *cls)
> >  {
> > -	return -EOPNOTSUPP;
> > +	struct adapter *adap = netdev2adap(dev);
> > +	struct ch_tc_flower_entry *ch_flower;
> > +	struct ch_filter_specification *fs;
> > +	struct filter_ctx ctx;
> > +	int fidx;
> > +	int ret;
> > +
> > +	if (cxgb4_validate_flow_actions(dev, cls))
> > +		return -EOPNOTSUPP;
> > +
> > +	if (cxgb4_validate_flow_match(dev, cls))
> > +		return -EOPNOTSUPP;
> > +
> > +	ch_flower = allocate_flower_entry();
> > +	if (!ch_flower) {
> > +		netdev_err(dev, "%s: ch_flower alloc failed.\n", __func__);
> > +		ret = -ENOMEM;
> > +		goto err;
> 
> Just return, err label is needed?

Yes, err label is not needed. I will take care of this in V2.

> 
> > +	}
> > +
> > +	fs = &ch_flower->fs;
> > +	fs->hitcnts = 1;
> > +	cxgb4_process_flow_actions(dev, cls, fs);
> > +	cxgb4_process_flow_match(dev, cls, fs);

[...]


> >  int cxgb4_tc_flower_destroy(struct net_device *dev,
> >  			    struct tc_cls_flower_offload *cls)
> >  {
> > -	return -EOPNOTSUPP;
> > +	struct adapter *adap = netdev2adap(dev);
> > +	struct ch_tc_flower_entry *ch_flower;
> > +	int ret;
> > +
> > +	ch_flower = ch_flower_lookup(adap, cls->cookie);
> > +	if (!ch_flower) {
> > +		ret = -ENOENT;
> > +		goto err;
> 
> Same as above

I will take care of this in V2.
Thank you.
