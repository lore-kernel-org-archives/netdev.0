From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] QoS: new per flow queue
Date: 05 Apr 2005 13:57:38 -0400
Message-ID: <1112723858.1076.46.camel@jzny.localdomain>
References: <20050405224956.0258.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050405224956.0258.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I quickly scanned the kernel portion. I dont think this is the best way
to achieve this - your qdisc is both a classifier and scheduler. I think
this is the major drwback.
And if you take out the classifier - whats left in your qdisc cant beat
htb or hfsc or cbq in terms of being proven to be accurate.
 
If you could write a meta action instead which is a simple dynamic
setter of something like fwmark that would suffice i.e something along
the lines of:

example:
----
tc filter ip u32 match ip sport 80 0xffff flowid 1:12 \
    action dynfwmark continue
tc filter fwmark 0x1 .. classid aaaa
tc filter fwmark 0x2 .. classid bbbb
..
..

tc qdisc htb/hfsc/cbq .... your rate parameters here.
---

dynfwmark will maintain your state table which gets deleted when timers
expire and will hash based on the current jenkins hash
Do you have to queue the packets? if not you could instead have the
police action (attached to fwmark) drop the packet once it exceeds
certain rate and then use any enqueueing scheme you want.
The drawback with above scheme is you will have as many entries for
fwmark as you want to have queues - each selecting its own queue.

cheers,
jamal

On Tue, 2005-04-05 at 11:25, Wang Jian wrote:
> Hi,
> 
> I write a per flow rate control qdisc. I posted it to LARTC list. Some
> discussion about it is here
> 
>     http://mailman.ds9a.nl/pipermail/lartc/2005q2/015381.html
> 
> I think I need more feedback and suggestion on it so I repost the patch
> here. Please read the thread and get a picture about why and how.
> 
> The kernel patch is agains kernel 2.6.11, the iproute2 patch is against
> iproute2-2.6.11-050314. 
> 
> The test scenario is like this
> 
>       www server <- [ eth0   eth1 ] -> www clients
> 
> The attached t.sh is used to generate test rules. Clients download a
> big ISO file from www server, so flows' rate can be estimated by view
> progress.
> 
> I have some test on it and it works well. It provides good fairness.
> When all slot being used, in most time, the real rate can keep at
> specified guaranteed rate. But I know it should receive more test.
> 
> I have some consideration though
> 
> 1. In the test sometimes there a pair of unbalanced stream and don't get
> balanced quickly. One stream get 8.4kbps and another get 11.5kbps. How
> to find the flow with highest traffic and punish it most?
> 
> 2. The default ceil equals to rate. Should I calculate it as
>    ceil = rate * 1.05 * limit, or
>    ceil = rate * 1.05?
> 
> 3. when flow slots are full, optionally reclassify untraceable traffic
>    into another specified class, instead of dropping it?
> 
> TODO:
> 
> 1. rtnetlink related code should be improved;
> 2. dump() and dump_stat();
> 
> 
> Regards
