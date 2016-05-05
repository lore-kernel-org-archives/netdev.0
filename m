From: Guodong Xu <guodong.xu@linaro.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Thu, 5 May 2016 20:19:13 +0800
Message-ID: <CAFGCpxyeXkbQXW6Dm9ZpUXpVDWgaQziPnsC9GcZPqeg5jnbJUA@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<57286E15.2080900@mentor.com>
	<CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
	<5728837D.60702@mentor.com>
	<CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
	<572B0023.9060505@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37397 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbcEEMTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 08:19:15 -0400
Received: by mail-ig0-f170.google.com with SMTP id s8so11950443ign.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 05:19:14 -0700 (PDT)
In-Reply-To: <572B0023.9060505@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 May 2016 at 16:11, Dean Jenkins <Dean_Jenkins@mentor.com> wrote:
> On 05/05/16 00:45, John Stultz wrote:
>>
>> On Tue, May 3, 2016 at 3:54 AM, Dean Jenkins <Dean_Jenkins@mentor.com>
>> wrote:
>>>
>>> On 03/05/16 11:04, Guodong Xu wrote:
>>>>
>>>> did you test on ARM 64-bit system or ARM 32-bit? I ask because HiKey
>>>> is an ARM 64-bit system. I suggest we should be careful on that. I saw
>>>> similar issues when transferring to a 64-bit system in other net
>>>> drivers.
>>>
>>> We used 32-bit ARM and never tested on 64-bit ARM so I suggest that the
>>> commits need to be reviewed with 64-bit OS in mind.
>>>>
>>>>
>>>> Do you have any suggestion on this regard?
>>>
>>> Try testing on a Linux PC x86 32-bit OS which has has a kernel containing
>>> my
>>> ASIX commits. This will help to confirm whether the failure is related to
>>> 32-bit or 64-bit OS. Then try with Linux PC x86 64-bit OS, this should
>>> fail
>>> otherwise it points to something specific in your ARM 64-bit platform.
>>
>> Just as a sample point, I have managed to reproduce exactly this issue
>> on an x86_64 system by simply scp'ing a large file.
>
> Please tell us the x86_64 kernel version number that you used and which
> Linux Distribution it was ? This allows other people a chance to reproduce
> your observations.
>
>>
>> [  417.819276] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
>> synchronisation was lost, remaining 988
>
> It is interesting that the reported "remaining" value is 988. Is 988 always
> shown ? I mean that do you see any other "remaining" values for the "Data
> Header synchronisation was lost" error message ?
>
>> [  417.823415] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0xef830347, offset 4
>
> The gap in the timestamps shows 417.823415 - 417.819276 = 0.004139 = 4ms
> which is a large gap in terms of USB 2.0 high speed communications. This gap
> is expected to be in the 100us range for consecutive URBs. So 4ms is
> strange.
>
> The expectation is that the "Data Header synchronisation was lost" error
> message resets the 32-bit header word synchronisation to the start of the
> next URB buffer. The "Bad Header Length, offset 4" is the expected outcome
> for the next URB because it is unlikely the 32-bit header word is at the
> start of URB buffer due to Ethernet frames spanning across URBs.
>>
>> [  417.827502] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x31e2b348, offset 4
>
> Timestamps show the gap to be 4ms which is strange for USB 2.0 high speed,
> are you sure high speed mode is being used ?
>>
>> [  417.843779] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
>> synchronisation was lost, remaining 988
>> [  417.847921] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x8af91035, offset 4
>> [  417.852004] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x8521fa03, offset 4
>> [  418.273394] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
>> synchronisation was lost, remaining 988
>> [  418.277532] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x33cd9c7c, offset 4
>> [  418.281683] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x3d850896, offset 4
>> [  418.286227] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0x86443357, offset 4
>> [  418.290319] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
>> 0xee6c81d1, offset 4
>>
>> I don't have any 32bit x86 installs around so I'm not sure I can easly
>> test there, but its clear its not arm64 specific.
>
> I agree the issue is not specific to your ARM 64 bit platform.
>
> Please can you supply the output of ifconfig for the USB to Ethernet
> adaptor, your example above shows eth1 as the device.
>
> Please show the output of ifconfig eth1 before and after the issue is seen.
> This will show us whether the kernel logs any network errors and how many
> bytes have been transferred.
>
> After the issue is seen, please can you show us the output of "dmesg | grep
> asix" so that we can see status messages from the ASIX driver that the USB
> to Ethernet adaptor is using. In particular we need to check that USB high
> speed operation (480Mbps) is being used and not full speed operation
> (12Mbps).

Hi, Dean

I am not sure why do you insist 'not full speed'. Actually, the tests
I run on ARM-64bit is at USB full speed mode. I pasted my log here:
http://paste.ubuntu.com/16236442/
, which includes the information you requested above, ifconfig, dmesg.
The interval between two consecutive errors varies from 10 to 40ms.

> It is interesting that the reported "remaining" value is 988. Is 988 always
> shown ? I mean that do you see any other "remaining" values for the "Data
> Header synchronisation was lost" error message ?

Yes and No. When doing iperf test in TCP mode, always 988. I have
never seen other "remaining" value.

But,
1. I tried "ping -f -s 1400 [my.arm.64bit.board.ip]", but this cannot
trigger the error.
2. Tried iperf in UDP mode, I saw "Data Header synchronisation was
lost" remaining value is 984 (again, seemingly always in several
tries). Log is pasted here. http://paste.ubuntu.com/16236764/

-Guodong Xu

>
> Thanks,
>
> Regards,
> Dean
>
>>
>> thanks
>> -john
>
>
>
> --
> Dean Jenkins
> Embedded Software Engineer
> Linux Transportation Solutions
> Mentor Embedded Software Division
> Mentor Graphics (UK) Ltd.
>
