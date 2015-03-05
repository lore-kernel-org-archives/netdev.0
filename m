From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Thu, 05 Mar 2015 06:55:07 -0800
Message-ID: <54F86E4B.9040403@cumulusnetworks.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com> <54F6C788.2010201@cumulusnetworks.com> <20150305080218.GB2033@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:38516 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbbCEOzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 09:55:24 -0500
Received: by pabrd3 with SMTP id rd3so19218034pab.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 06:55:23 -0800 (PST)
In-Reply-To: <20150305080218.GB2033@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15, 12:02 AM, Jiri Pirko wrote:
> Wed, Mar 04, 2015 at 09:51:20AM CET, roopa@cumulusnetworks.com wrote:
>> On 3/3/15, 11:02 PM, Scott Feldman wrote:
>>> On Tue, Mar 3, 2015 at 4:15 PM,  <roopa@cumulusnetworks.com> wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
>>>> on rocker ports, the second command (bridge link set) below will turn off
>>>> learning in the rocker hw (Scott/Jiri, need some confirmation from
>>>> you that this is indeed a problem and if the below patch is ok).
>>>>
>>>> ip link set dev swp1 master br0
>>>> bridge link set dev swp1 learning off master
>>>> bridge link set dev swp1 learning_sync on self
>>>>
>>>> This patch fixes rocker to ignore learning setting when 'master'
>>>> is set. This makes it possible to set/unset learning in kernel and bridge
>>>> driver independently.
>>>>
>>>> The below command will continue to set learning on in both kernel and rocker
>>>> hw:
>>>> bridge link set dev swp1 learning on
>>>>
>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> ---
>>>>   drivers/net/ethernet/rocker/rocker.c |    3 +++
>>>>   1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>>> index e5a15a4..d7c31d2 100644
>>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>>> @@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>>>>          struct nlattr *attr;
>>>>          int err;
>>>>
>>>> +       if (flags && !(flags & BRIDGE_FLAGS_SELF))
>>>> +               return 0;
>>>> +
>>>>          protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>>>>                                     IFLA_PROTINFO);
>>>>          if (protinfo) {
>>> NACK on this patch.  This is the problem with netlink creeping into
>>> ndo ops: it's too tempting to push work-arounds down to driver.
>> netlink has already crept into the driver. You do parse the netlink message
>> right below.
>> The patch actually does not touch the message. It is just using one of the
>> args already passed to the handler.
>>
>>> In this case, you're making the driver check to see if it's SELF when
>>> it's already SELF by definition.
>>>
>>> Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
>>> patches.
>>>   Now it is,
>> sure, I can submit a patch to remove the flag on rocker ports if thats what
>> you prefer.
> I don't believe that Scott prefers that. The offload flag is there not
> only for this case, but also for many future switch offloading cases.
I very well understand that.
> Rocker port have to have that port set by default. I do not really
> understand why you suggest removing it...
>
I was just making sure scott is on board with the use of the flag.
I added it on rocker ports for l2 and learning might be broken because 
of that. Which i am trying to fix.
also, scotts l3 patches dont seem to use the flag.
So, if the patch in this thread is not the right way to fix it..,.i was 
just trying to give scott an option to remove the flag to keep l2 
working and for him to bring back the flag when he is ready.
