From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: e1000e max frame calculation
Date: Mon, 06 Apr 2015 11:38:47 -0700
Message-ID: <5522D2B7.2050502@redhat.com>
References: <5522B685.2030104@cchtml.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org
To: Michael Cronenworth <mike@cchtml.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51508 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292AbbDFSix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 14:38:53 -0400
In-Reply-To: <5522B685.2030104@cchtml.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/06/2015 09:38 AM, Michael Cronenworth wrote:
> Hello,
>
> I have attempted to discuss this with upstream directly[1], but they 
> will not respond to me. I will now attempt here.
>
> The e1000e driver uses a different maximum frame calculation after a 
> commit[2] in kernel 3.15. This caused everyone's setups that were 
> using 9000 for MTU to break after they rebooted on their kernel 
> update. The addition of the VLAN bytes force users to use 8996.
>
> Other drivers appear to be using the "old" maximum frame calculation 
> and can continue to use 9000.
>
> Can a standard be decided upon that all drivers use or is it 
> acceptable that one driver "does its own thing?"
>
> Thanks,
> Michael

What do you mean by "does its own thing"?  The problem here (I'm 
assuming, please correct me if I am wrong) is that the e1000e hardware 
is configured with a maximum frame size of 9018 based on the 
max_hw_frame_size value reported in the e1000_info struct for your 
part.  As a result you are limited to 8996 since it is forced to 
guarantee there is enough room for 1 VLAN header (4 bytes), the Ethernet 
header (14 bytes), and a CRC (4 bytes).  What you would need to 
determine is the reason why the hardware is limited to 9018, and not 
something like 9216 (9K) which is the more common value since it is 
rounded of to the nearest 1K.

Every piece of hardware will do things differently.  Within just the 
e1000e driver there are some parts that don't support jumbo frames, and 
some that only support 4K jumbo frames.  What would need to be 
determined is if 9018 is the actual limit on the hardware due to some 
limitation in the part, or if it was just an arbitrary value that was 
added by a developer so that it would come out at 9000 for a limit when 
changing the MTU.

- Alex
