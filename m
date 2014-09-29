From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] xen/xenbus: Use 'void' instead of 'int' for the return
 of xenbus_switch_state()
Date: Mon, 29 Sep 2014 10:02:29 -0400
Message-ID: <20140929140229.GA28279@laptop.dumpdata.com>
References: <5425961A.5000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Vrabel <david.vrabel@citrix.com>, ian.campbell@citrix.com,
	wei.liu2@citrix.com, boris.ostrovsky@oracle.com,
	bhelgaas@google.com, jgross@suse.com,
	yongjun_wei@trendmicro.com.cn, mukesh.rathor@oracle.com,
	xen-devel@lists.xenproject.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5425961A.5000604@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 27, 2014 at 12:36:42AM +0800, Chen Gang wrote:
> When xenbus_switch_state() fails, it will call xenbus_switch_fatal()

Only on the first depth, not on the subsequent ones (as in if
the first xenbus_switch_fail fails, it won't try to call
xenbus_switch_state again and again).

> internally, so need not return any status value, then use 'void' instead
> of 'int' for xenbus_switch_state() and __xenbus_switch_state().

When that switch occurs (to XenbusStateConnected) won't the watches
fire - meaning we MUST make sure that the watch functions - if they
use the xenbus_switch_state() they MUST not hold any locks - because
they could be executed once more?

Oh wait, we don't have to worry about that right now as the callbacks
that pick up the messages from the XenBus are all gated on one mutex
anyhow.

Hm, anyhow, I would add this extra piece of information to the patch:


diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
index c214daa..f7399fd 100644
--- a/drivers/xen/xen-pciback/xenbus.c
+++ b/drivers/xen/xen-pciback/xenbus.c
@@ -661,6 +661,12 @@ static void xen_pcibk_be_watch(struct xenbus_watch *watch,
 
 	switch (xenbus_read_driver_state(pdev->xdev->nodename)) {
 	case XenbusStateInitWait:
+		/*
+		 * xenbus_switch_state can call xenbus_switch_fatal which will
+		 * immediately set the state to XenbusStateClosing which
+		 * means if we were reading for it here we MUST drop any
+		 * locks so that we don't dead-lock.
+		 */
 		xen_pcibk_setup_backend(pdev);
 		break;
 
> 
> Also need be sure that all callers which check the return value must let
> 'err' be 0.

I am bit uncomfortable with that, that is due to:


.. snip..
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 9c47b89..b5c3d47 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -337,10 +337,7 @@ static int netback_probe(struct xenbus_device *dev,
>  	if (err)
>  		pr_debug("Error writing multi-queue-max-queues\n");
>  
> -	err = xenbus_switch_state(dev, XenbusStateInitWait);
> -	if (err)
> -		goto fail;
> -
> +	xenbus_switch_state(dev, XenbusStateInitWait);

Which if it fails it won't call:

354 fail:                                                                           
355         pr_debug("failed\n");                                                   
356         netback_remove(dev);                                                    
357         return err;         


And since there is no watch on the backend state to go in Closing it won't
ever call those and we leak memory.

The same is for xen-blkback mechanism in the probe function.

>  	be->state = XenbusStateInitWait;
>  
>  	/* This kicks hotplug scripts, so do it immediately. */
> diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> index 53df39a..c1d73b7 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -901,18 +901,16 @@ static int pcifront_try_connect(struct pcifront_device *pdev)
>  		}
>  	}
>  
> -	err = xenbus_switch_state(pdev->xdev, XenbusStateConnected);
> -
> +	xenbus_switch_state(pdev->xdev, XenbusStateConnected);
> +	return 0;
>  out:
>  	return err;
>  }
>  
>  static int pcifront_try_disconnect(struct pcifront_device *pdev)
>  {
> -	int err = 0;
>  	enum xenbus_state prev_state;
>  
> -
>  	prev_state = xenbus_read_driver_state(pdev->xdev->nodename);
>  
>  	if (prev_state >= XenbusStateClosing)
> @@ -923,11 +921,10 @@ static int pcifront_try_disconnect(struct pcifront_device *pdev)
>  		pcifront_disconnect(pdev);
>  	}
>  
> -	err = xenbus_switch_state(pdev->xdev, XenbusStateClosed);
> +	xenbus_switch_state(pdev->xdev, XenbusStateClosed);
>  
>  out:
> -
> -	return err;
> +	return 0;
>  }
>  
>  static int pcifront_attach_devices(struct pcifront_device *pdev)
> @@ -1060,8 +1057,8 @@ static int pcifront_detach_devices(struct pcifront_device *pdev)
>  			domain, bus, slot, func);
>  	}
>  
> -	err = xenbus_switch_state(pdev->xdev, XenbusStateReconfiguring);
> -
> +	xenbus_switch_state(pdev->xdev, XenbusStateReconfiguring);
> +	return 0;
>  out:
>  	return err;
>  }
> diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
> index c214daa..630a215 100644

The xen-pcifront are OK, this one:

> --- a/drivers/xen/xen-pciback/xenbus.c
> +++ b/drivers/xen/xen-pciback/xenbus.c
> @@ -184,10 +184,7 @@ static int xen_pcibk_attach(struct xen_pcibk_device *pdev)
>  
>  	dev_dbg(&pdev->xdev->dev, "Connecting...\n");
>  
> -	err = xenbus_switch_state(pdev->xdev, XenbusStateConnected);
> -	if (err)
> -		xenbus_dev_fatal(pdev->xdev, err,
> -				 "Error switching to connected state!");
> +	xenbus_switch_state(pdev->xdev, XenbusStateConnected);


This one is OK
>  
>  	dev_dbg(&pdev->xdev->dev, "Connected? %d\n", err);
>  out:
> @@ -500,12 +497,7 @@ static int xen_pcibk_reconfigure(struct xen_pcibk_device *pdev)
>  		}
>  	}
>  
> -	err = xenbus_switch_state(pdev->xdev, XenbusStateReconfigured);
> -	if (err) {
> -		xenbus_dev_fatal(pdev->xdev, err,
> -				 "Error switching to reconfigured state!");
> -		goto out;
> -	}
> +	xenbus_switch_state(pdev->xdev, XenbusStateReconfigured);

That is OKish, thought I am not too happy about us holding the lock.
>  
>  out:
>  	mutex_unlock(&pdev->dev_lock);
> @@ -640,10 +632,7 @@ static int xen_pcibk_setup_backend(struct xen_pcibk_device *pdev)
>  		goto out;
>  	}
>  
> -	err = xenbus_switch_state(pdev->xdev, XenbusStateInitialised);
> -	if (err)
> -		xenbus_dev_fatal(pdev->xdev, err,
> -				 "Error switching to initialised state!");
> +	xenbus_switch_state(pdev->xdev, XenbusStateInitialised);

And this one needs that comment above about the mutex.
>  
>  out:
>  	mutex_unlock(&pdev->dev_lock);
> @@ -683,9 +672,7 @@ static int xen_pcibk_xenbus_probe(struct xenbus_device *dev,
>  	}
>  
>  	/* wait for xend to configure us */
> -	err = xenbus_switch_state(dev, XenbusStateInitWait);
> -	if (err)
> -		goto out;
> +	xenbus_switch_state(dev, XenbusStateInitWait);

That means the error that is returned on 'probe' is always zero. I don't
think that is right as we did fail to establish a connection.

>  
>  	/* watch the backend node for backend configuration information */
>  	err = xenbus_watch_path(dev, dev->nodename, &pdev->be_watch,
> diff --git a/drivers/xen/xen-scsiback.c b/drivers/xen/xen-scsiback.c
> index ad11258..847bc9c 100644
> --- a/drivers/xen/xen-scsiback.c
> +++ b/drivers/xen/xen-scsiback.c
> @@ -1225,10 +1225,7 @@ static int scsiback_probe(struct xenbus_device *dev,
>  	if (err)
>  		xenbus_dev_error(dev, err, "writing feature-sg-grant");
>  
> -	err = xenbus_switch_state(dev, XenbusStateInitWait);
> -	if (err)
> -		goto fail;
> -
> +	xenbus_switch_state(dev, XenbusStateInitWait);
>  	return 0;
>  
>  fail:
