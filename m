From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 1/2] bridge: Add flag to control mac
	learning.
Date: Mon, 29 Apr 2013 19:11:23 +0300
Message-ID: <20130429161123.GB10663@redhat.com>
References: <1367251102-25193-1-git-send-email-vyasevic@redhat.com>
	<1367251102-25193-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1367251102-25193-2-git-send-email-vyasevic@redhat.com>
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

On Mon, Apr 29, 2013 at 11:58:21AM -0400, Vlad Yasevich wrote:
> Allow user to control whether mac learning is enabled on the port.
> By default, mac learning is enabled.  Disabling mac learning will
> cause new dynamic FDB entries to not be created for a particular port.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  include/uapi/linux/if_link.h |    1 +
>  net/bridge/br_fdb.c          |    4 ++++
>  net/bridge/br_if.c           |    2 +-
>  net/bridge/br_netlink.c      |    6 +++++-
>  net/bridge/br_private.h      |    1 +
>  net/bridge/br_sysfs_if.c     |    2 ++
>  6 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index e316354..80fad7f 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -221,6 +221,7 @@ enum {
>  	IFLA_BRPORT_GUARD,	/* bpdu guard              */
>  	IFLA_BRPORT_PROTECT,	/* root port protection    */
>  	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
> +	IFLA_BRPORT_LEARNING,	/* mac learning */
>  	__IFLA_BRPORT_MAX
>  };
>  #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index c581f12..9c4fe65 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -477,10 +477,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>  	} else {
>  		spin_lock(&br->hash_lock);
>  		if (likely(!fdb_find(head, addr, vid))) {
> +			if (!(source->flags & BR_LEARNING))
> +				goto unlock;
> +
>  			fdb = fdb_create(head, source, addr, vid);
>  			if (fdb)
>  				fdb_notify(br, fdb, RTM_NEWNEIGH);
>  		}
> +unlock:
>  		/* else  we lose race and someone else inserts
>  		 * it first, don't bother updating
>  		 */

Wait a second, this will affect adding fdbs using RTM_NEWNEIGH, won't it?
And let's not bother with lookups if learning is off.
So I imagine we need something like the below instead
(in addition to the sysfs/netlink part of the patch which
look fine):

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index bab338e..30eaa6b 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -448,8 +448,9 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 	return ret;
 }
 
-void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr, u16 vid)
+static
+void __br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
+		     const unsigned char *addr, u16 vid)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
@@ -490,6 +491,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	}
 }
 
+void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
+		     const unsigned char *addr, u16 vid)
+{
+	if (!(source->flags & BR_LEARNING))
+		return;
+	__br_fdb_update(br, source, addr, vid);
+}
+
 static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
 {
 	if (fdb->is_local)
@@ -655,7 +664,7 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
 
 	if (ndm->ndm_flags & NTF_USE) {
 		rcu_read_lock();
-		br_fdb_update(p->br, p, addr, vid);
+		__br_fdb_update(p->br, p, addr, vid);
 		rcu_read_unlock();
 	} else {
 		spin_lock_bh(&p->br->hash_lock);
 
