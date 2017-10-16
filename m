From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio_net: implement VIRTIO_CONFIG_S_NEEDS_RESET
Date: Mon, 16 Oct 2017 11:03:18 -0400
Message-ID: <CAF=yD-LdGiKuf=k2FDgFWbhvExVX8t+VVgTQetKTegjMeQ598g@mail.gmail.com>
References: <20171013155140.124530-1-willemdebruijn.kernel@gmail.com>
	<20171015034018-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20171015034018-mutt-send-email-mst@kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

>> +static int virtnet_reset(struct virtnet_info *vi)
>> +{
>> +     struct virtio_device *dev = vi->vdev;
>> +     int ret;
>> +
>> +     virtio_config_disable(dev);
>> +     dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
>> +     virtnet_freeze_down(dev, true);
>> +     remove_vq_common(vi);
>> +
>> +     virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
>> +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
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
>
> I have a question here though. How do things like MAC address
> get restored?
>
> What about the rx mode?
>
> vlans?

The function as is releases and reinitializes only ring state.
Device configuration such as mac and vlan persist across
the reset.

> Also, it seems that LINK_ANNOUNCE requests will get ignored
> even if they got set before the reset, leading to downtime.

Do you mean act on VIRTIO_NET_F_GUEST_ANNOUNCE
requests? That flag is tested and netdev_notify_peers
called before resetting virtio ring state.
