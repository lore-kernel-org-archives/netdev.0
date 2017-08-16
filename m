From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/3] net/sched: Improve getting objects by
 indexes
Date: Wed, 16 Aug 2017 10:39:39 +0200
Message-ID: <20170816083939.GD1868@nanopsycho>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
 <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
 <20170816081631.GC1868@nanopsycho>
 <e3cb8f8e-7808-48b4-d90d-67f30ab39687@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38889 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdHPIjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 04:39:42 -0400
Received: by mail-wr0-f196.google.com with SMTP id g32so2016671wrd.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 01:39:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e3cb8f8e-7808-48b4-d90d-67f30ab39687@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 16, 2017 at 10:31:35AM CEST, christian.koenig@amd.com wrote:
>Am 16.08.2017 um 10:16 schrieb Jiri Pirko:
>> Wed, Aug 16, 2017 at 09:49:07AM CEST, christian.koenig@amd.com wrote:
>> > Am 16.08.2017 um 04:12 schrieb Chris Mi:
>> > > Using current TC code, it is very slow to insert a lot of rules.
>> > > 
>> > > In order to improve the rules update rate in TC,
>> > > we introduced the following two changes:
>> > >           1) changed cls_flower to use IDR to manage the filters.
>> > >           2) changed all act_xxx modules to use IDR instead of
>> > >              a small hash table
>> > > 
>> > > But IDR has a limitation that it uses int. TC handle uses u32.
>> > > To make sure there is no regression, we also changed IDR to use
>> > > unsigned long. All clients of IDR are changed to use new IDR API.
>> > WOW, wait a second. The idr change is touching a lot of drivers and to be
>> > honest doesn't looks correct at all.
>> > 
>> > Just look at the first chunk of your modification:
>> > > @@ -998,8 +999,9 @@ int bsg_register_queue(struct request_queue *q, struct device *parent,
>> > >    	mutex_lock(&bsg_mutex);
>> > > -	ret = idr_alloc(&bsg_minor_idr, bcd, 0, BSG_MAX_DEVS, GFP_KERNEL);
>> > > -	if (ret < 0) {
>> > > +	ret = idr_alloc(&bsg_minor_idr, bcd, &idr_index, 0, BSG_MAX_DEVS,
>> > > +			GFP_KERNEL);
>> > > +	if (ret) {
>> > >    		if (ret == -ENOSPC) {
>> > >    			printk(KERN_ERR "bsg: too many bsg devices\n");
>> > >    			ret = -EINVAL;
>> > The condition "if (ret)" will now always be true after the first allocation
>> > and so we always run into the error handling after that.
>> On success, idr_alloc returns 0.
>
>Ah, I see. You change the idr_alloc to return the resulting index as separate
>parameter.
>
>You should explicit note that in the commit message, cause that is something
>easily overlooked.
>
>In general I strongly suggest to add a separate interface for allocating
>unsigned long handles, use that for the while being and then move the
>existing drivers over bit by bit.
>
>A single patch which touches so many different driver is practically
>impossible to review consequently.

Understood. I think is is good to avoid having some "idr_alloc2". That
is why I suggested to do this in one go, to avoid "idr_alloc2" and then
patch to rename "idr_alloc2" to "idr_alloc" once nobody uses the original
"idr_alloc". In fact, if you do it driver, by driver, the review burden
would be the same, probably even bigger, you'll just have 100+ patches.
Why would it help?

I believe that the changes in drivers are trivial enough to have it in
one patch.


>
>> > I've never read the bsg code before, but that's certainly not correct. And
>> > that incorrect pattern repeats over and over again in this code.
>> > 
>> > Apart from that why the heck do you want to allocate more than 1<<31 handles?
>> tc action indexes for example. That is part of this patchset.
>
>Well, let me refine the question: Why does tc action indexes need more than
>31 bits? From an outside view that looks like pure overkill.

That is current state, uapi. We have to live with it.
