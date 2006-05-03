From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on e1000 patch, rx-copy-break related.
Date: Wed, 03 May 2006 11:12:50 -0700
Message-ID: <4458F2A2.60605@candelatech.com>
References: <4457B96A.4030808@candelatech.com> <4807377b0605031022s3b5bfad2x757fbd470884c6fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:3775 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751343AbWECSM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 14:12:57 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0605031022s3b5bfad2x757fbd470884c6fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On 5/2/06, Ben Greear <greearb@candelatech.com> wrote:
> 
>> In commit:  a292ca6efbc1f259ddfb9c902367f2588e0e8b0f
>> to e1000_main.c, there is the change below.
>>
>> I am curious why the skb_put no longer subtracts ETHERNET_FCS_SIZE
>> from the length.  Is the idea that we will now always include the
>> FCS at the end of the skb?
> 
> 
> This is a long and hairy story behind this, but there is a bit called
> SECRC that controls hardware stripping of the CRC.  In *this* driver
> we turned that bit on, so that we didn't have to mess with skb->len -=
> 4 and the nasty negative unwrap if we were using multiple descriptors
> for rx.
> 
> Since then, we've removed multiple descriptor rx.
> 
> And after that, I've discovered that some BMCs are very unhappy if we
> strip CRCs using SECRC.
> 
> So, my related question is: is it okay if we just always leave the CRC
> on the end of the data?  It doesn't seem to harm anything.

I believe it might mess up bridging logic if it tries to send the entire
skb to a peer interface, ie cause an extra 4 bytes to be written.

I know that this 'save-crc' feature did mess up my particular bridge-like
thing, but that could have been just bugs in my code.

Also, if the CRC data is there, but it is never 'put' into the skb, then
it will be correctly ignored by the stacks, including bridging, and hacks
such as my own that simply increase the skb-put by 4 bytes will work.

My personal preference is to set a flag in the skb struct indicating whether
or not the crc is appended (and skb_put).  Then, bridging code can ignore it if needed,
and sniffers and such can get the CRC in user-land.  To remain backwards compat,
at least the skb-put of the crc logic should default to OFF so that we don't
break any existing user-land bridging logic.  I have the ethtool API logic written to
twiddle this save-crc behaviour if someone decides this is worthy of the kernel.


> Well, its a changing picture.  I had planned to eventually enable the
> hardware to strip the CRC if we aren't connected to some kind of
> offboard management.  We'll get there in steps.

So, as of 2.6.16.13, is the hardware stripping (SERC) enabled?  Could
you also let me know where this bit is defined in case I want to twiddle
it myself (a quick grep for SERC in 2.6.16.13 yields nothing.)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

