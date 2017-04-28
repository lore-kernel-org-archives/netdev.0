From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Thu, 27 Apr 2017 17:11:54 -0700
Message-ID: <CAJieiUjE4ezt+J3hU-ZyjM-eT5CHed4ECHze2ObK1c1UJXWRJg@mail.gmail.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com> <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
 <CAJieiUi6Uu-=QBMfBXOjrEDXLCZx=mFo9SyLhgb+CcG2=uiyRA@mail.gmail.com> <8986b8c8-9bf1-21fc-49e5-e196630cd318@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:32906 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754271AbdD1ALz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 20:11:55 -0400
Received: by mail-ua0-f179.google.com with SMTP id j59so29136674uad.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 17:11:55 -0700 (PDT)
In-Reply-To: <8986b8c8-9bf1-21fc-49e5-e196630cd318@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:51 PM, Vlad Yasevich <vyasevic@redhat.com> wrote:
> On 04/24/2017 11:14 AM, Roopa Prabhu wrote:
>> On Sun, Apr 23, 2017 at 6:07 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>>
>>> On 4/21/17 11:31 AM, Vladislav Yasevich wrote:
>>>> @@ -1276,9 +1277,40 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>>>>       return err;
>>>>  }
>>>>
>>>> +static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
>>>> +{
>>>> +     u32 rtnl_event;
>>>> +
>>>> +     switch (event) {
>>>> +     case NETDEV_REBOOT:
>>>> +             rtnl_event = IFLA_EVENT_REBOOT;
>>>> +             break;
>>>> +     case NETDEV_FEAT_CHANGE:
>>>> +             rtnl_event = IFLA_EVENT_FEAT_CHANGE;
>>>> +             break;
>>>> +     case NETDEV_BONDING_FAILOVER:
>>>> +             rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
>>>> +             break;
>>>> +     case NETDEV_NOTIFY_PEERS:
>>>> +             rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
>>>> +             break;
>>>> +     case NETDEV_RESEND_IGMP:
>>>> +             rtnl_event = IFLA_EVENT_RESEND_IGMP;
>>>> +             break;
>>>> +     case NETDEV_CHANGEINFODATA:
>>>> +             rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
>>>> +             break;
>>>> +     default:
>>>> +             return 0;
>>>> +     }
>>>> +
>>>> +     return nla_put_u32(skb, IFLA_EVENT, rtnl_event);
>>>> +}
>>>> +
>>>
>>> I still have doubts about encoding kernel events into a uapi.
>>
>> agree. I don't see why user-space will need NETDEV_CHANGEINFODATA and
>> others david listed.
>>
>
> Well, I am not sure about CHANGEINFODATA as well, but I can see use
> cases for others.
>
>> My other concerns are, once we have this exposed to user-space and
>> user-space starts relying on it, it will need accurate information and
>> will expect to have this event information all the time.
>> IIUC, we cannot cover multiple events in a single notification and not
>> all link notifications will contain an IFLA_EVENT attribute.
>
> Uhm...  If the rtnetlink message was a result of an event, it will have
> an IFLA_EVENT.  If a message is something else, then it will not have
> an event.  That's the point.  Not all netlink attributes are in every
> netlink message.
>
>> In other
>> words, we will be telling user-space to not expect that the kernel
>> will send IFLA_EVENT every time.
>>
>
> No, we are telling the user that if it is interested in a specific event
> (let's say NOTIFY_PEERS or RESEND_IGMP), then it now can monitor netlink
> traffic for those events.
> As things stand right now, that's not possible.
>
> I've done this specifically for all events for which we currently generate
> a netlink message.
>
> The only concern I have is that if in the future we remove a certain netdev
> event, it may impact applications.  But we may be doing it right now as well,
> only silently, and the apps may have to find some ways to work around it.
>

ok, fair enough. it might be ok then....except for the specific
attributes that user-space may not be interested like CHANGEINFODATA.
