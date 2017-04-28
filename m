From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next v2] net: bridge: Fix improper taking
 over HW learned FDB
Date: Fri, 28 Apr 2017 20:36:35 +0300
Message-ID: <20170428173635.GA8634@splinter>
References: <1493397098-38756-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1493397098-38756-1-git-send-email-arkadis@mellanox.com>
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

On Fri, Apr 28, 2017 at 07:31:38PM +0300, Arkadi Sharshevsky wrote:
> Commit 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb
> entries") added the ability to "take over an entry which was previously
> learned via HW when it shows up from a SW port".
> 
> However, if an entry was learned via HW and then a control packet
> (e.g., ARP request) was trapped to the CPU, the bridge driver will
> update the entry and remove the externally learned flag, although the
> entry is still present in HW. Instead, only clear the externally learned
> flag in case of roaming.
> 
> Fixes: 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb entries")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Arkadi Sharashevsky <arkadis@mellanox.com>
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v1->v2
> - net-next rebase.
> ---
>  net/bridge/br_fdb.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index de7988b..5905eb7 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -589,16 +589,16 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>  			if (unlikely(source != fdb->dst)) {
>  				fdb->dst = source;
>  				fdb_modified = true;
> +				/* Take over HW learned entry */
> +				if (unlikely(fdb->added_by_external_learn)) {
> +					fdb->added_by_external_learn = 0;
> +					fdb_modified = true;

This line is redundant. 'fdb_modified' is already set.

> +				}
>  			}
>  			if (now != fdb->updated)
>  				fdb->updated = now;
>  			if (unlikely(added_by_user))
>  				fdb->added_by_user = 1;
> -			/* Take over HW learned entry */
> -			if (unlikely(fdb->added_by_external_learn)) {
> -				fdb->added_by_external_learn = 0;
> -				fdb_modified = true;
> -			}
>  			if (unlikely(fdb_modified))
>  				fdb_notify(br, fdb, RTM_NEWNEIGH);
>  		}
> -- 
> 2.4.11
> 
