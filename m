From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: BUG: scheduling while atomic: ifup-bonding/3711/0x00000002 -- V3.6.7
Date: Fri, 07 Dec 2012 13:00:54 -0800
Message-ID: <1013.1354914054@death.nxdomain>
References: <50B5248A.5010908@tlinx.org> <CAM_iQpUW2Oz9p0K0gGKc6JoD7WAu0kJtRa4uBSe+WfXg0Nn3jA@mail.gmail.com> <50B67F6B.6050008@tlinx.org> <50B6B4B6.3070304@tlinx.org> <4913.1354154236@death.nxdomain> <50C24C44.8000809@tlinx.org>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linda Walsh <lkml@tlinx.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <50C24C44.8000809@tlinx.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linda Walsh <lkml@tlinx.org> wrote:

>Sorry for the delay.... my distro (Suse) has made rebooting my system
>a chore (have to often boot from rescue to get it to come up because
>they put mount libs in /usr/lib expecting they will always boot
>from their ram disk -- preventing those of use who boot directly
>from disk from doing so easily...grrr.
>
>Jay Vosburgh wrote:
>> 	The miimon functionality is used to check link state and notice
>> when slaves lose carrier.
>---
>   If I am running 'rr' on 2 channels -- specifically for the purpose
>of link speed aggregation (getting 1 20Gb channel out of 2 10Gb channels)
>I'm not sure I see how miimon would provide benefit.  -- if 1 link dies,
>the other, being on the same card is likely to be dead too, so would
>it really serve a purpose?

	Perhaps, but if the link partner experiences a failure, that may
be a different situation.  Not all failures will necessarily cause both
links to fail simultaneously.

>>   Running without it will not detect failure of
>> the bonding slaves, which is likely not what you want.  The mode,
>> balance-rr in your case, is what selects the load balance to use, and is
>> separate from the miimon.
>>   
>----
>   Wouldn't the entire link die if a slave dies -- like RAID0, 1 disk
>dies, the entire link goes down? 

	No; failure of a single slave does not cause the entire bond to
fail (unless that is the last available slave).  For round robin, a
failed slave is taken out of the set used to transmit traffic, and any
remaining slaves continue to round robin amongst themselves.

>   The other end (windows) doesn't dynamically config for a static-link
>aggregation, so I don't think it would provide benefit.

	So it (windows) has no means to disable (and discontinue use of)
one channel of the aggregation should it fail, even in a static link
aggregation?

>> 	That said, the problem you're seeing appears to be caused by two
>> things: bonding holds a lock (in addition to RTNL) when calling
>> __ethtool_get_settings, and an ixgbe function in the call path to
>> retrieve the settings, ixgbe_acquire_swfw_sync_X540, can sleep.
>>
>> 	The test patch above handles one case in bond_enslave, but there
>> is another case in bond_miimon_commit when a slave changes link state
>> from down to up, which will occur shortly after the slave is added.
>>   
>----
>   Added your 2nd patch -- no more error messages...
>
>   however -- likely unrelated, the max speed read or write I am seeing
>is about 500MB/s, and that is rare -- usually it's barely <3x a 1Gb
>network speed. (119/125 MB R/W).  I'm not at all sure it's really
>combining the links
>properly.  Anyway to verify that?

	How are you testing the throughput?  If you configure the
aggregation with just one link, how does the throughput compare to the
aggregation with both links?

	It most likely is combining links properly, but any link
aggregation scheme has tradeoffs, and the best load balance algorithm to
use depends upon the work load.  Two aggregated 10G links are not
interchangable with a single 20G link.

	For a round robin transmission scheme, issues arise because
packets are delivered at the other end out of order.  This in turn
triggers various TCP behaviors to deal with what is perceived to be
transmission errors or lost packets (TCP fast retransmit being the most
notable).  This usually results in a single TCP connection being unable
to completely saturate a round-robin aggregated set of links.

	There are a few parameters on linux that can be adjusted.  I
don't know what the windows equivalents might be.

	On linux, adjusting the net.ipv4.tcp_reordering sysctl value
will increase the tolerance for out of order delivery.  

	The sysctl is adjusted via something like

sysctl -w net.ipv4.tcp_reordering=10

	the default value is 3, and higher values increase the tolerance
for out of order delivery.  If memory serves, the setting is applied to
connections as they are created, so existing connections will not see
changes.

	Also, adjusting the packet coalescing setting for the receiving
devices may also permit higher throughput. The packet coalescing setting
is adjusted via ethtool; the current settings can be viewed via

ethtool -c eth0

	and then adjusted via something like

ethtool -C eth0 rx-usecs 30

	I've seen reports that raising the "rx-usecs" parameter at the
receiver can increase the round-robin throughput.  My recollection is
that the value used was 30, but the best settings will likely be
dependent upon your particular hardware and configuration.

>   On the windows side it shows the bond-link as a 20Gb connection, but
>I don't see anyplace for something similar on linux. 

	There isn't any such indicator; bonding does not advertise its
link speed as the sum of its slaves link speeds.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
