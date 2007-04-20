From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take4 6/6] add ioctls for adding/removing
 target
Date: Thu, 19 Apr 2007 22:39:09 -0700
Message-ID: <20070419223909.00e8285d@localhost.localdomain>
References: <462605DC.2080804@bx.jp.nec.com>
	<46260BBF.2070202@bx.jp.nec.com>
	<20070419211630.70c20706.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, mpm@selenic.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47042 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161218AbXDTFkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 01:40:51 -0400
In-Reply-To: <20070419211630.70c20706.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Apr 2007 21:16:30 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 18 Apr 2007 21:14:55 +0900 Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> 
> > From: Keiichi KII <k-keiichi@bx.jp.nec.com>
> > 
> > We add ioctls for adding/removing target.
> > If we use NETCONSOLE_ADD_TARGET ioctl, 
> > we can dynamically add netconsole target.
> > If we use NETCONSOLE_REMOVE_TARGET ioctl,
> > we can dynamically remoe netconsole target.
> > 
> > ...
> >
> > --- mm.orig/drivers/net/netconsole.c
> > +++ mm/drivers/net/netconsole.c
> > @@ -47,6 +47,7 @@
> >  #include <linux/netpoll.h>
> >  #include <linux/miscdevice.h>
> >  #include <linux/inet.h>
> > +#include <linux/netconsole.h>
> >  
> >  MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
> >  MODULE_DESCRIPTION("Console driver for network interfaces");
> > @@ -313,6 +314,64 @@ static void release_target(struct kobjec
> >  	remove_target(nt);
> >  }
> >  
> > +static int netconsole_ioctl(struct inode *inode, struct file *file,
> > +			    unsigned int cmd, unsigned long arg)
> > +{
> > +	int id, count;
> > +	char config[256];
> > +	char *cur;
> > +	struct netconsole_request req;
> > +	struct netconsole_target *nt, *tmp;
> > +	void __user *argp = (void __user *)arg;
> > +
> > +	switch (cmd) {
> > +	case NETCON_ADD_TARGET:
> > +		printk(KERN_INFO "netconsole: cmd=NETCON_ADD_TARGET\n");
> > +		if (copy_from_user(&req, argp, sizeof(req)))
> > +			return -EFAULT;
> > +		cur = config;
> > +		count = sprintf(cur, "%d@", req.local_port);
> > +		cur += count;
> > +		if (req.local_ip)
> > +			count = sprintf(cur, "%d.%d.%d.%d/",
> > +					NIPQUAD(req.local_ip));
> > +		else
> > +			count = sprintf(cur, "/");
> > +		cur += count;
> > +		count = sprintf(cur, "%s,", req.netdev_name);
> > +		cur += count;
> > +		count = sprintf(cur, "%d@", req.remote_port);
> > +		cur += count;
> > +		count = sprintf(cur, "%d.%d.%d.%d/",
> > +				NIPQUAD(req.remote_ip));
> > +		cur += count;
> > +		count = sprintf(cur, "%02x:%02x:%02x:%02x:%02x:%02x",
> > +				req.remote_mac[0], req.remote_mac[1],
> > +				req.remote_mac[2], req.remote_mac[3],
> > +				req.remote_mac[4], req.remote_mac[5]);
> > +		printk(KERN_INFO "count = %d config=[%s]\n", count, config);
> > +		if (add_target(config))
> > +			return -EINVAL;
> > +		break;
> > +	case NETCON_REMOVE_TARGET:
> > +		printk(KERN_INFO "netconsole: cmd=NETCON_REMOVE_TARGET\n");
> > +		if (copy_from_user(&id, argp, sizeof(int)))
> > +			return -EFAULT;
> > +		printk(KERN_INFO "netconsole: id=%d\n", id);
> > +		list_for_each_entry_safe(nt, tmp, &target_list, list) {
> > +			if (nt->id == id) {
> > +				kobject_unregister(&nt->obj);
> > +				break;
> > +			}
> > +		}
> > +		break;
> > +	default:
> > +		return -ENOTTY;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> >  static struct sysfs_ops target_sysfs_ops = {
> >  	.show = show_target_attr,
> >  	.store = store_target_attr
> > @@ -324,9 +383,14 @@ static struct kobj_type target_ktype = {
> >  	.default_attrs = target_attrs,
> >  };
> >  
> > +static struct file_operations miscdev_fops = {
> > +	.ioctl = netconsole_ioctl,
> > +};
> > +
> >  static struct miscdevice netconsole_miscdev = {
> >  	.minor = MISC_DYNAMIC_MINOR,
> >  	.name = "netconsole",
> > +	.fops = &miscdev_fops,
> >  };
> >  
> >  static struct notifier_block netconsole_notifier = {
> 
> We'll need to wake up the net guys to get an opinion here.  Using an
> ioctl() against a miscdev is rather untypical for networking.  I'd expect
> they'd prefer to see a netlink-based interface to userspace.

Should't this just be a network ioctl against an UDP (AF_INET, SOCK_DGRAM) socket?
Also consider netconsole over IPV6 for future enhancement.
