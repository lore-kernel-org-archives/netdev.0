From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 4/4] virtio_net: Add support for VLAN filtering in the hypervisor
Date: Fri, 30 Jan 2009 16:31:32 +1030
Message-ID: <200901301631.32862.rusty@rustcorp.com.au>
References: <20090129230502.2672.87669.stgit@debian.lart> <20090129230523.2672.55464.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090129230523.2672.55464.stgit@debian.lart>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 January 2009 09:35:23 Alex Williamson wrote:
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
> +				  VIRTIO_NET_CTRL_VLAN_ADD, &vid, sizeof(vid)))
> +		printk(KERN_WARNING "%s: Failed to add VLAN ID %d.\n",
> +		       dev->name, vid);
> +}

Hmm, I should have mentioned dev_warn() in previous patches.

And possibly (since we never expect it to happen), we should move it into virtnet_send_command to save all the callers sweating on it.  It'd be
less informative tho.

> +		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN)) {
> +			u8 enable = 1;
> +
> +			/* Enable VLAN filtering */
> +			if (virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
> +						 VIRTIO_NET_CTRL_VLAN_ENABLE,
> +						 &enable, sizeof(enable)))
> +				dev->features |= NETIF_F_HW_VLAN_FILTER;
> +			else
> +				printk(KERN_WARNING "virtio_net: "
> +				       "Failed to enable VLAN filter\n");
> +		}

We can kill VLAN_ENABLE.  We activate it by acking the feature bit.

So this becomes:
	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
		dev->features |= NETIF_F_HW_VLAN_FILTER;

> + * The VLAN filter table is controlled via a simple ADD/DEL interface.
> + * VLAN IDs not added will be dropped.  Del is the opposite of add.
> + * Both commands expect an out entry containing a 2 byte VLAN ID.

s/will be dropped/may be filtered out by the host/ ?

Cheers,
Rusty.
