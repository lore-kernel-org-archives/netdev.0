From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 6/7] openvswitch: Add force commit.
Date: Tue, 7 Feb 2017 21:31:24 -0800
Message-ID: <361497AB-E351-4F1F-89CA-4735C46AE70E@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-6-git-send-email-jarno@ovn.org> <CAPWQB7HX3K9z-aYEv2kkJ2At6iPrEHk24iWce0Gz0TwhDHscYQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33187 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932128AbdBHFb1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 00:31:27 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so14122821pgd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 21:31:27 -0800 (PST)
In-Reply-To: <CAPWQB7HX3K9z-aYEv2kkJ2At6iPrEHk24iWce0Gz0TwhDHscYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 7, 2017, at 2:15 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Stateful network admission policy may allow connections to one
>> direction and reject connections initiated in the other direction.
>> After policy change it is possible that for a new connection an
>> overlapping conntrack entry already exist, where the connection
>> original direction is opposed to the new connection's initial packet.
>> 
>> Most importantly, conntrack state relating to the current packet gets
>> the "reply" designation based on whether the original direction tuple
>> or the reply direction tuple matched.  If this "directionality" is
>> wrong w.r.t. to the stateful network admission policy it may happen
>> that packets in neither direction are correctly admitted.
>> 
>> This patch adds a new "force commit" option to the OVS conntrack
>> action that checks the original direction of an existing conntrack
>> entry.  If that direction is opposed to the current packet, the
>> existing conntrack entry is deleted and a new one is subsequently
>> created in the correct direction.
>> 
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> include/uapi/linux/openvswitch.h | 10 ++++++++++
>> net/openvswitch/conntrack.c      | 27 +++++++++++++++++++++++++--
>> 2 files changed, 35 insertions(+), 2 deletions(-)
>> 
>> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
>> index 90af8b8..d5ba9a9 100644
>> --- a/include/uapi/linux/openvswitch.h
>> +++ b/include/uapi/linux/openvswitch.h
>> @@ -674,6 +674,10 @@ struct ovs_action_hash {
>>  * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
>>  * @OVS_CT_ATTR_NAT: Nested OVS_NAT_ATTR_* for performing L3 network address
>>  * translation (NAT) on the packet.
>> + * @OVS_CT_ATTR_FORCE_COMMIT: Like %OVS_CT_ATTR_COMMIT, but instead of doing
>> + * nothing if the connection is already committed will check that the current
>> + * packet is in conntrack entry's original direction.  If directionality does
>> + * not match, will delete the existing conntrack entry and commit a new one.
>>  */
>> enum ovs_ct_attr {
>>        OVS_CT_ATTR_UNSPEC,
>> @@ -684,6 +688,12 @@ enum ovs_ct_attr {
>>        OVS_CT_ATTR_HELPER,     /* netlink helper to assist detection of
>>                                   related connections. */
>>        OVS_CT_ATTR_NAT,        /* Nested OVS_NAT_ATTR_* */
>> +       OVS_CT_ATTR_FORCE_COMMIT,  /* No argument, commits connection.  If the
>> +                                   * conntrack entry original direction tuple
>> +                                   * does not match the current packet header
>> +                                   * values, will delete the current conntrack
>> +                                   * entry and create a new one.
>> +                                   */
> 
> We only need one copy of the explanation, keep it above the enum, then
> the inline comment can be /* No argument */.
> 

OK.

>>        __OVS_CT_ATTR_MAX
>> };
>> 
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> index 1afe153..1f27f44 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -65,6 +65,7 @@ struct ovs_conntrack_info {
>>        struct nf_conn *ct;
>>        u8 commit : 1;
>>        u8 nat : 3;                 /* enum ovs_ct_nat */
>> +       u8 force : 1;
>>        u16 family;
>>        struct md_mark mark;
>>        struct md_labels labels;
>> @@ -631,10 +632,13 @@ static bool skb_nfct_cached(struct net *net,
>>         */
>>        if (!ct && key->ct.state & OVS_CS_F_TRACKED &&
>>            !(key->ct.state & OVS_CS_F_INVALID) &&
>> -           key->ct.zone == info->zone.id)
>> +           key->ct.zone == info->zone.id) {
>>                ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
>>                                          !!(key->ct.state
>>                                             & OVS_CS_F_NAT_MASK));
>> +               if (ct)
>> +                       nf_ct_get(skb, &ctinfo);
>> +       }
> 
> If ctinfo is only used with the new call below, we can unconditionally
> fetch this just before it's used...
> 
>>        if (!ct)
>>                return false;
>>        if (!net_eq(net, read_pnet(&ct->ct_net)))
>> @@ -648,6 +652,19 @@ static bool skb_nfct_cached(struct net *net,
>>                if (help && rcu_access_pointer(help->helper) != info->helper)
>>                        return false;
>>        }
>> +       /* Force conntrack entry direction to the current packet? */
> 
> Here.
> 

But then we would be executing nf_ct_get() twice in the common case?

>> +       if (info->force && CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL) {
>> +               /* Delete the conntrack entry if confirmed, else just release
>> +                * the reference.
>> +                */
>> +               if (nf_ct_is_confirmed(ct))
>> +                       nf_ct_delete(ct, 0, 0);
>> +               else
>> +                       nf_ct_put(ct);
> 
> We've already ensured that ct is non-NULL, we can use
> nf_conntrack_put() instead.
> 

Right.

>> +               skb->nfct = NULL;
>> +               skb->nfctinfo = 0;
>> +               return false;
>> +       }
>> 
>>        return true;
>> }
>> @@ -1226,6 +1243,7 @@ static int parse_nat(const struct nlattr *attr,
>> 
>> static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
>>        [OVS_CT_ATTR_COMMIT]    = { .minlen = 0, .maxlen = 0 },
>> +       [OVS_CT_ATTR_FORCE_COMMIT]      = { .minlen = 0, .maxlen = 0 },
>>        [OVS_CT_ATTR_ZONE]      = { .minlen = sizeof(u16),
>>                                    .maxlen = sizeof(u16) },
>>        [OVS_CT_ATTR_MARK]      = { .minlen = sizeof(struct md_mark),
>> @@ -1265,6 +1283,9 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
>>                }
>> 
>>                switch (type) {
>> +               case OVS_CT_ATTR_FORCE_COMMIT:
>> +                       info->force = true;
>> +                       /* fall through. */
>>                case OVS_CT_ATTR_COMMIT:
>>                        info->commit = true;
>>                        break;
>> @@ -1491,7 +1512,9 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
>>        if (!start)
>>                return -EMSGSIZE;
>> 
>> -       if (ct_info->commit && nla_put_flag(skb, OVS_CT_ATTR_COMMIT))
>> +       if (ct_info->commit && nla_put_flag(skb, ct_info->force
>> +                                           ? OVS_CT_ATTR_FORCE_COMMIT
>> +                                           : OVS_CT_ATTR_COMMIT))
>>                return -EMSGSIZE;
>>        if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
>>            nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone.id))
>> --
>> 2.1.4
