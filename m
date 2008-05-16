From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH updated] net: add ability to clear per-interface
 network statistics via procfs
Date: Fri, 16 May 2008 13:00:04 -0700 (PDT)
Message-ID: <20080516.130004.18881610.davem@davemloft.net>
References: <482DA5B6.1020606@sngx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jimi@sngx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751331AbYEPUAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:00:09 -0400
In-Reply-To: <482DA5B6.1020606@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Cammarata <jimi@sngx.net>
Date: Fri, 16 May 2008 10:18:14 -0500

We saw your initial patch posting, you don't need to send this
again.

netdev added to CC:

> From: James Cammarata <jimi@sngx.net>
> 
> Added the ability to write to /proc/net/dev in order to clear the interface counters for a given interface.  The ability to zero out counters (especially the error counters) is extremely useful when troubleshooting interface issues.  Now diffed against 2.6.25.4, and added some sanity checking.
> 
> Syntax:
>   echo 'net clear-stats ifdev' > /proc/net/dev
> Where "ifdev" is the device name you wish to clear.
> 
> This code is based mainly on the code found in drivers/scsi/scsi_proc.c
> 
> Signed-off-by: James Cammarata <jimi@sngx.net>
> ---
> 
> --- linux-2.6.25.4/net/core/dev.c       2008-05-15 10:00:12.000000000 -0500
> +++ linux-2.6.25.4-jcammara/net/core/dev.c      2008-05-16 07:02:48.000000000 -0500
> @@ -2455,2 +2455,78 @@
> 
> +/**
> + * proc_net_dev_write - handle writes to /proc/net/dev
> + * @file: not used
> + * @buf: buffer to write
> + * @length: length of buf, at most PAGE_SIZE
> + * @ppos: not used
> + *
> + * Description: this provides a mechanism to clear statistics on a
> + * per-interface basis
> + * "echo 'net clear-stats ifdev' >/proc/net/dev"
> + * with  "ifdev" replaced by the device name you wish to clear.
> + *
> + */
> +static ssize_t proc_net_dev_write(struct file *file, const char __user *buf,
> +                                  size_t length, loff_t *ppos)
> +{
> +        char *buffer, *p;
> +        char devname[IFNAMSIZ];
> +        struct net *net;
> +        struct net_device *dev;
> +        int err;
> +
> +        if (!buf || length > PAGE_SIZE)
> +                return -EINVAL;
> +
> +        buffer = (char *)__get_free_page(GFP_KERNEL);
> +        if (!buffer)
> +                return -ENOMEM;
> +
> +        err = -EFAULT;
> +        if (copy_from_user(buffer, buf, length))
> +                goto out;
> +
> +        err = -EINVAL;
> +        if (length < PAGE_SIZE)
> +                buffer[length] = '\0';
> +        else if (buffer[PAGE_SIZE-1])
> +                goto out;
> +
> +        err = -ENXIO;
> +        net = get_proc_net(file->f_dentry->d_inode);
> +        if (!net)
> +                goto out;
> +
> +        /*
> +         * Usage: echo "net clear-stats ifdev" >/proc/net/dev
> +         * with  "ifdev" replaced by the device name you wish to clear.
> +         */
> +        if (!strncmp("net clear-stats",buffer,15)) {
> +                p = buffer + 16;
> +                if(sscanf(p,"%16s",devname)>0) {
> +                        dev = dev_get_by_name(net,devname);
> +                        if (dev) {
> +                                if (dev->get_stats) {
> +                                        struct net_device_stats *stats =
> +                                               dev->get_stats(dev);
> +                                        memset(stats,0,
> +                                               sizeof(struct net_device_stats));
> +                                }
> +                                dev_put(dev);
> +                        }
> +                }
> +        }
> +
> +        /*
> +         * convert success returns so that we return the
> +         * number of bytes consumed.
> +         */
> +        if (!err)
> +                err = length;
> +
> + out:
> +        free_page((unsigned long)buffer);
> +        return err;
> +}
> +
>  static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
> @@ -2498,2 +2574,3 @@
>         .read    = seq_read,
> +        .write   = proc_net_dev_write,
>         .llseek  = seq_lseek,
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
