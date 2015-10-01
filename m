From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 5/7] openvswitch: Reject ct_state unsupported bits
Date: Wed, 30 Sep 2015 19:32:17 -0700
Message-ID: <CALnjE+rchB2qD3pYbspJ5VzYjAz7m8g_CFdQYiS76DN2z-dp6g@mail.gmail.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
	<1443566380-22640-6-git-send-email-joestringer@nicira.com>
	<CALnjE+qh7hGu_45fTazJc8E_hr_Q-au1QOe-osYNKJPHxqx7hA@mail.gmail.com>
	<CANr6G5zYCaxct_gjF2Q_9wGDEZZWF9WG3RtX0Cj88eQztFb3hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36472 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754925AbbJACcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 22:32:18 -0400
Received: by igcrk20 with SMTP id rk20so5462997igc.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 19:32:18 -0700 (PDT)
In-Reply-To: <CANr6G5zYCaxct_gjF2Q_9wGDEZZWF9WG3RtX0Cj88eQztFb3hA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 6:20 PM, Joe Stringer <joestringer@nicira.com> wrote:
> On 30 September 2015 at 17:31, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Tue, Sep 29, 2015 at 3:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
>>> Previously, if userspace specified ct_state bits in the flow key which
>>> are currently undefined (and therefore unsupported), then they would be
>>> ignored. This could cause unexpected behaviour in future if userspace is
>>> extended to support additional bits but attempts to communicate with the
>>> current version of the kernel. This patch rectifies the situation by
>>> rejecting such ct_state bits.
>>>
>>> Fixes: 7f8a436 "openvswitch: Add conntrack action"
>>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>>> ---
>>>  net/openvswitch/conntrack.h    | 12 ++++++++++++
>>>  net/openvswitch/flow_netlink.c |  6 ++++++
>>>  2 files changed, 18 insertions(+)
>>>
>>> diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
>>> index 43f5dd7..c658d95 100644
>>> --- a/net/openvswitch/conntrack.h
>>> +++ b/net/openvswitch/conntrack.h
>>> @@ -34,6 +34,13 @@ int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
>>>  void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
>>>  int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
>>>  void ovs_ct_free_action(const struct nlattr *a);
>>> +
>>> +static inline bool ovs_ct_state_supported(u8 state)
>>> +{
>>> +       return !(state & ~(OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED |
>>> +                        OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR |
>>> +                        OVS_CS_F_INVALID | OVS_CS_F_TRACKED));
>>> +}
>>>  #else
>>>  #include <linux/errno.h>
>>>
>>> @@ -46,6 +53,11 @@ static inline bool ovs_ct_verify(struct net *net, int attr)
>>>         return false;
>>>  }
>>>
>>> +static inline bool ovs_ct_state_supported(u8 state)
>>> +{
>>> +       return false;
>>> +}
>>> +
>>>  static inline int ovs_ct_copy_action(struct net *net, const struct nlattr *nla,
>>>                                      const struct sw_flow_key *key,
>>>                                      struct sw_flow_actions **acts, bool log)
>>> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
>>> index ea82cd5..c4917c9 100644
>>> --- a/net/openvswitch/flow_netlink.c
>>> +++ b/net/openvswitch/flow_netlink.c
>>> @@ -816,6 +816,12 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>>>             ovs_ct_verify(net, OVS_KEY_ATTR_CT_STATE)) {
>>>                 u8 ct_state = nla_get_u8(a[OVS_KEY_ATTR_CT_STATE]);
>>>
>> We also need to return error if kernel does not support the feature.
>
> Already handled by ovs_ct_verify() in conntrack.h.

Right. Patch looks good then.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
