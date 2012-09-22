From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCHv2 bridge 2/7] bridge: Add vlan to unicast fdb entries
Date: Sat, 22 Sep 2012 18:17:17 +0100
Message-ID: <1348334237.2521.102.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
	 <1348058536-22607-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48556 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752135Ab2IVRRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:17:20 -0400
In-Reply-To: <1348058536-22607-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
> This patch adds vlan to unicast fdb entries that are created for
> learned addresses (not the manually configured ones).  It adds
> vlan id into the hash mix and uses vlan as an addditional parameter
> for an entry match.
[...]
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9ce430b..e17f9f2 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
[...]
> @@ -67,11 +68,12 @@ static inline int has_expired(const struct net_bridge *br,
>                 time_before_eq(fdb->updated + hold_time(br), jiffies);
>  }
>  
> -static inline int br_mac_hash(const unsigned char *mac)
> +static inline int br_mac_hash(const unsigned char *mac, __u16 vlan_tci)
>  {
> -       /* use 1 byte of OUI cnd 3 bytes of NIC */
> +       /* use 1 byte of OUI and 3 bytes of NIC */
>         u32 key = get_unaligned((u32 *)(mac + 2));
> -       return jhash_1word(key, fdb_salt) & (BR_HASH_SIZE - 1);
> +       return jhash_2words(key, (vlan_tci & VLAN_VID_MASK),
> +                               fdb_salt) & (BR_HASH_SIZE - 1);
>  }

Why do you add a vlan_tci parameter to so many functions, which they
then mask to get the VID?  Would it not make more sense to pass only
VIDs around?

[...]
> @@ -628,11 +640,12 @@ int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
>  
>         if (ndm->ndm_flags & NTF_USE) {
>                 rcu_read_lock();
> -               br_fdb_update(p->br, p, addr);
> +               br_fdb_update(p->br, p, addr, 0);
>                 rcu_read_unlock();
>         } else {
>                 spin_lock_bh(&p->br->hash_lock);
> -               err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags);
> +               err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags,
> +                               0);
>                 spin_unlock_bh(&p->br->hash_lock);
>         }
>  
> @@ -642,10 +655,10 @@ int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
>  static int fdb_delete_by_addr(struct net_bridge_port *p, u8 *addr)
>  {
>         struct net_bridge *br = p->br;
> -       struct hlist_head *head = &br->hash[br_mac_hash(addr)];
> +       struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
>         struct net_bridge_fdb_entry *fdb;
>  
> -       fdb = fdb_find(head, addr);
> +       fdb = fdb_find(head, addr, 0);
>         if (!fdb)
>                 return -ENOENT;
> 

So current tools will only be able to manipulate forwarding entries for
untagged frames?  Surely they should still insert and delete forwarding
entries that affect all VLANs, and new tools will be able to restrict
forwarding entries to specific VLANs?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
