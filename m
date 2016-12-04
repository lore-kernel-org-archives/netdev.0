From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v4 1/6] net: virtio dynamically disable/enable
 LRO
Date: Sun, 4 Dec 2016 10:59:12 -0800
Message-ID: <58446780.3040702@gmail.com>
References: <20161202204804.4331.61904.stgit@john-Precision-Tower-5810>
 <20161202204945.4331.2419.stgit@john-Precision-Tower-5810>
 <20161203010423-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35355 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750804AbcLDTAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 14:00:06 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so13961124pga.2
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 11:00:06 -0800 (PST)
In-Reply-To: <20161203010423-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-03 09:36 PM, Michael S. Tsirkin wrote:
> On Fri, Dec 02, 2016 at 12:49:45PM -0800, John Fastabend wrote:
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
>> index a21d93a..d814e7cb 100644
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
> 
> No need for VIRTIO_F_VERSION_1 here.
> 

Yep Dave pointed it out as well. Also I found a bug on driver unload
path where XDP tx queues are not cleaned up correctly so will need a v5
for that.

Thanks,
John
