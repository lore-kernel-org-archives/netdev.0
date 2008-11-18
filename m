From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 03/13] dmaengine: up-level reference counting to the
	module level
Date: Mon, 17 Nov 2008 20:42:04 -0700
Message-ID: <1226979724.25411.20.camel@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
	 <20081114220842.482d56e5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60128 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918AbYKRDmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 22:42:06 -0500
In-Reply-To: <20081114220842.482d56e5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review.

On Fri, 2008-11-14 at 23:08 -0700, Andrew Morton wrote: 
> > +static struct module *dma_chan_to_owner(struct dma_chan *chan)
> > +{
> > +	return chan->device->dev->driver->owner;
> > +}
> 
> Has this all been tested with CONFIG_MODULES=n?
> 

It works, the only thing that changes is that ->owner is always NULL. 

> It looks like we have a lot of unneeded code if CONFIG_MODULES=n. 
> However that might not be a case which is worth bothering about.

We still need all the other reference counting machinery to identify
busy channels.

> 
> > +/**
> > + * balance_ref_count - catch up the channel reference count
> > + */
> > +static void balance_ref_count(struct dma_chan *chan)
> 
> Forgot to kerneldocument the argument.

yup

> 
> > +{
> > +	struct module *owner = dma_chan_to_owner(chan);
> > +
> > +	while (chan->client_count < dmaengine_ref_count) {
> > +		__module_get(owner);
> > +		chan->client_count++;
> > +	}
> > +}
> 
> The locking for ->client_count is undocumented.

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index dce6d00..9396891 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -129,6 +129,9 @@ static struct module *dma_chan_to_owner(struct dma_chan *chan)
 
 /**
  * balance_ref_count - catch up the channel reference count
+ * @chan - channel to balance ->client_count versus dmaengine_ref_count
+ *
+ * balance_ref_count must be called under dma_list_mutex
  */
 static void balance_ref_count(struct dma_chan *chan)
 {


> > +/**
> > + * dma_chan_get - try to grab a dma channel's parent driver module
> > + * @chan - channel to grab
> > + */
> > +static int dma_chan_get(struct dma_chan *chan)
> > +{
> > +	int err = -ENODEV;
> > +	struct module *owner = dma_chan_to_owner(chan);
> > +
> > +	if (chan->client_count) {
> > +		__module_get(owner);
> > +		err = 0;
> > +	} else if (try_module_get(owner))
> > +		err = 0;
> 
> I wonder if try_module_get() could be used in both cases (migt not make
> sense to do so though).

Yes, but I like how it documents the assumption that the backing module
has been referenced when client_count is non-zero.

> 
> > +	if (err == 0)
> > +		chan->client_count++;
> 
> Locking for this?

@@ -146,6 +146,8 @@ static void balance_ref_count(struct dma_chan *chan)
 /**
  * dma_chan_get - try to grab a dma channel's parent driver module
  * @chan - channel to grab
+ *
+ * Must be called under dma_list_mutex
  */
 static int dma_chan_get(struct dma_chan *chan)
 {

> 
> > +	/* allocate upon first client reference */
> > +	if (chan->client_count == 1 && err == 0) {
> > +		int desc = chan->device->device_alloc_chan_resources(chan, NULL);
> > +
> > +		if (desc < 0) {
> > +			chan->client_count = 0;
> > +			module_put(owner);
> > +			err = -ENOMEM;
> 
> Shouldn't we just propagate the ->device_alloc_chan_resources() return value?
> 

Yes, this is broken.

@@ -165,12 +165,11 @@ static int dma_chan_get(struct dma_chan *chan)
 
 	/* allocate upon first client reference */
 	if (chan->client_count == 1 && err == 0) {
-		int desc = chan->device->device_alloc_chan_resources(chan);
+		err = chan->device->device_alloc_chan_resources(chan);
 
-		if (desc < 0) {
+		if (err < 0) {
 			chan->client_count = 0;
 			module_put(owner);
-			err = -ENOMEM;
 		} else if (!dma_has_cap(DMA_PRIVATE, chan->device->cap_mask))
 			balance_ref_count(chan);
 	}


> > +		} else
> > +			balance_ref_count(chan);
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static void dma_chan_put(struct dma_chan *chan)
> > +{
> > +	if (!chan->client_count)
> > +		return; /* this channel failed alloc_chan_resources */
> 
> Or we had a bug ;)

...hopefully caught by the BUG_ON(dmaengine_ref_count < 0) in
dmaengine_put().

> 
> > +	chan->client_count--;
> 
> Undocumented locking..

@@ -178,6 +178,12 @@ static int dma_chan_get(struct dma_chan *chan)
 	return err;
 }
 
+/**
+ * dma_chan_put - drop a reference to a dma channel's parent driver module
+ * @chan - channel to release
+ *
+ * Must be called under dma_list_mutex
+ */
 static void dma_chan_put(struct dma_chan *chan)
 {
 	if (!chan->client_count)


Regards,
Dan

