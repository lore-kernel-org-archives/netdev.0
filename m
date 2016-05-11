From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Wed, 11 May 2016 23:00:12 +0100
Message-ID: <5733AB6C.2060204@mentor.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <87ed4c76328ed9dc5591359ea0e98ab9@i4031.net> <57291539.6080405@mentor.com>
 <CALAqxLXsna_em_5w8yonXUCcMwbOGknYtL5LhqYCHUK9LKFr0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David B. Robins" <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	YongQin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ivan Vecera <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALAqxLXsna_em_5w8yonXUCcMwbOGknYtL5LhqYCHUK9LKFr0A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

I have purchased a "uGreen" USB Ethernet Adaptor which was reported as 
showing the issue:

lsusb shows:
ID 0b95:772b ASIX Electronics Corp. AX88772B

dmesg shows:
[119591.413298] usb 2-1: new high-speed USB device number 12 using ci_hdrc
[119591.576970] usb 2-1: New USB device found, idVendor=0b95, idProduct=772b
[119591.576994] usb 2-1: New USB device strings: Mfr=1, Product=2, 
SerialNumber=3
[119591.577010] usb 2-1: Product: AX88772C
[119591.577025] usb 2-1: Manufacturer: ASIX Elec. Corp.

Strangely the product string says "AX88772C" and lsusb shows "AX88772B"

I used our ARM (32-bit 2 core) board running our highly customised 3.14 
kernel and ran a ping test that slowly increments the ping payload size 
so forcing the Ethernet frames to slowly extend in length and eventually 
forcing IPv4 fragmentation to occur due to the MTU limit of 1500. In my 
test the ICMP ping payload lengths ranged from 1 to 5000.

During the test run I saw (only 3 errors):
[27455.113010] asix 2-1:1.0 eth0: asix_rx_fixup() Data Header 
synchronisation was lost, remaining 23
[27455.113037] asix 2-1:1.0 eth0: asix_rx_fixup() Bad Header Length 
0x77767574, offset 4
[27456.113269] asix 2-1:1.0 eth0: asix_rx_fixup() Data Header 
synchronisation was lost, remaining 27
[27456.113329] asix 2-1:1.0 eth0: asix_rx_fixup() Bad Header Length 
0x77767574, offset 4
[27457.113271] asix 2-1:1.0 eth0: asix_rx_fixup() Data Header 
synchronisation was lost, remaining 30
[27457.113328] asix 2-1:1.0 eth0: asix_rx_fixup() Bad Header Length 
0x77767574, offset 4

This meets my expectation of "sync lost" followed immediately by "Bad 
Header Length". A close look at the timestamps shows gaps of around 20us 
to 50us which suggests the code is processing the same URB eg. "sync 
lost" and "Bad Header Length" are written from the same instance of 
asix_rx_fixup_internal().

My example suggests that the previous URB went missing so data was lost 
causing a discontinuity in the data stream. This was the intended 
purpose of the commit to prevent bad Ethernet frames being sent up the 
IP stack when an URB went missing. A bad Ethernet frame would otherwise 
be created by having the start of an Ethernet frame appended with data 
from the current URB causing a corrupted Ethernet frame to be generated 
and sent up the IP stack.

Also the failure seems to be independent of the ping payload length but 
longer test periods of specific payload lengths would be needed to allow 
the 32 bit header word to move around relative to the start of the URB 
buffer.

In my example, the "Bad Header Length 0x77767574" is reading the ping 
payload data of 0x74, 0x75, 0x76, 077 which is located at the start of 
the URB buffer. The remaining values are low at 23 to 30 which suggests 
the end of the Ethernet frame was in the missing URB. The ICMP ping data 
of 0x74, 0x75, 0x76, 077 is from the next Ethernet frame meaning the end 
of the current Ethernet frame is missing and the next frame has a 
missing start of Ethernet frame.

Note that due to IPv4 fragmentation "consecutive" Ethernet frames will 
contain payloads of 1500 (MTU size) octets typically followed by a short 
Ethernet frame. The payloads are fragmented IP packets.

>
> So I've been trying to add some print messages here to better
> understand whats going on.
>
> Again, I'm a bit new to this code, so forgive me for my lack of
> understanding things. Since the remaining value seems to be key, I
> tried to look around and figure out where it was being set. It seems
> like its only set in this function, is that right?  So this made me
> guess something might be happening in a previous iteration that was
> causing this to trigger.
>
> I added some debug prints to every time we set the remaining value, or
> modify it, as well as to print the value if we enter the fixup
> function with a non-zero remaining value.
>
> When we set the remaining value, usually its to 1514, when the skblen is 1518.
1514 is Ethernet header length + payload at MTU size of 1500.
skblen of 1518 is 32-bit header word + maximum Ethernet frame length 
(for your Network).
>
> However, right before we catch the problem, I see this:
I am guessing where your debug is located in the code so I may have 
ms-interpreted your information.
>
>
> [   84.844337] JDB set remaining to 1514 (skblen: 1518)
This suggests 1 maximum length Ethernet frame of 1514 octets in the URB 
buffer.
> [   84.844379] JDB set remaining to 1514 (skblen: 1518)
> [   84.844429] JDB set remaining to 1514 (skblen: 1518)
> [   84.844458] JDB set remaining to 1514 (skblen: 1518)
> [   84.844483] JDB set remaining to 1514 (skblen: 1518)
> [   84.844507] JDB set remaining to 1514 (skblen: 1518)
> [   84.844559] JDB set remaining to 1514 (skblen: 2048)
This URB probably has 2 Ethernet frames; 1 complete frame plus the start 
of the next Ethernet frame.

I think 2048 could be the maximum URB transfer length for the USB bulk 
transfer. 2048 seems to be a low value so should be investigated.

> [   84.844583] JDB set remaining to 1514 (skblen: 2048)
> [   84.844595] JDB: 1514 > 2048 - 1522
> [   84.844606] JDB: dropping remaining by 526
32-bit header word + Ethernet frame of 1514 is consumed leaving 2048 - 
(4+1514) = 530 octets

So there is room for another 32-bit header word and the start of a new 
Ethernet frame within those 530 octets.
Start of Ethernet frame is 530 - 4 = 526 octets of Ethernet frame than 
spans into the next URB buffer.

The remaining value is 988 which means the total Ethernet frame length 
was 526 + 988 = 1514 which is a maximum length Ethernet frame

> [   84.844624] asix_rx_fixup_internal()  remaining: 988,  skb->len: 2048
> [   84.844672] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
There should be a 32-bit header word located after the Ethernet frame 
after location 988 but no 32-bit header was there. This is consistent 
with a missing URB (there could be other reasons).

However, the gap between the timestamps is higher than expected at 273us:
84.844945 - 84.844672 = 0.000273 = 273us

It could be that "Sync lost" and "Bad Header" are not from the same 
instance of asix_rx_fixup_internal() eg. processing different URBs

Therefore, it could be concluded that synchronisation has been recovered 
by the "sync lost" detector forcing to look at the start of the URB 
buffer for the 32-bit header word and a 32-bit header was found as no 
immediate "Bad Header length" message was indicated. This also suggests 
a URB was lost.

> [   84.844945] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
> 0xdd5f8f9b, offset 4

This time an URB containing the start of Ethernet frame is missing 
because remaining is 0 (as no "sync lost" message"). This means that 
there is no 32-bit header word at the start of the URB buffer meaning no 
start of an Ethernet frame. This is also consistent with a dropped URB 
which contained the start of the now missing Ethernet frame.

> [   84.845217] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
> 0x3ce1ad3c, offset 4
> [   84.845451] JDB set remaining to 1514 (skblen: 1518)
> [   84.845485] JDB set remaining to 1514 (skblen: 1518)
> [   84.845511] JDB set remaining to 1514 (skblen: 1518)
> [   84.851003] JDB set remaining to 1514 (skblen: 1518)
>
>
> So when the issue happens, it seems to be due to an larger then usual
> skb (2048). The first time through the wile loop we set the remaining
> to 1514, but offset is fairly small, so we set copy_length to 1514,
> and clear remaining. The offset is bumped by a little more then the
> copy length and we loop again.  Then the second time through we set
> remaining to 1514, but since offset is bigger now, the if
> (rx->remaining > skb->len - offset)  case is true..
>
> This is where it feels a little strange..
It is because you have to wait for the next URB to get the remaining 
part of the Ethernet frame which occurs in the near future. eg. Ethernet 
frame spanned across 2 URB buffers.
>
> We calculate the copy_length as the difference between the offset and
> the skb->len (so how much is left in the skb, which is 526), then
> decrement remaining by that amount.  Not really sure what remaining
> (now 988) is supposed to represent here. We copy the 526 bytes, and
> then exit the loop.
As explained above. The end of the current URB buffer contains the first 
526 octets of the Ethernet frame and we have to wait for the next URB to 
get the next part of the Ethernet frame.

The Ethernet frame length is 1514 so the remaining value is 1514 - 526 = 
988. So the next URB should contain the missing 988 octets.
> Now the next time we are called, we enter and we have a remaining
> value still of 988, which triggers the header synchronization error
> path.
The sync is lost because this new URB buffer is not containing the 
expected 988 octets because the 32-bit header word after the end of the 
Ethernet frame appears to be missing. Therefore, probably detected a 
dropped URB which had the 988 octets of the end of the current Ethernet 
frame.
> Now, I'm not sure if the remainder handling logic is sane, or if the
> skb->len being 2048 is problematic, or what.  The skb->lens can vary
> in sizes, usually 1518 during high throughput, but I've seen 1588,
> 1640, and other larger numbers that don't trigger the same problem.
I expect the USB bulk transfer is limited to a maximum transfer size of 
2048 octets eg. max URB buffer size. The ASIX driver code should be 
checked to see where the 2048 limit comes from. I wonder whether 4096 
could be used ?

If the USB to Ethernet adaptor has more data to send than can fit in 
2048 byte buffer then the Ethernet frame needs to be split across 2 URBs.

In the case of 1640 buffer, it probably means 2 Ethernet frames are in 
the buffer:
32-bit header word + 1514 Ethernet frame + 32-bit header word + ((1640 - 
(4 + 1514 +4)) = 118) Ethernet frame
This could be due to IP fragmentation.
>
> ie:
> [  106.946473] JDB set remaining to 1514 (skblen: 1518)
> [  106.946525] JDB set remaining to 1514 (skblen: 1640)
> [  106.946546] JDB set remaining to 118 (skblen: 1640)
Yes, that 118 confirms my reasoning above.
> [  106.946586] JDB set remaining to 1514 (skblen: 1518)
>
>
> So yea.. maybe that will help clue things in a bit? I'm still a bit lost. :)
Your observations are consistent with missing URBs from the USB host 
controller.

Here is a summary of what I think is happening in your case:

Good case:
URB #1: 1514 octets of 1514 Ethernet frame (A)
URB #2: 1514 octets of 1514 Ethernet frame (B) + 526 octets of 1514 
Ethernet frame (C)
URB #3: 988 octets of 1514 Ethernet frame (C)
URB #4: 1514 octets of 1514 Ethernet frame (D)

Therefore, Ethernet frame (C) is spanning URBs #2 and #3.

Bad case, URB #3 is lost:
URB #1: 1514 octets of 1514 Ethernet frame (A)
URB #2: 1514 octets of 1514 Ethernet frame (B) + 526 octets of 1514 
Ethernet frame (C)
Remaining is 988
URB #4: 1514 octets of 1514 Ethernet frame (D)

But when URB #4 is analysed the 32-bit Header word is not found after 
988 octets in the URB buffer so "sync lost".
The end of Ethernet frame (C) is missing so drop the Ethernet frame.
Now look at the start of the URB #4 buffer and find a 32-bit header word 
so Ethernet frame (D) can be consumed.

So I think the commit is acting as intended and you are suffering from 
lost URBs.

So perhaps you have a URB memory allocation issue for the USB host 
controller ? However, this would also mean x86 has the same issue. So 
perhaps it is a bug in common USB kernel code ?

You might find it helpful to get USB analyser logs or use the software 
utility usbmon to grab the USB host controller data. You might then be 
able to compare the data from the USB log with the URB buffer data. This 
might confirm that URBs are going missing.

On the other hand, it was suggested that removing my commit improved 
through-put. Is that really true ? Perhaps you can try an experiment 
where you add test code to add a counter to use my "sync lost" detector 
for 1000 URBs then by-pass the "sync lost" detector for 1000 URBs and 
repeat it cyclically. 1000 is a guess, you might need a higher value. 
Then run some tests to see whether the through-put periodically goes up 
and down in sympathy with the "sync lost" detector being used or not 
being used. Also track the RX error counter from ifconfig to see how 
many bad Ethernet frames got to the IP stack.

Also try using wireshark to see whether you are generating IP fragmented 
frames. Unfortunately, using iperf with IPv6 with defaults will generate 
IPv6 fragmentation causing twice as many Ethernet frames to be sent as 
needed so is inefficient. To fix that, in iperf reduce the data length 
so that the MTU size of 1500 is not exceeded.

The commit only runs when Ethernet frames span URBs which typically 
occurs when IP fragmentation happens or when there is a very high rate 
of Ethernet frames per second.

At least, it is now clear why you see "988 remaining", that is because 
you are using maximum length Ethernet frames and 2 of those frames are 
written into a single URB which means 988 octets of the 2nd Ethernet 
frame goes into the 2nd URB buffer. So that makes sense and is correct.

Regards,
Dean

>
> thanks
> -john


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
