From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 1/2] virtio_net: implement VIRTIO_CONFIG_S_NEEDS_RESET
Date: Thu, 5 Oct 2017 12:18:41 -0400
Message-ID: <CAF=yD-KHGg0Yay=qOFSOTYfD5tDQZvvC0WN19nyWb8OQgUOkNg@mail.gmail.com>
References: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
 <20170829200759.13975-2-willemdebruijn.kernel@gmail.com> <20170829231739-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:37396 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdJEQTX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:19:23 -0400
Received: by mail-oi0-f65.google.com with SMTP id h9so8839543oia.4
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 09:19:22 -0700 (PDT)
In-Reply-To: <20170829231739-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 4:20 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Aug 29, 2017 at 04:07:58PM -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Implement the reset communication request defined in the VIRTIO 1.0
>> specification and introduces in Linux in commit c00bbcf862896 ("virtio:
>> add VIRTIO_CONFIG_S_NEEDS_RESET device status bit").
>>
>> Since that patch, the virtio-net driver has added a virtnet_reset
>> function that implements the requested behavior through calls to the
>> power management freeze and restore functions.
>>
>> That function has recently been reverted when its sole caller was
>> updated. Bring it back and listen for the request from the host on
>> the config channel.
>>
>> Implement the feature analogous to other config requests. In
>> particular, acknowledge the request in the same manner as the
>> NET_S_ANNOUNCE link announce request, by responding with a new
>> VIRTIO_NET_CTRL_${TYPE} command. On reception, the host must check
>> the config status register for success or failure.
>
>
> Pls make it clearer why do you need these interface extensions.
>
>> The existing freeze handler verifies that no config changes are
>> running concurrently. Elide this check for reset. The request is
>> always handled from the config workqueue. No other config requests
>> can be active or scheduled concurrently on vi->config.
>
> You need to prevent packet TX from being in progress.

I had another look at this.

As of commit 713a98d90c5e ("virtio-net: serialize tx routine during reset")
virtnet_freeze_down calls synchronize_net() after stopping the queues
to quiesce the device before any further actions. This should suffice for
virtnet_reset, too.

The control path can indeed be much simpler than my initial patchset.
The host can read vdev->status to observe when the reset went through.
It adds flag VIRTIO_CONFIG_S_NEEDS_RESET to request the reset.
This flag is cleared by the operation itself.

>
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>>  drivers/net/virtio_net.c        | 69 +++++++++++++++++++++++++++++++++++------
>>  include/uapi/linux/virtio_net.h |  4 +++
>
> virtio dev or another virtio TC list must be Cc'd on any proposed API changes.
>
>
>>  2 files changed, 64 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 52ae78ca3d38..5e349226f7c1 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1458,12 +1458,11 @@ static void virtnet_netpoll(struct net_device *dev)
>>  }
>>  #endif
>>
>> -static void virtnet_ack_link_announce(struct virtnet_info *vi)
>> +static void virtnet_ack(struct virtnet_info *vi, u8 class, u8 cmd)
>>  {
>>       rtnl_lock();
>> -     if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_ANNOUNCE,
>> -                               VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL))
>> -             dev_warn(&vi->dev->dev, "Failed to ack link announce.\n");
>> +     if (!virtnet_send_command(vi, class, cmd, NULL))
>> +             dev_warn(&vi->dev->dev, "Failed to ack %u.%u\n", class, cmd);
>>       rtnl_unlock();
>>  }
>>
>> @@ -1857,13 +1856,16 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
>>       .set_link_ksettings = virtnet_set_link_ksettings,
>>  };
>>
>> -static void virtnet_freeze_down(struct virtio_device *vdev)
>> +static void virtnet_freeze_down(struct virtio_device *vdev, bool in_reset)
>>  {
>>       struct virtnet_info *vi = vdev->priv;
>>       int i;
>>
>> -     /* Make sure no work handler is accessing the device */
>> -     flush_work(&vi->config_work);
>> +     /* Make sure no work handler is accessing the device,
>> +      * unless this call is made from the reset work handler itself.
>> +      */
>> +     if (!in_reset)
>> +             flush_work(&vi->config_work);
>>
>>       netif_device_detach(vi->dev);
>>       netif_tx_disable(vi->dev);
>> @@ -1878,6 +1880,7 @@ static void virtnet_freeze_down(struct virtio_device *vdev)
>>  }
>>
>>  static int init_vqs(struct virtnet_info *vi);
>> +static void remove_vq_common(struct virtnet_info *vi);
>>
>>  static int virtnet_restore_up(struct virtio_device *vdev)
>>  {
>> @@ -1906,6 +1909,45 @@ static int virtnet_restore_up(struct virtio_device *vdev)
>>       return err;
>>  }
>>
>> +static int virtnet_reset(struct virtnet_info *vi)
>> +{
>> +     struct virtio_device *dev = vi->vdev;
>> +     bool failed;
>> +     int ret;
>> +
>> +     virtio_config_disable(dev);
>> +     failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
>> +     virtnet_freeze_down(dev, true);
>> +     remove_vq_common(vi);
>> +
>> +     virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
>> +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
>> +
>> +     /* Restore the failed status (see virtio_device_restore). */
>> +     if (failed)
>> +             virtio_add_status(dev, VIRTIO_CONFIG_S_FAILED);
>> +
>> +     ret = virtio_finalize_features(dev);
>> +     if (ret)
>> +             goto err;
>> +
>> +     ret = virtnet_restore_up(dev);
>> +     if (ret)
>> +             goto err;
>> +
>> +     ret = virtnet_set_queues(vi, vi->curr_queue_pairs);
>> +     if (ret)
>> +             goto err;
>> +
>> +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
>> +     virtio_config_enable(dev);
>> +     return 0;
>> +
>> +err:
>> +     virtio_add_status(dev, VIRTIO_CONFIG_S_FAILED);
>> +     return ret;
>> +}
>> +
>>  static int virtnet_set_guest_offloads(struct virtnet_info *vi, u64 offloads)
>>  {
>>       struct scatterlist sg;
>> @@ -2085,7 +2127,16 @@ static void virtnet_config_changed_work(struct work_struct *work)
>>
>>       if (v & VIRTIO_NET_S_ANNOUNCE) {
>>               netdev_notify_peers(vi->dev);
>> -             virtnet_ack_link_announce(vi);
>> +             virtnet_ack(vi, VIRTIO_NET_CTRL_ANNOUNCE,
>> +                         VIRTIO_NET_CTRL_ANNOUNCE_ACK);
>> +     }
>> +
>> +     if (vi->vdev->config->get_status(vi->vdev) &
>> +         VIRTIO_CONFIG_S_NEEDS_RESET) {
>> +             virtnet_reset(vi);
>> +             virtnet_ack(vi, VIRTIO_NET_CTRL_RESET,
>> +                         VIRTIO_NET_CTRL_RESET_ACK);
>> +
>>       }
>>
>>       /* Ignore unknown (future) status bits */
>> @@ -2708,7 +2759,7 @@ static __maybe_unused int virtnet_freeze(struct virtio_device *vdev)
>>       struct virtnet_info *vi = vdev->priv;
>>
>>       virtnet_cpu_notif_remove(vi);
>> -     virtnet_freeze_down(vdev);
>> +     virtnet_freeze_down(vdev, false);
>>       remove_vq_common(vi);
>>
>>       return 0;
>> diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
>> index fc353b518288..188fdc528f13 100644
>> --- a/include/uapi/linux/virtio_net.h
>> +++ b/include/uapi/linux/virtio_net.h
>> @@ -245,4 +245,8 @@ struct virtio_net_ctrl_mq {
>>  #define VIRTIO_NET_CTRL_GUEST_OFFLOADS   5
>>  #define VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET        0
>>
>> +/* Signal that the driver received and executed the reset command. */
>> +#define VIRTIO_NET_CTRL_RESET                        6
>> +#define VIRTIO_NET_CTRL_RESET_ACK            0
>> +
>>  #endif /* _UAPI_LINUX_VIRTIO_NET_H */
>> --
>> 2.14.1.342.g6490525c54-goog
