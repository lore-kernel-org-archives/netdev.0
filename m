From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: A race in register_netdevice()
Date: Thu, 28 Apr 2011 16:52:37 -0700
Message-ID: <20110428165237.0c1eddbc@nehalam>
References: <87y62ugg0a.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y62ugg0a.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2011 01:36:37 +0300
Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org> wrote:

> Hi,
> 
> there seems to be a race in register_netdevice(), which is reported here:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=15606
> 
> This is visible at least with flimflam and ath6kl. Basically what
> happens is this:
> 
> Apr 29 00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device() 
> Apr 29 00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
> 4): No such device
> Apr 29 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message() buf
> 0xbfefda3c len 1004
> Apr 29 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message()
> NEWLINK len 1004 type 16 flags 0x0000 seq 0
> 
> (ignore the 10 s delay, I added that to reproduce the issue easily)
> 
> There are two ways to fix this, first is to move kobject registration
> after the call to list_netdevice():
> 
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5425,11 +5425,6 @@ int register_netdevice(struct net_device *dev)
>         if (ret)
>                 goto err_uninit;
>  
> -       ret = netdev_register_kobject(dev);
> -       if (ret)
> -               goto err_uninit;
> -       dev->reg_state = NETREG_REGISTERED;
> -
>         netdev_update_features(dev);
>  
>         /*
> @@ -5443,6 +5438,11 @@ int register_netdevice(struct net_device *dev)
>         dev_hold(dev);
>         list_netdevice(dev);
>  
> +       ret = netdev_register_kobject(dev);
> +       if (ret)
> +               goto err_uninit;
> +       dev->reg_state = NETREG_REGISTERED;
> +
>         /* Notify protocols, that a new device appeared. */
>         ret = call_netdevice_notifiers(NETDEV_REGISTER, dev);
>         ret = notifier_to_errno(ret);
> 
> Other option, noticed by Jouni Malinen, is to take rtnl for
> SIOCGIFNAME. For some reason it's currently unprotected:
> 
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4917,8 +4917,12 @@ int dev_ioctl(struct net *net, unsigned int
> cmd, void __user *arg)
>           rtnl_unlock();
>                 return ret;
>                 }
> -               if (cmd == SIOCGIFNAME)
> -                  return dev_ifname(net, (struct ifreq __user *)arg);
> +                  if (cmd == SIOCGIFNAME) {
> +                     rtnl_lock();
> +                       ret = dev_ifname(net, (struct ifreq __user
> -                  *)arg);
> +                       rtnl_unlock();
> +                               return ret;
> +                               }
>  
>         if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
>            return -EFAULT;
> 
> I have confirmed that both of these patches fix the issue. Now I'm
> wondering which one is the best way forward. Or is there a better way
> to fix this?
> 

I see no problem with moving this.
SIOCGIFNAME should not need to hold rtnl.


-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
