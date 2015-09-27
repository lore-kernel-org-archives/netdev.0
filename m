From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] netpoll: Drop budget parameter from NAPI polling call
 hierarchy
Date: Sun, 27 Sep 2015 15:58:56 -0700
Message-ID: <560874B0.1080903@gmail.com>
References: <20150922215049.3088.32475.stgit@ahduyck-vm-fedora22>
 <20150926.223631.507670918270362716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36315 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbI0W66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 18:58:58 -0400
Received: by pablk4 with SMTP id lk4so58535599pab.3
        for <netdev@vger.kernel.org>; Sun, 27 Sep 2015 15:58:58 -0700 (PDT)
In-Reply-To: <20150926.223631.507670918270362716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2015 10:36 PM, David Miller wrote:
> From: Alexander Duyck <aduyck@mirantis.com>
> Date: Tue, 22 Sep 2015 14:56:08 -0700
>
>> Rather than carry around a value of budget that is 0 or less we can instead
>> just loop through and pass 0 to each napi->poll call.  If any driver
>> returns a value for work done that is non-zero then we can report that
>> driver and continue rather than allowing a bad actor to make the budget
>> value negative and pass that negative value to napi->poll.
> Unfortunately we have drivers that won't do any TX work if the budget
> is zero.

Well that is what we are doing right now.  The fact is the call starts 
out with a budget of 0, and it is somewhat hidden from the call since 
the budget is assigned a value of 0 in netpoll_poll_dev. That is one of 
the things I was wanting do address because that is clear as mud from 
looking at poll_one_napi.  Based on the code you would assume budget 
starts out as a non-zero value and it doesn't.

> Using the budget for TX work is unfortunate and not the recommended
> way for drivers to do things, but it's not explicitly disallowed
> either.
>
> So I'm not applying this because it definitely has the potential
> to break something.
>
> Sorry.

I don't see how this introduces a regression when all I am doing is 
avoiding tracking a value that should be 0 assuming everything is 
working correctly.  If work returns a non-zero value with the code as it 
currently is then the WARN_ONCE is triggered, and the value of budget is 
becoming negative.  I would consider a negative budget value worse than 
a 0 budget value.

I'll go back through the patch and rebase it since it looks like Neil 
had to submit a v3 of his patch and it may have impacted mine. However 
perhaps we need to revisit this code if you think it is risky as the 
only thing my changes did is remove the ability for the budget value to 
go from 0 to negative and then passing that negative value into the 
function.

- Alex
