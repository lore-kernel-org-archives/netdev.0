From: Rick Jones <rick.jones2@hp.com>
Subject: Re: L2 network namespaces + macvlan performances
Date: Mon, 09 Jul 2007 09:59:06 -0700
Message-ID: <4692695A.8000301@hp.com>
References: <468E724F.9070505@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:57470 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbXGIRAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 13:00:16 -0400
In-Reply-To: <468E724F.9070505@bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Between the "normal" case and the "net namespace + macvlan" case, 
> results are  about the same for both the throughput and the local CPU 
> load for the following test types: TCP_MAERTS, TCP_RR, UDP_STREAM, UDP_RR.
> 
> macvlan looks like a very good candidate for network namespace in these 
> cases.
> 
> But, with the TCP_STREAM test, I observed the CPU load is about the
> same (that's what we wanted) but the throughput decreases by about 5%:
> from 850MB/s down to 810MB/s.
> I haven't investigated yet why the throughput decrease in the case.
> Does it come from my setup, from macvlan additional treatments, other? I 
> don't know yet

Given that your "normal" case doesn't hit link-rate on the TCP_STREAM, 
but it does with UDP_STREAM, it could be that there isn't quite enough 
TCP window available, particularly given it seems the default settings 
for sockets/windows are in use.  You might try your normal case with the 
test-specific -S and -s options to increase the socket buffer size:

netperf -H 192.168.76.1 -i 30,3 -l 20 -t TCP_STREAM -- -m 1400 -S 128K 
-S 128K

and see if that gets you link-rate.  One other possibility there is the 
use of the 1400 byte send - that probably doesn't interact terribly well 
with TSO.  Also, it isn't (?) likely the MSS for the connection, which 
you can have reported by adding a "-v 2" to the global options.  You 
could/should then use the MSS in a subsequent test, or perhaps better 
still use a rather larger send size for TCP_STREAM|TCP_MAERTS - I myself 
for no particular reason tend to use either 32KB or 64KB as the send 
size in the netperf TCP_STREAM tests I run.

A final WAG - that the 1400 byte send size interacted poorly with the 
Nagle algorithm since it was a sub-MSS send.  When Nagle is involved, 
things can be very timing-sensitive, change the timing ever so slightly 
and you can have a rather larger change in throughput. That could be 
dealt-with either with the larger send sizes mentioned above, or by 
adding a test-specific -D option to set TCP_NODELAY.

happy benchmarking,

rick jones
