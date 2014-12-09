From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv11 net-next 2/2] openvswitch: Add support for unique flow IDs.
Date: Tue, 9 Dec 2014 10:32:38 -0800
Message-ID: <CALnjE+o4tbQVTyVkzdOG8zj=qxPZ8Dv3vGHbYkBmghxsLgKkkw@mail.gmail.com>
References: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
	<1417575363-13770-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417575363-13770-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 2, 2014 at 6:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, flows were manipulated by userspace specifying a full,
> unmasked flow key. This adds significant burden onto flow
> serialization/deserialization, particularly when dumping flows.
>
> This patch adds an alternative way to refer to flows using a
> variable-length "unique flow identifier" (UFID). At flow setup time,
> userspace may specify a UFID for a flow, which is stored with the flow
> and inserted into a separate table for lookup, in addition to the
> standard flow table. Flows created using a UFID must be fetched or
> deleted using the UFID.
>
> All flow dump operations may now be made more terse with OVS_UFID_F_*
> flags. For example, the OVS_UFID_F_OMIT_KEY flag allows responses to
> omit the flow key from a datapath operation if the flow has a
> corresponding UFID. This significantly reduces the time spent assembling
> and transacting netlink messages. With all OVS_UFID_F_OMIT_* flags
> enabled, the datapath only returns the UFID and statistics for each flow
> during flow dump, increasing ovs-vswitchd revalidator performance by up
> to 50%.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Thanks for updating patch against net-next.

> ---
> v11: Separate UFID and unmasked key from sw_flow.
>      Modify interface to remove nested UFID attributes.
>      Only allow UFIDs between 1-256 octets.
>      Move UFID nla fetch helpers to flow_netlink.h.
>      Perform complete nlmsg_parsing in ovs_flow_cmd_dump().
>      Check UFID table for flows with duplicate UFID at flow setup.
>      Tidy up mask/key/ufid insertion into flow_table.
>      Rebase.
> v10: Ignore flow_key in requests if UFID is specified.
>      Only allow UFID flows to be indexed by UFID.
>      Only allow non-UFID flows to be indexed by unmasked flow key.
>      Unite the unmasked_key and ufid+ufid_hash in 'struct sw_flow'.
>      Don't periodically rehash the UFID table.
>      Resize the UFID table independently from the flow table.
>      Modify table_destroy() to iterate once and delete from both tables.
>      Fix UFID memory leak in flow_free().
>      Remove kernel-only UFIDs for non-UFID cases.
>      Rename "OVS_UFID_F_SKIP_*" -> "OVS_UFID_F_OMIT_*"
>      Update documentation.
>      Rebase.
> v9: No change.
> v8: Rename UID -> UFID "unique flow identifier".
>     Fix null dereference when adding flow without uid or mask.
>     If UFID and not match are specified, and lookup fails, return ENOENT.
>     Rebase.
> v7: Remove OVS_DP_F_INDEX_BY_UID.
>     Rework UID serialisation for variable-length UID.
>     Log error if uid not specified and OVS_UID_F_SKIP_KEY is set.
>     Rebase against "probe" logging changes.
> v6: Fix documentation for supporting UIDs between 32-128 bits.
>     Minor style fixes.
>     Rebase.
> v5: No change.
> v4: Fix memory leaks.
>     Log when triggering the older userspace issue above.
> v3: Initial post.
> ---
>  Documentation/networking/openvswitch.txt |   13 ++
>  include/uapi/linux/openvswitch.h         |   20 +++
>  net/openvswitch/datapath.c               |  241 +++++++++++++++++++-----------
>  net/openvswitch/flow.h                   |   16 +-
>  net/openvswitch/flow_netlink.c           |   63 +++++++-
>  net/openvswitch/flow_netlink.h           |    4 +
>  net/openvswitch/flow_table.c             |  204 +++++++++++++++++++------
>  net/openvswitch/flow_table.h             |    7 +
>  8 files changed, 437 insertions(+), 131 deletions(-)
>
> diff --git a/Documentation/networking/openvswitch.txt b/Documentation/networking/openvswitch.txt
> index 37c20ee..b3b9ac6 100644
> --- a/Documentation/networking/openvswitch.txt
> +++ b/Documentation/networking/openvswitch.txt
> @@ -131,6 +131,19 @@ performs best-effort detection of overlapping wildcarded flows and may reject
>  some but not all of them. However, this behavior may change in future versions.
>
>
> +Unique flow identifiers
> +-----------------------
> +
> +An alternative to using the original match portion of a key as the handle for
> +flow identification is a unique flow identifier, or "UFID". UFIDs are optional
> +for both the kernel and user space program.
> +
> +User space programs that support UFID are expected to provide it during flow
> +setup in addition to the flow, then refer to the flow using the UFID for all
> +future operations. The kernel is not required to index flows by the original
> +flow key if a UFID is specified.
> +
> +
>  Basic rule for evolving flow keys
>  ---------------------------------
>
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 3a6dcaa..80db129 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -444,6 +444,14 @@ struct ovs_key_nd {
>   * a wildcarded match. Omitting attribute is treated as wildcarding all
>   * corresponding fields. Optional for all requests. If not present,
>   * all flow key bits are exact match bits.
> + * @OVS_FLOW_ATTR_UFID: A value between 1-256 octets specifying a unique
> + * identifier for the flow. Causes the flow to be indexed by this value rather
> + * than the value of the %OVS_FLOW_ATTR_KEY attribute. Optional for all
> + * requests. Present in notifications if the flow was created with this
> + * attribute.
> + * @OVS_FLOW_ATTR_UFID_FLAGS: A 32-bit value of OR'd %OVS_UFID_F_*
> + * flags that provide alternative semantics for flow installation and
> + * retrieval. Optional for all requests.
>   *
>   * These attributes follow the &struct ovs_header within the Generic Netlink
>   * payload for %OVS_FLOW_* commands.
> @@ -459,12 +467,24 @@ enum ovs_flow_attr {
>         OVS_FLOW_ATTR_MASK,      /* Sequence of OVS_KEY_ATTR_* attributes. */
>         OVS_FLOW_ATTR_PROBE,     /* Flow operation is a feature probe, error
>                                   * logging should be suppressed. */
> +       OVS_FLOW_ATTR_UFID,      /* Variable length unique flow identifier. */
> +       OVS_FLOW_ATTR_UFID_FLAGS,/* u32 of OVS_UFID_F_*. */
>         __OVS_FLOW_ATTR_MAX
>  };
>
>  #define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
>
>  /**
> + * Omit attributes for notifications.
> + *
> + * If a datapath request contains an %OVS_UFID_F_OMIT_* flag, then the datapath
> + * may omit the corresponding %OVS_FLOW_ATTR_* from the response.
> + */
> +#define OVS_UFID_F_OMIT_KEY      (1 << 0)
> +#define OVS_UFID_F_OMIT_MASK     (1 << 1)
> +#define OVS_UFID_F_OMIT_ACTIONS  (1 << 2)
> +
> +/**
>   * enum ovs_sample_attr - Attributes for %OVS_ACTION_ATTR_SAMPLE action.
>   * @OVS_SAMPLE_ATTR_PROBABILITY: 32-bit fraction of packets to sample with
>   * @OVS_ACTION_ATTR_SAMPLE.  A value of 0 samples no packets, a value of
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index b2a3796..d54e920 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -65,6 +65,8 @@ static struct genl_family dp_packet_genl_family;
>  static struct genl_family dp_flow_genl_family;
>  static struct genl_family dp_datapath_genl_family;
>
> +static const struct nla_policy flow_policy[];
> +
>  static const struct genl_multicast_group ovs_dp_flow_multicast_group = {
>         .name = OVS_FLOW_MCGROUP,
>  };
> @@ -662,11 +664,18 @@ static void get_dp_stats(const struct datapath *dp, struct ovs_dp_stats *stats,
>         }
>  }
>
> -static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
> +static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
> +                                   const struct sw_flow_id *sfid)
>  {
> +       size_t sfid_len = 0;
> +
> +       if (sfid && sfid->ufid_len)
> +               sfid_len = nla_total_size(sfid->ufid_len);
> +
Can you also use ufid_flags to determine exact msg size?

>         return NLMSG_ALIGN(sizeof(struct ovs_header))
>                 + nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_KEY */
>                 + nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_MASK */
> +               + sfid_len /* OVS_FLOW_ATTR_UFID */
>                 + nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
>                 + nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
>                 + nla_total_size(8) /* OVS_FLOW_ATTR_USED */
> @@ -741,7 +750,7 @@ static int ovs_flow_cmd_fill_actions(const struct sw_flow *flow,
>  /* Called with ovs_mutex or RCU read lock. */
>  static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
>                                   struct sk_buff *skb, u32 portid,
> -                                 u32 seq, u32 flags, u8 cmd)
> +                                 u32 seq, u32 flags, u8 cmd, u32 ufid_flags)
>  {
>         const int skb_orig_len = skb->len;
>         struct ovs_header *ovs_header;
> @@ -754,21 +763,35 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
>
>         ovs_header->dp_ifindex = dp_ifindex;
>
> -       err = ovs_nla_put_unmasked_key(flow, skb);
> +       if (flow->ufid)
> +               err = nla_put(skb, OVS_FLOW_ATTR_UFID, flow->ufid->ufid_len,
> +                             flow->ufid->ufid);
> +       else
> +               err = ovs_nla_put_unmasked_key(flow, skb);
>         if (err)
>                 goto error;
>
> -       err = ovs_nla_put_mask(flow, skb);
> -       if (err)
> -               goto error;
> +       if (!(ufid_flags & OVS_UFID_F_OMIT_KEY) && flow->ufid) {
> +               err = ovs_nla_put_masked_key(flow, skb);
> +               if (err)
> +                       goto error;
> +       }
> +
> +       if (!(ufid_flags & OVS_UFID_F_OMIT_MASK)) {
> +               err = ovs_nla_put_mask(flow, skb);
> +               if (err)
> +                       goto error;
> +       }
>
>         err = ovs_flow_cmd_fill_stats(flow, skb);
>         if (err)
>                 goto error;
>
> -       err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
> -       if (err)
> -               goto error;
> +       if (!(ufid_flags & OVS_UFID_F_OMIT_ACTIONS)) {
> +               err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
> +               if (err)
> +                       goto error;
> +       }
>
>         return genlmsg_end(skb, ovs_header);
>
> @@ -779,6 +802,7 @@ error:
>
>  /* May not be called with RCU read lock. */
>  static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *acts,
> +                                              const struct sw_flow_id *sfid,
>                                                struct genl_info *info,
>                                                bool always)
>  {
> @@ -787,7 +811,8 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
>         if (!always && !ovs_must_notify(&dp_flow_genl_family, info, 0))
>                 return NULL;
>
> -       skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts), info, GFP_KERNEL);
> +       skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts, sfid), info,
> +                                 GFP_KERNEL);
>         if (!skb)
>                 return ERR_PTR(-ENOMEM);
>
> @@ -798,19 +823,19 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
>  static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
>                                                int dp_ifindex,
>                                                struct genl_info *info, u8 cmd,
> -                                              bool always)
> +                                              bool always, u32 ufid_flags)
>  {
>         struct sk_buff *skb;
>         int retval;
>
> -       skb = ovs_flow_cmd_alloc_info(ovsl_dereference(flow->sf_acts), info,
> -                                     always);
> +       skb = ovs_flow_cmd_alloc_info(ovsl_dereference(flow->sf_acts),
> +                                     flow->ufid, info, always);
>         if (IS_ERR_OR_NULL(skb))
>                 return skb;
>
>         retval = ovs_flow_cmd_fill_info(flow, dp_ifindex, skb,
>                                         info->snd_portid, info->snd_seq, 0,
> -                                       cmd);
> +                                       cmd, ufid_flags);
>         BUG_ON(retval < 0);
>         return skb;
>  }
> @@ -819,12 +844,14 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>  {
>         struct nlattr **a = info->attrs;
>         struct ovs_header *ovs_header = info->userhdr;
> -       struct sw_flow *flow, *new_flow;
> +       struct sw_flow *flow = NULL, *new_flow;
>         struct sw_flow_mask mask;
>         struct sk_buff *reply;
>         struct datapath *dp;
> +       struct sw_flow_key key;
>         struct sw_flow_actions *acts;
>         struct sw_flow_match match;
> +       u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
>         int error;
>         bool log = !a[OVS_FLOW_ATTR_PROBE];
>
> @@ -849,13 +876,30 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>         }
>
>         /* Extract key. */
> -       ovs_match_init(&match, &new_flow->unmasked_key, &mask);
> +       ovs_match_init(&match, &key, &mask);
>         error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
>                                   a[OVS_FLOW_ATTR_MASK], log);
>         if (error)
>                 goto err_kfree_flow;
>
> -       ovs_flow_mask_key(&new_flow->key, &new_flow->unmasked_key, &mask);
> +       ovs_flow_mask_key(&new_flow->key, &key, &mask);
> +
> +       /* Extract flow id. */
> +       error = ovs_nla_copy_ufid(a[OVS_FLOW_ATTR_UFID], &new_flow->ufid, log);
> +       if (error)
> +               goto err_kfree_flow;

Returning zero in case of no UFID is strange. Can you check for UFID
attribute and then copy ufid unconditionally?

> +       if (!new_flow->ufid) {
> +               struct sw_flow_key *new_key;
> +
> +               new_key = kmalloc(sizeof(*new_flow->unmasked_key), GFP_KERNEL);
> +               if (new_key) {
> +                       memcpy(new_key, &key, sizeof(key));
> +                       new_flow->unmasked_key = new_key;
> +               } else {
> +                       error = -ENOMEM;
> +                       goto err_kfree_flow;
> +               }
> +       }
>
>         /* Validate actions. */
>         error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
> @@ -865,7 +909,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>                 goto err_kfree_flow;
>         }
>
> -       reply = ovs_flow_cmd_alloc_info(acts, info, false);
> +       reply = ovs_flow_cmd_alloc_info(acts, new_flow->ufid, info, false);
>         if (IS_ERR(reply)) {
>                 error = PTR_ERR(reply);
>                 goto err_kfree_acts;
> @@ -877,8 +921,12 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>                 error = -ENODEV;
>                 goto err_unlock_ovs;
>         }
> +
>         /* Check if this is a duplicate flow */
> -       flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->unmasked_key);
> +       if (new_flow->ufid)
> +               flow = ovs_flow_tbl_lookup_ufid(&dp->table, new_flow->ufid);
> +       if (!flow)
> +               flow = ovs_flow_tbl_lookup(&dp->table, &new_flow->key);

Need tight checking, for example what if flow with UFID does not exist
in UFID table but it exist in flow-table? This can complicate
flow-update case where we can not assume UFID of new and old flow is
same.


>         if (likely(!flow)) {
>                 rcu_assign_pointer(new_flow->sf_acts, acts);
>
> @@ -894,7 +942,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>                                                        ovs_header->dp_ifindex,
>                                                        reply, info->snd_portid,
>                                                        info->snd_seq, 0,
> -                                                      OVS_FLOW_CMD_NEW);
> +                                                      OVS_FLOW_CMD_NEW,
> +                                                      ufid_flags);
>                         BUG_ON(error < 0);
>                 }
>                 ovs_unlock();
> @@ -912,11 +961,13 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>                         error = -EEXIST;
>                         goto err_unlock_ovs;
>                 }
> -               /* The unmasked key has to be the same for flow updates. */
> -               if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
> -                       /* Look for any overlapping flow. */
> +               /* The flow identifier has to be the same for flow updates.
> +                * Look for any overlapping flow.
> +                */
> +               if (!flow->ufid &&
> +                   unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
>                         flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
> -                       if (!flow) {
> +                       if (unlikely(!flow)) {
>                                 error = -ENOENT;
>                                 goto err_unlock_ovs;
>                         }
> @@ -930,7 +981,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
>                                                        ovs_header->dp_ifindex,
>                                                        reply, info->snd_portid,
>                                                        info->snd_seq, 0,
> -                                                      OVS_FLOW_CMD_NEW);
> +                                                      OVS_FLOW_CMD_NEW,
> +                                                      ufid_flags);
>                         BUG_ON(error < 0);
>                 }
>                 ovs_unlock();
> @@ -980,45 +1032,34 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>         struct nlattr **a = info->attrs;
>         struct ovs_header *ovs_header = info->userhdr;
>         struct sw_flow_key key;
> -       struct sw_flow *flow;
> +       struct sw_flow *flow = NULL;
>         struct sw_flow_mask mask;
>         struct sk_buff *reply = NULL;
>         struct datapath *dp;
>         struct sw_flow_actions *old_acts = NULL, *acts = NULL;
>         struct sw_flow_match match;
> +       struct sw_flow_id *ufid;
> +       u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
>         int error;
>         bool log = !a[OVS_FLOW_ATTR_PROBE];
>
> -       /* Extract key. */
> -       error = -EINVAL;
> -       if (!a[OVS_FLOW_ATTR_KEY]) {
> +       /* Extract identifier. Take a copy to avoid "Wframe-larger-than=1024"
> +        * warning.
> +        */
What if we limit the implementation of UFID to max 128 bit, does it
still gives you the warning?

> +       error = ovs_nla_copy_ufid(a[OVS_FLOW_ATTR_UFID], &ufid, log);
> +       if (error)
> +               return error;
> +       if (a[OVS_FLOW_ATTR_KEY]) {
> +               ovs_match_init(&match, &key, &mask);
> +               error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
> +                                         a[OVS_FLOW_ATTR_MASK], log);
> +       } else if (!ufid) {
>                 OVS_NLERR(log, "Flow key attribute not present in set flow.");
> -               goto error;
> +               error = -EINVAL;
>         }
> -
> -       ovs_match_init(&match, &key, &mask);
> -       error = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY],
> -                                 a[OVS_FLOW_ATTR_MASK], log);
>         if (error)
>                 goto error;
>
> -       /* Validate actions. */
> -       if (a[OVS_FLOW_ATTR_ACTIONS]) {
> -               acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask,
> -                                       log);
> -               if (IS_ERR(acts)) {
> -                       error = PTR_ERR(acts);
> -                       goto error;
> -               }
> -
> -               /* Can allocate before locking if have acts. */
> -               reply = ovs_flow_cmd_alloc_info(acts, info, false);
> -               if (IS_ERR(reply)) {
> -                       error = PTR_ERR(reply);
> -                       goto err_kfree_acts;
> -               }
> -       }
> -
Why are you moving this action validation under ovs-lock?

>         ovs_lock();
>         dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
>         if (unlikely(!dp)) {
> @@ -1026,33 +1067,34 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>                 goto err_unlock_ovs;
>         }
>         /* Check that the flow exists. */
> -       flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
> +       if (ufid)
> +               flow = ovs_flow_tbl_lookup_ufid(&dp->table, ufid);
> +       else
> +               flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
>         if (unlikely(!flow)) {
>                 error = -ENOENT;
>                 goto err_unlock_ovs;
>         }
>
> -       /* Update actions, if present. */
> -       if (likely(acts)) {
> +       /* Validate and update actions. */
> +       if (a[OVS_FLOW_ATTR_ACTIONS]) {
> +               acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &flow->key,
> +                                       flow->mask, log);
> +               if (IS_ERR(acts)) {
> +                       error = PTR_ERR(acts);
> +                       goto err_unlock_ovs;
> +               }
> +
>                 old_acts = ovsl_dereference(flow->sf_acts);
>                 rcu_assign_pointer(flow->sf_acts, acts);
> +       }
>
> -               if (unlikely(reply)) {
> -                       error = ovs_flow_cmd_fill_info(flow,
> -                                                      ovs_header->dp_ifindex,
> -                                                      reply, info->snd_portid,
> -                                                      info->snd_seq, 0,
> -                                                      OVS_FLOW_CMD_NEW);
> -                       BUG_ON(error < 0);
> -               }
> -       } else {
> -               /* Could not alloc without acts before locking. */
> -               reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex,
> -                                               info, OVS_FLOW_CMD_NEW, false);
> -               if (unlikely(IS_ERR(reply))) {
> -                       error = PTR_ERR(reply);
> -                       goto err_unlock_ovs;
> -               }
> +       reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex,
> +                                       info, OVS_FLOW_CMD_NEW, false,
> +                                       ufid_flags);
> +       if (unlikely(IS_ERR(reply))) {
> +               error = PTR_ERR(reply);
> +               goto err_unlock_ovs;
>         }
>
>         /* Clear stats. */
> @@ -1070,9 +1112,9 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>  err_unlock_ovs:
>         ovs_unlock();
>         kfree_skb(reply);
> -err_kfree_acts:
>         kfree(acts);
>  error:
> +       kfree(ufid);
>         return error;
>  }
>
> @@ -1085,17 +1127,23 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
>         struct sw_flow *flow;
>         struct datapath *dp;
>         struct sw_flow_match match;
> +       struct sw_flow_id ufid;
> +       u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
>         int err;
>         bool log = !a[OVS_FLOW_ATTR_PROBE];
>
> -       if (!a[OVS_FLOW_ATTR_KEY]) {
> +       err = ovs_nla_get_ufid(a[OVS_FLOW_ATTR_UFID], &ufid, log);
> +       if (err)
> +               return err;
> +       if (a[OVS_FLOW_ATTR_KEY]) {
> +               ovs_match_init(&match, &key, NULL);
> +               err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
> +                                       log);
> +       } else if (!ufid.ufid_len) {
>                 OVS_NLERR(log,
>                           "Flow get message rejected, Key attribute missing.");
> -               return -EINVAL;
> +               err = -EINVAL;
>         }
> -
> -       ovs_match_init(&match, &key, NULL);
> -       err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL, log);
>         if (err)
>                 return err;
>
> @@ -1106,14 +1154,17 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
>                 goto unlock;
>         }
>
> -       flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
> +       if (ufid.ufid_len)
> +               flow = ovs_flow_tbl_lookup_ufid(&dp->table, &ufid);
> +       else
> +               flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
>         if (!flow) {
>                 err = -ENOENT;
>                 goto unlock;
>         }
>
>         reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex, info,
> -                                       OVS_FLOW_CMD_NEW, true);
> +                                       OVS_FLOW_CMD_NEW, true, ufid_flags);
>         if (IS_ERR(reply)) {
>                 err = PTR_ERR(reply);
>                 goto unlock;
> @@ -1132,13 +1183,18 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
>         struct ovs_header *ovs_header = info->userhdr;
>         struct sw_flow_key key;
>         struct sk_buff *reply;
> -       struct sw_flow *flow;
> +       struct sw_flow *flow = NULL;
>         struct datapath *dp;
>         struct sw_flow_match match;
> +       struct sw_flow_id ufid;
> +       u32 ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
>         int err;
>         bool log = !a[OVS_FLOW_ATTR_PROBE];
>
> -       if (likely(a[OVS_FLOW_ATTR_KEY])) {
> +       err = ovs_nla_get_ufid(a[OVS_FLOW_ATTR_UFID], &ufid, log);
> +       if (err)
> +               return err;
> +       if (a[OVS_FLOW_ATTR_KEY]) {
>                 ovs_match_init(&match, &key, NULL);
>                 err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL,
>                                         log);
> @@ -1153,12 +1209,15 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
>                 goto unlock;
>         }
>
> -       if (unlikely(!a[OVS_FLOW_ATTR_KEY])) {
> +       if (unlikely(!a[OVS_FLOW_ATTR_KEY] && !ufid.ufid_len)) {
>                 err = ovs_flow_tbl_flush(&dp->table);
>                 goto unlock;
>         }
>
> -       flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
> +       if (ufid.ufid_len)
> +               flow = ovs_flow_tbl_lookup_ufid(&dp->table, &ufid);
> +       else
> +               flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
>         if (unlikely(!flow)) {
>                 err = -ENOENT;
>                 goto unlock;
> @@ -1168,14 +1227,15 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
>         ovs_unlock();
>
>         reply = ovs_flow_cmd_alloc_info((const struct sw_flow_actions __force *) flow->sf_acts,
> -                                       info, false);
> +                                       flow->ufid, info, false);
>         if (likely(reply)) {
>                 if (likely(!IS_ERR(reply))) {
>                         rcu_read_lock();        /*To keep RCU checker happy. */
>                         err = ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex,
>                                                      reply, info->snd_portid,
>                                                      info->snd_seq, 0,
> -                                                    OVS_FLOW_CMD_DEL);
> +                                                    OVS_FLOW_CMD_DEL,
> +                                                    ufid_flags);
>                         rcu_read_unlock();
>                         BUG_ON(err < 0);
>
> @@ -1194,9 +1254,18 @@ unlock:
>
>  static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> +       struct nlattr *a[__OVS_FLOW_ATTR_MAX];
>         struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
>         struct table_instance *ti;
>         struct datapath *dp;
> +       u32 ufid_flags;
> +       int err;
> +
> +       err = nlmsg_parse(cb->nlh, GENL_HDRLEN + dp_flow_genl_family.hdrsize,
> +                         a, dp_flow_genl_family.maxattr, flow_policy);

Can you add genl helper function for this?

> +       if (err)
> +               return err;
> +       ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
>
>         rcu_read_lock();
>         dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
> @@ -1219,7 +1288,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
>                 if (ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex, skb,
>                                            NETLINK_CB(cb->skb).portid,
>                                            cb->nlh->nlmsg_seq, NLM_F_MULTI,
> -                                          OVS_FLOW_CMD_NEW) < 0)
> +                                          OVS_FLOW_CMD_NEW, ufid_flags) < 0)
>                         break;
>
>                 cb->args[0] = bucket;
> @@ -1235,6 +1304,8 @@ static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
>         [OVS_FLOW_ATTR_ACTIONS] = { .type = NLA_NESTED },
>         [OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
>         [OVS_FLOW_ATTR_PROBE] = { .type = NLA_FLAG },
> +       [OVS_FLOW_ATTR_UFID] = { .type = NLA_UNSPEC },
> +       [OVS_FLOW_ATTR_UFID_FLAGS] = { .type = NLA_U32 },
>  };
>
>  static const struct genl_ops dp_flow_genl_ops[] = {
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index a8b30f3..7f31dbf 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -197,6 +197,13 @@ struct sw_flow_match {
>         struct sw_flow_mask *mask;
>  };
>
> +#define MAX_UFID_LENGTH 256
> +
For now we can limit this to 128 bits.

> +struct sw_flow_id {
> +       u32 ufid_len;
> +       u32 ufid[MAX_UFID_LENGTH / 4];
> +};
> +
>  struct sw_flow_actions {
>         struct rcu_head rcu;
>         u32 actions_len;
> @@ -213,13 +220,16 @@ struct flow_stats {
>
>  struct sw_flow {
>         struct rcu_head rcu;
> -       struct hlist_node hash_node[2];
> -       u32 hash;
> +       struct {
> +               struct hlist_node node[2];
> +               u32 hash;
> +       } flow_hash, ufid_hash;
I am not sure about _hash suffix here, Can you explain it? I think
_table is better.

>         int stats_last_writer;          /* NUMA-node id of the last writer on
>                                          * 'stats[0]'.
>                                          */
>         struct sw_flow_key key;
> -       struct sw_flow_key unmasked_key;
> +       struct sw_flow_id *ufid;
Lets move this structure inside sw_flow, so that we can avoid one
kmalloc during flow-install in case of UFID. something like:

struct {
    u32 ufid_len;
    union {
        u32 ufid[MAX_UFID_LENGTH / 4];
        struct sw_flow_key *unmasked_key;
    }
} id;


> +       struct sw_flow_key *unmasked_key; /* Only valid if 'ufid' is NULL. */
>         struct sw_flow_mask *mask;
>         struct sw_flow_actions __rcu *sf_acts;
>         struct flow_stats __rcu *stats[]; /* One for each NUMA node.  First one
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 7bb571f..56a5d2e 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1095,6 +1095,67 @@ free_newmask:
>         return err;
>  }
>
> +static size_t get_ufid_size(const struct nlattr *attr, bool log)
> +{
> +       if (!attr)
> +               return 0;
> +       if (!nla_len(attr)) {
> +               OVS_NLERR(log, "Flow ufid must be at least 1 octet");
> +               return -EINVAL;
> +       }
> +       if (nla_len(attr) >= MAX_UFID_LENGTH) {
> +               OVS_NLERR(log, "Flow ufid size %u bytes exceeds max",
> +                         nla_len(attr));
> +               return -EINVAL;
> +       }
> +
> +       return nla_len(attr);
> +}
> +
> +/* Initializes 'flow->ufid'. */
> +int ovs_nla_get_ufid(const struct nlattr *attr, struct sw_flow_id *sfid,
> +                    bool log)
> +{
> +       size_t len;
> +
> +       sfid->ufid_len = 0;
> +       len = get_ufid_size(attr, log);
> +       if (len <= 0)
> +               return len;
> +
> +       sfid->ufid_len = len;
> +       memcpy(sfid->ufid, nla_data(attr), len);
> +
> +       return 0;
> +}
> +
> +int ovs_nla_copy_ufid(const struct nlattr *attr, struct sw_flow_id **sfid,
> +                     bool log)
> +{
> +       struct sw_flow_id *new_sfid = NULL;
> +       size_t len;
> +
> +       *sfid = NULL;
> +       len = get_ufid_size(attr, log);
> +       if (len <= 0)
> +               return len;
> +
> +       new_sfid = kmalloc(sizeof(*new_sfid), GFP_KERNEL);
> +       if (!new_sfid)
> +               return -ENOMEM;
> +
> +       new_sfid->ufid_len = len;
> +       memcpy(new_sfid->ufid, nla_data(attr), len);
> +       *sfid = new_sfid;
> +
> +       return 0;
> +}
> +
> +u32 ovs_nla_get_ufid_flags(const struct nlattr *attr)
> +{
> +       return attr ? nla_get_u32(attr) : 0;
> +}
> +
>  /**
>   * ovs_nla_get_flow_metadata - parses Netlink attributes into a flow key.
>   * @key: Receives extracted in_port, priority, tun_key and skb_mark.
> @@ -1367,7 +1428,7 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
>  /* Called with ovs_mutex or RCU read lock. */
>  int ovs_nla_put_unmasked_key(const struct sw_flow *flow, struct sk_buff *skb)
>  {
> -       return ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key,
> +       return ovs_nla_put_flow(flow->unmasked_key, flow->unmasked_key,
>                                 OVS_FLOW_ATTR_KEY, false, skb);
>  }
>
> diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
> index ea54564..4f1bd7a 100644
> --- a/net/openvswitch/flow_netlink.h
> +++ b/net/openvswitch/flow_netlink.h
> @@ -57,6 +57,10 @@ int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
>  int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
>                                   const struct ovs_tunnel_info *);
>
> +int ovs_nla_get_ufid(const struct nlattr *, struct sw_flow_id *, bool log);
> +int ovs_nla_copy_ufid(const struct nlattr *, struct sw_flow_id **, bool log);
> +u32 ovs_nla_get_ufid_flags(const struct nlattr *attr);
> +
>  int ovs_nla_copy_actions(const struct nlattr *attr,
>                          const struct sw_flow_key *key,
>                          struct sw_flow_actions **sfa, bool log);
> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index e0a7fef..7287805 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -85,6 +85,8 @@ struct sw_flow *ovs_flow_alloc(void)
>
>         flow->sf_acts = NULL;
>         flow->mask = NULL;
> +       flow->ufid = NULL;
> +       flow->unmasked_key = NULL;
>         flow->stats_last_writer = NUMA_NO_NODE;
>
>         /* Initialize the default stat node. */
> @@ -139,6 +141,8 @@ static void flow_free(struct sw_flow *flow)
>  {
>         int node;
>
> +       kfree(flow->ufid);
> +       kfree(flow->unmasked_key);
>         kfree((struct sw_flow_actions __force *)flow->sf_acts);
>         for_each_node(node)
>                 if (flow->stats[node])
> @@ -200,18 +204,28 @@ static struct table_instance *table_instance_alloc(int new_size)
>
>  int ovs_flow_tbl_init(struct flow_table *table)
>  {
> -       struct table_instance *ti;
> +       struct table_instance *ti, *ufid_ti;
>
>         ti = table_instance_alloc(TBL_MIN_BUCKETS);
>
>         if (!ti)
>                 return -ENOMEM;
>
> +       ufid_ti = table_instance_alloc(TBL_MIN_BUCKETS);
> +       if (!ufid_ti)
> +               goto free_ti;
> +
>         rcu_assign_pointer(table->ti, ti);
> +       rcu_assign_pointer(table->ufid_ti, ufid_ti);
>         INIT_LIST_HEAD(&table->mask_list);
>         table->last_rehash = jiffies;
>         table->count = 0;
> +       table->ufid_count = 0;
>         return 0;
> +
> +free_ti:
> +       __table_instance_destroy(ti);
> +       return -ENOMEM;
>  }
>
>  static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
> @@ -221,13 +235,16 @@ static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
>         __table_instance_destroy(ti);
>  }
>
> -static void table_instance_destroy(struct table_instance *ti, bool deferred)
> +static void table_instance_destroy(struct table_instance *ti,
> +                                  struct table_instance *ufid_ti,
> +                                  bool deferred)
>  {
>         int i;
>
>         if (!ti)
>                 return;
>
> +       BUG_ON(!ufid_ti);
>         if (ti->keep_flows)
>                 goto skip_flows;
>
> @@ -236,18 +253,24 @@ static void table_instance_destroy(struct table_instance *ti, bool deferred)
>                 struct hlist_head *head = flex_array_get(ti->buckets, i);
>                 struct hlist_node *n;
>                 int ver = ti->node_ver;
> +               int ufid_ver = ufid_ti->node_ver;
>
> -               hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
> -                       hlist_del_rcu(&flow->hash_node[ver]);
> +               hlist_for_each_entry_safe(flow, n, head, flow_hash.node[ver]) {
> +                       hlist_del_rcu(&flow->flow_hash.node[ver]);
> +                       if (flow->ufid)
> +                               hlist_del_rcu(&flow->ufid_hash.node[ufid_ver]);
>                         ovs_flow_free(flow, deferred);
>                 }
>         }
>
>  skip_flows:
> -       if (deferred)
> +       if (deferred) {
>                 call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
> -       else
> +               call_rcu(&ufid_ti->rcu, flow_tbl_destroy_rcu_cb);
> +       } else {
>                 __table_instance_destroy(ti);
> +               __table_instance_destroy(ufid_ti);
> +       }
>  }
>
>  /* No need for locking this function is called from RCU callback or
> @@ -256,8 +279,9 @@ skip_flows:
>  void ovs_flow_tbl_destroy(struct flow_table *table)
>  {
>         struct table_instance *ti = rcu_dereference_raw(table->ti);
> +       struct table_instance *ufid_ti = rcu_dereference_raw(table->ufid_ti);
>
> -       table_instance_destroy(ti, false);
> +       table_instance_destroy(ti, ufid_ti, false);
>  }
>
>  struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
> @@ -272,7 +296,7 @@ struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
>         while (*bucket < ti->n_buckets) {
>                 i = 0;
>                 head = flex_array_get(ti->buckets, *bucket);
> -               hlist_for_each_entry_rcu(flow, head, hash_node[ver]) {
> +               hlist_for_each_entry_rcu(flow, head, flow_hash.node[ver]) {
>                         if (i < *last) {
>                                 i++;
>                                 continue;
> @@ -294,16 +318,26 @@ static struct hlist_head *find_bucket(struct table_instance *ti, u32 hash)
>                                 (hash & (ti->n_buckets - 1)));
>  }
>
> -static void table_instance_insert(struct table_instance *ti, struct sw_flow *flow)
> +static void table_instance_insert(struct table_instance *ti,
> +                                 struct sw_flow *flow)
> +{
> +       struct hlist_head *head;
> +
> +       head = find_bucket(ti, flow->flow_hash.hash);
> +       hlist_add_head_rcu(&flow->flow_hash.node[ti->node_ver], head);
> +}
> +
> +static void ufid_table_instance_insert(struct table_instance *ti,
> +                                      struct sw_flow *flow)
>  {
>         struct hlist_head *head;
>
> -       head = find_bucket(ti, flow->hash);
> -       hlist_add_head_rcu(&flow->hash_node[ti->node_ver], head);
> +       head = find_bucket(ti, flow->ufid_hash.hash);
> +       hlist_add_head_rcu(&flow->ufid_hash.node[ti->node_ver], head);
>  }
>
>  static void flow_table_copy_flows(struct table_instance *old,
> -                                 struct table_instance *new)
> +                                 struct table_instance *new, bool ufid)
>  {
>         int old_ver;
>         int i;
> @@ -318,15 +352,21 @@ static void flow_table_copy_flows(struct table_instance *old,
>
>                 head = flex_array_get(old->buckets, i);
>
> -               hlist_for_each_entry(flow, head, hash_node[old_ver])
> -                       table_instance_insert(new, flow);
> +               if (ufid)
> +                       hlist_for_each_entry(flow, head,
> +                                            ufid_hash.node[old_ver])
> +                               ufid_table_instance_insert(new, flow);
> +               else
> +                       hlist_for_each_entry(flow, head,
> +                                            flow_hash.node[old_ver])
> +                               table_instance_insert(new, flow);
>         }
>
>         old->keep_flows = true;
>  }
>
>  static struct table_instance *table_instance_rehash(struct table_instance *ti,
> -                                           int n_buckets)
> +                                                   int n_buckets, bool ufid)
>  {
>         struct table_instance *new_ti;
>
> @@ -334,27 +374,37 @@ static struct table_instance *table_instance_rehash(struct table_instance *ti,
>         if (!new_ti)
>                 return NULL;
>
> -       flow_table_copy_flows(ti, new_ti);
> -
> +       flow_table_copy_flows(ti, new_ti, ufid);
>         return new_ti;
>  }
>
>  int ovs_flow_tbl_flush(struct flow_table *flow_table)
>  {
> -       struct table_instance *old_ti;
> -       struct table_instance *new_ti;
> +       struct table_instance *old_ti, *new_ti;
> +       struct table_instance *old_ufid_ti, *new_ufid_ti;
>
> -       old_ti = ovsl_dereference(flow_table->ti);
>         new_ti = table_instance_alloc(TBL_MIN_BUCKETS);
>         if (!new_ti)
>                 return -ENOMEM;
> +       new_ufid_ti = table_instance_alloc(TBL_MIN_BUCKETS);
> +       if (!new_ufid_ti)
> +               goto err_free_ti;
> +
> +       old_ti = ovsl_dereference(flow_table->ti);
> +       old_ufid_ti = ovsl_dereference(flow_table->ufid_ti);
>
>         rcu_assign_pointer(flow_table->ti, new_ti);
> +       rcu_assign_pointer(flow_table->ufid_ti, new_ufid_ti);
>         flow_table->last_rehash = jiffies;
>         flow_table->count = 0;
> +       flow_table->ufid_count = 0;
>
> -       table_instance_destroy(old_ti, true);
> +       table_instance_destroy(old_ti, old_ufid_ti, true);
>         return 0;
> +
> +err_free_ti:
> +       __table_instance_destroy(new_ti);
> +       return -ENOMEM;
>  }
>
>  static u32 flow_hash(const struct sw_flow_key *key, int key_start,
> @@ -407,7 +457,8 @@ bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
>         int key_start = flow_key_start(key);
>         int key_end = match->range.end;
>
> -       return cmp_key(&flow->unmasked_key, key, key_start, key_end);
> +       BUG_ON(flow->ufid);
> +       return cmp_key(flow->unmasked_key, key, key_start, key_end);
>  }
>
>  static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
> @@ -424,10 +475,9 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
>         ovs_flow_mask_key(&masked_key, unmasked, mask);
>         hash = flow_hash(&masked_key, key_start, key_end);
>         head = find_bucket(ti, hash);
> -       hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
> -               if (flow->mask == mask && flow->hash == hash &&
> -                   flow_cmp_masked_key(flow, &masked_key,
> -                                         key_start, key_end))
> +       hlist_for_each_entry_rcu(flow, head, flow_hash.node[ti->node_ver]) {
> +               if (flow->mask == mask && flow->flow_hash.hash == hash &&
> +                   flow_cmp_masked_key(flow, &masked_key, key_start, key_end))
>                         return flow;
>         }
>         return NULL;
> @@ -469,7 +519,40 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
>         /* Always called under ovs-mutex. */
>         list_for_each_entry(mask, &tbl->mask_list, list) {
>                 flow = masked_flow_lookup(ti, match->key, mask);
> -               if (flow && ovs_flow_cmp_unmasked_key(flow, match))  /* Found */
> +               if (flow && !flow->ufid &&
why not NULL check for flow->unmasked_key here rather than ufid?

> +                   ovs_flow_cmp_unmasked_key(flow, match))
> +                       return flow;
> +       }
> +       return NULL;
> +}
> +
> +static u32 ufid_hash(const struct sw_flow_id *sfid)
> +{
> +       return arch_fast_hash(sfid->ufid, sfid->ufid_len, 0);
> +}
> +
> +bool ovs_flow_cmp_ufid(const struct sw_flow *flow,
> +                      const struct sw_flow_id *sfid)
> +{
> +       if (flow->ufid->ufid_len != sfid->ufid_len)
> +               return false;
> +
> +       return !memcmp(flow->ufid->ufid, sfid->ufid, sfid->ufid_len);
> +}
> +
> +struct sw_flow *ovs_flow_tbl_lookup_ufid(struct flow_table *tbl,
> +                                        const struct sw_flow_id *ufid)
> +{
> +       struct table_instance *ti = rcu_dereference_ovsl(tbl->ufid_ti);
> +       struct sw_flow *flow;
> +       struct hlist_head *head;
> +       u32 hash;
> +
> +       hash = ufid_hash(ufid);
> +       head = find_bucket(ti, hash);
> +       hlist_for_each_entry_rcu(flow, head, ufid_hash.node[ti->node_ver]) {
> +               if (flow->ufid_hash.hash == hash &&
> +                   ovs_flow_cmp_ufid(flow, ufid))
>                         return flow;
>         }
>         return NULL;
> @@ -486,9 +569,10 @@ int ovs_flow_tbl_num_masks(const struct flow_table *table)
>         return num;
>  }
>
> -static struct table_instance *table_instance_expand(struct table_instance *ti)
> +static struct table_instance *table_instance_expand(struct table_instance *ti,
> +                                                   bool ufid)
>  {
> -       return table_instance_rehash(ti, ti->n_buckets * 2);
> +       return table_instance_rehash(ti, ti->n_buckets * 2, ufid);
>  }
>
>  /* Remove 'mask' from the mask list, if it is not needed any more. */
> @@ -513,10 +597,15 @@ static void flow_mask_remove(struct flow_table *tbl, struct sw_flow_mask *mask)
>  void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
>  {
>         struct table_instance *ti = ovsl_dereference(table->ti);
> +       struct table_instance *ufid_ti = ovsl_dereference(table->ufid_ti);
>
>         BUG_ON(table->count == 0);
> -       hlist_del_rcu(&flow->hash_node[ti->node_ver]);
> +       hlist_del_rcu(&flow->flow_hash.node[ti->node_ver]);
>         table->count--;
> +       if (flow->ufid) {
> +               hlist_del_rcu(&flow->ufid_hash.node[ufid_ti->node_ver]);
> +               table->ufid_count--;
> +       }
>
>         /* RCU delete the mask. 'flow->mask' is not NULLed, as it should be
>          * accessible as long as the RCU read lock is held.
> @@ -585,34 +674,65 @@ static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
>  }
>
>  /* Must be called with OVS mutex held. */
> -int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
> -                       const struct sw_flow_mask *mask)
> +static void flow_key_insert(struct flow_table *table, struct sw_flow *flow)
>  {
>         struct table_instance *new_ti = NULL;
>         struct table_instance *ti;
> -       int err;
>
> -       err = flow_mask_insert(table, flow, mask);
> -       if (err)
> -               return err;
> -
> -       flow->hash = flow_hash(&flow->key, flow->mask->range.start,
> -                       flow->mask->range.end);
> +       flow->flow_hash.hash = flow_hash(&flow->key, flow->mask->range.start,
> +                                        flow->mask->range.end);
>         ti = ovsl_dereference(table->ti);
>         table_instance_insert(ti, flow);
>         table->count++;
>
>         /* Expand table, if necessary, to make room. */
>         if (table->count > ti->n_buckets)
> -               new_ti = table_instance_expand(ti);
> +               new_ti = table_instance_expand(ti, false);
>         else if (time_after(jiffies, table->last_rehash + REHASH_INTERVAL))
> -               new_ti = table_instance_rehash(ti, ti->n_buckets);
> +               new_ti = table_instance_rehash(ti, ti->n_buckets, false);
>
>         if (new_ti) {
>                 rcu_assign_pointer(table->ti, new_ti);
> -               table_instance_destroy(ti, true);
> +               call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
>                 table->last_rehash = jiffies;
>         }
> +}
> +
> +/* Must be called with OVS mutex held. */
> +static void flow_ufid_insert(struct flow_table *table, struct sw_flow *flow)
> +{
> +       struct table_instance *ti;
> +
> +       flow->ufid_hash.hash = ufid_hash(flow->ufid);
> +       ti = ovsl_dereference(table->ufid_ti);
> +       ufid_table_instance_insert(ti, flow);
> +       table->ufid_count++;
> +
> +       /* Expand table, if necessary, to make room. */
> +       if (table->ufid_count > ti->n_buckets) {
> +               struct table_instance *new_ti;
> +
> +               new_ti = table_instance_expand(ti, true);
> +               if (new_ti) {
> +                       rcu_assign_pointer(table->ufid_ti, new_ti);
> +                       call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
> +               }
> +       }
> +}
> +
> +/* Must be called with OVS mutex held. */
> +int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
> +                       const struct sw_flow_mask *mask)
> +{
> +       int err;
> +
> +       err = flow_mask_insert(table, flow, mask);
> +       if (err)
> +               return err;
> +       flow_key_insert(table, flow);
> +       if (flow->ufid)
> +               flow_ufid_insert(table, flow);
> +
>         return 0;
>  }
>
> diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
> index 309fa64..454ef92 100644
> --- a/net/openvswitch/flow_table.h
> +++ b/net/openvswitch/flow_table.h
> @@ -47,9 +47,11 @@ struct table_instance {
>
>  struct flow_table {
>         struct table_instance __rcu *ti;
> +       struct table_instance __rcu *ufid_ti;
>         struct list_head mask_list;
>         unsigned long last_rehash;
>         unsigned int count;
> +       unsigned int ufid_count;
>  };
>
>  extern struct kmem_cache *flow_stats_cache;
> @@ -78,8 +80,13 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
>                                     const struct sw_flow_key *);
>  struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
>                                           const struct sw_flow_match *match);
> +struct sw_flow *ovs_flow_tbl_lookup_ufid(struct flow_table *,
> +                                        const struct sw_flow_id *);
> +
>  bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
>                                const struct sw_flow_match *match);
> +bool ovs_flow_cmp_ufid(const struct sw_flow *flow,
> +                      const struct sw_flow_id *sfid);
>
>  void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
>                        const struct sw_flow_mask *mask);
> --
> 1.7.10.4
>
