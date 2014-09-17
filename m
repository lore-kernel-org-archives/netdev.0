From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: restore OVS_FLOW_CMD_NEW notifications
Date: Wed, 17 Sep 2014 15:04:40 -0700
Message-ID: <CALnjE+qqv66Zkh==bJAxBSUEkh8H-9YMnox1yF+4_BwetqERmg@mail.gmail.com>
References: <1410970400-9797-1-git-send-email-nicolas.dichtel@6wind.com>
	<CALnjE+rzvxC1-SvkkF237JitBTqHWaria6mw4EmDygMUSzUcUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Samuel Gauthier <samuel.gauthier@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:54348 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755726AbaIQWEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:04:41 -0400
Received: by mail-ie0-f180.google.com with SMTP id rd18so2629154iec.25
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 15:04:40 -0700 (PDT)
In-Reply-To: <CALnjE+rzvxC1-SvkkF237JitBTqHWaria6mw4EmDygMUSzUcUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 2:56 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Sep 17, 2014 at 9:13 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> From: Samuel Gauthier <samuel.gauthier@6wind.com>
>>
>> Since commit fb5d1e9e127a ("openvswitch: Build flow cmd netlink reply only if needed."),
>> the new flows are not notified to the listeners of OVS_FLOW_MCGROUP.
>>
>> This commit fixes the problem by checking that there are listeners in
>> the actual OVS_FLOW_MCGROUP group, instead of 0.
>>
>
> right, this is bug. group id should be one.
>
>> Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>  net/openvswitch/datapath.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
>> index 91d66b7e64ac..8396f6063343 100644
>> --- a/net/openvswitch/datapath.c
>> +++ b/net/openvswitch/datapath.c
>> @@ -79,10 +79,10 @@ static const struct genl_multicast_group ovs_dp_vport_multicast_group = {
>>  /* Check if need to build a reply message.
>>   * OVS userspace sets the NLM_F_ECHO flag if it needs the reply. */
>>  static bool ovs_must_notify(struct genl_info *info,
>> -                           const struct genl_multicast_group *grp)
>> +                           unsigned int group)
>>  {
>>         return info->nlhdr->nlmsg_flags & NLM_F_ECHO ||
>> -               netlink_has_listeners(genl_info_net(info)->genl_sock, 0);
>> +               netlink_has_listeners(genl_info_net(info)->genl_sock, group);
>>  }
>>
>>  static void ovs_notify(struct genl_family *family,
>> @@ -763,7 +763,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
>>  {
>>         struct sk_buff *skb;
>>
>> -       if (!always && !ovs_must_notify(info, &ovs_dp_flow_multicast_group))
>> +       if (!always && !ovs_must_notify(info, dp_flow_genl_family.mcgrp_offset))
>>                 return NULL;
>>
>
>
> I do not think mcgrp_offset is right group id. It is starting offset
> of groups in a family and it is marked as private member of genl
> module.
> Rather we can just define enum for ovs_dp_flow_multicast_group and
> directly use that as group-id.
>

I just realized that there is no equivalent netlink_has_listeners()
function in genl, so we have to add such function first.
