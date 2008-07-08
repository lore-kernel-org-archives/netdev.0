From: Rick Jones <rick.jones2@hp.com>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 18:15:01 -0700
Message-ID: <4872BF95.9030209@hp.com>
References: <20080707142408.43aa2a2e@extreme>	<48728B09.1050801@citi.umich.edu>	<48729DAD.8010400@hp.com>	<20080707.160029.13296246.davem@davemloft.net> <4872A652.2050709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, rees@umich.edu, bfields@fieldses.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:36423 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264AbYGHBPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 21:15:06 -0400
In-Reply-To: <4872A652.2050709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> David Miller wrote:
> 
>> We need 2x, in order to have a full window during recovery.
>>
>> There was a measurement bug found a few months ago when the
>> google folks were probing in this area, which was fixed
>> by John Heffner.  Most of which had to deal with TSO subtleties.
>>
>> --------------------
>> commit 246eb2af060fc32650f07203c02bdc0456ad76c7
>> ...
>> commit ce447eb91409225f8a488f6b7b2a1bdf7b2d884f
>> ...
> I'll try my tests again with newer kernels since I'm not 100% certain I 
> was trying with those commits in place.

Did those commits make it into 2.6.26-rc9?  (Gentle taps of clue-bat as 
to how to use git to check commits in various trees would be welcome - 
to say I am a git noob would be an understatement - the tree from which 
that kernel was made was cloned from Linus' about 16:00 to 17:00 pacific 
time)

Assuming they did, a pair of systems with tg3-driven BCM5704's:

moe:~# ethtool -i eth0
driver: tg3
version: 3.92.1
firmware-version: 5704-v3.27
bus-info: 0000:01:02.0
moe:~# uname -a
Linux moe 2.6.26-rc9-raj #1 SMP Mon Jul 7 17:26:15 PDT 2008 ia64 GNU/Linux

with TSO enabled still takes the socket buffers all the way out to 4MB 
for a GbE LAN test:
moe:~# netperf -t omni -H manny -- -o foo
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to manny.west 
(10.208.0.13) port 0 AF_INET
Throughput,Local Send Socket Size Requested,Local Send Socket Size 
Initial,Local Send Socket Size Final,Remote Recv Socket Size 
Requested,Remote Recv Socket Size Initial,Remote Recv Socket Size Final
941.41,-1,16384,4194304,-1,87380,4194304

When a 64K socket buffer request was sufficient:
moe:~# netperf -t omni -H manny -- -o foo -s 64K -S 64K -m 16K
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to manny.west 
(10.208.0.13) port 0 AF_INET
Throughput,Local Send Socket Size Requested,Local Send Socket Size 
Initial,Local Send Socket Size Final,Remote Recv Socket Size 
Requested,Remote Recv Socket Size Initial,Remote Recv Socket Size Final
941.12,65536,131072,131072,65536,131072,131072


FWIW, disabling TSO via ethtool didn't seem to change the behaviour:

moe:~# ethtool -K eth0 tso off
moe:~# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
moe:~# netperf -t omni -H manny -- -o foo
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to manny.west 
(10.208.0.13) port 0 AF_INET
Throughput,Local Send Socket Size Requested,Local Send Socket Size 
Initial,Local Send Socket Size Final,Remote Recv Socket Size 
Requested,Remote Recv Socket Size Initial,Remote Recv Socket Size Final
941.40,-1,16384,4194304,-1,87380,4194304

If I was cloning off the wrong tree, my apologies and redirects to the 
correct tree would be gladly accepted.

rick jones

moe:~# cat foo
throughput,lss_size_req,lss_size,lss_size_end,rsr_size_req,rsr_size,rsr_size_end
