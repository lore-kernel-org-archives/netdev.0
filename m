From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv11 net-next 2/2] openvswitch: Add support for unique flow IDs.
Date: Tue, 9 Dec 2014 22:11:38 -0800
Message-ID: <CALnjE+pnJqHFaKZAGgN2Q_q-sAfuGYOb6fX0utkb-J1-JFv7dg@mail.gmail.com>
References: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
	<1417575363-13770-2-git-send-email-joestringer@nicira.com>
	<CALnjE+o4tbQVTyVkzdOG8zj=qxPZ8Dv3vGHbYkBmghxsLgKkkw@mail.gmail.com>
	<CANr6G5yOqVkA6hf3J9mk41Kh=0k3sM3tQx4sdADSgFaAx9xrWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANr6G5yOqVkA6hf3J9mk41Kh=0k3sM3tQx4sdADSgFaAx9xrWg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 9, 2014 at 4:25 PM, Joe Stringer <joestringer@nicira.com> wrote:
> On 9 December 2014 at 10:32, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Tue, Dec 2, 2014 at 6:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
>>> @@ -662,11 +664,18 @@ static void get_dp_stats(const struct datapath *dp, struct ovs_dp_stats *stats,
>>>         }
>>>  }

>>> +       error = ovs_nla_copy_ufid(a[OVS_FLOW_ATTR_UFID], &ufid, log);
>>> +       if (error)
>>> +               return error;
>>> +       if (a[OVS_FLOW_ATTR_KEY]) {
>>> +               ovs_match_init(&match, &key, &mask);
>>> +               error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
>>> +                                         a[OVS_FLOW_ATTR_MASK], log);
>>> +       } else if (!ufid) {
>>>                 OVS_NLERR(log, "Flow key attribute not present in set flow.");
>>> -               goto error;
>>> +               error = -EINVAL;
>>>         }
>>> -
>>> -       ovs_match_init(&match, &key, &mask);
>>> -       error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
>>> -                                 a[OVS_FLOW_ATTR_MASK], log);
>>>         if (error)
>>>                 goto error;
>>>
>>> -       /* Validate actions. */
>>> -       if (a[OVS_FLOW_ATTR_ACTIONS]) {
>>> -               acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask,
>>> -                                       log);
>>> -               if (IS_ERR(acts)) {
>>> -                       error = PTR_ERR(acts);
>>> -                       goto error;
>>> -               }
>>> -
>>> -               /* Can allocate before locking if have acts. */
>>> -               reply = ovs_flow_cmd_alloc_info(acts, info, false);
>>> -               if (IS_ERR(reply)) {
>>> -                       error = PTR_ERR(reply);
>>> -                       goto err_kfree_acts;
>>> -               }
>>> -       }
>>> -
>> Why are you moving this action validation under ovs-lock?
>
> The thought was that flow_cmd_set may receive UFID and not key/mask.
> One could imagine a command that sends a UFID and actions, telling OVS
> kmod to update just the actions. Masked key is required for
> ovs_nla_copy_actions(), so in this case a lookup would be required to
> get a masked key.
>
> Perhaps the better alternative for the moment is to still require flow
> key and mask for this command (just as we do for flow_cmd_new). That
> would simplify this change greatly, and doesn't affect current OVS
> userspace.
>
sounds good.

>>> @@ -1194,9 +1254,18 @@ unlock:
>>>
>>>  static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
>>>  {
>>> +       struct nlattr *a[__OVS_FLOW_ATTR_MAX];
>>>         struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
>>>         struct table_instance *ti;
>>>         struct datapath *dp;
>>> +       u32 ufid_flags;
>>> +       int err;
>>> +
>>> +       err = nlmsg_parse(cb->nlh, GENL_HDRLEN + dp_flow_genl_family.hdrsize,
>>> +                         a, dp_flow_genl_family.maxattr, flow_policy);
>>
>> Can you add genl helper function for this?
>
> OK.
>
>>> @@ -1235,6 +1304,8 @@ static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
>>>         [OVS_FLOW_ATTR_ACTIONS] = { .type = NLA_NESTED },
>>>         [OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
>>>         [OVS_FLOW_ATTR_PROBE] = { .type = NLA_FLAG },
>>> +       [OVS_FLOW_ATTR_UFID] = { .type = NLA_UNSPEC },
>>> +       [OVS_FLOW_ATTR_UFID_FLAGS] = { .type = NLA_U32 },
>>>  };
>>>
>>>  static const struct genl_ops dp_flow_genl_ops[] = {
>>> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
>>> index a8b30f3..7f31dbf 100644
>>> --- a/net/openvswitch/flow.h
>>> +++ b/net/openvswitch/flow.h
>>> @@ -197,6 +197,13 @@ struct sw_flow_match {
>>>         struct sw_flow_mask *mask;
>>>  };
>>>
>>> +#define MAX_UFID_LENGTH 256
>>> +
>> For now we can limit this to 128 bits.
>
> Is there a reason beyond trying to avoid the warning in flow_cmd_set()?
> I suppose that its purpose as an identifier means that it's unlikely to
> need to be much bigger in future (indeed, the larger it gets, the more
> it would trade off the performance gains from using it).
>
I am also not sure why would we need ID larger than 128 bit. In such
unlikely scenario I think we can increase it later if we need it.


>>> @@ -213,13 +220,16 @@ struct flow_stats {
>>>
>>>  struct sw_flow {
>>>         struct rcu_head rcu;
>>> -       struct hlist_node hash_node[2];
>>> -       u32 hash;
>>> +       struct {
>>> +               struct hlist_node node[2];
>>> +               u32 hash;
>>> +       } flow_hash, ufid_hash;
>> I am not sure about _hash suffix here, Can you explain it? I think
>> _table is better.
>
> Agreed, table is better.
>
>>>         int stats_last_writer;          /* NUMA-node id of the last writer on
>>>                                          * 'stats[0]'.
>>>                                          */
>>>         struct sw_flow_key key;
>>> -       struct sw_flow_key unmasked_key;
>>> +       struct sw_flow_id *ufid;
>> Lets move this structure inside sw_flow, so that we can avoid one
>> kmalloc during flow-install in case of UFID. something like:
>>
>> struct {
>>     u32 ufid_len;
>>     union {
>>         u32 ufid[MAX_UFID_LENGTH / 4];
>>         struct sw_flow_key *unmasked_key;
>>     }
>> } id;
>
> Agreed.
>
>>> @@ -424,10 +475,9 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
>>>         ovs_flow_mask_key(&masked_key, unmasked, mask);
>>>         hash = flow_hash(&masked_key, key_start, key_end);
>>>         head = find_bucket(ti, hash);
>>> -       hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
>>> -               if (flow->mask == mask && flow->hash == hash &&
>>> -                   flow_cmp_masked_key(flow, &masked_key,
>>> -                                         key_start, key_end))
>>> +       hlist_for_each_entry_rcu(flow, head, flow_hash.node[ti->node_ver]) {
>>> +               if (flow->mask == mask && flow->flow_hash.hash == hash &&
>>> +                   flow_cmp_masked_key(flow, &masked_key, key_start, key_end))
>>>                         return flow;
>>>         }
>>>         return NULL;
>>> @@ -469,7 +519,40 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
>>>         /* Always called under ovs-mutex. */
>>>         list_for_each_entry(mask, &tbl->mask_list, list) {
>>>                 flow = masked_flow_lookup(ti, match->key, mask);
>>> -               if (flow && ovs_flow_cmp_unmasked_key(flow, match))  /* Found */
>>> +               if (flow && !flow->ufid &&
>> why not NULL check for flow->unmasked_key here rather than ufid?
>
> In this version, I tried to consistently use flow->ufid as the switch
> for whether UFID exists or not. In the next version, this statement
> would refer to flow->id->ufid_len.
>
> The current approach means that ovs_flow_tbl_lookup_exact() is really
> ovs_flow_tbl_lookup_unmasked_key(). Do you think this should remain
> specific to unmasked key or should it be made to check that the
> identifier (ufid OR unmasked key) is the same?

It is easier to read code if we check for flow->unmasked_key here.
ovs_flow_cmp_unmasked_key() has assert on ufid anyways.
