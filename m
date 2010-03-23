From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch 3/3] bonding: make bonding support netpoll
Date: Tue, 23 Mar 2010 10:01:52 +0800
Message-ID: <4BA82110.6040201@redhat.com>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain> <20100322082123.4967.77433.sendpatchset@localhost.localdomain> <1269297485.3552.26.camel@calx> <12061.1269301015@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12061.1269301015@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Matt Mackall <mpm@selenic.com> wrote:
> 
>> On Mon, 2010-03-22 at 04:17 -0400, Amerigo Wang wrote:
>>> Based on Andy's work, but I modify a lot.
>>>
>>> Similar to the patch for bridge, this patch does:
>>>
>>> 1) implement the 4 methods to support netpoll for bonding;
>>>
>>> 2) modify netpoll during forwarding packets in bonding;
>>>
>>> 3) disable netpoll support of bridge when a netpoll-unabled device
>>>    is added to bonding;
>>>
>>> 4) enable netpoll support when all underlying devices support netpoll.
>> Again, not sure if this is the right policy. Seems to me that on a
>> bonding device we should simply pick an interface to send netpoll
>> messages on, without reference to balancing, etc. Thus, if any of the
>> bonded devices supports polling, it should work.
> 
> 	For some of the modes, the above is pretty straighforward.
> Others, 802.3ad and balance-alb, are a bit more complicated.
> 
> 	The risk is that the network peers and switches may see the same
> MAC address on multiple ports, or different MAC addresses for the same
> IP address.
> 
> 	To implement the above suggestion, I think a "current netpoll
> slave" would have to be tracked, and kept up to date (as slaves become
> active or inactive, etc).  Reusing the existing "current active slave"
> won't work for the case that the active slave is not netpoll-capable,
> but a different slave is; also, not all modes use the current active
> slave.
> 
> 	In 802.3ad, the "current netpoll slave" selector will have to
> poke into the aggregator status to choose the netpoll slave.  It's not a
> simple matter of picking one and then sticking with it forever; if the
> aggregator containing the netpoll slave is deactivated, then peers may
> not receive the traffic, etc.
> 
> 	In the active-backup mode, only the active slave can send or
> receive, so if it's not netpoll capable, but a backup slave is, you're
> still out of luck (unless netpoll awareness is added to the "best slave"
> selection logic, and even then it'd have to be a secondary criteria).
> Or, the inactive slave can be transmitted on, but if the same MAC comes
> out of the active and a backup slave, it can confuse switches.
> 
> 	In one mode (balance-alb), slaves keep their own MAC addresses,
> and are matched with peers.  Bypassing the balance algorithm could again
> confuse peers or switches, who could see two MAC addresses for the same
> IP address, if netpoll traffic goes out a different slave than the
> balance algorithm picks for the same destination.
> 
> 	I think, then, the question becomes: is this extra complexity
> worth it to cover the cases of netpoll over bonding wherein one or more
> slaves don't support netpoll?  
> 

I see, thanks for your explanation, I overlooked the bonding case.

The current implementation will totally disable netpoll when at least one
slave doesn't support netpoll, so it looks like a safe choice. ;)


> 	How many network drivers don't support netpoll nowadays?
> 

Only about 20% of network drivers support netpoll, a quick grep of 'ndo_poll_controller'
can show that.

Thanks a lot!
