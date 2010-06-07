From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [RFC] pm_qos: get rid of the allocation in pm_qos_add_request()
Date: Sun, 06 Jun 2010 22:47:42 -0400
Message-ID: <1275878862.7227.561.camel@mulgrave.site>
References: <1275765614.7227.42.camel@mulgrave.site>
	 <20100606213224.GC8610@gvim.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	Takashi Iwai <tiwai@suse.de>, Jaroslav Kysela <perex@perex.cz>
To: markgross@thegnar.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46494 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755220Ab0FGCrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 22:47:53 -0400
In-Reply-To: <20100606213224.GC8610@gvim.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-06 at 14:32 -0700, mark gross wrote:
> so the test for an un-registerd or in-initialized request is if list == null.

Actually I was using pm_qos_class == 0, but all current users use NULL
as the pointer test, so they must all be allocated in zero initialised
memory.

> >  
> > -struct pm_qos_request_list *pm_qos_add_request(int pm_qos_class, s32 value);
> > +void pm_qos_add_request(struct pm_qos_request_list *l, int pm_qos_class, s32 value);
> >  void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
> >  		s32 new_value);
> >  void pm_qos_remove_request(struct pm_qos_request_list *pm_qos_req);
> > @@ -25,3 +30,4 @@ int pm_qos_request(int pm_qos_class);
> >  int pm_qos_add_notifier(int pm_qos_class, struct notifier_block *notifier);
> >  int pm_qos_remove_notifier(int pm_qos_class, struct notifier_block *notifier);
> >  
> > +#endif
> > diff --git a/include/sound/pcm.h b/include/sound/pcm.h
> > index dd76cde..6e3a297 100644
> > --- a/include/sound/pcm.h
> > +++ b/include/sound/pcm.h
> > @@ -366,7 +366,7 @@ struct snd_pcm_substream {
> >  	int number;
> >  	char name[32];			/* substream name */
> >  	int stream;			/* stream (direction) */
> > -	struct pm_qos_request_list *latency_pm_qos_req; /* pm_qos request */
> > +	struct pm_qos_request_list latency_pm_qos_req; /* pm_qos request */
> >  	size_t buffer_bytes_max;	/* limit ring buffer size */
> >  	struct snd_dma_buffer dma_buffer;
> >  	unsigned int dma_buf_id;
> > diff --git a/kernel/pm_qos_params.c b/kernel/pm_qos_params.c
> > index 241fa79..f1d3d23 100644
> > --- a/kernel/pm_qos_params.c
> > +++ b/kernel/pm_qos_params.c
> > @@ -30,7 +30,6 @@
> >  /*#define DEBUG*/
> >  
> >  #include <linux/pm_qos_params.h>
> > -#include <linux/plist.h>
> ? plist pm_qos isn't yet in the code base yet. ;)
> Is this patch assumed after your RFC patch?
> It must be....

Yes, they're stacked.

> >  #include <linux/sched.h>
> >  #include <linux/spinlock.h>
> >  #include <linux/slab.h>
> > @@ -49,11 +48,6 @@
> >   * or pm_qos_object list and pm_qos_objects need to happen with pm_qos_lock
> >   * held, taken with _irqsave.  One lock to rule them all
> >   */
> > -struct pm_qos_request_list {
> > -	struct plist_node list;
> > -	int pm_qos_class;
> > -};
> > -
> >  enum pm_qos_type {
> >  	PM_QOS_MAX,		/* return the largest value */
> >  	PM_QOS_MIN,		/* return the smallest value */
> > @@ -195,6 +189,11 @@ int pm_qos_request(int pm_qos_class)
> >  }
> >  EXPORT_SYMBOL_GPL(pm_qos_request);
> >  
> > +static int pm_qos_request_active(struct pm_qos_request_list *req)
> > +{
> > +	return req->pm_qos_class != 0;
> > +}
> > +
> >  /**
> >   * pm_qos_add_request - inserts new qos request into the list
> >   * @pm_qos_class: identifies which list of qos request to us
> > @@ -206,25 +205,22 @@ EXPORT_SYMBOL_GPL(pm_qos_request);
> >   * element as a handle for use in updating and removal.  Call needs to save
> >   * this handle for later use.
> >   */
> > -struct pm_qos_request_list *pm_qos_add_request(int pm_qos_class, s32 value)
> > +void pm_qos_add_request(struct pm_qos_request_list *dep,
> > +			int pm_qos_class, s32 value)
> >  {
> > -	struct pm_qos_request_list *dep;
> > -
> > -	dep = kzalloc(sizeof(struct pm_qos_request_list), GFP_KERNEL);
> > -	if (dep) {
> > -		struct pm_qos_object *o =  pm_qos_array[pm_qos_class];
> > -		int new_value;
> > -
> > -		if (value == PM_QOS_DEFAULT_VALUE)
> > -			new_value = o->default_value;
> > -		else
> > -			new_value = value;
> > -		plist_node_init(&dep->list, new_value);
> > -		dep->pm_qos_class = pm_qos_class;
> > -		update_target(o, &dep->list, 0);
> > -	}
> > +	struct pm_qos_object *o =  pm_qos_array[pm_qos_class];
> > +	int new_value;
> > +
> > +	if (pm_qos_request_active(dep))
> > +		return;
> >  
> > -	return dep;
> > +	if (value == PM_QOS_DEFAULT_VALUE)
> > +		new_value = o->default_value;
> > +	else
> > +		new_value = value;
> > +	plist_node_init(&dep->list, new_value);
> > +	dep->pm_qos_class = pm_qos_class;
> > +	update_target(o, &dep->list, 0);
> >  }
> >  EXPORT_SYMBOL_GPL(pm_qos_add_request);
> >  
> > @@ -286,7 +282,7 @@ void pm_qos_remove_request(struct pm_qos_request_list *pm_qos_req)
> >  
> >  	o = pm_qos_array[pm_qos_req->pm_qos_class];
> >  	update_target(o, &pm_qos_req->list, 1);
> > -	kfree(pm_qos_req);
> > +	memset(pm_qos_req, 0, sizeof(*pm_qos_req));
> 
> I was wondering how to tell if a pm_qos_request was un-initialized
> un-registered request.

The assumption is zero initialised.

> >  }
> >  EXPORT_SYMBOL_GPL(pm_qos_remove_request);
> >  
> > @@ -334,8 +330,12 @@ static int pm_qos_power_open(struct inode *inode, struct file *filp)
> >  
> >  	pm_qos_class = find_pm_qos_object_by_minor(iminor(inode));
> >  	if (pm_qos_class >= 0) {
> > -		filp->private_data = (void *) pm_qos_add_request(pm_qos_class,
> > -				PM_QOS_DEFAULT_VALUE);
> > +		struct pm_qos_request_list *req = kzalloc(GFP_KERNEL, sizeof(*req));
> > +		if (!req)
> > +			return -ENOMEM;
> > +
> > +		pm_qos_add_request(req, pm_qos_class, PM_QOS_DEFAULT_VALUE);
> > +		filp->private_data = req;
> >  
> >  		if (filp->private_data)
> >  			return 0;
> > @@ -347,8 +347,9 @@ static int pm_qos_power_release(struct inode *inode, struct file *filp)
> >  {
> >  	struct pm_qos_request_list *req;
> >  
> > -	req = (struct pm_qos_request_list *)filp->private_data;
> > +	req = filp->private_data;
> >  	pm_qos_remove_request(req);
> > +	kfree(req);
> >  
> >  	return 0;
> >  }
> > diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
> > index 303ac04..d3b8b51 100644
> > --- a/sound/core/pcm_native.c
> > +++ b/sound/core/pcm_native.c
> > @@ -451,13 +451,10 @@ static int snd_pcm_hw_params(struct snd_pcm_substream *substream,
> >  	snd_pcm_timer_resolution_change(substream);
> >  	runtime->status->state = SNDRV_PCM_STATE_SETUP;
> >  
> > -	if (substream->latency_pm_qos_req) {
> > -		pm_qos_remove_request(substream->latency_pm_qos_req);
> > -		substream->latency_pm_qos_req = NULL;
> > -	}
> > +	pm_qos_remove_request(&substream->latency_pm_qos_req);
> >  	if ((usecs = period_to_usecs(runtime)) >= 0)
> > -		substream->latency_pm_qos_req = pm_qos_add_request(
> > -					PM_QOS_CPU_DMA_LATENCY, usecs);
> > +		pm_qos_add_request(&substream->latency_pm_qos_req,
> > +				   PM_QOS_CPU_DMA_LATENCY, usecs);
> How are we going to avoid re-adding the latency_pm_qos_request multiple
> times to the list?  the last time I looked at this I really wanted to
> change this to update_request.  But, I got pushback so I added the file
> gard in pmqos_params.c instead. 

There's a guard check in add that does this ... it seemed better putting
it there than replicating through the subsystems.

James


