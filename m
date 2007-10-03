From: Bill Fink <billfink@mindspring.com>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 3 Oct 2007 01:29:29 -0400
Message-ID: <20071003012929.d28f7cd8.billfink@mindspring.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
	<1190570409.4256.62.camel@localhost>
	<1191178346.6165.29.camel@localhost>
	<20071001001135.75d2b984.billfink@mindspring.com>
	<1191245440.4378.12.camel@localhost>
	<20071002002502.fe0f2bb3.billfink@mindspring.com>
	<1191331238.4353.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, jeff@garzik.org, rdreier@cisco.com,
	mcarlson@broadcom.com, general@lists.openfabrics.org,
	sri@us.ibm.com, jagana@us.ibm.com, mchan@broadcom.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	tgraf@suug.ch, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191331238.4353.59.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Oct 2007, jamal wrote:

> On Tue, 2007-02-10 at 00:25 -0400, Bill Fink wrote:
> 
> > One reason I ask, is that on an earlier set of alternative batching
> > xmit patches by Krishna Kumar, his performance testing showed a 30 %
> > performance hit for TCP for a single process and a size of 4 KB, and
> > a performance hit of 5 % for a single process and a size of 16 KB
> > (a size of 8 KB wasn't tested).  Unfortunately I was too busy at the
> > time to inquire further about it, but it would be a major potential
> > concern for me in my 10-GigE network testing with 9000-byte jumbo
> > frames.  Of course the single process and 4 KB or larger size was
> > the only case that showed a significant performance hit in Krishna
> > Kumar's latest reported test results, so it might be acceptable to
> > just have a switch to disable the batching feature for that specific
> > usage scenario.  So it would be useful to know if your xmit batching
> > changes would have similar issues.
> 
> There were many times while testing that i noticed inconsistencies and
> in each case when i analysed[1], i found it to be due to some variable
> other than batching which needed some resolving, always via some
> parametrization or other. I suspect what KK posted is in the same class.
> To give you an example, with UDP, batching was giving worse results at
> around 256B compared to 64B or 512B; investigating i found that the
> receiver just wasnt able to keep up and the udp layer dropped a lot of
> packets so both iperf and netperf reported bad numbers. Fixing the
> receiver ended up with consistency coming back. On why 256B was the one
> that overwhelmed the receiver more than 64B(which sent more pps)? On
> some limited investigation, it seemed to me to be the effect of the
> choice of the tg3 driver's default tx mitigation parameters as well tx
> ring size; which is something i plan to revisit (but neutralizing it
> helps me focus on just batching). In the end i dropped both netperf and
> iperf for similar reasons and wrote my own app. What i am trying to
> achieve is demonstrate if batching is a GoodThing. In experimentation
> like this, it is extremely valuable to reduce the variables. Batching
> may expose other orthogonal issues - those need to be resolved or fixed
> as they are found. I hope that sounds sensible.

It does sound sensible.  My own decidedly non-expert speculation
was that the big 30 % performance hit right at 4 KB may be related
to memory allocation issues or having to split the skb across
multiple 4 KB pages.  And perhaps it only affected the single
process case because with multiple processes lock contention may
be a bigger issue and the xmit batching changes would presumably
help with that.  I am admittedly a novice when it comes to the
detailed internals of TCP/skb processing, although I have been
slowly slogging my way through parts of the TCP kernel code to
try and get a better understanding, so I don't know if these
thoughts have any merit.

BTW does anyone know of a good book they would recommend that has
substantial coverage of the Linux kernel TCP code, that's fairly
up-to-date and gives both an overall view of the code and packet
flow as well as details on individual functions and algorithms,
and hopefully covers basic issues like locking and synchronization,
concurrency of different parts of the stack, and memory allocation.
I have several books already on Linux kernel and networking internals,
but they seem to only cover the IP (and perhaps UDP) portions of the
network stack, and none have more than a cursory reference to TCP.  
The most useful documentation on the Linux TCP stack that I have
found thus far is some of Dave Miller's excellent web pages and
a few other web references, but overall it seems fairly skimpy
for such an important part of the Linux network code.

> Back to the >=9K packet size you raise above:
> I dont have a 10Gige card so iam theorizing. Given that theres an
> observed benefit to batching for a saturated link with "smaller" packets
> (in my results "small" is anything below 256B which maps to about
> 380Kpps anything above that seems to approach wire speed and the link is
> the bottleneck); then i theorize that 10Gige with 9K jumbo frames if
> already achieving wire rate, should continue to do so. And sizes below
> that will see improvements if they were not already hitting wire rate.
> So i would say that with 10G NICS, there will be more observed
> improvements with batching with apps that do bulk transfers (assuming
> those apps are not seeing wire speed already). Note that this hasnt been
> quiet the case even with TSO given the bottlenecks in the Linux
> receivers that J Heffner put nicely in a response to some results you
> posted - but that exposes an issue with Linux receivers rather than TSO.

It would be good to see some empirical evidence that there aren't
any unforeseen gotchas for larger packet sizes, that at least the
same level of performance can be obtained with no greater CPU
utilization.

> > Also for your xmit batching changes, I think it would be good to see
> > performance comparisons for TCP and IP forwarding in addition to your
> > UDP pktgen tests, 
> 
> That is not pktgen - it is a udp app running in process context
> utilizing all 4CPUs to send traffic. pktgen bypasses the stack entirely
> and has its own merits in proving that batching infact is a GoodThing
> even if it is just for traffic generation ;->
> 
> > including various packet sizes up to and including
> > 9000-byte jumbo frames.
> 
> I will do TCP and forwarding tests in the near future. 

Looking forward to it.

> cheers,
> jamal
> 
> [1] On average i spend 10x more time performance testing and analysing
> results than writting code.

As you have written previously, and I heartily agree with, this is a
very good practice for developing performance enhancement patches.

						-Thanks

						-Bill
