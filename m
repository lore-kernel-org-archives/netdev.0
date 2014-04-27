From: Amos Kong <akong@redhat.com>
Subject: Re: RFC: sharing config interrupt between virtio devices for saving
 MSI
Date: Sun, 27 Apr 2014 22:35:41 +0800
Message-ID: <20140427143541.GA8623@amosk.info>
References: <20140330111427.GD24476@redhat.com>
 <20140419040815.GB4681@amosk.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: "MichaelS.Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbaD0Ofo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2014 10:35:44 -0400
Content-Disposition: inline
In-Reply-To: <20140419040815.GB4681@amosk.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Hi Michael, Alex

Any thoughts about this ? :)


Thanks, Amos


> diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
> index 101db3f..5ba348d 100644
> --- a/drivers/virtio/virtio_pci.c
> +++ b/drivers/virtio/virtio_pci.c
> @@ -302,6 +302,8 @@ static void vp_free_vectors(struct virtio_device *vdev)
>  	vp_dev->msix_affinity_masks = NULL;
>  }
>  
> +//static msix_entry *config_msix_entry;
> +static char config_msix_name[100];
>  static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
>  				   bool per_vq_vectors)
>  {
> @@ -341,14 +343,13 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
>  
>  	/* Set the vector used for configuration */
>  	v = vp_dev->msix_used_vectors;
> -	snprintf(vp_dev->msix_names[v], sizeof *vp_dev->msix_names,
> +	snprintf(config_msix_name, sizeof *vp_dev->msix_names,
>  		 "%s-config", name);
> -	err = request_irq(vp_dev->msix_entries[v].vector,
> -			  vp_config_changed, 0, vp_dev->msix_names[v],
> -			  vp_dev);
> +	err = request_irq(vp_dev->pci_dev->irq, vp_config_changed, IRQF_SHARED, config_msix_name, vp_dev);
>  	if (err)
>  		goto error;
> -	++vp_dev->msix_used_vectors;
> +
> +        //++vp_dev->msix_used_vectors;
>  
>  	iowrite16(v, vp_dev->ioaddr + VIRTIO_MSI_CONFIG_VECTOR);
>  	/* Verify we had enough resources to assign the vector */
> @@ -380,7 +381,7 @@ static int vp_request_intx(struct virtio_device *vdev)
>  {
>  	int err;
>  	struct virtio_pci_device *vp_dev = to_vp_device(vdev);
> -
> +	printk(KERN_INFO "share irq: %d\n", vp_dev->pci_dev->irq);
>  	err = request_irq(vp_dev->pci_dev->irq, vp_interrupt,
>  			  IRQF_SHARED, dev_name(&vdev->dev), vp_dev);
>  	if (!err)
> @@ -536,13 +537,13 @@ static int vp_try_to_find_vqs(struct virtio_device *vdev, unsigned nvqs,
>  	} else {
>  		if (per_vq_vectors) {
>  			/* Best option: one for change interrupt, one per vq. */
> -			nvectors = 1;
> +			nvectors = 0;
>  			for (i = 0; i < nvqs; ++i)
>  				if (callbacks[i])
>  					++nvectors;
>  		} else {
>  			/* Second best: one for change, shared for all vqs. */
> -			nvectors = 2;
> +			nvectors = 1;
>  		}
>  
>  		err = vp_request_msix_vectors(vdev, nvectors, per_vq_vectors);

> diff --git a/drivers/virtio/virtio_pci.c b/drivers/virtio/virtio_pci.c
> index 101db3f..5ae1844 100644
> --- a/drivers/virtio/virtio_pci.c
> +++ b/drivers/virtio/virtio_pci.c
> @@ -62,6 +62,8 @@ struct virtio_pci_device
>  
>  	/* Whether we have vector per vq */
>  	bool per_vq_vectors;
> +
> +	char config_msix_name[256];
>  };
>  
>  /* Constants for MSI-X */
> @@ -302,6 +304,8 @@ static void vp_free_vectors(struct virtio_device *vdev)
>  	vp_dev->msix_affinity_masks = NULL;
>  }
>  
> +static struct msix_entry *config_msix_entry;
> +static char *config_msix_name;
>  static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
>  				   bool per_vq_vectors)
>  {
> @@ -309,9 +313,14 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
>  	const char *name = dev_name(&vp_dev->vdev.dev);
>  	unsigned i, v;
>  	int err = -ENOMEM;
> +        int has_config_msix = 1;
>  
> -	vp_dev->msix_vectors = nvectors;
> +        if (!config_msix_entry) {
> +		has_config_msix = 0;
> +		nvectors += 1;
> +        }
>  
> +	vp_dev->msix_vectors = nvectors;
>  	vp_dev->msix_entries = kmalloc(nvectors * sizeof *vp_dev->msix_entries,
>  				       GFP_KERNEL);
>  	if (!vp_dev->msix_entries)
> @@ -341,14 +350,24 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
>  
>  	/* Set the vector used for configuration */
>  	v = vp_dev->msix_used_vectors;
> -	snprintf(vp_dev->msix_names[v], sizeof *vp_dev->msix_names,
> +
> +        if (has_config_msix == 0) {
> +		config_msix_entry = &vp_dev->msix_entries[v];
> +		config_msix_name = vp_dev->msix_names[v];
> +        } else {
> +		config_msix_name = vp_dev->config_msix_name;
> +	}
> +
> +	snprintf(vp_dev->config_msix_name, sizeof *vp_dev->msix_names,
>  		 "%s-config", name);
> -	err = request_irq(vp_dev->msix_entries[v].vector,
> -			  vp_config_changed, 0, vp_dev->msix_names[v],
> -			  vp_dev);
> +	err = request_irq(config_msix_entry->vector,
> +                          vp_config_changed, IRQF_SHARED,
> +                          vp_dev->config_msix_name, vp_dev);
>  	if (err)
>  		goto error;
> -	++vp_dev->msix_used_vectors;
> +
> +        if (has_config_msix == 0)
> +             ++vp_dev->msix_used_vectors;
>  
>  	iowrite16(v, vp_dev->ioaddr + VIRTIO_MSI_CONFIG_VECTOR);
>  	/* Verify we had enough resources to assign the vector */
> @@ -536,13 +555,13 @@ static int vp_try_to_find_vqs(struct virtio_device *vdev, unsigned nvqs,
>  	} else {
>  		if (per_vq_vectors) {
>  			/* Best option: one for change interrupt, one per vq. */
> -			nvectors = 1;
> +			nvectors = 0;
>  			for (i = 0; i < nvqs; ++i)
>  				if (callbacks[i])
>  					++nvectors;
>  		} else {
>  			/* Second best: one for change, shared for all vqs. */
> -			nvectors = 2;
> +			nvectors = 1;
>  		}
>  
>  		err = vp_request_msix_vectors(vdev, nvectors, per_vq_vectors);



-- 
			Amos.
