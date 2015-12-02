From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: gigaset: freeing an active object
Date: Wed, 2 Dec 2015 18:48:17 -0500
Message-ID: <565F8341.7010704@hurleysoftware.com>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
 <1448906497.3546.16.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>, Tilman Schmidt <tilman@imap.cc>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448906497.3546.16.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2015 01:01 PM, Paul Bolle wrote:
> On ma, 2015-11-30 at 00:23 +0100, Paul Bolle wrote:
>> Relevant part of dmesg attached at the end of this message. This
>> should give me (and Tilman too?) an entry to get to bottom of this. 
>> Since this is relevant for anyone with just the ser-gigaset module 
>> installed, I hope to do that soon.
> 
> I'm planning to send something similar to the attached draft to netdev
> in a few days. It fixes the issue on my machine. Sascha, does it fix
> this issue for syzkaller too? 
> 
> Should (something like) this go into stable too?

Definitely for stable since it has a userspace triggerable component.

> Any further comments on that draft are appreciated too, of course.
> 
> 
> Paul Bolle
> ------
> [DRAFT] gigaset: don't free() a struct platform_device
> 
> One is not supposed to free() a struct platform_device. Instead one
> should, in the common case, only call platform_device_unregister(). That
> will drop the platform device's reference count. (Actually it's the
> reference count of the embedded kobject that is important here. But for
> users of platform devices that's basically irrelevant.)
> 
> So move struct platform_device dev out of struct ser_cardstate, because
> ser_cardstate is (malloc'ed and) free'd.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Not-yet-signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
>  drivers/isdn/gigaset/ser-gigaset.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
> index 375be509e95f..f8ffa253496e 100644
> --- a/drivers/isdn/gigaset/ser-gigaset.c
> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> @@ -42,8 +42,9 @@ MODULE_PARM_DESC(cidmode, "stay in CID mode when idle");
>  
>  static struct gigaset_driver *driver;
>  
> +static struct platform_device pdev;
> +
>  struct ser_cardstate {
> -	struct platform_device	dev;
>  	struct tty_struct	*tty;
>  	atomic_t		refcnt;
>  	struct completion	dead_cmp;
> @@ -370,8 +371,8 @@ static void gigaset_freecshw(struct cardstate *cs)
>  	tasklet_kill(&cs->write_tasklet);
>  	if (!cs->hw.ser)
>  		return;
> -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
> -	platform_device_unregister(&cs->hw.ser->dev);
> +	dev_set_drvdata(&pdev.dev, NULL);
> +	platform_device_unregister(&pdev);
>  	kfree(cs->hw.ser);

Tilman,

Is there a 1:1 correspondence and lifetime for the embedded platform
device and it's containing memory?

I ask because the typical approach for device teardown is to put the
kfree() in the release method; naturally, that won't work if there
is some other lifetime issue.

Regards,
Peter Hurley


>  	cs->hw.ser = NULL;
>  }
> @@ -401,17 +402,17 @@ static int gigaset_initcshw(struct cardstate *cs)
>  	}
>  	cs->hw.ser = scs;
>  
> -	cs->hw.ser->dev.name = GIGASET_MODULENAME;
> -	cs->hw.ser->dev.id = cs->minor_index;
> -	cs->hw.ser->dev.dev.release = gigaset_device_release;
> -	rc = platform_device_register(&cs->hw.ser->dev);
> +	pdev.name = GIGASET_MODULENAME;
> +	pdev.id = cs->minor_index;
> +	pdev.dev.release = gigaset_device_release;
> +	rc = platform_device_register(&pdev);
>  	if (rc != 0) {
>  		pr_err("error %d registering platform device\n", rc);
>  		kfree(cs->hw.ser);
>  		cs->hw.ser = NULL;
>  		return rc;
>  	}
> -	dev_set_drvdata(&cs->hw.ser->dev.dev, cs);
> +	dev_set_drvdata(&pdev.dev, cs);
>  
>  	tasklet_init(&cs->write_tasklet,
>  		     gigaset_modem_fill, (unsigned long) cs);
> @@ -520,7 +521,7 @@ gigaset_tty_open(struct tty_struct *tty)
>  		goto error;
>  	}
>  
> -	cs->dev = &cs->hw.ser->dev.dev;
> +	cs->dev = &pdev.dev;
>  	cs->hw.ser->tty = tty;
>  	atomic_set(&cs->hw.ser->refcnt, 1);
>  	init_completion(&cs->hw.ser->dead_cmp);
> 
