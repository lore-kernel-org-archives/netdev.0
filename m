From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 1/5] net: virtio dynamically disable/enable
 LRO
Date: Tue, 22 Nov 2016 00:16:26 -0800
Message-ID: <5833FEDA.90701@gmail.com>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120024934.19187.8294.stgit@john-Precision-Tower-5810>
 <20161122012202-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, kubakici@wp.pl,
        shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33034 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755267AbcKVIQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 03:16:49 -0500
Received: by mail-pf0-f195.google.com with SMTP id 144so941072pfv.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 00:16:48 -0800 (PST)
In-Reply-To: <20161122012202-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-21 03:23 PM, Michael S. Tsirkin wrote:
> On Sat, Nov 19, 2016 at 06:49:34PM -0800, John Fastabend wrote:
>> This adds support for dynamically setting the LRO feature flag. The
>> message to control guest features in the backend uses the
>> CTRL_GUEST_OFFLOADS msg type.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  drivers/net/virtio_net.c |   45 ++++++++++++++++++++++++++++++++++++++++++++-
>>  1 file changed, 44 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index ca5239a..8189e5b 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1419,6 +1419,41 @@ static void virtnet_init_settings(struct net_device *dev)
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
>> +			dev_warn(&netdev->dev,
>> +				 "Failed to set guest offloads by virtnet command.\n");
>> +			return -EINVAL;
>> +		}
>> +	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS) &&
>> +		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
>> +		dev_warn(&netdev->dev,
>> +			 "No support for setting offloads pre version_1.\n");
>> +		return -EINVAL;
>> +	}
> 
> I don't get this last warning. VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
> was exposes by legacy devices, I don't think it's related to
> VIRTIO_F_VERSION_1.
> 

OK looks like I can just drop the else if branch here.

Thanks,
John
