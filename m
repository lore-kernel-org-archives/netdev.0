From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH updated] net: add ability to clear per-interface
 network statistics via procfs
Date: Fri, 16 May 2008 13:03:09 -0700 (PDT)
Message-ID: <20080516.130309.258561311.davem@davemloft.net>
References: <482DA5B6.1020606@sngx.net>
	<482DB46A.8020103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jimi@sngx.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbYEPUDP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:03:15 -0400
In-Reply-To: <482DB46A.8020103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 16 May 2008 18:20:58 +0200

netdev CC:'d, people please...  Eric, you in particular know
better :-)))

> James Cammarata a =E9crit :
> > From: James Cammarata <jimi@sngx.net>
> >
> > Added the ability to write to /proc/net/dev in order to clear the=20
> > interface counters for a given interface.  The ability to zero out=20
> > counters (especially the error counters) is extremely useful when=20
> > troubleshooting interface issues.  Now diffed against 2.6.25.4, and=
=20
> > added some sanity checking.
> >
> Hello James
>=20
> 1) Every call to get_proc_net() should be paired with a call to=20
> put_net(), or else you  leak  struct net.
>=20
> 2) I am not sure this is the right way to do this... Did you consider=
 to=20
> extend ethtool instead ?
>=20
> > Syntax:
> >  echo 'net clear-stats ifdev' > /proc/net/dev
> > Where "ifdev" is the device name you wish to clear.
> >
> > This code is based mainly on the code found in drivers/scsi/scsi_pr=
oc.c
> >
> > Signed-off-by: James Cammarata <jimi@sngx.net>
> > ---
> >
> > --- linux-2.6.25.4/net/core/dev.c       2008-05-15 10:00:12.0000000=
00=20
> > -0500
> > +++ linux-2.6.25.4-jcammara/net/core/dev.c      2008-05-16=20
> > 07:02:48.000000000 -0500
> > @@ -2455,2 +2455,78 @@
> >
> > +/**
> > + * proc_net_dev_write - handle writes to /proc/net/dev
> > + * @file: not used
> > + * @buf: buffer to write
> > + * @length: length of buf, at most PAGE_SIZE
> > + * @ppos: not used
> > + *
> > + * Description: this provides a mechanism to clear statistics on a
> > + * per-interface basis
> > + * "echo 'net clear-stats ifdev' >/proc/net/dev"
> > + * with  "ifdev" replaced by the device name you wish to clear.
> > + *
> > + */
> > +static ssize_t proc_net_dev_write(struct file *file, const char=20
> > __user *buf,
> > +                                  size_t length, loff_t *ppos)
> > +{
> > +        char *buffer, *p;
> > +        char devname[IFNAMSIZ];
> > +        struct net *net;
> > +        struct net_device *dev;
> > +        int err;
> > +
> > +        if (!buf || length > PAGE_SIZE)
> > +                return -EINVAL;
> > +
> > +        buffer =3D (char *)__get_free_page(GFP_KERNEL);
> > +        if (!buffer)
> > +                return -ENOMEM;
> > +
> > +        err =3D -EFAULT;
> > +        if (copy_from_user(buffer, buf, length))
> > +                goto out;
> > +
> > +        err =3D -EINVAL;
> > +        if (length < PAGE_SIZE)
> > +                buffer[length] =3D '\0';
> > +        else if (buffer[PAGE_SIZE-1])
> > +                goto out;
> > +
> > +        err =3D -ENXIO;
> > +        net =3D get_proc_net(file->f_dentry->d_inode);
> > +        if (!net)
> > +                goto out;
> > +
> > +        /*
> > +         * Usage: echo "net clear-stats ifdev" >/proc/net/dev
> > +         * with  "ifdev" replaced by the device name you wish to c=
lear.
> > +         */
> > +        if (!strncmp("net clear-stats",buffer,15)) {
> > +                p =3D buffer + 16;
> > +                if(sscanf(p,"%16s",devname)>0) {
> > +                        dev =3D dev_get_by_name(net,devname);
> > +                        if (dev) {
> > +                                if (dev->get_stats) {
> > +                                        struct net_device_stats *s=
tats =3D
> > +                                               dev->get_stats(dev)=
;
> > +                                        memset(stats,0,
> > +                                               sizeof(struct=20
> > net_device_stats));
> > +                                }
> > +                                dev_put(dev);
> > +                        }
> > +                }
> > +        }
> > +
> > +        /*
> > +         * convert success returns so that we return the
> > +         * number of bytes consumed.
> > +         */
> > +        if (!err)
> > +                err =3D length;
> > +
> Here probably, you should add
>=20
>     put_net(net);
>=20
> > + out:
> > +        free_page((unsigned long)buffer);
> > +        return err;
> > +}
> > +
> > static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
> > @@ -2498,2 +2574,3 @@
> >        .read    =3D seq_read,
> > +        .write   =3D proc_net_dev_write,
> >        .llseek  =3D seq_lseek,
> >
> >
>=20
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
