From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCH 03/13] dmaengine: up-level reference counting to the module level
Date: Mon, 15 Dec 2008 15:12:21 -0700
Message-ID: <e9c3a7c20812151412va63c2ceob7d57ea91a8c208@mail.gmail.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
	 <129600E5E5FB004392DDC3FB599660D70C8F3405@irsmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:54892 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbYLOWMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 17:12:22 -0500
In-Reply-To: <129600E5E5FB004392DDC3FB599660D70C8F3405@irsmsx504.ger.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 7:28 AM, Sosnowski, Maciej
<maciej.sosnowski@intel.com> wrote:
> Dan,
>
> General concern I see about this change is that it makes impossible
> to rmmod ioatdma in case of NET_DMA enabled.
> This is a specific case of situation when client is permanently registered in dmaengine,
> making it impossible to rmmod any device with "public" channels.
> Ioatdma is just an example here.
> However in ioatdma case it would be problematic now to switch between CPU and DMA copy modes.
> It seems that the only way to disable DMA after loading ioatdma would be raising tcp_dma_copybreak
> to some high enough value to direct all buffers to CPU copy path.
> This way is yet rather more like hacking than "normal" usage way (like "rmmod ioatdma" used so far).
>

Hi Maciej,

I have been waiting for you to point this out because I believe it
shows where more work is needed in net_dma.  The problem with net_dma
is that it never says "I am done with dma channels".  The result was
the old/complicated per-operation reference counting in dmaengine that
lead to the, now deleted, comment for ioat_remove():

/*
 * It is unsafe to remove this module: if removed while a requested
 * dma is outstanding, esp. from tcp, it is possible to hang while
 * waiting for something that will never finish.  However, if you're
 * feeling lucky, this usually works just fine.
 */

This also required the complexity of each client needing to handle
asynchronous channel removal events.  In all other cases in the kernel
a module is pinned as long as it has users, so dmaengine was backwards
in this regard.

Putting the end-node principal to work here means that the
complexity/effort of determining when net_dma is done with channels
should reside in net_dma, not dmaengine.  Since we cannot hook into a
"rmmod net" event to drop the dmaengine reference we will need some
out-of-band signal to enable "rmmod ioatdma" like detecting
network-idle, or having an explicit "dma disable" sysctl.

> Another issue I find problematic in this solution is that _any_ client
> declaring its presence in dmaengine causes holding reference for _all_ channels (and blocking them),
> does not matter if they are used or not.
> I agree with Guennadi's doubts here.
> Why not at least hold a reference only for channels with capabilities matching client's ones?
>

All channels share the same parent module, so taking a reference on
one will always involve blocking all channels.  Private channels have
this granularity, and this is a primary difference between public and
private channels.  I eventually want dmaengine to hook into cpu
hotplug notifications to guarantee that resources are only allocated
for channels with a non-zero ->table_count, but this is not there
today.

>> @@ -105,19 +106,8 @@ static ssize_t show_bytes_transferred(struct
>>  device *dev, struct device_attribut static ssize_t
>>  show_in_use(struct device *dev, struct device_attribute *attr, char
>>       *buf) { struct dma_chan *chan = to_dma_chan(dev);
>> -     int in_use = 0;
>> -
>> -     if (unlikely(chan->slow_ref) &&
>> -             atomic_read(&chan->refcount.refcount) > 1)
>> -             in_use = 1;
>> -     else {
>> -             if (local_read(&(per_cpu_ptr(chan->local,
>> -                     get_cpu())->refcount)) > 0)
>> -                     in_use = 1;
>> -             put_cpu();
>> -     }
>>
>> -     return sprintf(buf, "%d\n", in_use);
>> +     return sprintf(buf, "%d\n", chan->client_count);
>>  }
>
> In this case show_in_use will not show if the channel is really in use
> but rather how many clients are present, including these with different capabilities.
> Thus this number does not even show number of "potential" users of the channel...
> Again, maybe it would be better to limit chan->client_count
> to number of at least potential users ( = matching capabilities)?

To be clear show_in_use was broken before because it only looked at a
per-cpu variable[1], the situation is better now because it indeed
shows "potential" users in the public case and actual users in the
private case.  I.e. if a public channel client has the potential to
get this channel via dma_find_channel() then that will be reflected in
->client_count.

>
>>
>>       /* Find a channel */
>> @@ -178,23 +228,16 @@ static void dma_client_chan_alloc(struct
>>               dma_client *client)
>>               list_for_each_entry(chan, &device->channels, device_node) {
>>                       if (!dma_chan_satisfies_mask(chan, client->cap_mask))
>>                               continue;
>> +                     if (!chan->client_count)
>> +                             continue;
>
> As cap_mask is per device not per channel, checking capabilites matching
> is not necessary to be repeated for every channel.
> It would be more efficient to do it once yet before
> list_for_each_entry(chan, &device->channels, device_node).

This is changed in later patches [2].  We repeat for each channel in
the dma_request_channel() case under the assumption that the client
may be smart enough to disambiguate the channels on other criteria.

>
>> @@ -420,6 +443,19 @@ int dma_async_device_register(struct dma_device
>>       *device) }
>>
>>       mutex_lock(&dma_list_mutex);
>> +     list_for_each_entry(chan, &device->channels, device_node) {
>> +             /* if clients are already waiting for channels we need to
>> +              * take references on their behalf
>> +              */
>> +             if (dmaengine_ref_count && dma_chan_get(chan) == -ENODEV) {
>> +                     /* note we can only get here for the first
>> +                      * channel as the remaining channels are
>> +                      * guaranteed to get a reference
>> +                      */
>> +                     rc = -ENODEV;
>> +                     goto err_out;
>> +             }
>> +     }
>
> Going through this list_for_each_entry() loop makes sense only if there are any clients,
> so maybe it would be more efficient to move "if (dmaengine_ref_count)" check before
> list_for_each_entry(chan, &device->channels, device_node)?

Good point... will fix.

Thanks,
Dan

[1] http://marc.info/?l=linux-kernel&m=121448921721509&w=2
[2] http://marc.info/?l=linux-kernel&m=122835195303216&w=2
