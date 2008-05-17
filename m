From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH updated] net: add ability to clear per-interface network
 statistics via procfs
Date: Sat, 17 May 2008 23:41:39 +0200
Message-ID: <482F5113.5090703@cosmosbay.com>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.94]:23635 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759638AbYEQVlz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 17:41:55 -0400
In-Reply-To: <482EF192.4070707@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Cammarata a =E9crit :
>> 1) Every call to get_proc_net() should be paired with a call to=20
>> put_net(), or else you  leak  struct net.
>
> My mistake, I will add this and resubmit.
>
This version has a bug, please check again.
>> 2) I am not sure this is the right way to do this... Did you conside=
r=20
>> to extend ethtool instead ?
>
> Yes, I did consider that.  My reasoning for adding it to procfs is=20
> that each
> driver defines their own ethtool interface, so it was much simpler to=
=20
> add it here, with a lot less code changes and broader support.
>
Maybe much simpler but looks like a hack...
>
> ---
>
> --- linux-2.6.25.4/net/core/dev.c       2008-05-15 10:00:12.000000000=
=20
> -0500
> +++ linux-2.6.25.4-jcammara/net/core/dev.c      2008-05-17=20
> 09:50:22.000000000 -0500
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
> +static ssize_t proc_net_dev_write(struct file *file, const char=20
> __user *buf,
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
> +        buffer =3D (char *)__get_free_page(GFP_KERNEL);
> +        if (!buffer)
> +                return -ENOMEM;
> +
> +        err =3D -EFAULT;
> +        if (copy_from_user(buffer, buf, length))
net is not initialized so you will call put_net(garbage) and crash

My suggestion was better, since you dont have to test if (net) ,
just call put_net(net) at the right place (before out: label)
> +                goto out;
> +
> +        err =3D -EINVAL;
> +        if (length < PAGE_SIZE)
> +                buffer[length] =3D '\0';
> +        else if (buffer[PAGE_SIZE-1])
> +                goto out;
> +
> +        err =3D -ENXIO;
> +        net =3D get_proc_net(file->f_dentry->d_inode);
> +        if (!net)
> +                goto out;
> +
> +        /*
> +         * Usage: echo "net clear-stats ifdev" >/proc/net/dev
> +         * with  "ifdev" replaced by the device name you wish to cle=
ar.
> +         */
> +        if (!strncmp("net clear-stats",buffer,15)) {
> +                p =3D buffer + 16;
> +                if(sscanf(p,"%16s",devname)>0) {
> +                        dev =3D dev_get_by_name(net,devname);
> +                        if (dev) {
> +                                if (dev->get_stats) {
> +                                        struct net_device_stats *sta=
ts =3D
> +                                               dev->get_stats(dev);
> +                                        memset(stats,0,
> +                                               sizeof(struct=20
> net_device_stats));
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
> +                err =3D length;
> +
> + out:
> +        if(net)
> +                put_net(net);
> +        free_page((unsigned long)buffer);
> +        return err;
> +}
> +
> static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
> @@ -2498,2 +2576,3 @@
>        .read    =3D seq_read,
> +        .write   =3D proc_net_dev_write,
>        .llseek  =3D seq_lseek,
>
>




