From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Tue, 3 May 2016 08:44:46 -0700
Message-ID: <CALAqxLXVy7dRPp=rxM3E_4_V6oHUvfaUroXbvv_y6SnWySpHCw@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<87ed4c76328ed9dc5591359ea0e98ab9@i4031.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	YongQin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ivan Vecera <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "David B. Robins" <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ed4c76328ed9dc5591359ea0e98ab9-xeNgNI7VTeVeoWH0uzbU5w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 3, 2016 at 7:42 AM, David B. Robins <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org> wrote:
> On 2016-05-03 00:55, John Stultz wrote:
>>
>> Looking through the commits since the v4.1 kernel where we didn't see
>> this, I narrowed the regression down, and reverting the following two
>> commits seems to avoid the problem:
>>
>> 6a570814cd430fa5ef4f278e8046dcf12ee63f13 asix: Continue processing URB
>> if no RX netdev buffer
>> 3f30b158eba5c604b6e0870027eef5d19fc9271d asix: On RX avoid creating
>> bad Ethernet frames
>>
>
> I don't think the first one is giving you problems (except as triggered by
> the second) but I had concerns about the second myself (and emailed the
> author off-list, but received no reply), and we did not take that commit for
> our own product.

Yes, the first/later commit is being reverted as it modifies code that
was also changed by the second/earlier one. So the 3f30 patch doesn't
revert cleanly by itself, but I have tested by just removing the (now
modified by 6a57) chunk of code it adds does seem to avoid the problem
as well. Though I wasn't able to review things closely enough to be
confident that didn't introduce any subtle bugs in the remaining logic
in the 6a57 patch.

> Specifically, the second change, 3f30... (original patch:
> https://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg80720.html) (1)
> appears to do the exact opposite of what it claims, i.e., instead of "resync
> if this looks like a header", it does "resync if this does NOT look like a
> (packet) header", where "looks like a header" means "bits 0-10 (size) are
> equal to the bitwise-NOT of bits 16-26", and (2) can happen by coincidence
> for 1/2048 32-bit values starting a continuation URB (easy to hit dealing
> with large volumes of video data as we were). It appears to expect the
> header for every URB whereas the rest of the code at least expects it only
> once per network packet (look at following code that only reads it for
> remaining == 0).
>
> So that change made no sense to me, but I don't have significant kernel dev
> experience. Effectively it will drop/truncate every (2047/2048) split
> (longer than an URB) packet, and report an error for the second URB and then
> again for treating said second URB as a first URB for a packet. I would
> expect your problems will go away just removing the second change. You could
> also change the != to == in "if (size != ...)" but then you'd still have
> 1/2048 (depending on data patterns) false positives.

I'll have to look into this more. I'm not super familiar with usb or
networking, so I'm not sure I can judge the better approach.

thanks
-john
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
