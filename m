From: Linda Walsh <lkml@tlinx.org>
Subject: Re: BUG: scheduling while atomic: ifup-bonding/3711/0x00000002 -- V3.6.7
Date: Sat, 08 Dec 2012 23:48:22 -0800
Message-ID: <50C44246.3070705@tlinx.org>
References: <50B5248A.5010908@tlinx.org> <CAM_iQpUW2Oz9p0K0gGKc6JoD7WAu0kJtRa4uBSe+WfXg0Nn3jA@mail.gmail.com> <50B67F6B.6050008@tlinx.org> <50B6B4B6.3070304@tlinx.org> <4913.1354154236@death.nxdomain> <50C24C44.8000809@tlinx.org> <1013.1354914054@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1013.1354914054@death.nxdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
>> ---
>>   If I am running 'rr' on 2 channels -- specifically for the purpose
>> of link speed aggregation (getting 1 20Gb channel out of 2 10Gb channels)
>> I'm not sure I see how miimon would provide benefit.  -- if 1 link dies,
>> the other, being on the same card is likely to be dead too, so would
>> it really serve a purpose?
>>     
>
> 	Perhaps, but if the link partner experiences a failure, that may
> be a different situation.  Not all failures will necessarily cause both
> links to fail simultaneously.
>
>   
>>>   Running without it will not detect failure of
>>> the bonding slaves, which is likely not what you want.  The mode,
>>> balance-rr in your case, is what selects the load balance to use, and is
>>> separate from the miimon.
>>>   
>>>       
>> ----
>>   Wouldn't the entire link die if a slave dies -- like RAID0, 1 disk
>> dies, the entire link goes down? 
>>     
> 	No; failure of a single slave does not cause the entire bond to
> fail (unless that is the last available slave).  For round robin, a
> failed slave is taken out of the set used to transmit traffic, and any
> remaining slaves continue to round robin amongst themselves.
>
>   
>>   The other end (windows) doesn't dynamically config for a static-link
>> aggregation, so I don't think it would provide benefit.
>>     
> 	So it (windows) has no means to disable (and discontinue use of)
> one channel of the aggregation should it fail, even in a static link
> aggregation?
>   
-----------------
   Actually in rereading the docs again, it should, but not w/o packet loss.

It has a static and a dynamic link aggregation, and though only the dynamic
link aggregation had that -- but both do and both claim to balance all 
traffic.

    FWIW, my cables are direct connect, so only the capabilities of the
end cards (both Intel X540-T2 cards) are at issue, I believe.
I don't know if that is a problem or not, as each of the two ports
on the cards will only see half the traffic (from the wire
that is directly connected to it).

>
> 	How are you testing the throughput?  If you configure the
> aggregation with just one link, how does the throughput compare to the
> aggregation with both links?
>   
----
    When I did 1 link, I got about 2x faster writes, and reads that were
no faster, but I didn't do extensive testing...not sure how reliable those
figures were -- but they were sufficiently disappointing that I didn't
bother doing more testing and went immediately to trying teaming/bonding.


> 	It most likely is combining links properly, but any link
> aggregation scheme has tradeoffs, and the best load balance algorithm to
> use depends upon the work load.  Two aggregated 10G links are not
> interchangable with a single 20G link.
>   
---
    Not exactly, but for TCP streams, they mostly should be.

have tried a few TCP bench tests, and they got slower speeds than
my file R/W speeds through samba.  So use samba for testings, as
it seems to provide fairly low overhead such that I can get
line-speed writes w/1Gb ethers and >97% line speed reads.

    I'm not sure, but I think the scheduler may be coming into play
more on linux (though I would have thought it would have been Windows
slowing things down -- but I guess they got lots of grief over
their perf in WinXP and Vista... As Win7 seems to be better in that
regard.  Both cards are using 9k packets, and all possible offloading.
(udp/tcp..send/receive in addition to standard chksum offloading).

> 	For a round robin transmission scheme, issues arise because
> packets are delivered at the other end out of order.  This in turn
> triggers various TCP behaviors to deal with what is perceived to be
> transmission errors or lost packets (TCP fast retransmit being the most
> notable).  This usually results in a single TCP connection being unable
> to completely saturate a round-robin aggregated set of links.
>   
----
    I don't see that much retry traffic ... What appears maybe to be
a period drop -- like some period tic(?)...I do have tpc-low-latency,
but a 10Gb connection should low latency.  Have the tcp_reordering set
to 16...which isn't a new change -- had stack tuned for optimal perf
on 1Gb....but 10gb/20gb... -- not really sure where to start...
> 	There are a few parameters on linux that can be adjusted.  I
> don't know what the windows equivalents might be.
>
> 	On linux, adjusting the net.ipv4.tcp_reordering sysctl value
> will increase the tolerance for out of order delivery.  
>
> 	The sysctl is adjusted via something like
>
> sysctl -w net.ipv4.tcp_reordering=10
>   
---
    yeah... already got that.
> 	the default value is 3, and higher values increase the tolerance
> for out of order delivery.  If memory serves, the setting is applied to
> connections as they are created, so existing connections will not see
> changes.
>
> 	Also, adjusting the packet coalescing setting for the receiving
> devices may also permit higher throughput. The packet coalescing setting
> is adjusted via ethtool; the current settings can be viewed via
>
> ethtool -c eth0
>
> 	and then adjusted via something like
>
> ethtool -C eth0 rx-usecs 30
>   
---
    Had no clue what to set there....
Besides, wouldn't I need to set it on the bond interface, as
it is the stream coming from the bond interface that need coalescing?

    When i try it with the bond interface, I get 'not supported'
(it is on the slave interfaces, but seems like those wouldn't
"fit", as there wouldn't be contiguous i/o to either slave as
they alternate packets...  (?)

> 	I've seen reports that raising the "rx-usecs" parameter at the
> receiver can increase the round-robin throughput.  My recollection is
> that the value used was 30, but the best settings will likely be
> dependent upon your particular hardware and configuration.
>   
---
    Will have to play w/those...  right now, all '0's.

    Thanks for the patch(s)...and hints on ethtool..

    FWIW, windows has 2 timers -- a 1 once/sec status timer and a 1/10sec
load tick -- but I don't see the load tick doing anything on
static aggregation.

Linda W.
