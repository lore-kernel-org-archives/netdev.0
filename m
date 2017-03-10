From: Joe Stringer <joe@ovn.org>
Subject: Re: [RFC net-next sample action optimization 3/3] openvswitch:
 Optimize sample action for the clone use cases
Date: Fri, 10 Mar 2017 15:12:59 -0800
Message-ID: <CAPWQB7HdrdGZ95HTduS=MWGgDNvaY7_w9OyBO2yxU+OaYkfqng@mail.gmail.com>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org>
 <1488932137-120383-4-git-send-email-azhou@ovn.org> <CAPWQB7F0XkHWkJ15N-ru83XBUkr2474yjmk0C_H1WErhELr+Ew@mail.gmail.com>
 <CABKoBm3fQqdVugW9n7Bkj4t21AESgV9=k2yMpZCikVxAXmffMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pravin shelar <pshelar@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:54663 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755506AbdCJXN1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 18:13:27 -0500
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 47B7E172093
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:13:24 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Ex5sNclCOqwY for <netdev@vger.kernel.org>;
        Sat, 11 Mar 2017 00:13:22 +0100 (CET)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id F38CB172094
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:13:20 +0100 (CET)
Received: by mail-qk0-f179.google.com with SMTP id 1so189545205qkl.3
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 15:13:20 -0800 (PST)
In-Reply-To: <CABKoBm3fQqdVugW9n7Bkj4t21AESgV9=k2yMpZCikVxAXmffMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 March 2017 at 14:07, Andy Zhou <azhou@ovn.org> wrote:
> On Thu, Mar 9, 2017 at 11:46 AM, Joe Stringer <joe@ovn.org> wrote:
>> On 7 March 2017 at 16:15, Andy Zhou <azhou@ovn.org> wrote:
>>> With the introduction of open flow 'clone' action, the OVS user space
>>> can now translate the 'clone' action into kernel datapath 'sample'
>>> action, with 100% probability, to ensure that the clone semantics,
>>> which is that the packet seen by the clone action is the same as the
>>> packet seen by the action after clone, is faithfully carried out
>>> in the datapath.
>>>
>>> While the sample action in the datpath has the matching semantics,
>>> its implementation is only optimized for its original use.
>>> Specifically, there are two limitation: First, there is a 3 level of
>>> nesting restriction, enforced at the flow downloading time. This
>>> limit turns out to be too restrictive for the 'clone' use case.
>>> Second, the implementation avoid recursive call only if the sample
>>> action list has a single userspace action.
>>>
>>> The optimization implemented in this series removes the static
>>> nesting limit check, instead, implement the run time recursion limit
>>> check, and recursion avoidance similar to that of the 'recirc' action.
>>> This optimization solve both #1 and #2 issues above.
>>>
>>> Another optimization implemented is to avoid coping flow key as
>>
>> *copying
>>
>>> long as the actions enclosed does not change the flow key. The
>>> detection is performed only once at the flow downloading time.
>>>
>>> The third optimization implemented is to rewrite the action list
>>> at flow downloading time in order to save the fast path from parsing
>>> the sample action list in its original form repeatedly.
>>
>> Whenever there is an enumeration (1, 2, 3; ..another..., third thing
>> implemented) in a commit message, I have to ask whether each "another
>> change..." should be a separate patch. It certainly makes it easier to
>> review.
>>
> They are all part of the same implementation. Spliting them probably won't
> make much sense. I think I will drop #2 and #3 in the commit message since
> #1 is the main optimization.

Fair enough. You don't have to drop them from the commit message, it
makes the intention of all of the changes more clear.

>> I ran this through the OVS kernel tests and it's working correctly
>> from that point of view, but I didn't get a chance to dig in and
>> ensure for example, runtime behaviour of several nested
>> sample(actions(sample(actions(sample(actions(output)))))) handles
>> reasonably when it runs out of stack and deferred actions space. At a
>> high level though, this seems pretty straightforward.
>>
>> Several comments below, thanks.
>>
>>>
>>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>>> ---
>>>  net/openvswitch/actions.c      | 106 ++++++++++++++++++------------------
>>>  net/openvswitch/datapath.h     |   7 +++
>>>  net/openvswitch/flow_netlink.c | 118 ++++++++++++++++++++++++++++-------------
>>>  3 files changed, 140 insertions(+), 91 deletions(-)
>>>
>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>> index 259aea9..2e8c372 100644
>>> --- a/net/openvswitch/actions.c
>>> +++ b/net/openvswitch/actions.c
>>> @@ -930,71 +930,52 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>>>  }
>>>
>>>  static int sample(struct datapath *dp, struct sk_buff *skb,
>>> -                 struct sw_flow_key *key, const struct nlattr *attr,
>>> -                 const struct nlattr *actions, int actions_len)
>>> +                 struct sw_flow_key *key, const struct nlattr *attr)
>>>  {
>>> -       const struct nlattr *acts_list = NULL;
>>> -       const struct nlattr *a;
>>> -       int rem;
>>> -       u32 cutlen = 0;
>>> -
>>> -       for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>>> -                a = nla_next(a, &rem)) {
>>> -               u32 probability;
>>> -
>>> -               switch (nla_type(a)) {
>>> -               case OVS_SAMPLE_ATTR_PROBABILITY:
>>> -                       probability = nla_get_u32(a);
>>> -                       if (!probability || prandom_u32() > probability)
>>> -                               return 0;
>>> -                       break;
>>> -
>>> -               case OVS_SAMPLE_ATTR_ACTIONS:
>>> -                       acts_list = a;
>>> -                       break;
>>> -               }
>>> -       }
>>> +       struct nlattr *actions;
>>> +       struct nlattr *sample_arg;
>>> +       struct sw_flow_key *orig = key;
>>> +       int rem = nla_len(attr);
>>> +       int err = 0;
>>> +       const struct sample_arg *arg;
>>>
>>> -       rem = nla_len(acts_list);
>>> -       a = nla_data(acts_list);
>>> +       /* The first action is always 'OVS_SAMPLE_ATTR_AUX'. */
>>
>> Is it? This is the only reference to OVS_SAMPLE_ATTR_AUX I can see.
>>
>>> +       sample_arg = nla_data(attr);
>>
>> We could do this in the parent call, like several other actions do.
>
> What do you mean?

In do_execute_actions(), call like this:

err = sample(dp, clone_skb, key, nla_data(a));
