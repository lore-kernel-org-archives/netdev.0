From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost-net: fall back to vmalloc if high-order allocation fails
Date: Fri, 25 Jan 2013 13:15:51 +0800
Message-ID: <4164122.3gtdQVSA24@jason-thinkpad-t430s>
References: <87k3r31vbc.fsf@silenus.orebokech.com> <kdsslg$ddn$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776Ab3AYFP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 00:15:56 -0500
In-Reply-To: <kdsslg$ddn$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 25, 2013 03:03:13 AM Cong Wang wrote:
> ["Followup-To:" header set to gmane.linux.network.]
> 
> On Wed, 23 Jan 2013 at 20:46 GMT, Romain Francoise <romain@orebokech.com> 
wrote:
> > Creating a vhost-net device allocates an object large enough (34320 bytes
> > on x86-64) to trigger an order-4 allocation, which may fail if memory if
> > 
> > fragmented:
> >  libvirtd: page allocation failure: order:4, mode:0x2000d0
> >  ...
> >  SLAB: Unable to allocate memory on node 0 (gfp=0xd0)
> >  
> >    cache: size-65536, object size: 65536, order: 4
> >    node 0: slabs: 8/8, objs: 8/8, free: 0
> > 
> > In that situation, rather than forcing the caller to use regular
> > virtio-net, try to allocate the descriptor with vmalloc().
> 
> The real problem is vhost_net struct is really big, it
> should be reduced rather than workarounded like this.
> 

Looks like iov in vhost_virtqueue is a little big:

    struct iovec iov[UIO_MAXIOV];

Maybe we can use pointer and allocate it like indirect in 
vhost_dev_alloc_iovecs().

> > +static void vhost_net_kvfree(void *addr)
> > +{
> > +	if (is_vmalloc_addr(addr))
> > +		vfree(addr);
> > +	else
> > +		kfree(addr);
> > +}
> > +
> 
> This kind of stuff should really go to mm, not netdev.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
