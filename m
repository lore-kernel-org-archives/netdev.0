From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC PATCH v1 1/2] lsm: Add hooks to the TUN driver
Date: Wed, 5 Aug 2009 09:13:50 -0500
Message-ID: <20090805141350.GA353@us.ibm.com>
References: <20090804211304.10798.65601.stgit@flek.lan> <20090804212158.10798.34592.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090804212158.10798.34592.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Paul Moore (paul.moore@hp.com):
...
>  static int tun_attach(struct tun_struct *tun, struct file *file)
>  {
>  	struct tun_file *tfile = file->private_data;
> -	const struct cred *cred = current_cred();
> -	int err;
> +	int err = 0;
> 
>  	ASSERT_RTNL();
> 
> -	/* Check permissions */
> -	if (((tun->owner != -1 && cred->euid != tun->owner) ||
> -	     (tun->group != -1 && !in_egroup_p(tun->group))) &&
> -		!capable(CAP_NET_ADMIN))
> -		return -EPERM;
...

> @@ -935,6 +930,13 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		else
>  			return -EINVAL;
> 
> +		if ((tun->owner != -1 && cred->euid != tun->owner) ||
> +		    (tun->group != -1 && !in_egroup_p(tun->group)))
> +			return -EPERM;
> +		err = security_tun_dev_attach(tun->sk);
> +		if (err < 0)
> +			return err;
> +

...

> +/**
> + * cap_tun_dev_attach - Determine if attaching to an TUN device is allowed
> + *
> + * Determine if the user is allowed to attach to an existing persistent TUN
> + * device, historically this has always required the CAP_NET_ADMIN permission.
> + */
> +int cap_tun_dev_attach(void)
> +{
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +	return 0;
> +}

The checks before and after this patch are not equivalent.  Post-patch,
one must always have CAP_NET_ADMIN to do the attach, whereas pre-patch
you only needed those if current_cred() did not own the tun device.  Is
that intentional?

Also as Eric said this patch needs to set the cap_ hooks.  This patch
isn't yet introducing the selinux hooks, so iiuc actually this patch should
always oops if CONFIG_SECURITY=y.

-serge
