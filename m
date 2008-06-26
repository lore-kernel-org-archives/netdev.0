From: "Chris Friesen" <cfriesen@nortel.com>
Subject: wacky select timeout behaviour in strace
Date: Thu, 26 Jun 2008 10:48:42 -0600
Message-ID: <4863C86A.4080903@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:37551 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbYFZRtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 13:49:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got something odd in a couple of recent strace logs (running on an 
older kernel, I haven't yet tried to reproduce in mainline).

First case:

20418 22:06:50.583303 select(19, [7 11 12 13 14 15 16 17 18], NULL, 
NULL, {0, 498508}) = 1 (in [11], left {0, 0}) <5.074137>

select() was called with a timeout of half a second.  Five seconds later 
it returns with zero time left and a single socket readable.  Why 
wouldn't it have returned after half a second with a timeout?



Second case:

18383 01:46:23.572951 select(16, [15], NULL, NULL, {1, 0}) = 1 (in [15], 
left {0, 732000}) <1.337443>

Here we call select with a timeout of 1 sec, then 1.3337 sec later we 
return saying that we have 732ms left to sleep.

In addition, there was an interval timer set up to fire every 500ms, and 
it didn't interrupt the select call.  It did fire 60ms after the select 
call returned.  Interestingly, the timing of that firing (x.97 sec) 
didn't match the normal times (x.07 and x.57), but it then returned to 
the normal times after the single abnormal firing.

Anyone have any ideas what's going on?  This doesn't appear to be an 
strace artifact, as I can reproduce it without tracing the process in 
question.  It also doesn't appear to be a system-wide artifact as I know 
from instrumentation that other tasks are running during this interval.

Thanks,

Chris
