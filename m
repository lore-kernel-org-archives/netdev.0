From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen/xenbus: Use 'void' instead of 'int' for
 the return of xenbus_switch_state()
Date: Fri, 26 Sep 2014 19:07:19 +0100
Message-ID: <5425AB57.8040804@citrix.com>
References: <5425961A.5000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<konrad.wilk@oracle.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <boris.ostrovsky@oracle.com>,
	<bhelgaas@google.com>, <jgross@suse.com>,
	<yongjun_wei@trendmicro.com.cn>, <mukesh.rathor@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <5425961A.5000604@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/09/14 17:36, Chen Gang wrote:
> When xenbus_switch_state() fails, it will call xenbus_switch_fatal()
> internally, so need not return any status value, then use 'void' instead
> of 'int' for xenbus_switch_state() and __xenbus_switch_state().
> 
> Also need be sure that all callers which check the return value must let
> 'err' be 0.

I've rewritten the commit message as:

    xen/xenbus: don't return errors from xenbus_switch_state()

    Most users of xenbus_switch_state() weren't handling the failure of
    xenbus_switch_state() correctly.  They either called
    xenbus_dev_fatal() (which xenbus_switch_state() has effectively
    already tried to do), or ignored errors.

    xenbus_switch_state() may fail because:

    a) The device is being unplugged by the toolstack. The device will
    shortly be removed and the error does not need to be handled.

    b) Xenstore is broken.  There isn't much the driver can do in this
    case since xenstore is required to signal failure to the toolstack.

    So, don't report any errors from xenbus_switch_state() which removes
    some unnecessary error handling in some of the drivers.

I'd appreciate a review from some of the other front/backend driver
maintainers on whether this is sensible reasoning.

David

> 
> And also need change the related comments for xenbus_switch_state().
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  drivers/block/xen-blkback/xenbus.c |  9 ++-------
>  drivers/net/xen-netback/xenbus.c   |  5 +----
>  drivers/pci/xen-pcifront.c         | 15 ++++++---------
>  drivers/xen/xen-pciback/xenbus.c   | 21 ++++-----------------
>  drivers/xen/xen-scsiback.c         |  5 +----
>  drivers/xen/xenbus/xenbus_client.c | 16 ++++++++--------
>  include/xen/xenbus.h               |  3 ++-
>  7 files changed, 24 insertions(+), 50 deletions(-)
> 
> diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-blkback/xenbus.c
> index 3a8b810..fdcc584 100644
> --- a/drivers/block/xen-blkback/xenbus.c
> +++ b/drivers/block/xen-blkback/xenbus.c
> @@ -587,9 +587,7 @@ static int xen_blkbk_probe(struct xenbus_device *dev,
>  	if (err)
>  		goto fail;
>  
> -	err = xenbus_switch_state(dev, XenbusStateInitWait);
> -	if (err)
> -		goto fail;
> +	xenbus_switch_state(dev, XenbusStateInitWait);
>  
>  	return 0;
>  
> @@ -837,10 +835,7 @@ again:
>  	if (err)
>  		xenbus_dev_fatal(dev, err, "ending transaction");
>  
> -	err = xenbus_switch_state(dev, XenbusStateConnected);
> -	if (err)
> -		xenbus_dev_fatal(dev, err, "%s: switching to Connected state",
> -				 dev->nodename);
> +	xenbus_switch_state(dev, XenbusStateConnected);
>  
>  	return;
>   abort:
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
> diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
> index ca74410..e2bcd1d 100644
> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -166,7 +166,7 @@ EXPORT_SYMBOL_GPL(xenbus_watch_pathfmt);
>  static void xenbus_switch_fatal(struct xenbus_device *, int, int,
>  				const char *, ...);
>  
> -static int
> +static void
>  __xenbus_switch_state(struct xenbus_device *dev,
>  		      enum xenbus_state state, int depth)
>  {
> @@ -188,7 +188,7 @@ __xenbus_switch_state(struct xenbus_device *dev,
>  	int err, abort;
>  
>  	if (state == dev->state)
> -		return 0;
> +		return;
>  
>  again:
>  	abort = 1;
> @@ -196,7 +196,7 @@ again:
>  	err = xenbus_transaction_start(&xbt);
>  	if (err) {
>  		xenbus_switch_fatal(dev, depth, err, "starting transaction");
> -		return 0;
> +		return;
>  	}
>  
>  	err = xenbus_scanf(xbt, dev->nodename, "state", "%d", &current_state);
> @@ -219,7 +219,7 @@ abort:
>  	} else
>  		dev->state = state;
>  
> -	return 0;
> +	return;
>  }
>  
>  /**
> @@ -228,12 +228,12 @@ abort:
>   * @state: new state
>   *
>   * Advertise in the store a change of the given driver to the given new_state.
> - * Return 0 on success, or -errno on error.  On error, the device will switch
> - * to XenbusStateClosing, and the error will be saved in the store.
> + * When failure occurs, it will call xenbus_switch_fatal() internally, so need
> + * not return value to notify upper caller.
>   */
> -int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state state)
> +void xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state state)
>  {
> -	return __xenbus_switch_state(dev, state, 0);
> +	__xenbus_switch_state(dev, state, 0);
>  }
>  
>  EXPORT_SYMBOL_GPL(xenbus_switch_state);
> diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
> index 0324c6d..587c53d 100644
> --- a/include/xen/xenbus.h
> +++ b/include/xen/xenbus.h
> @@ -195,7 +195,8 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
>  					  const char **, unsigned int),
>  			 const char *pathfmt, ...);
>  
> -int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
> +void xenbus_switch_state(struct xenbus_device *dev,
> +			 enum xenbus_state new_state);
>  int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
>  int xenbus_map_ring_valloc(struct xenbus_device *dev,
>  			   int gnt_ref, void **vaddr);
> 
