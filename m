From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] virtio-net: fix buggy features advertised by host
Date: Thu, 13 Nov 2014 14:06:06 +0800
Message-ID: <54644A4E.7000902@cn.fujitsu.com>
References: <1415857974-23326-1-git-send-email-jasowang@redhat.com>
	<1415857974-23326-2-git-send-email-jasowang@redhat.com>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com
To: Jason Wang <jasowang@redhat.com>, <linux-kernel@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1415857974-23326-2-git-send-email-jasowang@redhat.com>
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

On 11/13/2014 01:52 PM, Jason Wang wrote:
> This patch tries to detect the possible buggy features advertised by host
> and fix them. One example is booting virtio-net with only ctrl_vq disabled,
> qemu may still advertise many features which depends on it. This will
> trigger several BUG()s in virtnet_send_command().
> 
> This patch utilizes the fix_features() method, and disables all features that
> depends on ctrl_vq if it was not advertised.
> 
> This fixes the crash when booting with ctrl_vq=off.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Changes from V1:
> - fix the cut-and-paste error
> ---
>  drivers/net/virtio_net.c | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index ec2a8b4..6ce125e 100644
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
> +			pr_warning("Disable VIRTIO_NET_F_GUEST_ANNOUNCE since "
> +				   "host does not advertise "
> +				   "VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev,
> +					       VIRTIO_NET_F_GUEST_ANNOUNCE);
> +		}
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_MQ)) {
> +			pr_warning("Disable VIRTIO_NET_F_MQ since host "
> +				   "does not advertise VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev, VIRTIO_NET_F_MQ);
> +		}
> +		if (virtio_has_feature(dev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> +			pr_warning("Disable VIRTIO_NET_F_CTRL_MAC_ADDR since "
> +				   "host does not advertise "
> +				   "VIRTIO_NET_F_CTRL_VQ");
> +			virtio_disable_feature(dev, VIRTIO_NET_F_CTRL_MAC_ADDR);
> +		}


Can we use a feature array and check with one loop?  The current check looks so dup?


Thanks,
Wanlong Gao

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
> 
