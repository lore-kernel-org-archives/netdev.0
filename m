From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Thu, 5 Mar 2015 09:02:18 +0100
Message-ID: <20150305080218.GB2033@nanopsycho.orion>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
 <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
 <54F6C788.2010201@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:42477 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbbCEIC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 03:02:28 -0500
Received: by wggz12 with SMTP id z12so14496453wgg.9
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 00:02:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54F6C788.2010201@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 04, 2015 at 09:51:20AM CET, roopa@cumulusnetworks.com wrote:
>On 3/3/15, 11:02 PM, Scott Feldman wrote:
>>On Tue, Mar 3, 2015 at 4:15 PM,  <roopa@cumulusnetworks.com> wrote:
>>>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>>With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
>>>on rocker ports, the second command (bridge link set) below will turn off
>>>learning in the rocker hw (Scott/Jiri, need some confirmation from
>>>you that this is indeed a problem and if the below patch is ok).
>>>
>>>ip link set dev swp1 master br0
>>>bridge link set dev swp1 learning off master
>>>bridge link set dev swp1 learning_sync on self
>>>
>>>This patch fixes rocker to ignore learning setting when 'master'
>>>is set. This makes it possible to set/unset learning in kernel and bridge
>>>driver independently.
>>>
>>>The below command will continue to set learning on in both kernel and rocker
>>>hw:
>>>bridge link set dev swp1 learning on
>>>
>>>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>---
>>>  drivers/net/ethernet/rocker/rocker.c |    3 +++
>>>  1 file changed, 3 insertions(+)
>>>
>>>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>>index e5a15a4..d7c31d2 100644
>>>--- a/drivers/net/ethernet/rocker/rocker.c
>>>+++ b/drivers/net/ethernet/rocker/rocker.c
>>>@@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>>>         struct nlattr *attr;
>>>         int err;
>>>
>>>+       if (flags && !(flags & BRIDGE_FLAGS_SELF))
>>>+               return 0;
>>>+
>>>         protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>>>                                    IFLA_PROTINFO);
>>>         if (protinfo) {
>>
>>NACK on this patch.  This is the problem with netlink creeping into
>>ndo ops: it's too tempting to push work-arounds down to driver.
>netlink has already crept into the driver. You do parse the netlink message
>right below.
>The patch actually does not touch the message. It is just using one of the
>args already passed to the handler.
>
>>In this case, you're making the driver check to see if it's SELF when
>>it's already SELF by definition.
>>
>>Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
>>patches.
>>  Now it is,
>sure, I can submit a patch to remove the flag on rocker ports if thats what
>you prefer.

I don't believe that Scott prefers that. The offload flag is there not
only for this case, but also for many future switch offloading cases.
Rocker port have to have that port set by default. I do not really
understand why you suggest removing it...


>
>>but this isn't the right fix.
>>
>>Can we revisit this so these two commands only hit MASTER:
>>
>>    bridge link set dev swp1 learning on
>>    bridge link set dev swp1 learning on master
>>
>>And this one hits SELF:
>>
>>     bridge link set dev swp1 learning on self
>
>For the above to work you just need to remove the feature flag in the driver (i can submit a patch).
>
>The reason why it is useful to have it the way it currently is:
>
>the setlink request does not always only contain the 'learning' flag.
>It handles vlans too. I dont see rocker parsing vlans yet ie IFLA_AF_SPEC (or
>did i miss it ?)
>and in those cases I thought it would be nice to pass the vlan info to the
>rocker ports when it
>is added to the bridge driver.
>
>For example the below command will hit the kernel bridge driver and rocker
>today.
>
>bridge vlan add vid 10-20 dev swp1
>
>If you remove the feature flag, you will have to run both
>
>bridge vlan add vid 10-20 dev swp1
>bridge vlan add vid 10-20 dev swp1 self
>
>
>Let me know,
>Thanks,
>Roopa
>
>
>
>
>
