From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Thu, 8 Aug 2002 18:42:06 +0100
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808184206.Q24631@parcelfarce.linux.theplanet.co.uk>
References: <20020808181717.P24631@parcelfarce.linux.theplanet.co.uk> <Mutt.LNX.4.44.0208090320010.20027-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, kuznet@ms2.inr.ac.ru, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0208090320010.20027-100000@blackbird.intercode.com.au>; from jmorris@intercode.com.au on Fri, Aug 09, 2002 at 03:26:10AM +1000
List-Id: netdev.vger.kernel.org

On Fri, Aug 09, 2002 at 03:26:10AM +1000, James Morris wrote:
> Yes, this patch is complete (see below), but is waiting on another fix to
> go in (which I sent you recently).  The unification of the ioctl code also
> now means SIOCSPGRP works exactly the same as F_SETOWN (i.e. it also works
> now for sigio).

this patch is for information purposes only, right?  ;-)

> diff -urN -X dontdiff linux-2.5.27.orig/fs/fcntl.c linux-2.5.27.w1/fs/fcntl.c
> --- linux-2.5.27.orig/fs/fcntl.c	Sun Jul 21 10:57:51 2002
> +++ linux-2.5.27.w1/fs/fcntl.c	Sun Jul 28 18:23:03 2002
> @@ -259,6 +259,18 @@
>  	return 0;
>  }
>  
> +long f_getown(struct file *filp)
> +{
> +	return filp->f_owner.pid;
> +}

i still think this function shouldn't exist -- a direct reference is
no problem.

>  		case F_SETOWN:
> -			lock_kernel();
> -			filp->f_owner.pid = arg;
> -			filp->f_owner.uid = current->uid;
> -			filp->f_owner.euid = current->euid;
>  			err = 0;
> -			if (S_ISSOCK (filp->f_dentry->d_inode->i_mode))
> -				err = sock_fcntl (filp, F_SETOWN, arg);
> +			lock_kernel();
> +			f_setown(filp, arg);
>  			unlock_kernel();

this is now hooked by the LSM folks so patch will need to be updated for
2.5.30.

> diff -urN -X dontdiff linux-2.5.27.orig/net/socket.c linux-2.5.27.w1/net/socket.c
> --- linux-2.5.27.orig/net/socket.c	Sat Jul  6 11:01:02 2002
> +++ linux-2.5.27.w1/net/socket.c	Sun Jul 28 22:08:37 2002
> +	switch(cmd) {
> +	case FIOSETOWN:
> +	case SIOCSPGRP:
> +		if (get_user(pid, (int *)arg))
> +			err = -EFAULT;
> +		else
> +			f_setown(sock->file, pid);
> +		break;

i'm pretty sure you need a lock_kernel + unlock_kernel around the else.
if two people are doing a F_SETOWN / SIOCSPGRP at the same time, you could
have a race.

-- 
Revolutions do not require corporate support.
