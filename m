From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] skfddi - convert to new pci model.
Date: Tue, 16 Dec 2003 00:43:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031216054326.GA8825@gtf.org>
References: <20031204163928.0f34d5d1.shemminger@osdl.org> <20031205005915.GD31510@devserv.devel.redhat.com> <20031205151249.44a067df.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Viro <aviro@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031205151249.44a067df.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 03:12:49PM -0800, Stephen Hemminger wrote:
> Second revision of the cleanup of skfddi driver.
>  * use new pci device bus initialization
>  * allocate network device with alloc_fddidev
>     and use dev->priv
>   * get rid of special module/non module distinctions.
> 
>   * fix error unwinds and return values on initialization
>   * call driver_init directly not via register_netdev
>   * reset internal queue count after purge
>   * get rid of h[iy]sterical comment that is no longer true
> 
> diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
> --- a/drivers/net/skfp/skfddi.c	Fri Dec  5 14:49:12 2003
> +++ b/drivers/net/skfp/skfddi.c	Fri Dec  5 14:49:12 2003
> @@ -39,12 +39,6 @@
>   *   are skfddi.c, h/types.h, h/osdef1st.h, h/targetos.h.
>   *   The others belong to the SysKonnect FDDI Hardware Module and
>   *   should better not be changed.
> - * NOTE:
> - *   Compiling this driver produces some warnings, but I did not fix
> - *   this, because the Hardware Module source is used for different
> - *   drivers, and fixing it for Linux might bring problems on other
> - *   projects. To keep the source common for all those drivers (and
> - *   thus simplify fixes to it), please do not clean it up!
>   *
>   * Modification History:
>   *              Date            Name    Description
> @@ -58,6 +52,7 @@
>   *		07-May-00	DM	64 bit fixes, new dma interface
>   *		31-Jul-03	DB	Audit copy_*_user in skfp_ioctl
>   *					  Daniele Bellucci <bellucda@tiscali.it>
> + *		03-Dec-03	SH	Convert to PCI device model
>   *
>   * Compilation options (-Dxxx):
>   *              DRIVERDEBUG     print lots of messages to log file
> @@ -70,7 +65,7 @@
>  
>  /* Version information string - should be updated prior to */
>  /* each new release!!! */
> -#define VERSION		"2.06"
> +#define VERSION		"2.07"
>  
>  static const char *boot_msg = 
>  	"SysKonnect FDDI PCI Adapter driver v" VERSION " for\n"
> @@ -80,15 +75,11 @@
>  
>  #include <linux/module.h>
>  #include <linux/kernel.h>
> -#include <linux/string.h>
> -#include <linux/ptrace.h>
>  #include <linux/errno.h>
>  #include <linux/ioport.h>
>  #include <linux/slab.h>
>  #include <linux/interrupt.h>
>  #include <linux/pci.h>
> -#include <linux/delay.h>
> -#include <linux/ctype.h>	// isdigit
>  #include <linux/netdevice.h>
>  #include <linux/fddidevice.h>
>  #include <linux/skbuff.h>
> @@ -107,11 +98,6 @@
>  
>  
>  // Define module-wide (static) routines
> -static struct net_device *alloc_device(struct net_device *dev, u_long iobase);
> -static struct net_device *insert_device(struct net_device *dev);
> -static int fddi_dev_index(unsigned char *s);
> -static void init_dev(struct net_device *dev, u_long iobase);
> -static void link_modules(struct net_device *dev, struct net_device *tmp);
>  static int skfp_driver_init(struct net_device *dev);
>  static int skfp_open(struct net_device *dev);
>  static int skfp_close(struct net_device *dev);
> @@ -188,15 +174,6 @@
>  // Define module-wide (static) variables
>  
>  static int num_boards;	/* total number of adapters configured */
> -static int num_fddi;
> -static int autoprobed;
> -
> -#ifdef MODULE
> -static struct net_device *unlink_modules(struct net_device *p);
> -static int loading_module = 1;
> -#else
> -static int loading_module;
> -#endif				// MODULE
>  
>  #ifdef DRIVERDEBUG
>  #define PRINTK(s, args...) printk(s, ## args)
> @@ -207,9 +184,9 @@
>  #define PRIV(dev) (&(((struct s_smc *)dev->priv)->os))
>  
>  /*
> - * ==============
> - * = skfp_probe =
> - * ==============
> + * =================
> + * = skfp_init_one =
> + * =================
>   *   
>   * Overview:
>   *   Probes for supported FDDI PCI controllers
> @@ -218,30 +195,11 @@
>   *   Condition code
>   *       
>   * Arguments:
> - *   dev - pointer to device information
> + *   pdev - pointer to PCI device information
>   *
>   * Functional Description:
> - *   This routine is called by the OS for each FDDI device name (fddi0,
> - *   fddi1,...,fddi6, fddi7) specified in drivers/net/Space.c.
> - *   If loaded as a module, it will detect and initialize all 
> - *   adapters the first time it is called.
> - *
> - *   Let's say that skfp_probe() is getting called to initialize fddi0.
> - *   Furthermore, let's say there are three supported controllers in the
> - *   system.  Before skfp_probe() leaves, devices fddi0, fddi1, and fddi2
> - *   will be initialized and a global flag will be set to indicate that
> - *   skfp_probe() has already been called.
> - *
> - *   However...the OS doesn't know that we've already initialized
> - *   devices fddi1 and fddi2 so skfp_probe() gets called again and again
> - *   until it reaches the end of the device list for FDDI (presently,
> - *   fddi7).  It's important that the driver "pretend" to probe for
> - *   devices fddi1 and fddi2 and return success.  Devices fddi3
> - *   through fddi7 will return failure since they weren't initialized.
> - *
> - *   This algorithm seems to work for the time being.  As other FDDI
> - *   drivers are written for Linux, a more generic approach (perhaps
> - *   similar to the Ethernet card approach) may need to be implemented.
> + *   This is now called by PCI driver registration process
> + *   for each board found.
>   *   
>   * Return Codes:
>   *   0           - This device (fddi0, fddi1, etc) configured successfully
> @@ -254,370 +212,176 @@
>   *   initialized and the board resources are read and stored in
>   *   the device structure.
>   */
> -static int skfp_probe(struct net_device *dev)
> +static __init int skfp_init_one(struct pci_dev *pdev,

I take back my private email... patch doesn't apply.

Can you please rediff, and also remove the above "__init" ?

	Jeff
