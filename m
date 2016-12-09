From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v5 1/6] net: virtio dynamically disable/enable
 LRO
Date: Thu, 8 Dec 2016 16:04:58 -0800
Message-ID: <5849F52A.7050105@gmail.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161207201111.28121.4879.stgit@john-Precision-Tower-5810>
 <20161208231857-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36678 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932299AbcLIAFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 19:05:16 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so238989pgx.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 16:05:16 -0800 (PST)
In-Reply-To: <20161208231857-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-08 01:36 PM, Michael S. Tsirkin wrote:
> On Wed, Dec 07, 2016 at 12:11:11PM -0800, John Fastabend wrote:
>> This adds support for dynamically setting the LRO feature flag. The
>> message to control guest features in the backend uses the
>> CTRL_GUEST_OFFLOADS msg type.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  drivers/net/virtio_net.c |   40 +++++++++++++++++++++++++++++++++++++++-
>>  1 file changed, 39 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index a21d93a..a5c47b1 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1419,6 +1419,36 @@ static void virtnet_init_settings(struct net_device *dev)
>>  	.set_settings = virtnet_set_settings,
>>  };
>>  
>> +static int virtnet_set_features(struct net_device *netdev,
>> +				netdev_features_t features)
>> +{
>> +	struct virtnet_info *vi = netdev_priv(netdev);
>> +	struct virtio_device *vdev = vi->vdev;
>> +	struct scatterlist sg;
>> +	u64 offloads = 0;
>> +
>> +	if (features & NETIF_F_LRO)
>> +		offloads |= (1 << VIRTIO_NET_F_GUEST_TSO4) |
>> +			    (1 << VIRTIO_NET_F_GUEST_TSO6);
>> +
>> +	if (features & NETIF_F_RXCSUM)
>> +		offloads |= (1 << VIRTIO_NET_F_GUEST_CSUM);
>> +
>> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS)) {
>> +		sg_init_one(&sg, &offloads, sizeof(uint64_t));
>> +		if (!virtnet_send_command(vi,
>> +					  VIRTIO_NET_CTRL_GUEST_OFFLOADS,
>> +					  VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET,
>> +					  &sg)) {
> 
> Hmm I just realised that this will slow down setups that bridge
> virtio net interfaces since bridge calls this if provided.
> See below.


Really? What code is trying to turn off GRO via the GUEST_OFFLOADS LRO
command. My qemu/Linux setup has a set of tap/vhost devices attached to
a bridge and all of them have LRO enabled even with this patch series.

I must missing a setup handler somewhere?

> 
>> +			dev_warn(&netdev->dev,
>> +				 "Failed to set guest offloads by virtnet command.\n");
>> +			return -EINVAL;
>> +		}
>> +	}
> 
> Hmm if VIRTIO_NET_F_CTRL_GUEST_OFFLOADS is off, this fails
> silently. It might actually be a good idea to avoid
> breaking setups.
> 
>> +
>> +	return 0;
>> +}
>> +
>>  static const struct net_device_ops virtnet_netdev = {
>>  	.ndo_open            = virtnet_open,
>>  	.ndo_stop   	     = virtnet_close,
>> @@ -1435,6 +1465,7 @@ static void virtnet_init_settings(struct net_device *dev)
>>  #ifdef CONFIG_NET_RX_BUSY_POLL
>>  	.ndo_busy_poll		= virtnet_busy_poll,
>>  #endif
>> +	.ndo_set_features	= virtnet_set_features,
>>  };
>>  
>>  static void virtnet_config_changed_work(struct work_struct *work)
>> @@ -1815,6 +1846,12 @@ static int virtnet_probe(struct virtio_device *vdev)
>>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
>>  		dev->features |= NETIF_F_RXCSUM;
>>  
>> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) &&
>> +	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)) {
>> +		dev->features |= NETIF_F_LRO;
>> +		dev->hw_features |= NETIF_F_LRO;
> 
> So the issue is I think that the virtio "LRO" isn't really
> LRO, it's typically just GRO forwarded to guests.
> So these are easily re-split along MTU boundaries,
> which makes it ok to forward these across bridges.
> 
> It's not nice that we don't document this in the spec,
> but it's the reality and people rely on this.
> 
> For now, how about doing a custom thing and just disable/enable
> it as XDP is attached/detached?

The annoying part about doing this is ethtool will say that it is fixed
yet it will be changed by seemingly unrelated operation. I'm not sure I
like the idea to start automatically configuring the link via xdp_set.

> 
>> +	}
>> +
>>  	dev->vlan_features = dev->features;
>>  
>>  	/* MTU range: 68 - 65535 */
>> @@ -2057,7 +2094,8 @@ static int virtnet_restore(struct virtio_device *vdev)
>>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
>>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
>>  	VIRTIO_NET_F_CTRL_MAC_ADDR, \
>> -	VIRTIO_NET_F_MTU
>> +	VIRTIO_NET_F_MTU, \
>> +	VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
>>  
>>  static unsigned int features[] = {
>>  	VIRTNET_FEATURES,
