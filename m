From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/2] virtio-net: fix buggy features advertised by host
Date: Thu, 13 Nov 2014 13:42:00 +0800
Message-ID: <546444A8.3030209@redhat.com>
References: <1415856287-12849-1-git-send-email-jasowang@redhat.com>
	<1415856287-12849-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1415856287-12849-2-git-send-email-jasowang@redhat.com>
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

On 11/13/2014 01:24 PM, Jason Wang wrote:
> This patch tries to detect the possible buggy features advertised by host
> and fix them. One example is current booting virtio-net with only
> ctrl_vq disabled, qemu may still advertise many features which depends
> it. This will trigger several BUG()s in virtnet_send_command().
>
> This patch utilizes the fix_features() method, and disable all features that
> depends on ctrl_vq if it was not advertised.
>
> This fixes the crash when booting with ctrl_vq=off.
>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index ec2a8b4..d6bb5fa 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1948,6 +1948,40 @@ static int virtnet_restore(struct virtio_device *vdev)
>  }
>  #endif
>  
> +static void virtnet_fix_features(struct virtio_device *dev)
> +{
> +	if (!virtio_has_feature(dev, VIRTIO_NET_F_CTRL_VQ)) {
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_CTRL_RX)) {
> +			pr_warning("Disable VIRTIO_NET_F_CTRL_RX since host "
> +				   "does not advertise VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev, VIRTIO_NET_F_CTRL_RX);
> +		}
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_CTRL_VLAN)) {
> +			pr_warning("Disable VIRTIO_NET_F_CTRL_VLAN since host "
> +				   "does not advertise VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev, VIRTIO_NET_F_CTRL_VLAN);
> +		}
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_GUEST_ANNOUNCE)) {
> +			pr_warning("Disable VIRTIO_NET_F_GUEST_ANNOUCE since "
> +				   "host does not advertise "
> +				   "VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev,
> +					       VIRTIO_NET_F_GUEST_ANNOUNCE);
> +		}
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_MQ)) {
> +			pr_warning("Disable VIRTIO_NET_F_MQ since host "
> +				   "does not advertise VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev, VIRTIO_NET_F_CTRL_VLAN);
> +		}
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> +			pr_warning("Disable VIRTIO_NET_F_CTRL_MAC_ADDR since "
> +				   "host does not advertise "
> +				   "VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev, VIRTIO_NET_F_CTRL_VLAN);

Oops, this looks like a cut-and-paste error. Will post V2.
> +		}
> +	}
> +}
> +
>  static struct virtio_device_id id_table[] = {
>  	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
>  	{ 0 },
> @@ -1975,6 +2009,7 @@ static struct virtio_driver virtio_net_driver = {
>  	.probe =	virtnet_probe,
>  	.remove =	virtnet_remove,
>  	.config_changed = virtnet_config_changed,
> +	.fix_features = virtnet_fix_features,
>  #ifdef CONFIG_PM_SLEEP
>  	.freeze =	virtnet_freeze,
>  	.restore =	virtnet_restore,
