From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] [PATCH 1/3] ioat: DMA subsystem
Date: Thu, 24 Nov 2005 11:48:01 +0000
Message-ID: <20051124114801.GA20244@infradead.org>
References: <Pine.LNX.4.44.0511231207410.32487-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932630AbVKXLsF@vger.kernel.org>
To: Andrew Grover <andrew.grover@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0511231207410.32487-100000@isotope.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +++ b/drivers/dma/cb_list.h
> @@ -0,0 +1,12 @@
> +/* Extra macros that build on <linux/list.h> */
> +#ifndef CB_LIST_H
> +#define CB_LIST_H
> +
> +#include <linux/list.h>
> +
> +/* Provide some safty to list_add, which I find easy to swap the arguments to */
> +
> +#define list_add_entry(pos, head, member)      list_add(&pos->member, head)
> +#define list_add_entry_tail(pos, head, member) list_add_tail(&pos->member, head)

these macros seem rather useless.  if you disagree please submit a patch to
<linux/list.h> - if it gets accepted fine, else just remove this usage.


> +	struct dma_chan *chan = container_of(cd, struct dma_chan, class_dev);

What about a

#define to_dma_chan(cdev) \
	container_of(cd, struct dma_chan, cdev)

helper as we have in many subsystems?

> +static void
> +dma_class_release(struct class_device *cd)
> +{
> +	/* do something */
> +}

umm, yeah.. :)

> +static struct dma_chan *
> +dma_client_chan_alloc(struct dma_client *client)
> +{
> +	struct dma_device *device;
> +	struct dma_chan *chan;
> +
> +	BUG_ON(!client);
> +
> +	/* Find a channel, any DMA engine will do */
> +	list_for_each_entry(device, &dma_device_list, global_node) {
> +		list_for_each_entry(chan, &device->channels, device_node) {
> +			if (chan->client)
> +				continue;

couldn't you use the normal device model list for this?

> +static void
> +dma_client_chan_free(struct dma_chan *chan)
> +{
> +	BUG_ON(!chan);
> +
> +	chan->device->device_free_chan_resources(chan);

you'll get the oops here anyway, no need for the BUG_ON

> +			chan = list_entry(client->channels.next, struct dma_chan, client_node);

please shorten the line length to fit 80 column terminals.

> +static int __init dma_bus_init(void)
> +{
> +	int cpu;
> +
> +	dma_wait_wq = create_workqueue("dmapoll");
> +	for_each_online_cpu(cpu) {
> +		init_completion(&per_cpu(kick_dma_poll, cpu));

you either need to make this for_each_possible_cpu or add a hotplug
cpu notifier.  the first is probably a lot easier :)
