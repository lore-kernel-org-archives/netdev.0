From: Scott Feldman <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Mon, 26 Jan 2015 01:14:06 -0800
Message-ID: <CAE4R7bAoTAMMtq0JQK0vmyLqooU88VVuoLkZcFd=1WfxCaqyaw@mail.gmail.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
	<1394712342-15778-119-Taiwan-albertk@realtek.com>
	<CAE4R7bAv26f-+DW-TmjspJxAb-3Add5sf563mnMUTGCyiqG3rQ@mail.gmail.com>
	<20150119.161333.1471925264489559119.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2EE6E76@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2EE6E76-JIZ+AM9kKNzuvTFwvkocLypo8c9IxeqyAjHCUHv49ws@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2015 at 6:48 PM, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org> wrote:
>  David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
>> Sent: Tuesday, January 20, 2015 5:14 AM
> [...]
>> >> -               r8152_submit_rx(tp, agg, GFP_ATOMIC);
>> >> +               if (!ret) {
>> >> +                       ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
>> >> +               } else {
>> >> +                       urb->actual_length = 0;
>> >> +                       list_add_tail(&agg->list, next);
>> >
>> > Do you need a spin_lock_irqsave(&tp->rx_lock, flags) around this?
>>
>> Indeed, and rtl_start_rx() seems to also access agg->list without
>> proper locking.
>
> It is unnecessary because I deal with them in a local list_head. My steps are
>    1. Move the whole list from tp->rx_done to local rx_queue. (with spin lock)
>    2. dequeue/enqueue the lists in rx_queue.
>    3. Move the lists in rx_queue to tp->rx_done if it is necessary. (spin lock)
> For step 2, it wouldn't have race, because the list_head is local and no other
> function would change it. Therefore, I don't think it needs the spin lock.

Sorry guys, I think I made a mistake in my review and caused some
confusion/grief.

My mistake was getting the params to list_add_tail() backwards.  It's
list_add_tail(entry, head).  I saw list_add_tail(&agg->list, next) and
was fooled into thinking agg->list was the list getting appended with
the entry 'next'.  It's the opposite.  Duh.  So locking isn't needed
because the list is indeed local.

-scott
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
