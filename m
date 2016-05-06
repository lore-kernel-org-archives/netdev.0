From: "David B. Robins" <linux@davidrobins.net>
Subject: Re: [REGRESSION] asix: Lots of =?UTF-8?Q?asix=5Frx=5Ffixup=28=29?=
 =?UTF-8?Q?=20errors=20and=20slow=20transmissions?=
Date: Fri, 06 May 2016 16:45:16 -0400
Message-ID: <918e1422f872d1277d28cf2a29e4dac6@i4031.net>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <87ed4c76328ed9dc5591359ea0e98ab9@i4031.net> <57291539.6080405@mentor.com>
 <e4efd48d3c16c27de68d464ad3170b02@i4031.net> <5729AB90.9010704@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	Guodong Xu <guodong.xu@linaro.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-28-9-118.lightspeed.iplsin.sbcglobal.net ([99.28.9.118]:11297
	"EHLO i4031.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758275AbcEFUpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:45:44 -0400
In-Reply-To: <5729AB90.9010704@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-05-04 03:58, Dean Jenkins wrote:
> On 04/05/16 01:28, David B. Robins wrote:
>> 
>>> 
>>> Here is the code snippet from the patch with my annotations between #
>>> #, I will try to explain my intentions. Feel free to point out any
>>> flaws:
>>> 
>>>     if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
>>>         # Only runs when rx->remaining !=0 and the end of the 
>>> Ethernet
>>> frame + next 32-bit header word is within the URB buffer. #
>>>         # Therefore, this code does not run when the end of an
>>> Ethernet frame has been reached in the previous URB #
>>>         # or when the end of the Ethernet frame + next 32-bit header
>>> word will be in a later URB buffer #
>> 
>> It may well be. I don't have the setup with me now, but I can try 
>> tomorrow to reproduce an environment where I can add some more 
>> detailed logging.
>> 
>> Since the URB length has to be >= than the remaining data plus a u32, 
>> the devices that John Stultz and I are using (AX88772B in my case) may 
>> be adding some additional data/padding after an Ethernet frame, 
>> expecting it to be discarded, and running into this check and its 
>> consequences. This may mean the device is badly behaved, if it is 
>> specified not to send anything extra; in any case, a well-intentioned 
>> error correction has gone badly, but I better understand the intent 
>> now. I am curious to know how often the device you are using benefits 
>> from this block of code.
> 
> The issue is that the driver should be robust to cope with missing
> URBs. Whilst testing with D-Link DUB-E100 C1 AX88772 USB to Ethernet
> adaptor in our ARM embedded system which runs in hostile environments,
> it was noticed that URBs could be lost (probably due to a bug
> elsewhere or low memory issue). Without this patch, a missing URB
> causes bad Ethernet frames to be passed up to the IP stack because
> rx->remaining spans multiple URBs.
> 
> In the good case of an Ethernet frame spanning 2 URBs, the 1st URB is
> processed and copies the 1st part of the Ethernet frame into the
> netdev buffer, for the 2nd URB the remaining part of the Ethernet
> frame is copied into the same netdev buffer to complete the Ethernet
> frame. The netdev buffer is then sent up to the IP stack.
> 
> In the case of a missing URB, a bad Ethernet frame is created as 
> follows:
> The 1st URB is processed and copies the 1st part of the Ethernet frame
> into the netdev buffer, the 2nd URB is lost (somehow),  the 3rd URB is
> processed and blindly copies what it thinks is the remaining part of
> the Ethernet frame in the same netdev buffer which corrupts the
> Ethernet frame. The netdev buffer is then sent up to the IP stack. The
> 3rd URB and subsequent URBs are processed but synchronisation has been
> lost so can misread data as a 32-bit header word. It is likely that
> some good Ethernet frames get discarded whilst trying to
> resynchronise.
> 
> A recovery strategy for regaining lock with the 32-bit header word is
> necessary otherwise the driver will have difficulty in recovering from
> a lost URB.
> 
> In the "olden days", the 32-bit header word was always at the start of
> the URB buffer so previous URBs did not influence the current URB. So
> no recovery strategy was needed at that time. But now we have to
> remember what happened in the previous URB and a lost URB can cause a
> discontinuity in the data stream because the data is not always
> aligned to the start of the URB buffer.
> 
> I agree that your environment may never suffer from lost URBs so
> removal of the patch would work OK.
> 
> I will try to find some time to setup a test environment.

I got the chance to add some more logging (and add back the header 
synchronization code) to a system which is receiving video data on an 
8-port POE device using AX88772Bs - it replaces the "Data header 
synchronization was lost" log and logs a few more local items ("u32" = 
rx->header):

[3105478.073908] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3105478.073918] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() Bad Header 
Length 0xf05b7c5f, offset 4
[3105478.074022] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() skb->len = 
2048
[3105478.074032] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() Bad Header 
Length 0xffaae2a5, offset 4
[3105478.074146] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() skb->len = 
1518
[3105478.074280] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() skb->len = 
2048
[3105478.074291] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() Bad Header 
Length 0xe1478400, offset 4
[3105478.074399] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() skb->len = 916
[3105478.074409] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() Bad Header 
Length 0x9fa84eb5, offset 4
[3105478.074657] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() skb->len = 
1518

Grepping for just the SYNC_LOSS messages shows a similar pattern to that 
seen elsewhere in the thread:

[3104761.056033] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.058035] asix 1-1.4.1.3:1.0 poe2: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.076795] asix 1-1.4.2.3:1.0 poe4: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.107904] asix 1-1.4.2.3:1.0 poe4: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.114649] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.121152] asix 1-1.4.1.1:1.0 poe1: asix_rx_fixup() SYNC_LOSS 
remain 988 len 1518 offset 992 u32 0xecf95000
[3104761.147784] asix 1-1.4.1.3:1.0 poe2: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.160535] asix 1-1.4.1.1:1.0 poe1: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.168024] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.168403] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.170654] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.180418] asix 1-1.4.1.1:1.0 poe1: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.221783] asix 1-1.4.1.1:1.0 poe1: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.248784] asix 1-1.4.2.2:1.0 poe7: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.252421] asix 1-1.4.1.2:1.0 poe5: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.262903] asix 1-1.4.2.4:1.0 poe8: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.266904] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.267281] asix 1-1.4.2.4:1.0 poe8: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.271665] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.273915] asix 1-1.4.2.4:1.0 poe8: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.280048] asix 1-1.4.2.4:1.0 poe8: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.287152] asix 1-1.4.2.3:1.0 poe4: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.292157] asix 1-1.4.2.3:1.0 poe4: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.295054] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.310915] asix 1-1.4.1.1:1.0 poe1: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2022 offset 992 u32 0xecf95000
[3104761.316918] asix 1-1.4.2.3:1.0 poe4: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.324935] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.326665] asix 1-1.4.2.3:1.0 poe4: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000
[3104761.336420] asix 1-1.4.1.4:1.0 poe6: asix_rx_fixup() SYNC_LOSS 
remain 988 len 2048 offset 992 u32 0xecf95000

This is an Ubuntu 14.04.2 LTS i686 (32-bit) system running kernel 
3.13.0-53-generic. I don't see any "low-speed" warnings, and lsusb -t 
shows each device (and their hubs) running at 480M.

ifconfig poe1:

poe1      Link encap:Ethernet  HWaddr 00:50:f9:ec:4f:d8
           inet addr:192.168.201.1  Bcast:192.168.201.255  
Mask:255.255.255.0
           inet6 addr: fe80::250:f9ff:feec:4fd8/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:194441 errors:16649 dropped:15 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:267310738 (267.3 MB)  TX bytes:10300282 (10.3 MB)

Without the "sanity test/synchronization" code:

poe1      Link encap:Ethernet  HWaddr 00:50:f9:ec:4f:d8
           inet addr:192.168.201.1  Bcast:192.168.201.255  
Mask:255.255.255.0
           inet6 addr: fe80::250:f9ff:feec:4fd8/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:398910 errors:1 dropped:14 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:513363997 (513.3 MB)  TX bytes:13154142 (13.1 MB)

> 
> Regards,
> Dean

David
