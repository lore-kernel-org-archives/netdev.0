From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v1 2/5] ixgbevf: Add a RETA query code
Date: Thu, 01 Jan 2015 10:09:45 -0800
Message-ID: <54A58D69.7080706@gmail.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com> <1420019519-18139-3-git-send-email-vladz@cloudius-systems.com> <54A439C4.8020004@gmail.com> <54A44188.204@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"tantilov, Emil S" <emil.s.tantilov@intel.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:62125 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbAASJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 13:09:47 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so6964149pdb.39
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 10:09:47 -0800 (PST)
In-Reply-To: <54A44188.204@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2014 10:33 AM, Vlad Zolotarov wrote:
>
> On 12/31/14 20:00, Alexander Duyck wrote:
>> I suspect this code is badly broken as it doesn't take several things
>> into account.
>>
>> First the PF redirection table can have values outside of the range
>> supported by the VF.  This is allowed as the VF can set how many bits of
>> the redirection table it actually wants to use.  This is controlled via
>> the PSRTYPE register.  So for example the PF can be running with 4
>> queues, and the VF can run either in single queue or as just a pair of
>> queues.
>>
>> Second you could compress this data much more tightly by taking
>> advantage of the bit widths allowed.  So for everything x540 and older
>> they only use a 4 bit value per entry.  That means you could
>> theoretically stuff 8 entries per u32 instead of just 4.
>
> Compression is nice but I think ethtool expects it in a certain
> format: one entry per byte. And since this patch is targeting the
> ethtool the output format should be as ethtool expects it to be and
> this is what this patch does. However I agree that masking the
> appropriate bits according to PSRTYPE is required. Good catch!

The idea of compression comes into play when you consider there is
significant latency trying to get messages across the mailbox.  By
reducing the number of messages needed to get the redirection table you
should be able to significantly reduce the amount of time needed to
fetch it.  The job of compressing/expanding the values is actually
pretty straight forward when you consider all that should be needed is a
simple loop to perform some shift, and, and or operations.

- Alex
