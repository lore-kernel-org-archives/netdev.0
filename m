From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [CFT] 2.6.x experimental net driver updates
Date: Thu, 20 Nov 2003 05:47:29 +0000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031120054729.GC24159@parcelfarce.linux.theplanet.co.uk>
References: <3FBBA954.6000601@pobox.com> <20031120025423.GB24159@parcelfarce.linux.theplanet.co.uk> <3FBC4FE0.2020705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FBC4FE0.2020705@pobox.com>
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2003 at 12:23:44AM -0500, Jeff Garzik wrote:
> viro@parcelfarce.linux.theplanet.co.uk wrote:
> >On Wed, Nov 19, 2003 at 12:33:08PM -0500, Jeff Garzik wrote:
> >
> >>Ok, Al Viro's net driver refcounting work is pretty much complete, and 
> >
> >
> >The hell it is.  We are through with legacy probes, we are through with
> >init_etherdev(), we are practically through with static struct net_device.
> 
> hehe :)  I don't mean to suggest that all is clean and pure :)
> 
> 
> >However, we still have weird allocators (I've got almost all of them
> >done by now, will submit in the next batch) and we still have struct
> >net_device embedded as a field of other structures in several drivers.
> 
> Some of that will be interesting.  ns83820 for example embedded 
> net_device on purpose...  Ben seemed to think at the time it gave him 
> some speed, a few less pointer derefs and such.

That's fine, but 83820 should be doing that the other way round.

Note that for objects allocated by alloc_netdev() we have
	(char*) dev->priv == (char *)dev + const
and constant can be found at compile time _if_ we pad in front of
net_device and add a pointer to allocated block into net_device.

So we can have exactly the same structure (modulo padding) and no extra
dereferencing.  All we need is inlined void *net_priv(struct net_device *);

That, BTW, would be a win for other drivers using alloc_...() and not
reassigning ->priv (i.e. majority of those beasts).
