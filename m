From: "David B. Robins" <linux@davidrobins.net>
Subject: Re: [REGRESSION] asix: Lots of =?UTF-8?Q?asix=5Frx=5Ffixup=28=29?=
 =?UTF-8?Q?=20errors=20and=20slow=20transmissions?=
Date: Tue, 03 May 2016 20:28:10 -0400
Message-ID: <e4efd48d3c16c27de68d464ad3170b02@i4031.net>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <87ed4c76328ed9dc5591359ea0e98ab9@i4031.net> <57291539.6080405@mentor.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57291539.6080405@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-05-03 17:16, Dean Jenkins wrote:
> On 03/05/16 15:42, David B. Robins wrote:
>> 
>> I don't think the first one is giving you problems (except as 
>> triggered by the second) but I had concerns about the second myself 
>> (and emailed the author off-list, but received no reply), and we did 
>> not take that commit for our own product.
>> 
> Sorry, I might have missed your original E-mail.
> 
>> Specifically, the second change, 3f30... (original patch: 
>> https://www.mail-archive.com/netdev@vger.kernel.org/msg80720.html) (1) 
>> appears to do the exact opposite of what it claims, i.e., instead of 
>> "resync if this looks like a header", it does "resync if this does NOT 
>> look like a (packet) header", where "looks like a header" means "bits 
>> 0-10 (size) are equal to the bitwise-NOT of bits 16-26", and (2) can 
>> happen by coincidence for 1/2048 32-bit values starting a continuation 
>> URB (easy to hit dealing with large volumes of video data as we were). 
>> It appears to expect the header for every URB whereas the rest of the 
>> code at least expects it only once per network packet (look at 
>> following code that only reads it for remaining == 0).
> 
> David, I think that your interpretation is incorrect. Please see below.
> 
> Here is the code snippet from the patch with my annotations between #
> #, I will try to explain my intentions. Feel free to point out any
> flaws:
> 
>     if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
>         # Only runs when rx->remaining !=0 and the end of the Ethernet
> frame + next 32-bit header word is within the URB buffer. #
>         # Therefore, this code does not run when the end of an
> Ethernet frame has been reached in the previous URB #
>         # or when the end of the Ethernet frame + next 32-bit header
> word will be in a later URB buffer #

It may well be. I don't have the setup with me now, but I can try 
tomorrow to reproduce an environment where I can add some more detailed 
logging.

Since the URB length has to be >= than the remaining data plus a u32, 
the devices that John Stultz and I are using (AX88772B in my case) may 
be adding some additional data/padding after an Ethernet frame, 
expecting it to be discarded, and running into this check and its 
consequences. This may mean the device is badly behaved, if it is 
specified not to send anything extra; in any case, a well-intentioned 
error correction has gone badly, but I better understand the intent now. 
I am curious to know how often the device you are using benefits from 
this block of code.

> Regards,
> Dean

David
