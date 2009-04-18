From: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Subject: Re: [1/2] tun: Only free a netdev when all tun descriptors are
	closed
Date: Sat, 18 Apr 2009 22:09:39 +0300
Message-ID: <20090418190937.GA7799@dhcp-1-124.tlv.redhat.com>
References: <20090416195745.GA5826@dhcp-1-124.tlv.redhat.com> <20090417000923.GE29988@gondor.apana.org.au>
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
Received: from fg-out-1718.google.com ([72.14.220.158]:11677 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbZDRTKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 15:10:49 -0400
Received: by fg-out-1718.google.com with SMTP id 22so68976fge.17
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 12:10:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090417000923.GE29988@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 08:09:23AM +0800, Herbert Xu wrote:
> On Thu, Apr 16, 2009 at 10:57:45PM +0300, Michael S. Tsirkin wrote:
> >
> > This last bit seems to make a simple test using a non-persistent tap device
> > deadlock for me: we don't drop a reference acquired with __tun_get sock
> > unregister_netdevice blocks printing unregister_netdevice: waiting for tap0 to
> > become free. Usage count = 1.
> 
> Ah yes, I'd overlooked the fact that the original code didn't
> require the tfile refcount to hit zero.  Now we do.  Here's an
> updated version of the first patch.  The second patch should still
> work as is.
> 
> tun: Only free a netdev when all tun descriptors are closed

...

> @@ -1275,20 +1278,17 @@ static int tun_chr_close(struct inode *inode, struct file *file)
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
> +		tun_put(tun);
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

Does this work with TUN_PERSIST off?
I haven't tested this, but won't unregister_netdev block forever
waiting for device reference to become 0? Maybe you want

+		tun_put(tun);
+		if (!(tun->flags & TUN_PERSIST))
+			unregister_netdev(tun->dev);

or is there a race here?

-- 
MST
