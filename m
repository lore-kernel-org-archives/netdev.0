From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [ovs-dev] [PATCHv11 net-next 2/2] openvswitch: Add support for
 unique flow IDs.
Date: Wed, 10 Dec 2014 10:15:27 -0800
Message-ID: <CAOftzPjp3++6X50m27fhnAqVPsNRRfrhtmWGoeVi_8v3KCHWhA@mail.gmail.com>
References: <1417575363-13770-1-git-send-email-joestringer@nicira.com>
 <1417575363-13770-2-git-send-email-joestringer@nicira.com>
 <CALnjE+o4tbQVTyVkzdOG8zj=qxPZ8Dv3vGHbYkBmghxsLgKkkw@mail.gmail.com>
 <CANr6G5yOqVkA6hf3J9mk41Kh=0k3sM3tQx4sdADSgFaAx9xrWg@mail.gmail.com> <CALnjE+pnJqHFaKZAGgN2Q_q-sAfuGYOb6fX0utkb-J1-JFv7dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:32871 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbaLJSPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 13:15:48 -0500
In-Reply-To: <CALnjE+pnJqHFaKZAGgN2Q_q-sAfuGYOb6fX0utkb-J1-JFv7dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 December 2014 at 22:11, Pravin Shelar <pshelar@nicira.com> wrote:
> On Tue, Dec 9, 2014 at 4:25 PM, Joe Stringer <joestringer@nicira.com> wrote:
>> On 9 December 2014 at 10:32, Pravin Shelar <pshelar@nicira.com> wrote:
>>> On Tue, Dec 2, 2014 at 6:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
>>>> @@ -424,10 +475,9 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
>>>>         ovs_flow_mask_key(&masked_key, unmasked, mask);
>>>>         hash = flow_hash(&masked_key, key_start, key_end);
>>>>         head = find_bucket(ti, hash);
>>>> -       hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
>>>> -               if (flow->mask == mask && flow->hash == hash &&
>>>> -                   flow_cmp_masked_key(flow, &masked_key,
>>>> -                                         key_start, key_end))
>>>> +       hlist_for_each_entry_rcu(flow, head, flow_hash.node[ti->node_ver]) {
>>>> +               if (flow->mask == mask && flow->flow_hash.hash == hash &&
>>>> +                   flow_cmp_masked_key(flow, &masked_key, key_start, key_end))
>>>>                         return flow;
>>>>         }
>>>>         return NULL;
>>>> @@ -469,7 +519,40 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
>>>>         /* Always called under ovs-mutex. */
>>>>         list_for_each_entry(mask, &tbl->mask_list, list) {
>>>>                 flow = masked_flow_lookup(ti, match->key, mask);
>>>> -               if (flow && ovs_flow_cmp_unmasked_key(flow, match))  /* Found */
>>>> +               if (flow && !flow->ufid &&
>>> why not NULL check for flow->unmasked_key here rather than ufid?
>>
>> In this version, I tried to consistently use flow->ufid as the switch
>> for whether UFID exists or not. In the next version, this statement
>> would refer to flow->id->ufid_len.
>>
>> The current approach means that ovs_flow_tbl_lookup_exact() is really
>> ovs_flow_tbl_lookup_unmasked_key(). Do you think this should remain
>> specific to unmasked key or should it be made to check that the
>> identifier (ufid OR unmasked key) is the same?
>
> It is easier to read code if we check for flow->unmasked_key here.
> ovs_flow_cmp_unmasked_key() has assert on ufid anyways.

With the change to put UFID/unmasked key in the same struct, there
will be no such pointer to check, only ufid_len.

However, we could shift this check at the start of the function instead.
