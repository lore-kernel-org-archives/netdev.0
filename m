From: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Subject: Re: [1/2] tun: Only free a netdev when all tun descriptors are
	closed
Date: Thu, 16 Apr 2009 22:57:45 +0300
Message-ID: <20090416195745.GA5826@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:61600 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756883AbZDPT6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:58:55 -0400
Received: by fxm2 with SMTP id 2so600576fxm.37
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 12:58:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 01:08:18AM -0000, Herbert Xu wrote:
> On Wed, Apr 15, 2009 at 10:38:34PM +0800, Herbert Xu wrote:
> > 
> > So how about this? We replace the dev destructor with our own that
> > doesn't immediately call free_netdev.  We only call free_netdev once
> > all tun fd's attached to the device have been closed.
> 
> Here's the patch.  I'd appreciate if everyone can review it
> and see if they can recreate the original race by
> 
> 1) Starting a process using tun and polls on it;
> 2) Doing ip tun del tunXXX while the process is polling.
> 
> tun: Only free a netdev when all tun descriptors are closed
> 
> The commit c70f182940f988448f3c12a209d18b1edc276e33 ("tun: Fix
> races between tun_net_close and free_netdev") fixed a race where
> an asynchronous deletion of a tun device can hose a poll(2) on
> a tun fd attached to that device.
> 
> However, this came at the cost of moving the tun wait queue into
> the tun file data structure.  The problem with this is that it
> imposes restrictions on when and where the tun device can access
> the wait queue since the tun file may change at any time due to
> detaching and reattaching.
> 
> In particular, now that we need to use the wait queue on the
> receive path it becomes difficult to properly synchronise this
> with the detachment of the tun device.
> 
> This patch solves the original race in a different way.  Since
> the race is only because the underlying memory gets freed, we
> can prevent it simply by ensuring that we don't do that until
> all tun descriptors ever attached to the device (even if they
> have since be detached because they may still be sitting in poll)
> have been closed.
> 
> This is done by using reference counting the attached tun file
> descriptors.  The refcount in tun->sk has been reappropriated
> for this purpose since it was already being used for that, albeit
> from the opposite angle.
> 
> Note that we no longer zero tfile->tun since tun_get will return
> NULL anyway after the refcount on tfile hits zero.  Instead it
> represents whether this device has ever been attached to a device.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> 
> Cheers,
> 
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> 
> .....
>
> @@ -1275,20 +1278,18 @@ static int tun_chr_close(struct inode *inode, struct file *file)
>  	struct tun_file *tfile = file->private_data;
>  	struct tun_struct *tun = __tun_get(tfile);
>  
> -
>  	if (tun) {
> -		DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
> -
> -		rtnl_lock();
> -		__tun_detach(tun);
> -
>  		/* If desireable, unregister the netdevice. */
> -		if (!(tun->flags & TUN_PERSIST)) {
> -			sock_put(tun->sk);
> -			unregister_netdevice(tun->dev);
> -		}
> +		if (!(tun->flags & TUN_PERSIST))
> +			unregister_netdev(tun->dev);
> +		else
> +			tun_put(tun);
> +	} else
> +		tun = tfile->tun;
>  
> -		rtnl_unlock();
> +	if (tun) {
> +		DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
> +		sock_put(tun->sk);
>  	}
>  
>  	put_net(tfile->net);

This last bit seems to make a simple test using a non-persistent tap device
deadlock for me: we don't drop a reference acquired with __tun_get sock
unregister_netdevice blocks printing unregister_netdevice: waiting for tap0 to
become free. Usage count = 1.


