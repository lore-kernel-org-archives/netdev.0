From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 18 Apr 2013 11:51:25 +0800
Message-ID: <CACVXFVP=DrbPinLt_rxYETmRYONt-MOsmhAv_O8EcrnpbVohMA@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1637650.tuYfvStuVJ@linux-5eaq.site>
	<CACVXFVMN4N2EJ0RSzcr8TuUM0ABcJzFSOotaib4Rb-1AJTLHiQ@mail.gmail.com>
	<5581442.KzM2iaDSQ0@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5581442.KzM2iaDSQ0-7ztolUikljGernLeA6q8OA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 17, 2013 at 2:55 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
> On Wednesday 17 April 2013 09:56:33 Ming Lei wrote:
>> On Tue, Apr 16, 2013 at 3:57 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
>
>> > Generally, saying that somebody else has a problem is not an argument
>> > as long as the fix is very simple. Of course it is a corner case, but why
>> > fail to solve it as long as the cost is extremely low?
>>
>> The cost isn't low because users have to decide(learn) when to use GFP_NOIO
>> and when to use GFP_KERNEL, and GFP_NOIO isn't easy to use,
>> especially in the corner case which isn't easy to understand too. I bet few of
>> guys can think of the case and the usage if they don't recall previous threads.
>
> 1. Kernel coders generally need to learn when to use which GFP
> 2. We have code review
>
>> If you want to avoid the corner case, just hardcode GFP_NOIO in the API. As
>> we see, both current usage of the API may have the corner case.
>
> That would make it a worse API for little gain.
>
>> >> - usbnet_status_start() is called from either probe() or work queue scheduled
>> >> from probe(), if we want to address the probable issue, the memflags should
>> >
>> > No, we export this symbol. So we keep it generic if that is possible at low cost.
>> > We cannot assume that the conditions it would be called in now, remain so.
>> > Of course we don't add stuff needlessly, but here the fix is trivial.
>>
>> Why we can't assume the conditions?  The API is introduced just for solving
>> one specific problem of sierra net, and shouldn't apply to general situations
>> and its usage is __not__ encouraged since it introduces extra power
>> consumption. If you have other use cases which need the API, please post
>> them out for discussion.
>
> If we have a function for starting a status URB we want to use it whenever
> it applies, that is also when we need to poll status for internal reason while
> an interface is up.

For other non-sierra usbnet devices, when an interface is up, the status URB
is scheduled in open() and needn't the API.

>
>> In fact, it is sort of a workaround for sierra device only, so we don't
>> need to make it general in the extreme, IMO.
>
> As soon as we export it, it is available to general use.

It doesn't mean there are general uses, looks you don't provide
one valid general one too, :-)

>
>> The fix isn't trivial since GFP_NOIO isn't trivial and the corner case
>> isn't easy
>> to understand, as I said above.
>
> You don't need to understand it any more than you need to understand
> the rule for usb_submit_urb(). The rules are the very same. There is no
> special effort here.

No, there isn't one rule for the corner case here, and the corner case should
have existed in probe() or cancel queue with reset of all USB drivers, instead
of usbnet only.

Also the rule 3 is a bit obscure, maybe not correct, at least there are much
GFP_KERNEL usages in kthread of usbnet. I am wondering if there are
other usbnet specific memflags rules except for 1 & 6.

Strictly speaking, the rule 5 isn't correct, since it might trigger the corner
case you mentioned, right?

I think we need to review the memflags part of usb_submit_urb() doc now.

>
>> > Again, no. This is a generic API. It may be called for devices which need
>> > their status polled forever and we cannot block them from sleeping.
>> > If a driver wants to block suspend while a status URB is on, it should
>> > call the autopm method. This is the way we do it while the connection
>> > is up.
>>
>> The API can't be called in atomic context at all since mutex is to be held.
>
> ???

+int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
+{
+       int ret = 0;
+
+       WARN_ON_ONCE(dev->interrupt == NULL);
+       if (dev->interrupt) {
+               mutex_lock(&dev->interrupt_mutex);

....

+}

Obviously, the API can't be called in atomic context, and putting runtime PM
inside is reasonable and correct.

>
> I meant block suspend in the sense of disallowing it. Which is very problematic.
> The CDC protocols generally support remote wakeup for status information,
> so we need to be able to sleep while status is running to accomodate devices
> which are intended to be always online.

At least now, for non-sierra drivers, it needn't the API to schedule status URB
which will be started in normal open() path, so won't power on device runtime
unnecessarily. That is what I say the API shouldn't be for a general usage, :-)


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
