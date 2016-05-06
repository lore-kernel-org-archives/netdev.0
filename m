From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Fri, 6 May 2016 16:00:24 +0100
Message-ID: <572CB188.7050203@mentor.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <57286E15.2080900@mentor.com>
 <CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
 <5728837D.60702@mentor.com>
 <CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
 <572B0023.9060505@mentor.com>
 <CAFGCpxyeXkbQXW6Dm9ZpUXpVDWgaQziPnsC9GcZPqeg5jnbJUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>
To: Guodong Xu <guodong.xu@linaro.org>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:55325 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758514AbcEFPAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 11:00:30 -0400
In-Reply-To: <CAFGCpxyeXkbQXW6Dm9ZpUXpVDWgaQziPnsC9GcZPqeg5jnbJUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/16 13:19, Guodong Xu wrote:
> Hi, Dean
>
> I am not sure why do you insist 'not full speed'. Actually, the tests
> I run on ARM-64bit is at USB full speed mode. I pasted my log here:
> http://paste.ubuntu.com/16236442/
> , which includes the information you requested above, ifconfig, dmesg.
> The interval between two consecutive errors varies from 10 to 40ms.
>

Your log from http://paste.ubuntu.com/16236442/ shows high speed for 
device 3 is not being used:

[    3.586968] usb 1-1: new full-speed USB device number 2 using dwc2
[    3.792091] usb 1-1: not running at top speed; connect to a high 
speed hub
[    3.800477] hub 1-1:1.0: USB hub found
[    3.803658] hub 1-1:1.0: 3 ports detected
[    4.086636] usb 1-1.2: new full-speed USB device number 3 using dwc2
[    4.202209] usb 1-1.2: not running at top speed; connect to a high 
speed hub
[    8.851236] asix 1-1.2:1.0 eth0: register 'asix' at 
usb-f72c0000.usb-1.2, ASIX AX88772B USB 2.0 Ethernet, 00:0e:c6:fa:bf:fd

Hopefully, you know USB 2.0 high speed (480Mbps) is faster than full 
speed (12Mbps) mode.

Therefore, your USB to Ethernet Adaptor is not running in its optimal 
"normal" high speed operation and there is a USB hub in the way that is 
not running at USB high speed mode. This is an abnormal configuration 
and potentially explains some of your failure observations.

Running at full-speed (12Mbps) mode would explain why the timestamps has 
gaps of ms rather than us gaps (for 480Mbps).

In other words, the full-speed hub is restricting the USB to Ethernet 
Adaptor to a 12Mbps (half-duplex) bandwidth to support Ethernet 100Mbps 
(full-duplex) traffic. That is not going to work very well because 
Ethernet frames (perhaps partial Ethernet frames) need to be discarded 
within the USB link.

Your ifconfig output from http://paste.ubuntu.com/16236442/ shows 249 errors

eth0      Link encap:Ethernet  HWaddr 00:0e:c6:fa:bf:fd
           inet addr:192.168.1.11  Bcast:192.168.1.255 Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:865 errors:249 dropped:0 overruns:0 frame:0
           TX packets:880 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1228273 (1.1 MiB)  TX bytes:68955 (67.3 KiB)

Before the test
RX packets:28 errors:0 dropped:0 overruns:0 frame:0

After the test
RX packets:865 errors:249 dropped:0 overruns:0 frame:0

Good test packets = 865 - 28 = 837
Detected bad Ethernet frames = 249

Bad to good ratio is 249:837 = 1:3.36 so 1 detected bad Ethernet frame 
per 3.36 good Ethernet frames


Your ifconfig output from http://paste.ubuntu.com/16236764/ shows 1282 
errors

eth0      Link encap:Ethernet  HWaddr 00:0e:c6:fa:bf:fd
           inet addr:192.168.1.11  Bcast:192.168.1.255 Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:55 errors:1282 dropped:0 overruns:0 frame:0
           TX packets:64 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:14287 (13.9 KiB)  TX bytes:7639 (7.4 KiB)

Before the test
RX packets:19 errors:0 dropped:0 overruns:0 frame:0

After the test
RX packets:55 errors:1282 dropped:0 overruns:0 frame:0

Good test packets = 55 - 19 = 36
Detected bad Ethernet frames = 1282

Bad to good ratio is 1282:36 = 1:0.28 so 1 detected bad Ethernet frame 
per 0.028 good Ethernet frames

This suggests a very high error rate.


>> It is interesting that the reported "remaining" value is 988. Is 988 always
>> shown ? I mean that do you see any other "remaining" values for the "Data
>> Header synchronisation was lost" error message ?
> Yes and No. When doing iperf test in TCP mode, always 988. I have
> never seen other "remaining" value.
>
> But,
> 1. I tried "ping -f -s 1400 [my.arm.64bit.board.ip]", but this cannot
> trigger the error.
> 2. Tried iperf in UDP mode, I saw "Data Header synchronisation was
> lost" remaining value is 984 (again, seemingly always in several
> tries). Log is pasted here. http://paste.ubuntu.com/16236764/
>
In http://paste.ubuntu.com/16236764/ you see very many
[   41.938370] asix 1-1.2:1.0 eth0: asix_rx_fixup() Bad Header Length 
0x11400040, offset 4

but only a few
[   42.214607] asix 1-1.2:1.0 eth0: asix_rx_fixup() Data Header 
synchronisation was lost, remaining 984

This suggests that the "Bad Header Length" and "Data Header 
synchronisation was lost" error messages are not related to consecutive 
URBs. The expectation is that a "Data Header synchronisation was lost" 
error message is immediately followed by a "Bad Header Length" message 
with a timestamp much less than 1ms (for high speed USB). This is 
because an Ethernet frame that spans URBs needs low latency so should be 
sent quickly in consecutive URBs.

The Bad Header Length error messages with offset 4 indicates that 32-bit 
header word was not found in the expected location at the start of the 
URB buffer.
[   41.938370] asix 1-1.2:1.0 eth0: asix_rx_fixup() Bad Header Length 
0x11400040, offset 4

This evidence is suggesting either the data stream is garbled such as by 
many dropped URBs or lost partial Ethernet frames, or the ASIX protocol 
for the AX88772B chipset differs from the AX88772 chipset so the ASIX 
driver is looking in the wrong place for the 32-bit header word. I 
suspect data is lost due to the restricted 12Mbps bandwidth.


My conclusion is that your USB to Ethernet Adaptor is not running at 
high speed (480Mbps) mode which is causing a partial loss (corruption) 
of Ethernet frames across the USB link. A USB Protocol Analyser or 
software tool usbmon could be used to confirm this scenario.

Therefore please retest with a working high-speed USB hub or remove the 
full-speed USB hub from the test environment and directly connect the 
USB to Ethernet Adaptor to the root hub of the USB port. Then repeat the 
tests to see whether anything improved.

In other words, you need to eliminate the dmesg messages saying "not 
running at top speed; connect to a high speed hub".

Best regards,
Dean

> -Guodong Xu
>
>

-- 
Dean Jenkins
Embedded Software Engineer
Linux Transportation Solutions
Mentor Embedded Software Division
Mentor Graphics (UK) Ltd.
