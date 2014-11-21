From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv10 ovs 12/15] datapath: Add support for unique flow identifiers.
Date: Fri, 21 Nov 2014 10:08:56 -0800
Message-ID: <CALnjE+p-1+Nh2yHu_zRxrLPnFKnAcW0hDFL1Dex_8ZNUhJ4oNQ@mail.gmail.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
	<1415906275-3172-13-git-send-email-joestringer@nicira.com>
	<CALnjE+owCheaKK8=JBmW0whpC1_iP67XfnaGCghi4jSWYaDfkg@mail.gmail.com>
	<CANr6G5zoe=vAme08cHzdM76iYCjMYPz-mcbw236mk1-dVqxLdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:38324 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751273AbaKUSI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 13:08:56 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so27271igb.9
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 10:08:56 -0800 (PST)
In-Reply-To: <CANr6G5zoe=vAme08cHzdM76iYCjMYPz-mcbw236mk1-dVqxLdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 4:33 PM, Joe Stringer <joestringer@nicira.com> wrote:
> On 19 November 2014 15:34, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Thu, Nov 13, 2014 at 11:17 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>> @@ -684,33 +691,43 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
>>>
>>>  /* Called with ovs_mutex or RCU read lock. */
>>>  static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
>>> -                                  struct sk_buff *skb)
>>> +                                  struct sk_buff *skb, u32 ufid_flags)
>>>  {
>>>         struct nlattr *nla;
>>>         int err;
>>>
>>> -       /* Fill flow key. */
>>> -       nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
>>> -       if (!nla)
>>> -               return -EMSGSIZE;
>>> -
>>> -       err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb,
>>> -                              false);
>>> -       if (err)
>>> -               return err;
>>> -
>>> -       nla_nest_end(skb, nla);
>>> +       /* Fill flow key. If userspace didn't specify a UFID, then ignore the
>>> +        * OMIT_KEY flag. */
>>> +       if (!(ufid_flags & OVS_UFID_F_OMIT_KEY) ||
>>> +           !flow->index_by_ufid) {
>>
>> I am not sure about this check, userspace needs to send atleast ufid
>> or the unmasked key as id for flow. otherwise we shld flag error. Here
>> we can serialize flow->key.
>> There could be another function which takes care of flow-id
>> serialization where we serialize use ufid or unmasked key as flow id.
>> Lets group ufid and unmasked key together rather than masked key and
>> unmasked key which are not related.
>
> Let me start from scratch and see if this is what you're saying.
>
> fill_id() would serialize the UFID or unmasked key if UFID is not available.
> fill_key() would serialize the masked key if !(ufid_flags &
> OVS_UFID_F_OMIT_KEY) and UFID was provided (but not when the UFID is
> missing).
> fill_mask() would serialize the mask if !(ufid_flags & OVS_UFID_F_OMIT_MASK).
>
> I see key and id as related, because the flow_key serves as both the
> "match" and the "id" in the non-ufid case, so we need to know the same
> piece of information in both functions to ensure we don't serialize
> the key twice.

Lets follow new model where ID and key are two separate attributes. I
agree we also need to check for ufid in key serialization function to
handle compatibility code. Keeping masked and unmasked key separate is
easier to understand.
