From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv10 ovs 12/15] datapath: Add support for unique flow identifiers.
Date: Wed, 19 Nov 2014 16:20:32 -0800
Message-ID: <201411191620.32217.joestringer@nicira.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com> <1415906275-3172-13-git-send-email-joestringer@nicira.com> <CALnjE+owCheaKK8=JBmW0whpC1_iP67XfnaGCghi4jSWYaDfkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:35077 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753629AbaKTA20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 19:28:26 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so1358896pad.3
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 16:28:25 -0800 (PST)
In-Reply-To: <CALnjE+owCheaKK8=JBmW0whpC1_iP67XfnaGCghi4jSWYaDfkg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 19, 2014 15:34:24 Pravin Shelar wrote:
> On Thu, Nov 13, 2014 at 11:17 AM, Joe Stringer <joestringer@nicira.com> 
wrote:
> > @@ -684,33 +691,43 @@ static size_t ovs_flow_cmd_msg_size(const struct
> > sw_flow_actions *acts)
> > 
> >  /* Called with ovs_mutex or RCU read lock. */
> >  static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
> > 
> > -                                  struct sk_buff *skb)
> > +                                  struct sk_buff *skb, u32 ufid_flags)
> > 
> >  {
> >  
> >         struct nlattr *nla;
> >         int err;
> > 
> > -       /* Fill flow key. */
> > -       nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
> > -       if (!nla)
> > -               return -EMSGSIZE;
> > -
> > -       err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key,
> > skb, -                              false);
> > -       if (err)
> > -               return err;
> > -
> > -       nla_nest_end(skb, nla);
> > +       /* Fill flow key. If userspace didn't specify a UFID, then ignore
> > the +        * OMIT_KEY flag. */
> > +       if (!(ufid_flags & OVS_UFID_F_OMIT_KEY) ||
> > +           !flow->index_by_ufid) {
> 
> I am not sure about this check, userspace needs to send atleast ufid
> or the unmasked key as id for flow. otherwise we shld flag error. Here
> we can serialize flow->key.
> There could be another function which takes care of flow-id
> serialization where we serialize use ufid or unmasked key as flow id.
> Lets group ufid and unmasked key together rather than masked key and
> unmasked key which are not related.

Right, at flow setup time the flow key is always required, but the UFID is 
optional. For most other cases, one of the two most be specified. For flow dump, 
neither is required from userspace, but OMIT_KEY flag may be raised. That's the 
particular case that this logic is trying to catch (dump all flows, including 
those that were set up without UFID - in which case the OMIT_KEY flag doesn't 
make sense, so treat the flag like a request rather than a command).

Happy to split the key/identifier out from the mask.
 
> > @@ -740,6 +757,32 @@ static int ovs_flow_cmd_fill_stats(const struct
> > sw_flow *flow,
> > 
> >  }
> >  
> >  /* Called with ovs_mutex or RCU read lock. */
> > 
> > +static int ovs_flow_cmd_fill_ufid(const struct sw_flow *flow,
> > +                                 struct sk_buff *skb)
> > +{
> > +       struct nlattr *start;
> > +       const struct sw_flow_id *sfid;
> > +
> > +       if (!flow->index_by_ufid)
> > +               return 0;
> > +
> > +       sfid = &flow->index.ufid;
> > +       start = nla_nest_start(skb, OVS_FLOW_ATTR_UFID);
> > +       if (start) {
> > +               int err;
> > +
> > +               err = nla_put(skb, OVS_UFID_ATTR_ID, sfid->ufid_len,
> > +                             sfid->ufid);
> > +               if (err)
> > +                       return err;
> > +               nla_nest_end(skb, start);
> > +       } else
> > +               return -EMSGSIZE;
> > +
> > +       return 0;
> > +}
> > +
> 
> Can you change this function according to comments above?

OK.

> > @@ -795,18 +838,24 @@ static int ovs_flow_cmd_fill_info(const struct
> > sw_flow *flow, int dp_ifindex,
> > 
> >         ovs_header->dp_ifindex = dp_ifindex;
> > 
> > -       err = ovs_flow_cmd_fill_match(flow, skb);
> > +       err = ovs_flow_cmd_fill_match(flow, skb, ufid_flags);
> > 
> >         if (err)
> >         
> >                 goto error;
> > 
> > -       err = ovs_flow_cmd_fill_stats(flow, skb);
> > +       err = ovs_flow_cmd_fill_ufid(flow, skb);
> > 
> >         if (err)
> >         
> >                 goto error;
> 
> Flow ID should go first in the netlink msg.

OK.

> > @@ -915,8 +980,9 @@ static int ovs_flow_cmd_new(struct sk_buff *skb,
> > struct genl_info *info)
> > 
> >                 error = -ENODEV;
> >                 goto err_unlock_ovs;
> >         
> >         }
> > 
> > +
> > 
> >         /* Check if this is a duplicate flow */
> > 
> > -       flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->unmasked_key);
> > +       flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->key);
> 
> Need to check for ufid table to find duplicate ufid entry here.
 
OK.

> > diff --git a/datapath/flow.h b/datapath/flow.h
> > index 2bbf789..736e0eb 100644
> > --- a/datapath/flow.h
> > +++ b/datapath/flow.h
> > @@ -196,6 +196,13 @@ struct sw_flow_match {
> > 
> >         struct sw_flow_mask *mask;
> >  
> >  };
> > 
> > +struct sw_flow_id {
> > +       struct hlist_node node[2];
> > +       u32 hash;
> > +       u8 *ufid;
> > +       u8 ufid_len;
> > +};
> > +
> 
> Lets make ufid array of size 256, we can reject any key greater than
> this. current patch does not support key greater than 256 anyways.

Ok, that sounds reasonable.

> >  struct sw_flow_actions {
> >  
> >         struct rcu_head rcu;
> >         u32 actions_len;
> > 
> > @@ -212,13 +219,20 @@ struct flow_stats {
> > 
> >  struct sw_flow {
> >  
> >         struct rcu_head rcu;
> > 
> > -       struct hlist_node hash_node[2];
> > -       u32 hash;
> > +       struct {
> > +               struct hlist_node node[2];
> > +               u32 hash;
> > +       } flow_hash;
> 
> This change does not look related to this work.

Right, this is unnecessary leftover from earlier iteration.


> >         int stats_last_writer;          /* NUMA-node id of the last
> >         writer on
> >         
> >                                          * 'stats[0]'.
> >                                          */
> >         
> >         struct sw_flow_key key;
> > 
> > -       struct sw_flow_key unmasked_key;
> > +       bool index_by_ufid;             /* Which of the below that
> > userspace +                                          uses to index this
> > flow. */ +       union {
> > +               struct sw_flow_key unmasked_key;
> > +               struct sw_flow_id ufid;
> > +       } index;
> 
> Rather than storing ufid or unmasked key inside struct flow we can
> keep pointer to these objects, that will save some memory.

OK. Do you still care about the union being there?

> > @@ -818,31 +914,65 @@ static int flow_mask_insert(struct flow_table *tbl,
> > struct sw_flow *flow,
> > 
> >  int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
> >  
> >                         const struct sw_flow_mask *mask)
> >  
> >  {
> > 
> > -       struct table_instance *new_ti = NULL;
> > -       struct table_instance *ti;
> > +       struct table_instance *new_ti = NULL, *new_ufid_ti = NULL;
> > +       struct table_instance *ti, *ufid_ti = NULL;
> > 
> >         int err;
> >         
> >         err = flow_mask_insert(table, flow, mask);
> >         if (err)
> >         
> >                 return err;
> > 
> > -       flow->hash = flow_hash(&flow->key, flow->mask->range.start,
> > -                       flow->mask->range.end);
> > +       flow->flow_hash.hash = flow_hash(&flow->key,
> > flow->mask->range.start, +                                       
> > flow->mask->range.end);
> > 
> >         ti = ovsl_dereference(table->ti);
> >         table_instance_insert(ti, flow);
> >         table->count++;
> > 
> > +       if (flow->index_by_ufid) {
> > +               flow->index.ufid.hash = ufid_hash(&flow->index.ufid);
> > +               ufid_ti = ovsl_dereference(table->ufid_ti);
> > +               ufid_table_instance_insert(ufid_ti, flow);
> > +               table->ufid_count++;
> > +       }
> > 
> >         /* Expand table, if necessary, to make room. */
> >         if (table->count > ti->n_buckets)
> > 
> > -               new_ti = table_instance_expand(ti);
> > +               new_ti = flow_table_expand(ti, false);
> > 
> >         else if (time_after(jiffies, table->last_rehash +
> >         REHASH_INTERVAL))
> > 
> > -               new_ti = table_instance_rehash(ti, ti->n_buckets);
> > +               new_ti = flow_table_rehash(ti, ti->n_buckets, false);
> > +       if (ufid_ti && table->ufid_count > ufid_ti->n_buckets)
> > +               new_ufid_ti = flow_table_expand(ufid_ti, true);
> > 
> >         if (new_ti) {
> >         
> >                 rcu_assign_pointer(table->ti, new_ti);
> > 
> > -               table_instance_destroy(ti, true);
> > +               call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
> > 
> >                 table->last_rehash = jiffies;
> >         
> >         }
> > 
> > +       if (new_ufid_ti) {
> > +               rcu_assign_pointer(table->ufid_ti, new_ufid_ti);
> > +               call_rcu(&ufid_ti->rcu, flow_tbl_destroy_rcu_cb);
> > +       }
> > +       return 0;
> > +}
> 
> Insert function can be simplified by first updating flow-table and
> then updating ufid table.

Sure.


> >  #define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
> >  
> >  /**
> > 
> > + * enum ovs_ufid_attr - Unique identifier types.
> > + *
> > + * @OVS_UFID_ATTR_FLAGS: A 32-bit value specifying changes to the
> > behaviour of + * the current %OVS_FLOW_CMD_* request. Optional for all
> > requests. + * @OVS_UFID_ATTR_ID: A unique identifier for a flow.
> > + */
> > +enum ovs_ufid_attr {
> > +       OVS_UFID_ATTR_UNSPEC,
> > +       OVS_UFID_ATTR_FLAGS,     /* u32 of OVS_UFID_F_* */
> > +       OVS_UFID_ATTR_ID,        /* variable length identifier. */
> > +       __OVS_UFID_ATTR_MAX
> > +};
> > +
> > +#define OVS_UFID_ATTR_MAX (__OVS_UFID_ATTR_MAX - 1)
> > +
> > +/**
> > + * Omit attributes for notifications.
> > + *
> > + * If a datapath request contains an OVS_UFID_F_OMIT_* flag, then the
> > datapath + * may omit the corresponding 'ovs_flow_attr' from the
> > response. + */
> > +#define OVS_UFID_F_OMIT_KEY      (1 << 0)
> > +#define OVS_UFID_F_OMIT_MASK     (1 << 1)
> > +#define OVS_UFID_F_OMIT_ACTIONS  (1 << 2)
> > +
> 
> These flags are related to flow operations. So OVS_UFID_ATTR_FLAGS
> should be part of enum ovs_flow_attr.
> This way we do not need to make UFID nested attr.

OK, I'll shift it out.

Thanks for the review, I'll work on a fresh revision.
