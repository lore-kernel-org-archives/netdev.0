From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 01 Aug 2009 11:15:24 +0200
Message-ID: <4A7407AC.1010204@hartkopp.net>
References: <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net> <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar> <4A705604.3040807@hartkopp.net> <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com> <4A717083.5090101@hartkopp.net> <20090731093949.GA4867@darkstar> <a8e1da0907310310h483cedeeg433947d51345246c@mail.gmail.com> <4A72D373.7080802@hartkopp.net> <20090801031705.GA2817@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:50749 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbZHAJP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2009 05:15:29 -0400
In-Reply-To: <20090801031705.GA2817@darkstar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Young wrote:
> On Fri, Jul 31, 2009 at 01:20:19PM +0200, Oliver Hartkopp wrote:

>> applied this patch and replaced mdelay(100) with msleep(100).
>>
>> I got two crashes and three proper boots.
>>
>> The crashes look like the formerly posted screenshots.
>> When it boots properly i can see the delay in the boot process.
>>
>> Does this help?
> 
> Yes, I think so.
> 
> Please unapply the before two patch, try the following v2 patch instead.
> Changes from v1: fixes 'goto' path again, make tty init before sock init.

Hi Dave,

i did a 'git reset --hard' to get back to vanilla 2.6.31-rc4 .

Applied the v2 patch and booted five times without any problems.

I'll keep you informed if anything changes ;-)

Thanks,
Oliver


> ---
> 
> rfcomm tty may be used before rfcomm_tty_driver initilized,
> The problem is that now socket layer init before tty layer, if userspace
> program do socket callback right here then oops will happen.
> 
> reporting in:
> http://marc.info/?l=linux-bluetooth&m=124404919324542&w=2
> 
> make 3 changes:
> 1. remove #ifdef in rfcomm/core.c,
> make it blank function when rfcomm tty not selected in rfcomm.h
> 
> 2. tune the rfcomm_init error patch to ensure
> tty driver initilized before rfcomm socket usage.
> 
> 3. remove __exit for rfcomm_cleanup_sockets
> because above change need call it in a __init function. 
> 
> 
> CC: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Reported-by: Oliver Hartkopp <oliver@hartkopp.net>
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
> --
> include/net/bluetooth/rfcomm.h |   13 ++++++++++++-
> net/bluetooth/rfcomm/core.c    |   29 ++++++++++++++++++++---------
> net/bluetooth/rfcomm/sock.c    |    2 +-
> 3 files changed, 33 insertions(+), 11 deletions(-)
> 
> --- linux-2.6.orig/include/net/bluetooth/rfcomm.h	2009-08-01 10:53:18.000000000 +0800
> +++ linux-2.6/include/net/bluetooth/rfcomm.h	2009-08-01 10:55:29.000000000 +0800
> @@ -355,7 +355,18 @@ struct rfcomm_dev_list_req {
>  };
>  
>  int  rfcomm_dev_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
> +
> +#ifdef CONFIG_BT_RFCOMM_TTY
>  int  rfcomm_init_ttys(void);
>  void rfcomm_cleanup_ttys(void);
> -
> +#else
> +static inline int rfcomm_init_ttys(void)
> +{
> +	return 0;
> +}
> +static inline int rfcomm_cleanup_ttys(void)
> +{
> +	return 0;
> +}
> +#endif
>  #endif /* __RFCOMM_H */
> --- linux-2.6.orig/net/bluetooth/rfcomm/core.c	2009-08-01 10:53:18.000000000 +0800
> +++ linux-2.6/net/bluetooth/rfcomm/core.c	2009-08-01 11:03:24.000000000 +0800
> @@ -2080,28 +2080,41 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
>  /* ---- Initialization ---- */
>  static int __init rfcomm_init(void)
>  {
> +	int ret;
> +
>  	l2cap_load();
>  
>  	hci_register_cb(&rfcomm_cb);
>  
>  	rfcomm_thread = kthread_run(rfcomm_run, NULL, "krfcommd");
>  	if (IS_ERR(rfcomm_thread)) {
> -		hci_unregister_cb(&rfcomm_cb);
> -		return PTR_ERR(rfcomm_thread);
> +		ret = PTR_ERR(rfcomm_thread);
> +		goto out_thread;
>  	}
>  
>  	if (class_create_file(bt_class, &class_attr_rfcomm_dlc) < 0)
>  		BT_ERR("Failed to create RFCOMM info file");
>  
> -	rfcomm_init_sockets();
> -
> -#ifdef CONFIG_BT_RFCOMM_TTY
> -	rfcomm_init_ttys();
> -#endif
> +	ret = rfcomm_init_ttys();
> +	if (ret)
> +		goto out_tty;
> +
> +	ret = rfcomm_init_sockets();
> +	if (ret)
> +		goto out_sock;
>  
>  	BT_INFO("RFCOMM ver %s", VERSION);
>  
>  	return 0;
> +
> +out_sock:
> +	rfcomm_cleanup_ttys();
> +out_tty:
> +	kthread_stop(rfcomm_thread);
> +out_thread:
> +	hci_unregister_cb(&rfcomm_cb);
> +
> +	return ret;
>  }
>  
>  static void __exit rfcomm_exit(void)
> @@ -2112,9 +2125,7 @@ static void __exit rfcomm_exit(void)
>  
>  	kthread_stop(rfcomm_thread);
>  
> -#ifdef CONFIG_BT_RFCOMM_TTY
>  	rfcomm_cleanup_ttys();
> -#endif
>  
>  	rfcomm_cleanup_sockets();
>  }
> --- linux-2.6.orig/net/bluetooth/rfcomm/sock.c	2009-08-01 10:53:18.000000000 +0800
> +++ linux-2.6/net/bluetooth/rfcomm/sock.c	2009-08-01 10:55:29.000000000 +0800
> @@ -1132,7 +1132,7 @@ error:
>  	return err;
>  }
>  
> -void __exit rfcomm_cleanup_sockets(void)
> +void rfcomm_cleanup_sockets(void)
>  {
>  	class_remove_file(bt_class, &class_attr_rfcomm);
>  

