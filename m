From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH updated] net: add ability to clear per-interface network statistics via procfs
Date: Sun, 18 May 2008 01:31:05 +0100
Message-ID: <20080518003104.GK28241@solarflare.com>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net> <482F5113.5090703@cosmosbay.com> <482F610D.2080108@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760288AbYERAbg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <482F610D.2080108@sngx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Cammarata wrote:
> >This version has a bug, please check again.
> 
> Gah, you're right, fixed below.
> 
> ---
> 
> --- linux-2.6.25.4/net/core/dev.c       2008-05-15 10:00:12.000000000 -0500
> +++ linux-2.6.25.4-jcammara/net/core/dev.c      2008-05-17 
> 17:45:57.000000000 -0500
> @@ -2455,2 +2455,80 @@
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
> +static ssize_t proc_net_dev_write(struct file *file, const char __user 
> *buf,

You need to stop your mail client word-wrapping patches.  It looks like
something has converted tabs to spaces, too.

[...]
> +        /*
> +         * Usage: echo "net clear-stats ifdev" >/proc/net/dev
> +         * with  "ifdev" replaced by the device name you wish to clear.
> +         */

This is redundant with the kernel-doc comment.

> +        if (!strncmp("net clear-stats",buffer,15)) {

This doesn't check for a space after, which you rely on later on.  (What if
length == 15?)  Also, explicitly writing the length of a literal string is
error-prone.  Seems like it would be better to do something like:

	static const char command[] = "net clear-stats ";
        ...
        if (!strncmp(command, buffer, sizeof(command) - 1)) {

> +                p = buffer + 16;
> +                if(sscanf(p,"%16s",devname)>0) {
> +                        dev = dev_get_by_name(net,devname);
> +                        if (dev) {
> +                                if (dev->get_stats) {
> +                                        struct net_device_stats *stats =
> +                                               dev->get_stats(dev);
> +                                        memset(stats,0,
> +                                               sizeof(struct 
> net_device_stats));
> +                                }
> +                                dev_put(dev);
> +                        }

Shouldn't this return an error if the device doesn't exist?

> +                }
> +        }
> +
> +        /*
> +         * convert success returns so that we return the
> +         * number of bytes consumed.
> +         */
> +        if (!err)
> +                err = length;

This won't work; the function updates err unconditionally further up!

> +
> +        put_net(net);
> +
> + out:
> +        free_page((unsigned long)buffer);
> +        return err;
> +}
> +
> static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
> @@ -2498,2 +2576,3 @@
>        .read    = seq_read,
> +        .write   = proc_net_dev_write,
>        .llseek  = seq_lseek,

The context for this chunk seems to be too short.

There are a few formatting oddities; checkpatch.pl will point them out.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
