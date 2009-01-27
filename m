From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 5/5] virtio_net: Add support for VLAN filtering in the
 hypervisor
Date: Mon, 26 Jan 2009 21:19:52 -0700
Message-ID: <1233029992.7148.82.camel@2710p.home>
References: <1232357520.5627.15.camel@blaa>
	 <20090120163636.10034.5080.stgit@debian.lart>
	 <200901271422.33369.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200901271422.33369.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty,

On Tue, 2009-01-27 at 14:22 +1030, Rusty Russell wrote:
> > + struct virtnet_info *vi = netdev_priv(dev);
> > + u16 id = vid;
> > +
> > + if (virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
> > + VIRTIO_NET_CTRL_VLAN_ADD, &id, sizeof(id)))
> > + printk(KERN_WARNING "%s: Failed to add VLAN ID %d.\n",
> > + dev->name, id);
> > +}
> 
> The temporary var seems strange here, and in kill_vid.

It does stand out a bit.  I can't think of a valid reason for why I had
this, so I'll drop it.

> > - .ndo_poll_controller = virtnet_netpoll,
> > + .ndo_poll_controller = virtnet_netpoll,
> 
> Pretty lining up is a pet peeve of mine. Just indent them one more and
> be happy :)

Noted ;^)

> 
> > + /* Enable VLAN filtering if supported by the backend */
> > + if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
> > + VIRTIO_NET_CTRL_VLAN_ENABLE,
> > + &vlan_filter, sizeof(vlan_filter))) {
> > + printk(KERN_DEBUG "virtio_net: VLAN filter enabled\n");
> > + dev->features |= NETIF_F_HW_VLAN_FILTER;
> > + }
> 
> OK, several things here. Should probably be a feature bit. What is the
> vlan_filter arg for? Finally, using ! for the "success" case is YA API
> nastiness for me; if we were leaving virtnet_send_command as is I'd
> make it return bool, if it really returned a sensible -errno I'd
> compare against 0 here. 

The VLAN_ENABLE command can either enable or disable the VLAN filter, so
the vlan_filter arg is setting enable to "on".  A feature bit might be
more efficient, but since this happens at device init and the enable
will fail if it's not supported by the backend, it seemed redundant.

I agree the success/failure logic would be more clear w/o the !, I'll
switch this to a == 0, or something better depending on what we decide
to do with send_command.  Thanks for the comments,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

