From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: fix rtnl even race in register_netdevice()
Date: Fri, 29 Apr 2011 13:53:39 -0700 (PDT)
Message-ID: <20110429.135339.200375209.davem@davemloft.net>
References: <20110429172634.27130.25375.stgit@x201>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110429172634.27130.25375.stgit@x201>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Date: Fri, 29 Apr 2011 20:26:34 +0300

> From: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> 
> There's a race in register_netdevice so that the rtnl event is sent before
> the device is actually ready. This was visible with flimflam, chrome os
> connection manager:
> 
> 00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device()
> 00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
>    4): No such device
> 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message() buf
>    0xbfefda3c len 1004
> 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message()
>    NEWLINK len 1004 type 16 flags 0x0000 seq 0
> 
> So the kobject is visible in udev before the device is ready.
> 
> (ignore the 10 s delay, I added that to reproduce the issue easily)
> 
> The issue is reported here:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=15606
> 
> The fix is to call netdev_register_kobject() after the device is added
> to the list.
> 
> Signed-off-by: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>

This is not correct.

If you move the kobject registry around, you have to change the
error handling cleanup to match.

This change will leave the netdevice on all sorts of lists, it will
also leak a reference to the device.

I also think this points a fundamental problem with this change, in
that you can't register the kobject after the device is added to
the various lists in list_netdevice().

Once it's in those lists, any thread of control can find the device
and those threads of control may try to get at the data backed by
the kobject and therefore they really expect it to be there by
then.

What you can do instead is try to delay the NETREG_REGISTERED
setting, and block the problematic notifications by testing
reg_state or similar.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
