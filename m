From: Lifeng Sun <lifongsun@gmail.com>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket should
 return ENOTTY
Date: Wed, 27 Apr 2011 21:54:00 +0800
Message-ID: <20110427135400.GA2373@localhost>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
 <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13:09 Wed 04/27/11 Apr, Alan Cox wrote:
> > diff --git a/drivers/char/applicom.c b/drivers/char/applicom.c
> > index 25373df..50c09e4 100644
> > --- a/drivers/char/applicom.c
> > +++ b/drivers/char/applicom.c
> > @@ -838,6 +838,6 @@ static long ac_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> >  	Dummy = readb(apbs[IndexCard].RamIO + VERS);
> >  	kfree(adgl);
> >  	mutex_unlock(&ac_mutex);
> > -	return 0;
> > +	return ret;
> >  }
> 
> This one in fact is a bug fix where 0 gets returned not an error code it
> ought to be submitted separately and described as such.

Will do.

> 
> > diff --git a/drivers/char/dtlk.c b/drivers/char/dtlk.c
> > index 85156dd..2d116d5 100644
> > --- a/drivers/char/dtlk.c
> > +++ b/drivers/char/dtlk.c
> > @@ -289,7 +289,7 @@ static long dtlk_ioctl(struct file *file,
> >  		return put_user(portval, argp);
> >  
> >  	default:
> > -		return -EINVAL;
> > +		return -ENOTTY;
> >  	}
> >  }
> 
> This one looks good (and the driver has another error in the ioctl
> handler too that wants fixing where it returnds -EINVAL not -EFAULT)

Will fix.

> > diff --git a/drivers/char/i8k.c b/drivers/char/i8k.c
> > index d72433f..4ba9b9f 100644
> > --- a/drivers/char/i8k.c
> > +++ b/drivers/char/i8k.c
> > @@ -370,7 +370,7 @@ i8k_ioctl_unlocked(struct file *fp, unsigned int cmd, unsigned long arg)
> >  		break;
> >  
> >  	default:
> > -		return -EINVAL;
> > +		return -ENOTTY;
> 
> This one is incomplete - the driver also has a bogus check for arg being
> non zero. That means ioctl(fd, BOGUS, 0) will return the wrong error code
> still.

Will fix.

> > diff --git a/drivers/char/ipmi/ipmi_devintf.c b/drivers/char/ipmi/ipmi_devintf.c
> > index 2aa3977..bc8af5a 100644
> > --- a/drivers/char/ipmi/ipmi_devintf.c
> > +++ b/drivers/char/ipmi/ipmi_devintf.c
> > @@ -232,7 +232,7 @@ static int ipmi_ioctl(struct file   *file,
> >  		      unsigned int  cmd,
> >  		      unsigned long data)
> >  {
> > -	int                      rv = -EINVAL;
> > +	int                      rv = -ENOTTY;
> >  	struct ipmi_file_private *priv = file->private_data;
> >  	void __user *arg = (void __user *)data;
> 
> No - there are cases that should return -EINVAL that this will break - a
> default case needs adding

All execution paths overwrite the return value except those should
return -ENOTTY, but it's more clear to add a default case.

Will do.

> > diff --git a/drivers/char/viotape.c b/drivers/char/viotape.c
> > index ad6e64a..a427d40 100644
> > --- a/drivers/char/viotape.c
> > +++ b/drivers/char/viotape.c
> > @@ -529,7 +529,7 @@ static int viotap_ioctl(struct inode *inode, struct file *file,
> >  
> >  	down(&reqSem);
> >  
> > -	ret = -EINVAL;
> > +	ret = -ENOTTY;
> 
> Again this messes up the returns because code assumes the initial
> default.

Likewise, except the unsupported MTIOCPOS command. SuSv4 has two
appropriate errno's for this unsupported case and the one below
returns EOPNOTSUPP,

 [ENOTSUP]
     Not supported (may be the same value as [EOPNOTSUPP]).

 [EOPNOTSUPP]
     Operation not supported on socket (may be the same value as
     [ENOTSUP]).

but the manpage of ioctl disagree. I am wondering how to handle
unsupported ioctl operations. Maybe following the manpage is a better
choice though it's not exact.


> The original code also has bugs too (wrong error off copy_*_user()
> again)

Will fix.

> > diff --git a/fs/pipe.c b/fs/pipe.c
> > index da42f7d..fe7ffe4 100644
> > --- a/fs/pipe.c
> > +++ b/fs/pipe.c
> > @@ -665,7 +665,7 @@ static long pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
> >  
> >  			return put_user(count, (int __user *)arg);
> >  		default:
> > -			return -EINVAL;
> > +			return -ENOTTY;
> >  	}
> 
> Looks good - but this one really does want to be a patch on its own as if
> anything causes compatibility funnies it will be this, and we need to be
> sure we can bisect nicely to it should this occur.

will submit serparately.

> > @@ -5041,7 +5041,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
> >  		/* Set the per device memory buffer space.
> >  		 * Not applicable in our case */
> >  	case SIOCSIFLINK:
> > -		return -EINVAL;
> > +		return -EOPNOTSUPP;
> 
> This change seems unrelated to anything in your description and outside
> of anything SuS cares about or demands.

As stated above. I would submit separately.


- Lifeng

-- 
