From: Roopa Prabhu via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net] bridge: Fix problems around fdb entries
 pointing to the bridge device
Date: Thu, 04 Aug 2016 00:24:04 -0700
Message-ID: <57A2ED94.2020709@cumulusnetworks.com>
References: <1470276679-5533-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: Roopa Prabhu <roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1470276679-5533-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

On 8/3/16, 7:11 PM, Toshiaki Makita wrote:
> Adding fdb entries pointing to the bridge device uses fdb_insert(),
> which lacks various checks and does not respect added_by_user flag.
>
> As a result, some inconsistent behavior can happen:
> * Adding temporary entries succeeds but results in permanent entries.

IIRC this is not specific to fdb entries on the bridge device. all temp
fdb entries via iproute2 result in permanent entries. thats why 'dynamic'
was added.
> * Same goes for "dynamic" and "use".
This patch seems to not allow dynamic and use entries
on the bridge device. I don't see a strong use-case to
allow them, but any reason you want to add the restriction now ?
> * Changing mac address of the bridge device causes deletion of
>   user-added entries.
unless I am missing something, this does not seem to be related to the
external fdb entry on the bridge device.

> * Replacing existing entries looks successful from userspace but actually
>   not, regardless of NLM_F_EXCL flag.
curious about this one. I will try it, but if you have an example that
will help.
>
> Use the same logic as other entries and fix them.
>
> Fixes: 3741873b4f73 ("bridge: allow adding of fdb entries pointing to the bridge device")
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
no objections to the patch.
Good to see both paths being unified by making __br_fdb_add work
for both cases.

>  net/bridge/br_fdb.c | 52 +++++++++++++++++++++++++++-------------------------
>  1 file changed, 27 insertions(+), 25 deletions(-)
>
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index c18080a..cd620fa 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -267,7 +267,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
>  
>  	/* If old entry was unassociated with any port, then delete it. */
>  	f = __br_fdb_get(br, br->dev->dev_addr, 0);
> -	if (f && f->is_local && !f->dst)
> +	if (f && f->is_local && !f->dst && !f->added_by_user)
>  		fdb_delete_local(br, NULL, f);
>  
>  	fdb_insert(br, NULL, newaddr, 0);
> @@ -282,7 +282,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
>  		if (!br_vlan_should_use(v))
>  			continue;
>  		f = __br_fdb_get(br, br->dev->dev_addr, v->vid);
> -		if (f && f->is_local && !f->dst)
> +		if (f && f->is_local && !f->dst && !f->added_by_user)
>  			fdb_delete_local(br, NULL, f);
>  		fdb_insert(br, NULL, newaddr, v->vid);
>  	}
> @@ -764,20 +764,25 @@ out:
>  }
>  
>  /* Update (create or replace) forwarding database entry */
> -static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
> -			 __u16 state, __u16 flags, __u16 vid)
> +static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
> +			 const __u8 *addr, __u16 state, __u16 flags, __u16 vid)
>  {
> -	struct net_bridge *br = source->br;
>  	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
>  	struct net_bridge_fdb_entry *fdb;
>  	bool modified = false;
>  
>  	/* If the port cannot learn allow only local and static entries */
> -	if (!(state & NUD_PERMANENT) && !(state & NUD_NOARP) &&
> +	if (source && !(state & NUD_PERMANENT) && !(state & NUD_NOARP) &&
>  	    !(source->state == BR_STATE_LEARNING ||
>  	      source->state == BR_STATE_FORWARDING))
>  		return -EPERM;
>  
> +	if (!source && !(state & NUD_PERMANENT)) {
> +		pr_info("bridge: RTM_NEWNEIGH %s without NUD_PERMANENT\n",
> +			br->dev->name);
> +		return -EINVAL;
> +	}
> +
>  	fdb = fdb_find(head, addr, vid);
>  	if (fdb == NULL) {
>  		if (!(flags & NLM_F_CREATE))
> @@ -832,22 +837,28 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
>  	return 0;
>  }
>  
> -static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
> -	       const unsigned char *addr, u16 nlh_flags, u16 vid)
> +static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge *br,
> +			struct net_bridge_port *p, const unsigned char *addr,
> +			u16 nlh_flags, u16 vid)
>  {
>  	int err = 0;
>  
>  	if (ndm->ndm_flags & NTF_USE) {
> +		if (!p) {
> +			pr_info("bridge: RTM_NEWNEIGH %s with NTF_USE is not supported\n",
> +				br->dev->name);
> +			return -EINVAL;
> +		}
>  		local_bh_disable();
>  		rcu_read_lock();
> -		br_fdb_update(p->br, p, addr, vid, true);
> +		br_fdb_update(br, p, addr, vid, true);
>  		rcu_read_unlock();
>  		local_bh_enable();
>  	} else {
> -		spin_lock_bh(&p->br->hash_lock);
> -		err = fdb_add_entry(p, addr, ndm->ndm_state,
> +		spin_lock_bh(&br->hash_lock);
> +		err = fdb_add_entry(br, p, addr, ndm->ndm_state,
>  				    nlh_flags, vid);
> -		spin_unlock_bh(&p->br->hash_lock);
> +		spin_unlock_bh(&br->hash_lock);
>  	}
>  
>  	return err;
> @@ -884,6 +895,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  				dev->name);
>  			return -EINVAL;
>  		}
> +		br = p->br;
>  		vg = nbp_vlan_group(p);
>  	}
>  
> @@ -895,15 +907,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  		}
>  
>  		/* VID was specified, so use it. */
> -		if (dev->priv_flags & IFF_EBRIDGE)
> -			err = br_fdb_insert(br, NULL, addr, vid);
> -		else
> -			err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
> +		err = __br_fdb_add(ndm, br, p, addr, nlh_flags, vid);
>  	} else {
> -		if (dev->priv_flags & IFF_EBRIDGE)
> -			err = br_fdb_insert(br, NULL, addr, 0);
> -		else
> -			err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
> +		err = __br_fdb_add(ndm, br, p, addr, nlh_flags, 0);
>  		if (err || !vg || !vg->num_vlans)
>  			goto out;
>  
> @@ -914,11 +920,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  		list_for_each_entry(v, &vg->vlan_list, vlist) {
>  			if (!br_vlan_should_use(v))
>  				continue;
> -			if (dev->priv_flags & IFF_EBRIDGE)
> -				err = br_fdb_insert(br, NULL, addr, v->vid);
> -			else
> -				err = __br_fdb_add(ndm, p, addr, nlh_flags,
> -						   v->vid);
> +			err = __br_fdb_add(ndm, br, p, addr, nlh_flags, v->vid);
>  			if (err)
>  				goto out;
>  		}
