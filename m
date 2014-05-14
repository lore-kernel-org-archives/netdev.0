From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/8] Non-promisc bidge ports support
Date: Wed, 14 May 2014 18:21:37 +0300
Message-ID: <20140514152137.GA11339@redhat.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
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

On Wed, May 14, 2014 at 11:09:20AM -0400, Vlad Yasevich wrote:
> This series adds functionality to the bridge device to enable
> operations without setting all ports to promiscuous mode.
> 
> The basic concept is this.  The bridge keeps track of the ports
> that support learning and flooding packets to unknown destinations.
> We call these ports auto-discovery ports since they automatically
> discover who is behind them through learning and flooding.  
> 
> If flooding and learning are disabled via flags, then the port
> requires static configuration to tell it which mac addresses
> are behind it.  This is accomplished through adding of fdbs.
> These fdbs should be static as dynamic fdbs can expire and systems
> will become unreachable due to lack of flooding.
> 
> If the user marks all ports as needing static configuration then
> we can safely make them non-promiscuous since we will know all the
> information about them.
> 
> If the user leaves only 1 port as automatic, then we can mark
> that port as not-promiscuous as well.  One could think of
> this a edge relay similar to what's support by embedded switches
> in SRIOV devices.  Since we have all the information about the
> other ports, we can just program the mac addresses into the
> single automatic port to receive all necessary traffic.
> More information about this is patch 6.
> 
> In other cases, we keep all ports promiscuous as before.
> 
> There are some other cases when promiscuous mode has to be turned
> back on.  One is when the bridge itself if placed in promiscuous
> mode (user sets promisc flag).  The other is if vlan filtering is
> turned off.  Since this is the default configuration, the default
> bridge operation is not changed.
> 
> Changes since rfc v2:
>  - Better description of in the commit logs
>  - Leave port in promiscuous mode if IFF_UNICAST_FLT is disabled on the
>    device.
>  - Fix issue with flag masking
>  - Rework patch ordering a bit.
> 
> Changes since rfc v1:
>  - Removed private list.  We now traverse the fdb hashtable itself
>    to write necessary addresses to the ports (Stephen's concern)
>  - Add learning flag to the mask for flags that decides if the port
>    is 'auto' or not (suggest by MST and Jamal).
>  - Simplified tracking of such ports at the cost of a loop over all
>    ports (suggested by MST)
> 
> I've played with quite a large number of ports and the current approach
> seems to work fairly well.
> 
> Thanks
> -vlad

For the series

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> Vlad Yasevich (8):
>   bridge: Turn flag change macro into a function.
>   bridge: Keep track of ports capable of automatic discovery.
>   bridge: Add functionality to sync static fdb entries to hw
>   bridge: Introduce BR_PROISC flag
>   bridge: Add addresses from static fdbs to non-promisc ports
>   bridge: Automatically manage port promiscuous mode.
>   bridge: Correctly manage promiscuity when user requested it.
>   bridge: Automatically manage promisc mode when vlan filtering is on.
> 
>  net/bridge/br_device.c   |   7 +++
>  net/bridge/br_fdb.c      | 132 ++++++++++++++++++++++++++++++++++++++++++++---
>  net/bridge/br_if.c       | 126 ++++++++++++++++++++++++++++++++++++++++++--
>  net/bridge/br_netlink.c  |   3 ++
>  net/bridge/br_private.h  |  20 +++++++
>  net/bridge/br_sysfs_if.c |  31 +++++++----
>  net/bridge/br_vlan.c     |   1 +
>  7 files changed, 300 insertions(+), 20 deletions(-)
> 
> -- 
> 1.9.0
