From: Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Wed, 9 Aug 2017 18:36:39 -0700
Message-ID: <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com> <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux USB List <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 6:26 PM, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
> On Wed, Aug 9, 2017 at 5:36 PM, Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> On Wed, Aug 9, 2017 at 4:44 PM, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>>> On Wed, Aug 9, 2017 at 4:34 PM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>> (Cc'ing Wei whose commit was blamed)
>>>>
>>>> On Mon, Aug 7, 2017 at 2:15 PM, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>>>>> On Mon, Aug 7, 2017 at 2:05 PM, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>>>>>> So, with recent testing with my HiKey board, I've been noticing some
>>>>>> quirky behavior with my USB eth adapter.
>>>>>>
>>>>>> Basically, pluging the usb eth adapter in and then removing it, when
>>>>>> plugging it back in I often find that its not detected, and the system
>>>>>> slowly spits out the following message over and over:
>>>>>>   unregister_netdevice: waiting for eth0 to become free. Usage count = 1
>>>>>
>>>>> The other bit is that after this starts printing, the board will no
>>>>> longer reboot (it hangs continuing to occasionally print the above
>>>>> message), and I have to manually reset the device.
>>>>>
>>>>
>>>> So this warning is not temporarily shown but lasts until a reboot,
>>>> right? If so it is a dst refcnt leak.
>>>
>>> Correct, once I get into the state it lasts until a reboot.
>>>
>>>> How reproducible is it for you? From my reading, it seems always
>>>> reproduced when you unplug and plug your usb eth interface?
>>>> Is there anything else involved? For example, network namespace.
>>>
>>> So with 4.13-rc3/4 I seem to trigger it easily, often with the first
>>> unplug of the USB eth adapter.
>>>
>>> But as I get back closer to 4.12, it seemingly becomes harder to
>>> trigger, but sometimes still happens.
>>>
>>> So far, I've not been able to trigger it with 4.12.
>>>
>>> I don't think network namespaces are involved?  Though its out of my
>>> area, so AOSP may be using them these days.  Is there a simple way to
>>> check?
>>>
>>> I'll also do another bisection to see if the bad point moves back any further.
>
> So I went through another bisection around and got  9514528d92d4 ipv6:
> call dst_dev_put() properly as the first bad commit again.
>
>> If you see the problem starts to happen on commit
>> 9514528d92d4cbe086499322370155ed69f5d06c, could you try reverting all
>> the following commits:
>> (from new to old)
>> 1eb04e7c9e63 net: reorder all the dst flags
>> a4c2fd7f7891 net: remove DST_NOCACHE flag
>> b2a9c0ed75a3 net: remove DST_NOGC flag
>> 5b7c9a8ff828 net: remove dst gc related code
>> db916649b5dd ipv6: get rid of icmp6 dst garbage collector
>> 587fea741134 ipv6: mark DST_NOGC and remove the operation of dst_free()
>> ad65a2f05695 ipv6: call dst_hold_safe() properly
>> 9514528d92d4 ipv6: call dst_dev_put() properly
>
>
> And reverting this set off of 4.13-rc4 seems to make the issue go away.
>
> Is there anything I can test to help narrow down the specific problem
> with that patchset?
>

Thanks John for confirming.
Let me spend some time on the commits and I will let you know if I
have some debug image for you to try.

Wei


> thanks
> -john
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
