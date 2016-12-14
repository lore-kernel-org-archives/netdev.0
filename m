From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v5 1/6] net: virtio dynamically disable/enable
 LRO
Date: Wed, 14 Dec 2016 09:01:27 -0800
Message-ID: <58517AE7.5090104@gmail.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161207201111.28121.4879.stgit@john-Precision-Tower-5810>
 <20161208231857-mutt-send-email-mst@kernel.org> <5849F52A.7050105@gmail.com>
 <20161214152924-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36036 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932786AbcLNRSy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 12:18:54 -0500
Received: by mail-pf0-f194.google.com with SMTP id c4so1418270pfb.3
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 09:18:29 -0800 (PST)
In-Reply-To: <20161214152924-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-14 05:31 AM, Michael S. Tsirkin wrote:
> On Thu, Dec 08, 2016 at 04:04:58PM -0800, John Fastabend wrote:
>> On 16-12-08 01:36 PM, Michael S. Tsirkin wrote:
>>> On Wed, Dec 07, 2016 at 12:11:11PM -0800, John Fastabend wrote:
>>>> This adds support for dynamically setting the LRO feature flag. The
>>>> message to control guest features in the backend uses the
>>>> CTRL_GUEST_OFFLOADS msg type.
>>>>
>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>> ---

[...]

>>>>  
>>>>  static void virtnet_config_changed_work(struct work_struct *work)
>>>> @@ -1815,6 +1846,12 @@ static int virtnet_probe(struct virtio_device *vdev)
>>>>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
>>>>  		dev->features |= NETIF_F_RXCSUM;
>>>>  
>>>> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) &&
>>>> +	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)) {
>>>> +		dev->features |= NETIF_F_LRO;
>>>> +		dev->hw_features |= NETIF_F_LRO;
>>>
>>> So the issue is I think that the virtio "LRO" isn't really
>>> LRO, it's typically just GRO forwarded to guests.
>>> So these are easily re-split along MTU boundaries,
>>> which makes it ok to forward these across bridges.
>>>
>>> It's not nice that we don't document this in the spec,
>>> but it's the reality and people rely on this.
>>>
>>> For now, how about doing a custom thing and just disable/enable
>>> it as XDP is attached/detached?
>>
>> The annoying part about doing this is ethtool will say that it is fixed
>> yet it will be changed by seemingly unrelated operation. I'm not sure I
>> like the idea to start automatically configuring the link via xdp_set.
> 
> I really don't like the idea of dropping performance
> by a factor of 3 for people bridging two virtio net
> interfaces.
> 
> So how about a simple approach for now, just disable
> XDP if GUEST_TSO is enabled?
> 
> We can discuss better approaches in next version.
> 

So the proposal is to add a check in XDP setup so that

  if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO{4|6})
	return -ENOPSUPP;

Or whatever is the most appropriate return code? Then we can
disable TSO via qemu-system with guest_tso4=off,guest_tso6=off for
XDP use cases.

Sounds like a reasonable start to me. I'll make the change should this
go through DaveMs net-next tree or do you want it on virtio tree? Either
is fine with me.

Thanks,
John
