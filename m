From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 9/9] geneve: Implement rtnl changelink
Date: Wed, 19 Aug 2015 15:39:22 -0700
Message-ID: <CAEP_g=_j_DzjJaSX6ou57+OGe2qNpo9EDSM7ES9i9iiGmYE3qA@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
 <1439845905-31666-10-git-send-email-pshelar@nicira.com> <CAEP_g=8w4wYxFMvZcxUiCMpW5qT5ZMY0JQ9oJ=pxeK4E8Jpudw@mail.gmail.com>
 <CALnjE+qRTFXono-qTknRkREWRJnVp1qJQMnDCy7ODqGu-9xRhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33956 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbbHSWjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 18:39:43 -0400
Received: by lbbtg9 with SMTP id tg9so12745197lbb.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 15:39:42 -0700 (PDT)
In-Reply-To: <CALnjE+qRTFXono-qTknRkREWRJnVp1qJQMnDCy7ODqGu-9xRhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 1:12 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Aug 19, 2015 at 12:40 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>>> index e47cdd9..0d7fbef 100644
>>> --- a/drivers/net/geneve.c
>>> +++ b/drivers/net/geneve.c
>>>         geneve->remote.sin_addr.s_addr = rem_addr;
>>>         if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
>>>                 return -EINVAL;
>>>
>>> +       u32_to_vni(vni, geneve->vni);
>>>         list_for_each_entry(t, &gn->geneve_list, next) {
>>>                 if (!memcmp(geneve->vni, t->vni, sizeof(t->vni)) &&
>>>                     rem_addr == t->remote.sin_addr.s_addr &&
>>
>> I'm not sure that these types of operations are safe if the device is
>> already running. We first overwrite the remote value and then we do
>> error checking but that means that if there is an error, then the
>> device will be left in a broken state. Don't we also need to update
>> the hash table if some of these parameters change?
>>
> ok, I will stop device before making changes. that way we can add it
> to hash table.

I think we should still strive to make changes as minimally disruptive
as possible. At least some changes can still be done safely at runtime
so it would be nice to be able to handle those cleanly.

>>> +static int geneve_changelink(struct net_device *dev,
>>> +                            struct nlattr *tb[], struct nlattr *data[])
>>> +{
>> [...]
>>> -       if (data[IFLA_GENEVE_PORT])
>>> -               dst_port = nla_get_u16(data[IFLA_GENEVE_PORT]);
>>> +       if (geneve->sock && (dst_port != ntohs(geneve->dst_port) ||
>>> +                            metadata != geneve->collect_md)) {
>>
>> It seems like in an ideal world, we wouldn't need to recreate the
>> socket if metadata collection changed (assuming that there are no new
>> conflicts).
>
> To keep changelink simple I am thinking of disallowing metadata changes.

I guess I would rather allow it but make changes slower than disallow
it. That way it is easier to improve in the future if necessary.
