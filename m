From: Amos Kong <akong@redhat.com>
Subject: Re: RFC: sharing config interrupt between virtio devices for saving
	MSI
Date: Tue, 22 Apr 2014 16:15:27 +0800
Message-ID: <20140422081527.GC2543@amosk.info>
References: <20140330111427.GD24476@redhat.com>
	<20140419040815.GB4681@amosk.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arusty@rustcorp.com.au
To: "MichaelS.Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140419040815.GB4681@amosk.info>
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

On Sat, Apr 19, 2014 at 12:08:15PM +0800, Amos Kong wrote:
> 
> Hi all,
> 
> I'm working on this item in Upstream Networking todolist:
> 
> | - Sharing config interrupts
> |    Support more devices by sharing a single msi vector
> |    between multiple virtio devices.
> |    (Applies to virtio-blk too).
> 
> I have this solution here, and only have draft patches of Solution
> 1 & 2, let's discuss if solution 3 is feasible.
> 
> * We should not introduce perf regression in this change
> * little effect is acceptable because we are _sharing_ interrupt
> 
> Solution 1:
> ==========
> share one LSI interrupt for configuration change of all virtio devices.
> Draft patch: share_lsi_for_all_config.patch
> 
> Solution 2:
> ==========
> share one MSI interrupt for configuration change of all virtio devices.
> Draft patch: share_msix_for_all_config.patch
> 
> Solution 3:
> ==========
> dynamic adjust interrupt policy when device is added or removed
> Current:
> -------
> - try to allocate a MSI to device's config
> - try to allocate a MSI for each vq
> - share one MSI for all vqs of one device
> - share one LSI for config & vqs of one device
> 
> additional dynamic policies:
> ---------------------------
> - if there is no enough MSI, adjust interrupt allocation for returning
>   some MSI
>    - try to find a device that allocated one MSI for each vq, change
>      it to share one MSI for saving the MSI
>    - try to share one MSI for config of all virtio_pci devices
>    - try to share one LSI for config of all devices
> 
> - if device is removed, try to re-allocate freed MSI to existed
>   devices, if they aren't in best status (one MSI for config, one
>   MSI for each vq)
>    - if config of all devices is sharing one LSI, try to upgrade it to MSI
>    - if config of all devices is sharing one MSI, try to allocate one
>      MSI for configuration change of each device
>    - try to find a device that is sharing one MSI for all vqs, try to
>      allocate one MSI for each vq
> 
> 
> 
> BTW, I saw we still notify all vqs even VIRTIO_PCI_ISR_CONFIG bit of
> isr is set, is it necessary?

[Reply myself]

Quote from Virtio-spec:

| 2.4.3 Dealing With Configuration Changes
| Some virtio PCI devices can change the device configuration state, as reflected
| in the virtio header in the PCI configuration space. In this case:
| 
| 1. If MSI-X capability is disabled: an interrupt is delivered and the sec-
| ond highest bit is set in the ISR Status field to indicate that the driver
| should re-examine the configuration space.

| Note that a single interrupt can
| indicate both that one or more virtqueue has been used and that the con-
| figuration space has changed: even if the config bit is set, virtqueues must
| be scanned. <<<<

It seems current code is fine.

 
> diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
> index 101db3f..176aabc 100644
> --- a/drivers/virtio/virtio_pci.c
> +++ b/drivers/virtio/virtio_pci.c
> @@ -259,9 +259,9 @@ static irqreturn_t vp_interrupt(int irq, void
> *opaque)
>  
>         /* Configuration change?  Tell driver if it wants to know. */
>         if (isr & VIRTIO_PCI_ISR_CONFIG)
> -               vp_config_changed(irq, opaque);
> -
> -       return vp_vring_interrupt(irq, opaque);
> +               return vp_config_changed(irq, opaque);
> +       else
> +               return vp_vring_interrupt(irq, opaque);
>  }
>  
>  static void vp_free_vectors(struct virtio_device *vdev)
> 
> -- 
> 			Amos.
