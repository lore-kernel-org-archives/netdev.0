From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target, seq_file version
Date: 21 Oct 2004 13:44:11 -0400
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <1098380650.1031.82.camel@jzny.localdomain>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
	<20041021163655.GK3551@sunbeam.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	lmb@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041021163655.GK3551@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


Sorry, couldnt resist - so out of hiding for just a few seconds; should
be able to achieve this much simpler with gact.

Example:
Consider two machines with allowed to receive only packets for 10.0.0.3.
A simple balance scheme is to have even src IPs being processed by one
and odd by another.

#add ingress qdisc to eth2
# Accept arps destined for 10.0.0.3 but sourced from even numbered
# src addresses
tc filter add dev eth2 parent ffff: protocol arp prio 6 u32 match u32
0xa000003 0xffffffff at 24 match u8 0x0 0x1 at 17 flowid 1:2 action ok
# drop any other arps for 10.0.0.3
tc filter add dev eth2 parent ffff: protocol arp prio 7 u32 match u32
0xa000003 0xffffffff at 24 flowid 1:2 action drop

On a second machine which is doing odd just change the u8 to 0x1 0x1.
No need to send fake ARPs using multicast with this. But if you wanted
to be funky you could use pedit to create a virtual MAC address.

We use this well with a lot more complex static rules and failover.

cheers,
jamal (Back to work)

On Thu, 2004-10-21 at 12:36, Harald Welte wrote:
> On Thu, Oct 21, 2004 at 12:38:28AM +0200, Harald Welte wrote:
> Hi Dave!
> 
> This is the 'CLUSTERIP' target for iptables, this time no core kernel
> changes required, please apply.
> 
> This enables you to build a static load sharing cluster between multiple
> nodes - without the requirement to have a load balancer.  It uses a
> series of [evil] tricks like replying with linklayer multicast addresses
> to ARP requests, and using CONNMARK for stateful blocking all traffic
> not intended for the local node.
> 
> Apart from the usual netfilter-specific file additions and
> Kconfig/Makefile patches, this needs to export proc_file_operations in
> order to get the reference counting of certain data objects right.  I
> hope this change is acceptable.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>
