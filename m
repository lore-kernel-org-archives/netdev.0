From: Hanna Linder <hannal@us.ibm.com>
Subject: Re: [PATCH 2.6] Patch to hook up PPP to simple class sysfs support
Date: Thu, 04 Mar 2004 18:05:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <42870000.1078452314@w-hlinder.beaverton.ibm.com>
References: <200403032328.i23NSwlv009796@orion.dwf.com> <22370000.1078362205@w-hlinder.beaverton.ibm.com> <20040303195539.S22989@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Hanna Linder <hannal@us.ibm.com>, linux-kernel@vger.kernel.org,
        greg@kroah.com, paulus@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20040303195539.S22989@build.pdx.osdl.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Thanks Chris. Your changes fixed the reload oops I was seeing.

root@w-hlinder2 root]# modprobe ppp_generic
[root@w-hlinder2 root]# tree /sys/class/ppp
/sys/class/ppp
`-- ppp
    `-- dev

1 directory, 1 file
[root@w-hlinder2 root]# rmmod ppp_generic
[root@w-hlinder2 root]# tree /sys/class/ppp
/sys/class/ppp [error opening dir]

0 directories, 0 files
[root@w-hlinder2 root]# modprobe ppp_generic
[root@w-hlinder2 root]# tree /sys/class/ppp
/sys/class/ppp
`-- ppp
    `-- dev

1 directory, 1 file

Please consider the patch below for inclusion.

Thanks.


--On Wednesday, March 03, 2004 07:55:39 PM -0800 Chris Wright <chrisw@osdl.org> wrote:

> 
> something like below.
> 
> thanks,
> -chris
> 
> ===== drivers/net/ppp_generic.c 1.43 vs edited =====
> --- 1.43/drivers/net/ppp_generic.c	Wed Feb 18 19:42:37 2004
> +++ edited/drivers/net/ppp_generic.c	Wed Mar  3 19:08:24 2004
> @@ -45,6 +45,7 @@
>  #include <linux/smp_lock.h>
>  #include <linux/rwsem.h>
>  #include <linux/stddef.h>
> +#include <linux/device.h>
>  #include <net/slhc_vj.h>
>  #include <asm/atomic.h>
>  
> @@ -271,6 +272,8 @@
>  static int ppp_disconnect_channel(struct channel *pch);
>  static void ppp_destroy_channel(struct channel *pch);
>  
> +static struct class_simple *ppp_class;
> +
>  /* Translates a PPP protocol number to a NP index (NP == network protocol) */
>  static inline int proto_to_npindex(int proto)
>  {
> @@ -804,15 +807,29 @@
>  	printk(KERN_INFO "PPP generic driver version " PPP_VERSION "\n");
>  	err = register_chrdev(PPP_MAJOR, "ppp", &ppp_device_fops);
>  	if (!err) {
> +		ppp_class = class_simple_create(THIS_MODULE, "ppp");
> +		if (IS_ERR(ppp_class)) {
> +			err = PTR_ERR(ppp_class);
> +			goto out_chrdev;
> +		}
> +		class_simple_device_add(ppp_class, MKDEV(PPP_MAJOR, 0), NULL, "ppp");
>  		err = devfs_mk_cdev(MKDEV(PPP_MAJOR, 0),
>  				S_IFCHR|S_IRUSR|S_IWUSR, "ppp");
>  		if (err)
> -			unregister_chrdev(PPP_MAJOR, "ppp");
> +			goto out_class;
>  	}
>  
> +out:
>  	if (err)
>  		printk(KERN_ERR "failed to register PPP device (%d)\n", err);
>  	return err;
> +
> +out_class:
> +	class_simple_device_remove(MKDEV(PPP_MAJOR,0));
> +	class_simple_destroy(ppp_class);
> +out_chrdev:
> +	unregister_chrdev(PPP_MAJOR, "ppp");
> +	goto out;
>  }
>  
>  /*
> @@ -2545,6 +2562,8 @@
>  	if (unregister_chrdev(PPP_MAJOR, "ppp") != 0)
>  		printk(KERN_ERR "PPP: failed to unregister PPP device\n");
>  	devfs_remove("ppp");
> +	class_simple_device_remove(MKDEV(PPP_MAJOR, 0));
> +	class_simple_destroy(ppp_class);
>  }
>  
>  /*
> 
