From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting
 Vlan
Date: Thu, 12 Oct 2017 21:12:31 +0300
Message-ID: <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
 <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
 <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Roman Mashak <mrv@mojatatu.com>, David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:46992 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753225AbdJLSMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 14:12:34 -0400
Received: by mail-wm0-f51.google.com with SMTP id m72so15424284wmc.1
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 11:12:34 -0700 (PDT)
In-Reply-To: <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/17 21:07, Roman Mashak wrote:
> On Thu, Oct 12, 2017 at 10:19 AM, David Ahern <dsahern@gmail.com> wrote:
>> On 10/12/17 7:51 AM, Roman Mashak wrote:
>>> v2:
>>>  Return err immediately if nbp_vlan_delete() fails (pointed by David Ahern)
>>>
>>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>> ---
>>>  net/bridge/br_netlink.c | 8 +++++---
>>>  1 file changed, 5 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>> index f0e8268..1efdd48 100644
>>> --- a/net/bridge/br_netlink.c
>>> +++ b/net/bridge/br_netlink.c
>>> @@ -527,11 +527,13 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>>>
>>>       case RTM_DELLINK:
>>>               if (p) {
>>> -                     nbp_vlan_delete(p, vinfo->vid);
>>> +                     err = nbp_vlan_delete(p, vinfo->vid);
>>> +                     if (err)
>>> +                             break;
>>
>> I'm not sure a break is the right thing to do. Seems like you leave it
>> in a half configured state.
>>
>>>                       if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>>> -                             br_vlan_delete(p->br, vinfo->vid);
>>> +                             err = br_vlan_delete(p->br, vinfo->vid);
>>>               } else {
>>> -                     br_vlan_delete(br, vinfo->vid);
>>> +                     err = br_vlan_delete(br, vinfo->vid);
>>>               }
>>>               break;
>>>       }
>>>
>>
>> Why do you want to return the error code here? Walking the code paths
>> seems like ENOENT or err from switchdev_port_obj_del are the 2 error
>> possibilities.
> 
> For example, if you attempt to delete a non-existing vlan on a port,
> the current code succeeds and also sends event :
> 
> rtnetlink_rcv_msg
>     rtnl_bridge_dellink
>        br_dellink
>           br_afspec
>              br_vlan_info
> 
> int br_dellink(..)
> {
>   ...
>   err = br_afspec()
>   if (err == 0)
>       br_ifinfo_notify(RTM_NEWLINK, p);
> }
> 
> This is misleading, so a proper errcode has to be produced.
> 

True, but you also change the expected behaviour because now a user can
clear all vlans with one request (1 - 4094), and after the change that
will fail with a partial delete if some vlan was missing.

This has been the behaviour forever and some script might depend on it.
Also IMO, and as David also mentioned, doing a partial delete is not good.
