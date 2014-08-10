From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probefrom init
Date: Sun, 10 Aug 2014 22:42:26 +0900
Message-ID: <201408102242.FGG43287.FMFFLQJVOHOOSt@I-love.SAKURA.ne.jp>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
	<1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
	<20140730.151107.1328294951387764830.davem@davemloft.net>
	<20140809164119.GI21930@wotan.suse.de>
	<20140810124331.GE30451@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mcgrof@do-not-panic.com, tiwai@suse.de,
	linux-kernel@vger.kernel.org, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com, bpoirier@suse.de,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	hariprasad@chelsio.com, santosh@chelsio.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, mcgrof@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140810124331.GE30451@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> Why doesn't it work?  Doesn't modprobe come right back and the init
> sequence still takes a while to run?  What exactly fails?

I guess ...

> @@ -5429,9 +5429,19 @@ mptsas_init(void)
>  	return error;
>  }
>  
> +static struct task_struct *init_thread;
> +
> +static int __init
> +mptsas_init(void)
> +{
> +	init_thread = kthread_run(mptsas_real_init, NULL, "mptsas_init");
> +	return 0;
> +}
> +
>  static void __exit
>  mptsas_exit(void)
>  {
> +	kthread_stop(init_thread);
>  	pci_unregister_driver(&mptsas_driver);
>  	sas_release_transport(mptsas_transport_template);
>  
> 

kthread_run() can fail. sas_attach_transport() and/or pci_register_driver()
in mptsas_real_init() can fail. Caller process may fail to continue if
sas_attach_transport() and pci_register_driver() in mptsas_real_init() has
not completed yet.

kthread_stop() must not be called when kthread_run() failed.
pci_unregister_driver() and/or sas_release_transport() must not be called
when mptsas_real_init() did not return 0 (or has not returned 0 yet).
