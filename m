From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket should
 return ENOTTY
Date: Wed, 27 Apr 2011 13:09:04 +0100
Message-ID: <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lifeng Sun <lifongsun@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/char/applicom.c b/drivers/char/applicom.c
> index 25373df..50c09e4 100644
> --- a/drivers/char/applicom.c
> +++ b/drivers/char/applicom.c
> @@ -838,6 +838,6 @@ static long ac_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  	Dummy = readb(apbs[IndexCard].RamIO + VERS);
>  	kfree(adgl);
>  	mutex_unlock(&ac_mutex);
> -	return 0;
> +	return ret;
>  }

This one in fact is a bug fix where 0 gets returned not an error code it
ought to be submitted separately and described as such.

> diff --git a/drivers/char/dtlk.c b/drivers/char/dtlk.c
> index 85156dd..2d116d5 100644
> --- a/drivers/char/dtlk.c
> +++ b/drivers/char/dtlk.c
> @@ -289,7 +289,7 @@ static long dtlk_ioctl(struct file *file,
>  		return put_user(portval, argp);
>  
>  	default:
> -		return -EINVAL;
> +		return -ENOTTY;
>  	}
>  }

This one looks good (and the driver has another error in the ioctl
handler too that wants fixing where it returnds -EINVAL not -EFAULT)

>  
> diff --git a/drivers/char/generic_nvram.c b/drivers/char/generic_nvram.c
> index 0e941b5..95278e9 100644
> --- a/drivers/char/generic_nvram.c
> +++ b/drivers/char/generic_nvram.c
> @@ -111,7 +111,7 @@ static int nvram_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  		nvram_sync();
>  		break;
>  	default:
> -		return -EINVAL;
> +		return -ENOTTY;
>  	}

Looks good

>  	return 0;
> diff --git a/drivers/char/genrtc.c b/drivers/char/genrtc.c
> index f773a9d..6f4c3da 100644
> --- a/drivers/char/genrtc.c
> +++ b/drivers/char/genrtc.c
> @@ -330,7 +330,7 @@ static int gen_rtc_ioctl(struct file *file,
>  	    }
>  	}
>  
> -	return -EINVAL;
> +	return -ENOTTY;
>  }

Likewise


>  static long gen_rtc_unlocked_ioctl(struct file *file, unsigned int cmd,
> diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
> index 7066e80..720de66 100644
> --- a/drivers/char/hpet.c
> +++ b/drivers/char/hpet.c
> @@ -575,7 +575,7 @@ hpet_ioctl_common(struct hpet_dev *devp, int cmd, unsigned long arg,
>  	case HPET_IE_ON:
>  		return hpet_ioctl_ieon(devp);
>  	default:
> -		return -EINVAL;
> +		return -ENOTTY;
>  	}

Ok

>  	err = 0;
> diff --git a/drivers/char/i8k.c b/drivers/char/i8k.c
> index d72433f..4ba9b9f 100644
> --- a/drivers/char/i8k.c
> +++ b/drivers/char/i8k.c
> @@ -370,7 +370,7 @@ i8k_ioctl_unlocked(struct file *fp, unsigned int cmd, unsigned long arg)
>  		break;
>  
>  	default:
> -		return -EINVAL;
> +		return -ENOTTY;

This one is incomplete - the driver also has a bogus check for arg being
non zero. That means ioctl(fd, BOGUS, 0) will return the wrong error code
still.

>  	}
>  
>  	if (val < 0)
> diff --git a/drivers/char/ipmi/ipmi_devintf.c b/drivers/char/ipmi/ipmi_devintf.c
> index 2aa3977..bc8af5a 100644
> --- a/drivers/char/ipmi/ipmi_devintf.c
> +++ b/drivers/char/ipmi/ipmi_devintf.c
> @@ -232,7 +232,7 @@ static int ipmi_ioctl(struct file   *file,
>  		      unsigned int  cmd,
>  		      unsigned long data)
>  {
> -	int                      rv = -EINVAL;
> +	int                      rv = -ENOTTY;
>  	struct ipmi_file_private *priv = file->private_data;
>  	void __user *arg = (void __user *)data;

No - there are cases that should return -EINVAL that this will break - a
default case needs adding

> diff --git a/drivers/char/lp.c b/drivers/char/lp.c
> index 97c3edb..2ff32c8 100644
> --- a/drivers/char/lp.c
> +++ b/drivers/char/lp.c
> @@ -650,7 +650,7 @@ static int lp_do_ioctl(unsigned int minor, unsigned int cmd,
>  			break;
>  
>  		default:
> -			retval = -EINVAL;
> +			retval = -ENOTTY;
>  	}
>  	return retval;

Looks good

>  }
> diff --git a/drivers/char/nwflash.c b/drivers/char/nwflash.c
> index a12f524..45b7a7a 100644
> --- a/drivers/char/nwflash.c
> +++ b/drivers/char/nwflash.c
> @@ -115,7 +115,7 @@ static long flash_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
>  		gbWriteBase64Enable = 0;
>  		gbWriteEnable = 0;
>  		mutex_unlock(&flash_mutex);
> -		return -EINVAL;
> +		return -ENOTTY;

Ok

>  	}
>  	mutex_unlock(&flash_mutex);
>  	return 0;
> diff --git a/drivers/char/ppdev.c b/drivers/char/ppdev.c
> index f176dba..8dce214 100644
> --- a/drivers/char/ppdev.c
> +++ b/drivers/char/ppdev.c
> @@ -622,7 +622,7 @@ static int pp_do_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  
>  	default:
>  		pr_debug(CHRDEV "%x: What? (cmd=0x%x)\n", minor, cmd);
> -		return -EINVAL;
> +		return -ENOTTY;
>  	}

Looks good

>  
>  	/* Keep the compiler happy */
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index d4ddeba..40aad1c 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1157,7 +1157,7 @@ static long random_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
>  		rand_initialize();
>  		return 0;
>  	default:
> -		return -EINVAL;
> +		return -ENOTTY;

Ok
>  	}
>  }
>  
> diff --git a/drivers/char/raw.c b/drivers/char/raw.c
> index b4b9d5a..a992bf1 100644
> --- a/drivers/char/raw.c
> +++ b/drivers/char/raw.c
> @@ -231,7 +231,7 @@ static long raw_ctl_ioctl(struct file *filp, unsigned int command,
>  		return 0;
>  	}
>  
> -	return -EINVAL;
> +	return -ENOTTY;

Ok

>  }
>  
>  #ifdef CONFIG_COMPAT
> @@ -273,7 +273,7 @@ static long raw_ctl_compat_ioctl(struct file *file, unsigned int cmd,
>  		return 0;
>  	}
>  
> -	return -EINVAL;
> +	return -ENOTTY;
>  }
>  #endif

Ok

>  
> diff --git a/drivers/char/viotape.c b/drivers/char/viotape.c
> index ad6e64a..a427d40 100644
> --- a/drivers/char/viotape.c
> +++ b/drivers/char/viotape.c
> @@ -529,7 +529,7 @@ static int viotap_ioctl(struct inode *inode, struct file *file,
>  
>  	down(&reqSem);
>  
> -	ret = -EINVAL;
> +	ret = -ENOTTY;

Again this messes up the returns because code assumes the initial
default. The original code also has bugs too (wrong error off
copy_*_user() again)

>  
>  	switch (cmd) {
>  	case MTIOCTOP:
> diff --git a/fs/pipe.c b/fs/pipe.c
> index da42f7d..fe7ffe4 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -665,7 +665,7 @@ static long pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
>  
>  			return put_user(count, (int __user *)arg);
>  		default:
> -			return -EINVAL;
> +			return -ENOTTY;
>  	}

Looks good - but this one really does want to be a patch on its own as if
anything causes compatibility funnies it will be this, and we need to be
sure we can bisect nicely to it should this occur.

>  }
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c2ac599..b93c76d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4773,7 +4773,7 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
>  		 * is never reached
>  		 */
>  		WARN_ON(1);
> -		err = -EINVAL;
> +		err = -ENOTTY;

This case doesn't really matter - it can't happen anyway so might as well
change
>  		break;
>  
>  	}
> @@ -5041,7 +5041,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>  		/* Set the per device memory buffer space.
>  		 * Not applicable in our case */
>  	case SIOCSIFLINK:
> -		return -EINVAL;
> +		return -EOPNOTSUPP;

This change seems unrelated to anything in your description and outside
of anything SuS cares about or demands.
>  
>  	/*
>  	 *	Unknown or private ioctl.
> @@ -5062,7 +5062,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>  		/* Take care of Wireless Extensions */
>  		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
>  			return wext_handle_ioctl(net, &ifr, cmd, arg);
> -		return -EINVAL;
> +		return -ENOTTY;

and this one looks right.

Alan
