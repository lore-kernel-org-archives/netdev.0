From: Rick Jones <rick.jones2@hp.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 15:19:47 -0700
Message-ID: <49C17383.2090909@hp.com>
References: <49C12E64.1000301@us.ibm.com> <87prge1rhu.fsf@basil.nowhere.org>	<49C16294.8050101@us.ibm.com>	<1237412732.29116.2.camel@lb-tlvb-eliezer>	<49C16CD4.3010708@us.ibm.com> <20090318215901.GV11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vernon Mauery <vernux@us.ibm.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090318215901.GV11935@one.firstfloor.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>Thanks.  I will test to see how this affects this lock contention the
>>next time the broadcom hardware is available.
> 
> 
> The other strategy to reduce lock contention here is to use TSO/GSO/USO.
> With that the lock has to be taken less often because there are less packets
> travelling down the stack. I'm not sure how well that works with netperf style 
> workloads though. 

All depends on what the user provides with the test-specific -m option for how 
much data they shove into the socket each time "send" is called, and I suppose if 
they use a test-specific -D option to set TCP_NODELAY in the case of a TCP test 
when they have small values of -m.  Eg

netperf -t TCP_STREAM ... -- -m 64K
vs
netperf -t TCP_STREAM ... -- -m 1024
vs
netperf -t TCP_STREAM ... -- -m 1024 -D
vs
netperf -t UDP_STREAM ... -- -m 1024

etc etc.

If the netperf test is:

netperf -t TCP_RR ... -- -r 1   (single-byte request/response)

then TSO/GSO/USO won't matter at all, and probably still wont matter even if the 
user has ./configure'd netperf with --enable-burst and does:

netperf -t TCP_RR ... -- -r 1 -b 64
or
netperf -t TCP_RR ... -- -r 1 -b 64 -D

which was basically what I was doing for the 32-core scaling stuff I posted about 
a few weeks ago.  That was running on multi-queue NICs, so looking at some of the 
profiles of the "no iptables" data may help show how big/small the problem is, 
keeping in mind that my runs (either the XFrame II runs, or the Chelsio T3C runs 
before them) had one queue per core in the system...and as such may be a best 
case scenario as far as lock contention on a per-queue basis goes.

ftp://ftp.netperf.org/

happy benchmarking,

rick jones

BTW, that setup went "poof" and had to go to other nefarious porpoises.  I'm not 
sure when I can recreate it, but I still have both the XFrame and T3C NICs when 
the HW comes free again.
