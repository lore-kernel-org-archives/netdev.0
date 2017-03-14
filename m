From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization 3/3] openvswitch: Optimize
 sample action for the clone use cases
Date: Mon, 13 Mar 2017 22:57:31 -0700
Message-ID: <CAOrHB_Bq6j0njO0a2RAtdjzS0bqe7-HYajy2hyVXOPdFob3n-A@mail.gmail.com>
References: <1489193500-15260-1-git-send-email-azhou@ovn.org>
 <1489193500-15260-4-git-send-email-azhou@ovn.org> <CAOrHB_CNyhQM5wVJvYNQtE8+RKLAbPrjsrQtbGe-poHi+5AW+g@mail.gmail.com>
 <CABKoBm14S4QRZCNYqBdfcVXrmvDnf3xrRXbDsBKGsMufdgeXZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:58939 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdCNF5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 01:57:36 -0400
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 43447C5A49
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 06:57:34 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id wNHCN06mFRe1 for <netdev@vger.kernel.org>;
        Tue, 14 Mar 2017 06:57:32 +0100 (CET)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 435F1C5A43
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 06:57:32 +0100 (CET)
Received: by mail-wm0-f44.google.com with SMTP id n11so55340308wma.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 22:57:32 -0700 (PDT)
In-Reply-To: <CABKoBm14S4QRZCNYqBdfcVXrmvDnf3xrRXbDsBKGsMufdgeXZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 1:14 PM, Andy Zhou <azhou@ovn.org> wrote:
> Thanks for the review. Please see comments inline.
>
> On Mon, Mar 13, 2017 at 12:08 AM, Pravin Shelar <pshelar@ovn.org> wrote:
>> On Fri, Mar 10, 2017 at 4:51 PM, Andy Zhou <azhou@ovn.org> wrote:
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
>>> The main optimization implemented in this series removes the static
>>> nesting limit check, instead, implement the run time recursion limit
>>> check, and recursion avoidance similar to that of the 'recirc' action.
>>> This optimization solve both #1 and #2 issues above.
>>>
>>> One related optimization attemps to avoid copying flow key as
>>> long as the actions enclosed does not change the flow key. The
>>> detection is performed only once at the flow downloading time.
>>>
>>> Another related optimization is to rewrite the action list
>>> at flow downloading time in order to save the fast path from parsing
>>> the sample action list in its original form repeatedly.
>>>
>>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>>> ---
>>>  include/uapi/linux/openvswitch.h |  13 ++++
>>>  net/openvswitch/actions.c        | 111 ++++++++++++++++++----------------
>>>  net/openvswitch/datapath.h       |   1 +
>>>  net/openvswitch/flow_netlink.c   | 126 ++++++++++++++++++++++++++++-----------
>>>  4 files changed, 162 insertions(+), 89 deletions(-)
>>>
>> ....
>> ...
>>>  static int sample(struct datapath *dp, struct sk_buff *skb,
>>>                   struct sw_flow_key *key, const struct nlattr *attr,
>>> -                 const struct nlattr *actions, int actions_len)
>>> +                 bool last)
>>>  {
>>> -       const struct nlattr *acts_list = NULL;
>>> -       const struct nlattr *a;
>>> -       int rem;
>>> -       u32 cutlen = 0;
>>> -
>>> -       for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
>>> -                a = nla_next(a, &rem)) {
>>> -               u32 probability;
>>> +       struct nlattr *actions;
>>> +       struct nlattr *sample_arg;
>>> +       struct sk_buff *clone_skb;
>>> +       struct sw_flow_key *orig = key;
>>> +       int rem = nla_len(attr);
>>> +       int err = 0;
>>> +       const struct sample_arg *arg;
>>>
>>> -               switch (nla_type(a)) {
>>> -               case OVS_SAMPLE_ATTR_PROBABILITY:
>>> -                       probability = nla_get_u32(a);
>>> -                       if (!probability || prandom_u32() > probability)
>>> -                               return 0;
>>> -                       break;
>>> +       /* The first action is always 'OVS_SAMPLE_ATTR_ARG'. */
>>> +       sample_arg = nla_data(attr);
>>> +       arg = nla_data(sample_arg);
>>> +       actions = nla_next(sample_arg, &rem);
>>>
>>> -               case OVS_SAMPLE_ATTR_ACTIONS:
>>> -                       acts_list = a;
>>> -                       break;
>>> -               }
>>> +       if ((arg->probability != U32_MAX) &&
>>> +               (!arg->probability || prandom_u32() > arg->probability)) {
>>> +               if (last)
>>> +                       consume_skb(skb);
>> To simplify let the existing code in do_execute_action() handle
>> freeing skb in this case.
>
> In the 'last' case, this function always consumes skb. In case the
> probability test passes, this is done by not cloning the skb
> before passing the skb to 'do_execute_actions'.  In case the
> probability test does not pass, the skb has to be explicitly freed.
> Currently, the caller does not know which case it is.  Are you
> suggesting that we change the function signature to pass
> this information back to the caller? Or something else?
>>
I see, lets keep this code then.
