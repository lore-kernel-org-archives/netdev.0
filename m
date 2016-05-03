From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Tue, 3 May 2016 10:23:33 +0100
Message-ID: <57286E15.2080900@mentor.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	YongQin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ivan Vecera <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David B. Robins" <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>
To: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/05/16 05:55, John Stultz wrote:
> In testing with HiKey, we found that since commit 3f30b158eba5c60
> (asix: On RX avoid creating bad Ethernet frames), we're seeing lots of
> noise during network transfers:
>
> [  239.027993] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
> [  239.037310] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x54ebb5ec, offset 4
> [  239.045519] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0xcdffe7a2, offset 4
> [  239.275044] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
> [  239.284355] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x1d36f59d, offset 4
> [  239.292541] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0xaef3c1e9, offset 4
> [  239.518996] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
> [  239.528300] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x2881912, offset 4
> [  239.536413] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x5638f7e2, offset 4
>
>
> And network throughput ends up being pretty bursty and slow with a
> overall throughput of at best ~30kB/s.
>
> Looking through the commits since the v4.1 kernel where we didn't see
> this, I narrowed the regression down, and reverting the following two
> commits seems to avoid the problem:
>
> 6a570814cd430fa5ef4f278e8046dcf12ee63f13 asix: Continue processing URB
> if no RX netdev buffer
> 3f30b158eba5c604b6e0870027eef5d19fc9271d asix: On RX avoid creating
> bad Ethernet frames
>
> With these reverted, we don't see all the error messages, and we see
> better ~1.1MB/s throughput (I've got a mouse plugged in, so I think
> the usb host is only running at "full-speed" mode here).
>
> This worries me some, as the patches seem to describe trying to fix
> the issue they seem to cause, so I suspect a revert isn't the correct
> solution, but am not sure why we're having such trouble and the patch
> authors did not.  I'd be happy to do further testing of patches if
> folks have any ideas.
>
> Originally Reported-by: Yongqin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>
> thanks
> -john
Hi John,

Some ASIX chipsets span the Ethernet frame over consecutive URBs which 
requires successful transfer of 2 URBs.

This means states of a previous URB influences the processing of the 
next URB including a dropped URB (causes a discontinuity in the data 
stream). In other words synchronisation of the in-band 32-bit header 
word needs to be tracked between URBs. Some ASIX chipsets allow the 
in-band 32-bit header word to be no longer fixed to the start of the URB 
buffer so it moves to any position within the URB buffer.

I understand your point of suggesting it is a "regression" for your 
device but the driver was broken for DUB-E100 C1 (small black USB 
device). So you cannot revert the commits as this would break DUB-E100 
C1 (small black USB device).

> 6a570814cd430fa5ef4f278e8046dcf12ee63f13 asix: Continue processing URB
> if no RX netdev buffer
This commit is necessary because it avoids a crash when netdev buffer 
failed to be allocated for the 1st URB and the 2nd URB containing a 
spanned Ethernet frame is processed. The crash happens because the 2nd 
URB assumed that the netdev buffer had been allocated.

> 3f30b158eba5c604b6e0870027eef5d19fc9271d asix: On RX avoid creating
> bad Ethernet frames
This commit is necessary to avoid sending bad Ethernet frames into the 
IP stack during loss of synchronisation and to dropping good Ethernet 
frames. This commit improves the synchronisation recovery mechanism of 
the in-band 32-bit header word.

The ASIX USB to Ethernet devices these commits were tested on where 
DUB-E100 C1 (small black USB device). Embedded ARM based systems were 
used where memory resources can run out.

It could be that for your USB to Ethernet device that the wrong 
configuration settings have been used. In other words the ASIX driver is 
flexible to support various variants of the ASIX chipsets. For example, 
does your device support Ethernet frames spanning multiple URBs 
(multiple USB transfers) ?

So I doubt my commits are "broken" because we don't see your failures 
(not tested your device). It is more likely that your ASIX device needs 
to be properly identified and configured to be compatible with the ASIX 
driver. At least, I suggest that is the best place to start your 
investigation.

Of course, your ASIX chipset might have a different behaviour for how 
the in-band 32-bit header word operates so perhaps special treatment is 
needed for your chipset ?

Please send to the mailing list the output of lsusb for your device so 
that people can know the USB product ID and vendor ID for your device. 
This is allows people to assist with the investigation. Do you have any 
links to websites that sell your device ?

Are you using UDP or TCP connections ?

Regards,
Dean

-- 
Dean Jenkins
Embedded Software Engineer
Linux Transportation Solutions
Mentor Embedded Software Division
Mentor Graphics (UK) Ltd.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
