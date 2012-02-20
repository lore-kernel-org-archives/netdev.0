From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: calling request_firmware() from module init will not work
 with recent/future udev versions
Date: Mon, 20 Feb 2012 18:43:54 +0100
Message-ID: <4F42865A.5060006@broadcom.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tom Gundersen" <teg-B22kvLQNl6c@public.gmane.org>,
	"Andy Whitcroft" <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"Larry Finger" <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	"Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Kay Sievers" <kay.sievers-tD+1rO4QERM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/14/2012 04:25 PM, Kay Sievers wrote:
> We changed udev to strictly enforce sequence order and dependency
> handling of events. This seems to break some netdev drivers which
> block in modprobe until the firmware from userspace is loaded into the
> driver.

Working on the issue complicated the behavior of the driver so I decided 
to take a step back to determine the actual issue.

> These are the drivers we received bug reports so far. We didn't look
> into any of details of the drivers, but according to the logs, they
> seem to block for 60 seconds in modprobe, when userspace is not
> behaving like expected:
>    bnx2/bnx2-mips-06-6.2.1.fw
>    rtlwifi/rtl8192sefw.bin
>    brcm/bcm43xx-0.fw

The main problem is that the init_module() syscall should not block. 
However, the driver I am responsible for (brcm80211) does not request 
firmware in the init_module() path. It does that on the probe() 
callback. So the problem is that the probe() code path is done in the 
context of the init_module() syscall. So the thing to do is decouple the 
probe() callback from the init_module() syscall.

One option is using the nowait version of request_firmware(), but 
another option I am considering is to defer the driver registration 
using a workqueue and schedule it in the init_module() syscall. That way 
I think I can avoid having to call the device_unregister_driver() when 
firmware loading fails.

Another thing to consider is to change the driver core subsystem and 
assure the probe() callback is never done in the init_module() context.

Any opinions?

Gr. AvS

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
