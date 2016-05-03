From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Tue, 3 May 2016 22:16:41 +0100
Message-ID: <57291539.6080405@mentor.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <87ed4c76328ed9dc5591359ea0e98ab9@i4031.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	YongQin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ivan Vecera <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "David B. Robins" <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ed4c76328ed9dc5591359ea0e98ab9-xeNgNI7VTeVeoWH0uzbU5w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/05/16 15:42, David B. Robins wrote:
>
> I don't think the first one is giving you problems (except as 
> triggered by the second) but I had concerns about the second myself 
> (and emailed the author off-list, but received no reply), and we did 
> not take that commit for our own product.
>
Sorry, I might have missed your original E-mail.

> Specifically, the second change, 3f30... (original patch: 
> https://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg80720.html) (1) 
> appears to do the exact opposite of what it claims, i.e., instead of 
> "resync if this looks like a header", it does "resync if this does NOT 
> look like a (packet) header", where "looks like a header" means "bits 
> 0-10 (size) are equal to the bitwise-NOT of bits 16-26", and (2) can 
> happen by coincidence for 1/2048 32-bit values starting a continuation 
> URB (easy to hit dealing with large volumes of video data as we were). 
> It appears to expect the header for every URB whereas the rest of the 
> code at least expects it only once per network packet (look at 
> following code that only reads it for remaining == 0).

David, I think that your interpretation is incorrect. Please see below.

Here is the code snippet from the patch with my annotations between # #, 
I will try to explain my intentions. Feel free to point out any flaws:

     if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
         # Only runs when rx->remaining !=0 and the end of the Ethernet 
frame + next 32-bit header word is within the URB buffer. #
         # Therefore, this code does not run when the end of an Ethernet 
frame has been reached in the previous URB #
         # or when the end of the Ethernet frame + next 32-bit header 
word will be in a later URB buffer #

         # offset is an index to the expected next 32-bit header word 
after the end of the Ethernet frame #
         offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);

         # rx->header contains the expected 32-bit header value 
corrected for Endianness and alignment #
         rx->header = get_unaligned_le32(skb->data + offset);
         offset = 0;

         # check the data integrity of the size value from the header word #
         size = (u16)(rx->header & 0x7ff);
         # if the size value fails the integrity check then we are not 
looking at a valid header word so #
         # synchronisation has been lost #
         if (size != ((~rx->header >> 16) & 0x7ff)) {
             netdev_err(dev->net, "asix_rx_fixup() Data Header 
synchronisation was lost, remaining %d\n",
                    rx->remaining);
             if (rx->ax_skb) {
                 kfree_skb(rx->ax_skb);
                 rx->ax_skb = NULL;
                 /* Discard the incomplete netdev Ethernet frame
                  * and assume the Data header is at the start of
                  * the current URB socket buffer.
                  */
             }
             rx->remaining = 0;
         }
     }


>
> So that change made no sense to me, but I don't have significant 
> kernel dev experience. Effectively it will drop/truncate every 
> (2047/2048) split (longer than an URB) packet, and report an error for 
> the second URB and then again for treating said second URB as a first 
> URB for a packet. I would expect your problems will go away just 
> removing the second change. You could also change the != to == in "if 
> (size != ...)" but then you'd still have 1/2048 (depending on data 
> patterns) false positives.
The code only runs when the Ethernet frame spans across URBs and is 
checking that the next 32-bit header word is present and valid.

Upon loss of synchronisation, the strategy is to assume that the 32-bit 
header is at the start of the URB buffer. Obviously, that might not be 
true every time but it is the most likely location especially when 
Ethernet frames are not spanning URBs at that point at time.

Looking at the error messages:

> [  239.037310] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x54ebb5ec, offset 4 

The offset 4 means that the 32-bit header word was invalid at the start 
of the URB buffer. This could be a consequence of data synchronisation 
being lost however, we would expect the timestamps between the error 
messages of "synchronisation was lost" and "Bad Header Length" to very 
close as they would be consecutive URBs. The evidence is showing 10ms 
gaps which does not suggest consecutive URBs. In other words, an 
Ethernet frame should not be spanned over a time gap of 10ms as that 
would be very inefficient. If that were true then there would be USB 
communications problem with the USB to Ethernet adaptor which I hope is 
not true.

[  239.027993] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988

This error message consistently shows the remaining value to be 988, at 
least for the 3 examples provided by John. This does not suggest a 
random failure unless there are other examples of a non 988 remaining 
value error message. 988 is well within a Ethernet frame length so seems 
to be valid.

I think a good step would be to add some debug to print the 
rx->remaining value at entry to asix_rx_fixup_internal(). This would 
generate a lot of debug but a pattern of the values might emerge.

A good test would be to run "ping -c 1 -s $packet_length $ip_address" 
inside a script which has a loop with an increasing payload length 
$packet_length with a small delay between ping calls. This will show 
whether particular packet sizes trigger the failures.

Then try with "ping -f -c 200 -s $packet_length $ip_address" to load up 
the USB link.

Seems that I need kernel v4.4 or later to get a kernel with my patch in. 
This will take me a few days to find time to rig something up to test...

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
