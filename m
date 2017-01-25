From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net v2 0/4] r8152: fix scheduling napi
Date: Wed, 25 Jan 2017 14:31:19 -0500 (EST)
Message-ID: <20170125.143119.411717735878453521.davem@davemloft.net>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
        <1394712342-15778-242-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-242-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Wed, 25 Jan 2017 16:13:17 +0800

> v2:
> Add smp_mb__after_atomic() for patch #1.
> 
> v1:
> Scheduling the napi during the following periods would let it be ignored.
> And the events wouldn't be handled until next napi_schedule() is called.
> 
> 1. after napi_disable and before napi_enable().
> 2. after all actions of napi function is completed and before calling
>    napi_complete().
> 
> If no next napi_schedule() is called, tx or rx would stop working.
> 
> In order to avoid these situations, the followings solutions are applied.
> 
> 1. prevent start_xmit() from calling napi_schedule() during runtime suspend
>    or after napi_disable().
> 2. re-schedule the napi for tx if it is necessary.
> 3. check if any rx is finished or not after napi_enable().

I think the fundamental issue is that since you can't stop URBs from
queueing up, you cannot properly synchronize NAPI and schedule polling
properly.

>From my perspective what happened here is you want GRO support, but it
comes at the expense of this extremely racey NAPI support which does
not at all achieve one of the main advantages of NAPI which is
interrupt mitigation.

It would have been so much better to implement a generic way for
drivers to get GRO support without NAPI, especially if their packet
feeding engine works the way that the USB networking drivers's do.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
