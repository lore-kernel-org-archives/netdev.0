From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Mon, 3 Jun 2013 13:45:12 -0700
Message-ID: <20130603134512.46ce434f@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:54247 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758113Ab3FCUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 16:45:18 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so1058661pad.16
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 13:45:17 -0700 (PDT)
In-Reply-To: <OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Jun 2013 16:18:14 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> > --- a/drivers/net/vxlan.c   2013-06-03 11:08:39.214230482 -0700
> > +++ b/drivers/net/vxlan.c   2013-06-03 11:11:37.220114181 -0700
> > @@ -101,7 +101,7 @@ struct vxlan_rdst {
> >     __be16          remote_port;
> >     u32          remote_vni;
> >     u32          remote_ifindex;
> > -   struct vxlan_rdst   *remote_next;
> > +   struct list_head    list;
> >  };
> > 
> >  /* Forwarding table entry */
> > @@ -110,7 +110,7 @@ struct vxlan_fdb {
> >     struct rcu_head     rcu;
> >     unsigned long     updated;   /* jiffies */
> >     unsigned long     used;
> > -   struct vxlan_rdst remote;
> > +   struct list_head  remotes;
> >     u16        state;   /* see ndm_state */
> >     u8        flags;   /* see ndm_flags */
> >     u8        eth_addr[ETH_ALEN];
> > @@ -163,6 +163,12 @@ static inline struct hlist_head *vs_head
> >     return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
> >  }
> > 
> > +/* First remote destination for a forwarding entry (or NULL) */
> > +static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
> > +{
> > +   return list_first_or_null_rcu(&fdb->remotes, struct vxlan_rdst, 
> list);
> > +}
> > +
> >  /* Find VXLAN socket based on network namespace and UDP port */
> >  static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
> >  {
> > @@ -216,10 +222,11 @@ static int vxlan_fdb_info(struct sk_buff
> > 
> >     if (type == RTM_GETNEIGH) {
> >        ndm->ndm_family   = AF_INET;
> > -      send_ip = rdst->remote_ip != htonl(INADDR_ANY);
> > +      send_ip = rdst && rdst->remote_ip != htonl(INADDR_ANY);
> >        send_eth = !is_zero_ether_addr(fdb->eth_addr);
> >     } else
> >        ndm->ndm_family   = AF_BRIDGE;
> 
> rdst cannot be NULL in the original code, and no fdb entry should
> ever have a NULL destination, so I'm not sure I understand why you
> appear to be sending netlink messages at all if rdst is NULL.

Just being safe. need to audit to make sure not possible for all
destinations to be removed from FDB entry via netlink.

> 
> > +
> >     ndm->ndm_state = fdb->state;
> >     ndm->ndm_ifindex = vxlan->dev->ifindex;
> >     ndm->ndm_flags = fdb->flags;
> > @@ -228,18 +235,20 @@ static int vxlan_fdb_info(struct sk_buff
> >     if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
> >        goto nla_put_failure;
> > 
> > -   if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
> > -      goto nla_put_failure;
> > -
> > -   if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
> > -       nla_put_be16(skb, NDA_PORT, rdst->remote_port))
> > -      goto nla_put_failure;
> > -   if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
> > -       nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
> > -      goto nla_put_failure;
> > -   if (rdst->remote_ifindex &&
> > -       nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
> > -      goto nla_put_failure;
> > +   if (rdst) {
> > +      if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
> > +         goto nla_put_failure;
> > +
> > +      if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
> > +          nla_put_be16(skb, NDA_PORT, rdst->remote_port))
> > +         goto nla_put_failure;
> > +      if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
> > +          nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
> > +         goto nla_put_failure;
> > +      if (rdst->remote_ifindex &&
> > +          nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
> > +         goto nla_put_failure;
> > +   }
> > 
> >     ci.ndm_used    = jiffies_to_clock_t(now - fdb->used);
> >     ci.ndm_confirmed = 0;
> 
> Again, if rdst == NULL, why are we sending anything? It should never
> happen, so should be an error case if you check at all, shouldn't it?

It maybe possible to create or modify existing fdb entry so no destinatons
left.

> 
> > @@ -1173,32 +1192,40 @@ static netdev_tx_t vxlan_xmit(struct sk_
> >           f = vxlan_find_mac(vxlan, eth->h_dest);
> >     }
> > 
> > -   if (f == NULL) {
> > +   if (f) {
> > +      struct vxlan_rdst *rdst;
> > +
> > +      rdst0 = NULL;
> > +      list_for_each_entry_rcu(rdst, &f->remotes, list) {
> > +         if (rdst0) {
> > +            struct sk_buff *skb1;
> > +            skb1 = skb_clone(skb, GFP_ATOMIC);
> > +            if (skb1)
> > +               vxlan_xmit_one(skb1, dev,
> > +                         rdst0, did_rsc);
> 
> This ignores the return value of vxlan_xmit_one(); the original
> code returns an error if any of the destinations fail, while this
> code ignores errors for all but the last destination.

Return value doesn't really matter here anyway, and certainly not
in the fanout case.


> > +            else
> > +               ++dev->stats.tx_dropped;
> > +         }
> > +         rdst0 = rdst;
> > +      }
> > +
> > +      if (!rdst0) {
> > +         /* forwarding entry but destination list empty */
> > +         ++dev->stats.tx_dropped;
> > +         kfree_skb(skb);
> > +         return NETDEV_TX_OK;
> > +      }
> 
>         This should be a panic, in the original code -- it can't
> happen unless the fdb table is corrupted.
> 
> You say:
> 
> My changes:
> > 1. eliminate second rcu for rdst free
> 
> Why is this a good thing?

Because FDB is only freed by RCU, and don't need another RCU synchronization
pass to drop the dst entries.


> 
> > 2. handle possilble races where fdb notify called but no rdst
> 
> How can an fdb entry ever not have an rdst? Isn't that a reason
> to remove the fdb entry? I don't count "0.0.0.0" as not having an
> rdst, since that is explicitly used for ARP reduction suppression,
> but rather I mean: when can a netlink message adding an fdb entry
> not have an NDA_DST (even if it is 0.0.0.0) and why would that not
> be an error to add an fdb entry without a dst?
> 
> > 3. only update snooped entries for dynamic entries, shouldn't modify 
> static entries
> 
> I agree with this part.
> 
> > 4. clean up the multi-dest tx code
> 
> Everybody likes their own code, of course, but I think the original
> was cleaner. A vxlan_rdst was part of an fdb structure because all
> fdbs require a remote destination, while the clean-up changes that
> to a list which may then be NULL, and in my opinion is notably less
> clean. I don't know the reasoning for that-- perhaps some thread I
> missed?

I don't like code with _continue_ since it is often error prone.
But the original was okay.

> 
> So, I guess I don't see what you're trying to fix here, other than
> preventing snoop updates on static entries, which I agree with.
> 
>                                                         +-DLS

Mike's code didn't allow delete of modification of dst entries to be
done in a safe manner.
