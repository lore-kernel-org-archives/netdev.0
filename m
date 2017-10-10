From: Joe Stringer <joe@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next] openvswitch: add ct_clear action
Date: Tue, 10 Oct 2017 13:24:20 -0700
Message-ID: <CAOftzPgKT-0g=d_SREfBJNXcA+5zzG1=n51u=up_vbhG_D=z1g@mail.gmail.com>
References: <20171006164426.9752-1-e@erig.me> <CAOrHB_BUVwWqYQcbWiQ69EhnQpY8epqu55pRBGA6g7xG21zSqQ@mail.gmail.com>
 <CAPWQB7FgKYe4Ax08NzW97-WGmriC7j9YhxQF9QtuQZwMjA00bQ@mail.gmail.com>
 <20171010150949.GG26353@dev-rhel7> <CAPWQB7FFNB1vghe+y_Y7B3buYmANjMTaEOgAKVHsmbOsDZxh6g@mail.gmail.com>
 <20171010191329.GH26353@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Eric Garver <e@erig.me>, Joe Stringer <joe@ovn.org>,
        Pravin Shelar <pshelar@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:36013 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934450AbdJJUYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:24:44 -0400
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com [209.85.216.180])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id AA6D8FB886
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 22:24:42 +0200 (CEST)
Received: by mail-qt0-f180.google.com with SMTP id f8so20124258qta.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 13:24:42 -0700 (PDT)
In-Reply-To: <20171010191329.GH26353@dev-rhel7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 October 2017 at 12:13, Eric Garver <e@erig.me> wrote:
> On Tue, Oct 10, 2017 at 10:24:20AM -0700, Joe Stringer wrote:
>> On 10 October 2017 at 08:09, Eric Garver <e@erig.me> wrote:
>> > On Tue, Oct 10, 2017 at 05:33:48AM -0700, Joe Stringer wrote:
>> >> On 9 October 2017 at 21:41, Pravin Shelar <pshelar@ovn.org> wrote:
>> >> > On Fri, Oct 6, 2017 at 9:44 AM, Eric Garver <e@erig.me> wrote:
>> >> >> This adds a ct_clear action for clearing conntrack state. ct_clear is
>> >> >> currently implemented in OVS userspace, but is not backed by an action
>> >> >> in the kernel datapath. This is useful for flows that may modify a
>> >> >> packet tuple after a ct lookup has already occurred.
>> >> >>
>> >> >> Signed-off-by: Eric Garver <e@erig.me>
>> >> > Patch mostly looks good. I have following comments.
>> >> >
>> >> >> ---
>> >> >>  include/uapi/linux/openvswitch.h |  2 ++
>> >> >>  net/openvswitch/actions.c        |  5 +++++
>> >> >>  net/openvswitch/conntrack.c      | 12 ++++++++++++
>> >> >>  net/openvswitch/conntrack.h      |  7 +++++++
>> >> >>  net/openvswitch/flow_netlink.c   |  5 +++++
>> >> >>  5 files changed, 31 insertions(+)
>> >> >>
>> >> >> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
>> >> >> index 156ee4cab82e..1b6e510e2cc6 100644
>> >> >> --- a/include/uapi/linux/openvswitch.h
>> >> >> +++ b/include/uapi/linux/openvswitch.h
>> >> >> @@ -806,6 +806,7 @@ struct ovs_action_push_eth {
>> >> >>   * packet.
>> >> >>   * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
>> >> >>   * packet.
>> >> >> + * @OVS_ACTION_ATTR_CT_CLEAR: Clear conntrack state from the packet.
>> >> >>   *
>> >> >>   * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
>> >> >>   * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
>> >> >> @@ -835,6 +836,7 @@ enum ovs_action_attr {
>> >> >>         OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
>> >> >>         OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
>> >> >>         OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
>> >> >> +       OVS_ACTION_ATTR_CT_CLEAR,     /* No argument. */
>> >> >>
>> >> >>         __OVS_ACTION_ATTR_MAX,        /* Nothing past this will be accepted
>> >> >>                                        * from userspace. */
>> >> >> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> >> >> index a54a556fcdb5..db9c7f2e662b 100644
>> >> >> --- a/net/openvswitch/actions.c
>> >> >> +++ b/net/openvswitch/actions.c
>> >> >> @@ -1203,6 +1203,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>> >> >>                                 return err == -EINPROGRESS ? 0 : err;
>> >> >>                         break;
>> >> >>
>> >> >> +               case OVS_ACTION_ATTR_CT_CLEAR:
>> >> >> +                       err = ovs_ct_clear(skb, key);
>> >> >> +                       break;
>> >> >> +
>> >> >>                 case OVS_ACTION_ATTR_PUSH_ETH:
>> >> >>                         err = push_eth(skb, key, nla_data(a));
>> >> >>                         break;
>> >> >> @@ -1210,6 +1214,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>> >> >>                 case OVS_ACTION_ATTR_POP_ETH:
>> >> >>                         err = pop_eth(skb, key);
>> >> >>                         break;
>> >> >> +
>> >> >>                 }
>> >> > Unrelated change.
>> >> >
>> >> >>
>> >> >>                 if (unlikely(err)) {
>> >> >> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> >> >> index d558e882ca0c..f9b73c726ad7 100644
>> >> >> --- a/net/openvswitch/conntrack.c
>> >> >> +++ b/net/openvswitch/conntrack.c
>> >> >> @@ -1129,6 +1129,18 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
>> >> >>         return err;
>> >> >>  }
>> >> >>
>> >> >> +int ovs_ct_clear(struct sk_buff *skb, struct sw_flow_key *key)
>> >> >> +{
>> >> >> +       if (skb_nfct(skb)) {
>> >> >> +               nf_conntrack_put(skb_nfct(skb));
>> >> >> +               nf_ct_set(skb, NULL, 0);
>> >> > Can the new conntract state be appropriate? may be IP_CT_UNTRACKED?
>> >> >
>> >> >> +       }
>> >> >> +
>> >> >> +       ovs_ct_fill_key(skb, key);
>> >> >> +
>> >> > I do not see need to refill the key if there is no skb-nf-ct.
>> >>
>> >> Really this is trying to just zero the CT key fields, but reuses
>> >> existing functions, right? This means that subsequent upcalls, for
>> >
>> > Right.
>> >
>> >> instance, won't have the outdated view of the CT state from the
>> >> previous lookup (that was prior to the ct_clear). I'd expect these key
>> >> fields to be cleared.
>> >
>> > I assumed Pravin was saying that we don't need to clear them if there is
>> > no conntrack state. They should already be zero.
>>
>> The conntrack calls aren't going to clear it, so I don't see what else
>> would clear it?
>>
>> If you execute ct(),ct_clear(), then the first ct will set the
>> values.. what will zero them?
>
> I meant move ovs_ct_fill_key() to inside the if statement.
> i.e.
>
>        if (skb_nfct(skb)) {
>                nf_conntrack_put(skb_nfct(skb));
>                nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
>                ovs_ct_fill_key(skb, key);
>        }
>
> Should be nothing to fill/zero if we have not yet done conntrack.
> Is there a case where we may lose skb->_nfct, but the key still has
> conntrack data?

Ah, misreading on my part. Right, if there is no nfct then it should
already have the right value. I don't think there's a way to lose it
and leave the key with conntrack data.
