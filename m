From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 2/4] virtio_net: Add a virtqueue for outbound control
 commands
Date: Wed, 14 Jan 2009 09:01:08 -0700
Message-ID: <1231948868.7109.288.camel@lappy>
References: <1231881797.9095.187.camel@bling>
	 <1231928110.4944.290.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231928110.4944.290.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-01-14 at 10:15 +0000, Mark McLoughlin wrote:
> On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:
> > This will be used for RX mode, MAC filter table, VLAN filtering, etc...
> 
> Looks very reasonable. I'm a bit wary of send_command() being
> synchronous, but it probably makes sense.

Yes, I tried to make it async, but quickly ran into problems sleeping
when I wasn't allowed to.  Using it in this way does pretty much limit
it to an outbound channel though... all worthy of commit log comments.

> > +static int virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> > +				void *data, unsigned int len)
> > +{
> > +	struct scatterlist sg[3];
> > +	struct {
> > +		u8 class;
> > +		u8 cmd;
> > +	} ctrl_cmd;
> 
> I'd like to see this defined in virtio_net_hdr.

As part of struct virtio_net_hdr?  I'm not sure what that'd buy us and
would likely break compatibility.  Or do you simply mean defined in
virtio-net.h?

> Why the need for class/cmd? Why not just a single 16 bit command field?

It seemed like a good way to logically divide up an address space and
makes it easy for the backend to break up the code so it doesn't become
a huge table.

> > +	u8 ctrl_status;
> > +	unsigned int tmp;
> > +	int i = 0;
> > +
> > +	if (!vi->cvq)
> > +		return -EFAULT;
> 
> BUG_ON() probably makes more sense here.

This is to allow a newer virtio_net guest driver to run on an old qemu.
That's why I don't generate a fatal error if we don't find the control
queue.  In that case the backend will be running in promiscuous mode and
I think all of these commands can safely fail.  Thanks for the comments.

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

