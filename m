From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/7] Non-promisc bidge ports support
Date: Wed, 26 Feb 2014 18:34:52 +0200
Message-ID: <20140226163452.GM15330@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 10:18:18AM -0500, Vlad Yasevich wrote:
> This patch series is a complete re-design and re-implementation of
> prior attempts to support non-promiscuous bridge ports.

Nice.
For those that wonder: the setups that benefit from this
could look e.g. like this:

A---+
    |
    |
   BRIDGE--C
    |
    |
B---+

If A, B, C all use standard NICs without setting them
into promiscous mode, unicast packets sent to e.g. A that don't match
the address of its NIC will be dropped anyway.  Same applies to B and C.

With this patchset we'll be able to bypass the
need for promisc mode on NICs in the BRIDGE box.





> The basic design is as follows.  The bridge keeps track of
> all the ports that flood packets to unknown destinations.  If
> the flooding is disabled on the port, to get traffic to flow
> through, user/management would need to add an fdb describing
> such traffic.  When such fdb is added, we save the address
> to bridge private hardware address list. 
> Since we now have static configuration for all non-flooding
> ports and only 1 flooding port, we can make this single port
> non-promiscuous and program the receive filter with our list
> of addresses.  On HW that doesn't support unicast filtering or
> if the list too bit, the device will be placed in promiscuous mode
> by the application of the filter.
> 
> There are multiple reasons I chose to do private hw address
> list in the bridge in patch 3:
>   1)  I tried using the fdb table itself as main repository, but
>       this caused difficulties in synchronizing this table with
>       the interface filters later on.
>   2)  I tried using the bridge device 'uc' list to store these
>       addresses, but that caused issues with devices on top of
>       a bridge (vlans, bonds) that changed their mac addresses
>       and propagated this down to bridge.   I recently figured
>       out a way that might allow us to do this which involves
>       learning to be added br_dev_xmi().  We can discuss this,
>       if there serious objections to current proposal.
> 
> There are some other cases when promiscuous mode has to be turned
> back on.  One is when the bridge itself if placed in promiscuous
> mode (use sets promisc flag).  The other is when vlans devices are
> configured on top of the bridge and vlan filtering is disabled (default).
> This allows the bridge to receive all tagged frames and doesn't create
> a dependency between this code and vlan filtering.
> 
> The last patch in the series is a special case where all ports
> are non-flooding.  This could be useful in a routed configurations.
> In this case, since all ports will be configured manually, we can
> sync the our address list across all port of the bridge and make all
> ports non-promiscuous.
> 
> Thanks
> -vlad
> 
> Vlad Yasevich (7):
>   bridge: Turn flag change macro into a function.
>   bridge: Keep track of ports capable of flooding.
>   bridge: Add addresses from static fdbs to bridge address list
>   bridge: Automatically manage port promiscuous mode.
>   bridge: Correctly manage promiscuity when user requested it.
>   bridge: Manage promisc mode when vlans are configured on top of a
>     bridge
>   bridge: Support promisc management when all ports are non-flooding
> 
>  include/linux/netdevice.h |   9 +++
>  net/bridge/br_device.c    |  23 +++++++
>  net/bridge/br_fdb.c       | 122 +++++++++++++++++++++++++++++++++--
>  net/bridge/br_if.c        | 159 ++++++++++++++++++++++++++++++++++++++++++++--
>  net/bridge/br_netlink.c   |   3 +
>  net/bridge/br_private.h   |  18 ++++++
>  net/bridge/br_sysfs_if.c  |  33 +++++++---
>  net/bridge/br_vlan.c      |   1 +
>  net/core/dev.c            |   1 +
>  net/core/dev_addr_lists.c |  21 +++---
>  10 files changed, 361 insertions(+), 29 deletions(-)
> 
> -- 
> 1.8.5.3
