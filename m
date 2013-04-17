From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Wed, 17 Apr 2013 09:56:33 +0800
Message-ID: <CACVXFVMN4N2EJ0RSzcr8TuUM0ABcJzFSOotaib4Rb-1AJTLHiQ@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1366041560.5649.0.camel@dcbw.foobar.com>
	<CACVXFVOpd6LLjYcz5smx5NktS=+jN74uePSPq7DAeUfpmNYm4w@mail.gmail.com>
	<1637650.tuYfvStuVJ@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1637650.tuYfvStuVJ-7ztolUikljGernLeA6q8OA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 16, 2013 at 3:57 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
> On Tuesday 16 April 2013 09:15:45 Ming Lei wrote:
>> On Mon, Apr 15, 2013 at 11:59 PM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> >
>> > So, what was the general consensus on this one?  I know Oliver signed
>> > off on it, but the discussion about memflags seemed to die out without a
>> > specific conclusion.  davem might be looking for that conclusion before
>> > moving forward with the series :)
>>
>> Suggest to remove the memflags parameter, because:
>>
>> - the probable issue addressed by introducing memflags is a general issue
>> of all USB drivers, also very corener one, not a specific one on usbnet, and
>> the issue only exists on devices with at least one mass storage interface and
>> another non-mass-storage interface, and it is not considered by other USB
>> drivers now.
>
> Generally, saying that somebody else has a problem is not an argument
> as long as the fix is very simple. Of course it is a corner case, but why
> fail to solve it as long as the cost is extremely low?

The cost isn't low because users have to decide(learn) when to use GFP_NOIO
and when to use GFP_KERNEL, and GFP_NOIO isn't easy to use,
especially in the corner case which isn't easy to understand too. I bet few of
guys can think of the case and the usage if they don't recall previous threads.

If you want to avoid the corner case, just hardcode GFP_NOIO in the API. As
we see, both current usage of the API may have the corner case.

>
>> - usbnet_status_start() is called from either probe() or work queue scheduled
>> from probe(), if we want to address the probable issue, the memflags should
>
> No, we export this symbol. So we keep it generic if that is possible at low cost.
> We cannot assume that the conditions it would be called in now, remain so.
> Of course we don't add stuff needlessly, but here the fix is trivial.

Why we can't assume the conditions?  The API is introduced just for solving
one specific problem of sierra net, and shouldn't apply to general situations
and its usage is __not__ encouraged since it introduces extra power
consumption. If you have other use cases which need the API, please post
them out for discussion.

In fact, it is sort of a workaround for sierra device only, so we don't
need to make it general in the extreme, IMO.

The fix isn't trivial since GFP_NOIO isn't trivial and the corner case
isn't easy
to understand, as I said above.

>
>> always be GFP_NOIO under the two situations, __or__ GFP_KERNEL if we
>> choose to ignore the very corner case like other USB drivers.  So hardcoded
>> GFP_NOIO or GFP_KERNEL should be accepted.
>>
>> Oliver, do you have objections on not adding the memflags parameter now?
>
> Yes, it is a change of almost no gain and a known problem.
> It should be added with mem_flags.
>> Williams, looks there is another problem in your patch, sorry for not
>> finding it previously.  usb_autopm_get_interface() need to be called before
>> submitting URB inside usbnet_status_start(), and usb_autopm_put_interface()
>> need to be called after killing URB inside usbnet_status_stop(). Otherwise
>> your patch doesn't work as you expected under runtime PM situation.
>
> Again, no. This is a generic API. It may be called for devices which need
> their status polled forever and we cannot block them from sleeping.
> If a driver wants to block suspend while a status URB is on, it should
> call the autopm method. This is the way we do it while the connection
> is up.

The API can't be called in atomic context at all since mutex is to be held.

Also I am wondering there is valid use case for such usage, if you have,
please post them out.


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
