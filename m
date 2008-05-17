From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Sat, 17 May 2008 11:38:16 -0600
Message-ID: <482F1808.4060700@shaw.ca>
References: <fa.LFS/TATb5YijFetLw6A+gczrVAQ@ifi.uio.no>
 <482E3B1B.9070400@shaw.ca> <20080517141235.GA13130@duo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jens Axboe <jens.axboe@oracle.com>, yang.shi@windriver.com
To: Andrea Arcangeli <andrea@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:26382 "EHLO
	pd2mo2so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378AbYEQRgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 13:36:18 -0400
In-reply-to: <20080517141235.GA13130@duo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrea Arcangeli wrote:
> On Fri, May 16, 2008 at 07:55:39PM -0600, Robert Hancock wrote:
>> Arjan van de Ven wrote:
>>> Rank 10: __alloc_pages
>>>     Reported 16 times (31 total reports)
>>>     Sleeping allocation in interrupt context, some in netlink, some in the 
>>> nv sata driver
>>>     This oops was last seen in version 2.6.25.3, and first seen in 
>>> 2.6.18-rc1.
>>>     More info: 
>>> http://www.kerneloops.org/searchweek.php?search=__alloc_pages
>> In the case of the sata_nv error, it appears this is happening now because 
>> blk_queue_bounce_limit is initializing emergency ISA pools which can't be 
>> done under spinlock. This is happening because the code in 
>> blk_queue_bounce_limit now thinks that a 32-bit DMA mask requires 
>> allocating with GFP_DMA. This is only needed for a DMA mask less than 
>> 32-bit, which is what the original code did. It looks like this was broken 
>> by this commit:
> 
> Looks like or you're certain? I ask because I had your exact same
> problem with a regression introduced in 2.6.25-rc, and my patch
> attempted to fix it. It looks like it wasn't enough to fix all of it,
> but at least it looked like to improve things a bit to reduce the
> regression impact without introducing any other problem compared to
> the previous 2.6.25-rc code.

What was the original patch that you were trying to fix? If it's this 
one, it does seem to be wrong:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=419c434c35614609fd0c79d335c134bf4b88b30b

author	Yang Shi <yang.shi@windriver.com>
	Tue, 4 Mar 2008 10:20:51 +0000 (11:20 +0100)
committer	Jens Axboe <jens.axboe@oracle.com>
	Tue, 4 Mar 2008 10:20:51 +0000 (11:20 +0100)

Fix DMA access of block device in 64-bit kernel on some non-x86 systems 
with 4GB or upper 4GB memory

Originally it was using the DMA path only for DMA masks of less than 
32-bit. This change made it use that path for 32-bit or less. Looking 
more closely it doesn't seem like your patch is really harmful, it just 
doesn't completely repair the damage from the first one.

IMO both of these patches should just be reverted. The commit 
description doesn't specify what arch the first one was trying to fix 
but it seems to break x86_64 anyway..
