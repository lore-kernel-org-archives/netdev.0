From: Arun Sharma <asharma@fb.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Thu, 26 May 2011 12:30:04 -0700
Message-ID: <4DDEAA3C.7020502@fb.com>
References: <201104250033.03401.maxi@daemonizer.de>	 <1303878240.2699.41.camel@edumazet-laptop>	 <1303878771.2699.44.camel@edumazet-laptop>	 <201104271352.00601.maxi@daemonizer.de>	 <20110512211033.GA3468@dev1756.snc6.facebook.com>	 <1305234953.2831.2.camel@edumazet-laptop>	 <20110524213327.GA3917@dev1756.snc6.facebook.com>	 <1306291469.3305.11.camel@edumazet-laptop>	 <20110525060609.GA32244@dev1756.snc6.facebook.com> <1306305331.3305.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmail015.snc4.facebook.com ([66.220.144.147]:47365 "EHLO
	mx-out.facebook.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756933Ab1EZT3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 15:29:43 -0400
In-Reply-To: <1306305331.3305.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/24/11 11:35 PM, Eric Dumazet wrote:

>> Another possibility is to do the list_empty() check twice. Once without
>> taking the lock and again with the spinlock held.
>>
>
> Why ?
>

Part of the problem is that I don't have a precise understanding of the 
race condition that's causing the list to become corrupted.

All I know is that doing it under the lock fixes it. If it's slowing 
things down, we do a check outside the lock (since it's cheap). But if 
we get the wrong answer, we verify it again under the lock.

> list_del_init(&p->unused); (done under lock of course) is safe, you can
> call it twice, no problem.

Doing it twice is not a problem. But doing it when we shouldn't be doing 
it could be the problem.

The list modification under unused_peers.lock looks generally safe. But 
the control flow (based on refcnt) done outside the lock might have races.

Eg: inet_putpeer() might find the refcnt go to zero, but before it adds 
it to the unused list, another thread may be doing inet_getpeer() and 
set refcnt to 1. In the end, we end up with a node that's potentially in 
use, but ends up on the unused list.

  -Arun
