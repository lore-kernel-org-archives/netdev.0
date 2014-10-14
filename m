From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 04/25] virtio: defer config changed notifications
Date: Tue, 14 Oct 2014 11:59:08 +0300
Message-ID: <20141014085908.GA6016@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
	<1413114332-626-5-git-send-email-mst-v4@redhat.com>
	<87lhojcx0v.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87lhojcx0v.fsf@rustcorp.com.au>
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

On Tue, Oct 14, 2014 at 11:01:12AM +1030, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > Defer config changed notifications that arrive during
> > probe/scan/freeze/restore.
> >
> > This will allow drivers to set DRIVER_OK earlier, without worrying about
> > racing with config change interrupts.
> >
> > This change will also benefit old hypervisors (before 2009)
> > that send interrupts without checking DRIVER_OK: previously,
> > the callback could race with driver-specific initialization.
> >
> > This will also help simplify drivers.
> 
> But AFAICT you never *read* dev->config_changed.
> 
> You unconditionally trigger a config_changed event in
> virtio_config_enable().  That's a bit weird, but probably OK.
> 
> How about the following change (on top of your patch).  I
> think the renaming is clearer, and note the added if() test in
> virtio_config_enable().
> 
> If you approve, I'll fold it in.
> 
> Cheers,
> Rusty.

Hi Rusty,
I'm okay with both changes.
You can fold it in if you prefer, or just make it a patch on top.

> diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
> index 2536701b098b..df598dd8c5c8 100644
> --- a/drivers/virtio/virtio.c
> +++ b/drivers/virtio/virtio.c
> @@ -122,7 +122,7 @@ static void __virtio_config_changed(struct virtio_device *dev)
>  	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
>  
>  	if (!dev->config_enabled)
> -		dev->config_changed = true;
> +		dev->config_change_pending = true;
>  	else if (drv && drv->config_changed)
>  		drv->config_changed(dev);
>  }
> @@ -148,8 +148,9 @@ static void virtio_config_enable(struct virtio_device *dev)
>  {
>  	spin_lock_irq(&dev->config_lock);
>  	dev->config_enabled = true;
> -	__virtio_config_changed(dev);
> -	dev->config_changed = false;
> +	if (dev->config_change_pending)
> +		__virtio_config_changed(dev);
> +	dev->config_change_pending = false;
>  	spin_unlock_irq(&dev->config_lock);
>  }
>  
> @@ -253,7 +254,7 @@ int register_virtio_device(struct virtio_device *dev)
>  
>  	spin_lock_init(&dev->config_lock);
>  	dev->config_enabled = false;
> -	dev->config_changed = false;
> +	dev->config_change_pending = false;
>  
>  	/* We always start by resetting the device, in case a previous
>  	 * driver messed it up.  This also tests that code path a little. */
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 5636b119dc25..65261a7244fc 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -80,7 +80,7 @@ bool virtqueue_is_broken(struct virtqueue *vq);
>   * @index: unique position on the virtio bus
>   * @failed: saved value for CONFIG_S_FAILED bit (for restore)
>   * @config_enabled: configuration change reporting enabled
> - * @config_changed: configuration change reported while disabled
> + * @config_change_pending: configuration change reported while disabled
>   * @config_lock: protects configuration change reporting
>   * @dev: underlying device.
>   * @id: the device type identification (used to match it with a driver).
> @@ -94,7 +94,7 @@ struct virtio_device {
>  	int index;
>  	bool failed;
>  	bool config_enabled;
> -	bool config_changed;
> +	bool config_change_pending;
>  	spinlock_t config_lock;
>  	struct device dev;
>  	struct virtio_device_id id;
