From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net-next] net: bridge: add support for IGMP/MLD
 stats and export them via netlink
Date: Tue, 28 Jun 2016 14:48:17 +0200
Message-ID: <57727211.30508@cumulusnetworks.com>
References: <1467051048-32604-1-git-send-email-nikolay@cumulusnetworks.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1467051048-32604-1-git-send-email-nikolay@cumulusnetworks.com>
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

On 27/06/16 20:10, Nikolay Aleksandrov wrote:
> This patch adds stats support for the currently used IGMP/MLD types by the
> bridge. The stats are per-port (plus one stat per-bridge) and per-direction
> (RX/TX). The stats are exported via netlink via the new linkxstats API
> (RTM_GETSTATS). In order to minimize the performance impact, a new option
> is used to enable/disable the stats - multicast_stats_enabled, similar to
> the recent vlan stats. Also in order to avoid multiple IGMP/MLD type
> lookups and checks, we make use of the current "igmp" member of the bridge
> private skb->cb region to record the type on Rx (both host-generated and
> external packets pass by multicast_rcv()). We can do that since the igmp
> member was used as a boolean and all the valid IGMP/MLD types are positive
> values. The normal bridge fast-path is not affected at all, the only
> affected paths are the flooding ones and since we make use of the IGMP/MLD
> type, we can quickly determine if the packet should be counted using
> cache-hot data (cb's igmp member). We add counters for:
> * IGMP Queries
> * IGMP Leaves
> * IGMP v1/v2/v3 reports
> 
> * MLD Queries
> * MLD Leaves
> * MLD v1/v2 reports
> 
> These are invaluable when monitoring or debugging complex multicast setups
> with bridges.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  include/uapi/linux/if_bridge.h |  27 +++++++
>  include/uapi/linux/if_link.h   |   1 +
>  net/bridge/br_device.c         |  10 ++-
>  net/bridge/br_forward.c        |  13 ++-
>  net/bridge/br_if.c             |   9 ++-
>  net/bridge/br_input.c          |   3 +
>  net/bridge/br_multicast.c      | 176 +++++++++++++++++++++++++++++++++++++----
>  net/bridge/br_netlink.c        |  94 ++++++++++++++++------
>  net/bridge/br_private.h        |  41 +++++++++-
>  net/bridge/br_sysfs_br.c       |  25 ++++++
>  10 files changed, 356 insertions(+), 43 deletions(-)
> 

Self-NAK, while the patch is okay, me and Roopa have been talking about exporting
the stats via the new API better and would like to introduce a way to expose only
per-port stats via a specific RTM_GETSTATS request instead of dumping it all via
the bridge request in order to be able to get the stats only for a single device.

I will post v2 after working out the details on how to achieve per-port export of
linkxstats.

Thanks,
 Nik
