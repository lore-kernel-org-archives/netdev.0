From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Wed, 4 May 2016 08:58:08 +0100
Message-ID: <5729AB90.9010704@mentor.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <87ed4c76328ed9dc5591359ea0e98ab9@i4031.net> <57291539.6080405@mentor.com>
 <e4efd48d3c16c27de68d464ad3170b02@i4031.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	Guodong Xu <guodong.xu@linaro.org>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	Ivan Vecera <ivecera@redhat.com>
To: "David B. Robins" <linux@davidrobins.net>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e4efd48d3c16c27de68d464ad3170b02@i4031.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/05/16 01:28, David B. Robins wrote:
>
>>
>> Here is the code snippet from the patch with my annotations between #
>> #, I will try to explain my intentions. Feel free to point out any
>> flaws:
>>
>>     if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
>>         # Only runs when rx->remaining !=0 and the end of the Ethernet
>> frame + next 32-bit header word is within the URB buffer. #
>>         # Therefore, this code does not run when the end of an
>> Ethernet frame has been reached in the previous URB #
>>         # or when the end of the Ethernet frame + next 32-bit header
>> word will be in a later URB buffer #
>
> It may well be. I don't have the setup with me now, but I can try 
> tomorrow to reproduce an environment where I can add some more 
> detailed logging.
>
> Since the URB length has to be >= than the remaining data plus a u32, 
> the devices that John Stultz and I are using (AX88772B in my case) may 
> be adding some additional data/padding after an Ethernet frame, 
> expecting it to be discarded, and running into this check and its 
> consequences. This may mean the device is badly behaved, if it is 
> specified not to send anything extra; in any case, a well-intentioned 
> error correction has gone badly, but I better understand the intent 
> now. I am curious to know how often the device you are using benefits 
> from this block of code.

The issue is that the driver should be robust to cope with missing URBs. 
Whilst testing with D-Link DUB-E100 C1 AX88772 USB to Ethernet adaptor 
in our ARM embedded system which runs in hostile environments, it was 
noticed that URBs could be lost (probably due to a bug elsewhere or low 
memory issue). Without this patch, a missing URB causes bad Ethernet 
frames to be passed up to the IP stack because rx->remaining spans 
multiple URBs.

In the good case of an Ethernet frame spanning 2 URBs, the 1st URB is 
processed and copies the 1st part of the Ethernet frame into the netdev 
buffer, for the 2nd URB the remaining part of the Ethernet frame is 
copied into the same netdev buffer to complete the Ethernet frame. The 
netdev buffer is then sent up to the IP stack.

In the case of a missing URB, a bad Ethernet frame is created as follows:
The 1st URB is processed and copies the 1st part of the Ethernet frame 
into the netdev buffer, the 2nd URB is lost (somehow),  the 3rd URB is 
processed and blindly copies what it thinks is the remaining part of the 
Ethernet frame in the same netdev buffer which corrupts the Ethernet 
frame. The netdev buffer is then sent up to the IP stack. The 3rd URB 
and subsequent URBs are processed but synchronisation has been lost so 
can misread data as a 32-bit header word. It is likely that some good 
Ethernet frames get discarded whilst trying to resynchronise.

A recovery strategy for regaining lock with the 32-bit header word is 
necessary otherwise the driver will have difficulty in recovering from a 
lost URB.

In the "olden days", the 32-bit header word was always at the start of 
the URB buffer so previous URBs did not influence the current URB. So no 
recovery strategy was needed at that time. But now we have to remember 
what happened in the previous URB and a lost URB can cause a 
discontinuity in the data stream because the data is not always aligned 
to the start of the URB buffer.

I agree that your environment may never suffer from lost URBs so removal 
of the patch would work OK.

I will try to find some time to setup a test environment.

Regards,
Dean

-- 
Dean Jenkins
Embedded Software Engineer
Linux Transportation Solutions
Mentor Embedded Software Division
Mentor Graphics (UK) Ltd.
