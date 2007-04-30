From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 27/32] xen: Add the Xen virtual network device driver.
Date: Mon, 30 Apr 2007 11:11:25 -0700
Message-ID: <4636314D.7070006@goop.org>
References: <20070429172835.284784000@goop.org> <20070429172916.025602000@goop.org> <20070429175942.GA3551@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminge@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:57743 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946564AbXD3SMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 14:12:25 -0400
In-Reply-To: <20070429175942.GA3551@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Sun, Apr 29, 2007 at 10:29:02AM -0700, Jeremy Fitzhardinge wrote:
>   
>> +#include <linux/version.h>
>>     
>
> not needed.
>   

Yup.

>> +#include <xen/xenbus.h>
>> +#include <xen/interface/io/netif.h>
>> +#include <xen/interface/memory.h>
>> +#ifdef CONFIG_XEN_BALLOON
>> +#include <xen/balloon.h>
>> +#endif
>> +#include <xen/interface/grant_table.h>
>>     
>
> Please don't try to put such a fucked up include hierachy in.
> Just move everything under include/xen or you will soon get
> problems with the 80 line length limit for your includes..
>   

I'm trying to draw the distinction between kernel-internal Xen-related
headers, and the Xen hypervisor ABI itself.  The stuff under
xen/interface is more or less copied in from the main Xen tree, so it
would be nice to keep it distinct.

> Also please make sure that <xen/balloon.h> can be included unconditionally,
> as we really don't like ifdefs around includes.
>   

The balloon driver isn't in this patch set, so I'll drop all references
to it.

>> +	grant_ref_t gref_tx_head;
>>     
>
> What's a grant_ref_t?  Should this really be a typedef or better
> a struct type?

Structurally it's just a u32.  I could wrap it up in a structure for
typedef reasons, I suppose.

>   Also it really wants a xen_ prefix instead of someting
> so generic.
>   

OK.

>> + * Implement our own carrier flag: the network stack's version causes delays
>> + * when the carrier is re-enabled (in particular, dev_activate() may not
>> + * immediately be called, which can cause packet loss).
>> + */
>>     
>
> Did you talk to the networking folks about these problems?
>   

Not sure what the deliberations were leading to those changes.

Herbert, Keir?


>> +#define netfront_carrier_on(netif)	((netif)->carrier = 1)
>> +#define netfront_carrier_off(netif)	((netif)->carrier = 0)
>> +#define netfront_carrier_ok(netif)	((netif)->carrier)
>>     
>
> Please use proper symbolic names for the ctal states and kill these
> wrappers.
>   

OK.

>
> Any chance you could avoid these forward-prototypes by reordering
> the functions a little?
>   

I'll give it a go.

> Also a lot of these names are horribly generic.  A proper xennet_
> prefix would probably help.
>   

Yes.

>> +static int __devexit netfront_remove(struct xenbus_device *dev)
>> +{
>> +	struct netfront_info *info = dev->dev.driver_data;
>> +
>> +	dev_dbg(&dev->dev, "%s\n", dev->nodename);
>> +
>> +	netif_disconnect_backend(info);
>> +
>> +	del_timer_sync(&info->rx_refill_timer);
>> +
>> +	xennet_sysfs_delif(info->netdev);
>> +
>> +	unregister_netdev(info->netdev);
>> +
>> +	free_netdev(info->netdev);
>>     
>
> This looks like very wrong ordering to me.  unregister_netdev should
> be the first thing in the remove function.
>   

I know this ordering was the result of a relatively recent bugfix
replacing something that was completely broken.

>> +	SHARED_RING_INIT(rxs);
>> +	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
>>     
>
> Can you replace these shouting macros with proper named functions?
>   

Will do.

>> +	 * receive ring. This creates a less bursty demand on the memory
>> +	 * allocator, so should reduce the chance of failed allocation requests
>> +	 * both for ourself and for other kernel subsystems.
>> +	 */
>> +	batch_target = np->rx_target - (req_prod - np->rx.rsp_cons);
>> +	for (i = skb_queue_len(&np->rx_batch); i < batch_target; i++) {
>> +		/*
>> +		 * Allocate an skb and a page. Do not use __dev_alloc_skb as
>> +		 * that will allocate page-sized buffers which is not
>> +		 * necessary here.
>> +		 * 16 bytes added as necessary headroom for netif_receive_skb.
>> +		 */
>> +		skb = alloc_skb(RX_COPY_THRESHOLD + 16 + NET_IP_ALIGN,
>> +				GFP_ATOMIC | __GFP_NOWARN);
>>     
>
> This comment doesn't make any sense, __dev_alloc_skb is:
>   

Yes, it has probably dated.  I'll give it another look.

>> +		skb->nh.raw = (void *)skb_shinfo(skb)->frags[0].page;
>> +		skb->h.raw = skb->nh.raw + rx->offset;
>>     
>
> Stuff like this won't compile anymore in the current tree.
>   

Fixed later in the series.

Thanks,
    J
