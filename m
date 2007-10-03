From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 03 Oct 2007 09:42:34 -0400
Message-ID: <1191418954.4357.49.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>
	 <1190570205.4256.56.camel@localhost> <1190570317.4256.59.camel@localhost>
	 <1190570409.4256.62.camel@localhost> <1191178346.6165.29.camel@localhost>
	 <20071001001135.75d2b984.billfink@mindspring.com>
	 <1191245440.4378.12.camel@localhost>
	 <20071002002502.fe0f2bb3.billfink@mindspring.com>
	 <1191331238.4353.59.camel@localhost>
	 <20071003012929.d28f7cd8.billfink@mindspring.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:17610 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbXJCNmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 09:42:40 -0400
Received: by nz-out-0506.google.com with SMTP id s18so3259814nze
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 06:42:39 -0700 (PDT)
In-Reply-To: <20071003012929.d28f7cd8.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-03-10 at 01:29 -0400, Bill Fink wrote:

> It does sound sensible.  My own decidedly non-expert speculation
> was that the big 30 % performance hit right at 4 KB may be related
> to memory allocation issues or having to split the skb across
> multiple 4 KB pages.  

plausible. But i also worry it could be 10 other things; example, could
it be the driver used? I noted in my udp test the oddity that turned out
to be tx coal parameter related.
In any case, I will attempt to run those tests later.

> And perhaps it only affected the single
> process case because with multiple processes lock contention may
> be a bigger issue and the xmit batching changes would presumably
> help with that.  I am admittedly a novice when it comes to the
> detailed internals of TCP/skb processing, although I have been
> slowly slogging my way through parts of the TCP kernel code to
> try and get a better understanding, so I don't know if these
> thoughts have any merit.

You do bring up issues that need to be looked into and i will run those
tests.
Note, the effectiveness of batching becomes evident as the number of
flows grows. Actually, scratch that: It becomes evident if you can keep
the tx path busyed out to which multiple users running contribute. If i
can have a user per CPU with lots of traffic to send, i can create that
condition. It's a little boring in the scenario where the bottleneck is
the wire but it needs to be checked.

> BTW does anyone know of a good book they would recommend that has
> substantial coverage of the Linux kernel TCP code, that's fairly
> up-to-date and gives both an overall view of the code and packet
> flow as well as details on individual functions and algorithms,
> and hopefully covers basic issues like locking and synchronization,
> concurrency of different parts of the stack, and memory allocation.
> I have several books already on Linux kernel and networking internals,
> but they seem to only cover the IP (and perhaps UDP) portions of the
> network stack, and none have more than a cursory reference to TCP.  
> The most useful documentation on the Linux TCP stack that I have
> found thus far is some of Dave Miller's excellent web pages and
> a few other web references, but overall it seems fairly skimpy
> for such an important part of the Linux network code.

Reading books or magazines may end up busying you out with some small
gains of knowledge at the end. They tend to be outdated fast. My advice
is if you start with a focus on one thing, watch the patches that fly
around on that area and learn that way. Read the code to further
understand things then ask questions when its not clear. Other folks may
have different views. The other way to do it is pick yourself some task
to either add or improve something and get your hands dirty that way. 

> It would be good to see some empirical evidence that there aren't
> any unforeseen gotchas for larger packet sizes, that at least the
> same level of performance can be obtained with no greater CPU
> utilization.

Reasonable - I will try with 9K after i move over to the new tree from
Dave and make sure nothing else broke in the previous tests.
And when all looks good, i will move to TCP.


> > [1] On average i spend 10x more time performance testing and analysing
> > results than writting code.
> 
> As you have written previously, and I heartily agree with, this is a
> very good practice for developing performance enhancement patches.

To give you a perspective, the results i posted were each run 10
iterations per packet size per kernel. Each run is 60 seconds long. I
think i am past that stage for resolving or fixing anything for UDP or
pktgen, but i need to keep checking for any new regressions when Dave
updates his tree. Now multiply that by 5 packet sizes (I am going to add
2 more) and multiply that by 3-4 kernels. Then add the time it takes to
sift through the data and collect it then analyze it and go back to the
drawing table when something doesnt look right.  Essentially, it needs a
weekend ;->

cheers,
jamal

