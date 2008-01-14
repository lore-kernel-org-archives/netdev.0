From: Mark Seger <Mark.Seger@hp.com>
Subject: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 12:20:38 -0500
Message-ID: <478B99E6.2050800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:53922 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188AbYANRVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 12:21:36 -0500
Received: from seeaxp.zko.hp.com (seeaxp.zko.hp.com [16.116.23.219])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by palrel12.hp.com (Postfix) with ESMTP id 5A34534808
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 09:21:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had posted the following on linux-net and haven't see any responses 
possibly because nobody had any or that list is obsolete.  I have been 
told this is the current list for everything networking on linux so I 
thought I'd try again...

I suspect the answer will be that it is what it is, but here's the 
deal.  I have a tool I use for monitoring network traffic among other 
things - see http://collectl.sourceforge.net/ - and one of its benefits  
is that you can run it continuously as a daemon (similar to sar) and 
generate data in a format suitable for plotting.  This means that you 
can automate your entire network monitoring infrastructure at fairly 
fine granularity, down to second if you like.  Actually 1-second level 
monitoring will provide incorrect data on earlier kernels because the 
stats aren't updated on 1 second boundaries and you need to monitor at 
an interval of 0.9765 seconds, but that's a different story which is 
explained at http://collectl.sourceforge.net/NetworkStats.html

But more importantly, I've found that occasionally (not that often) 
there is bogus data reported from /proc/net/dev.  While I don't have a 
lot of details on this it seems to only show up in 64 bit kernels.  Look 
at the following samples taken at 1 second intervals:

 eth0:135115809 1024897    0    0    0     0          0         9 
135458926  910340    0    0    0     0       0          0
 eth0:135118023 1024923    0    0    0     0          0         9 
135460952  910363    0    0    0     0       0          0
 eth0:        0  884620    0    0    0     0          0    909397   
9687563 1049736    0    0    0     0       0          0
 eth0:135121189 1024957    0    0    0     0          0         9 
135464222  910400    0    0    0     0       0          0
 eth0:135129565 1024995    0    0    0     0          0         9 
135473687  910435    0    0    0     0       0          0

see the middle sample?  When I look at the change between samples it 
generates a really big number since the difference is assumed to be 
caused a counter wrapping.  The problem is it's not always 
straightforward when there is bad data.  For example if the original and 
bogus values are close enough it's not even clear there is a problem.

So the obvious question is, is there any way to prevent the bogus data 
from getting reported?   If not, is there any way to set the values to 
something to indicate that the correct values can't be determined?  
Clearly this problem would be visible to any tool that looks at /proc 
but since many tools are not automated or don't take it to the level I 
do, nobody probably notices.  As for the counter update frequency, even 
though they now appear to be updated closer to a 1 second boundary it 
also means tools that can monitor at sub-second intervals will report 
incorrect data since the counters only change once a second.

-mark

