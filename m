From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 29 Jul 2015 11:38:28 +0100
Message-ID: <55B8AD24.6020205@brocade.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
 <55B78EFD.1030306@brocade.com> <55B7AAD1.7010603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:15146 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbbG2Kio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 06:38:44 -0400
In-Reply-To: <55B7AAD1.7010603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/15 17:16, roopa wrote:
> On 7/28/15, 7:17 AM, Robert Shearman wrote:
>> On 28/07/15 07:40, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> Undefined reference to ip6_route_output and ip_route_output
>>> was reported with CONFIG_INET=n and CONFIG_IPV6=n.
>>>
>>> This patch adds new CONFIG_MPLS_NEXTHOP_DEVLOOKUP
>>> to lookup nexthop device if user has not specified it
>>> in RTA_OIF attribute. Make CONFIG_MPLS_NEXTHOP_DEVLOOKUP
>>> depend on INET and (IPV6 || IPV6=n) because it
>>> uses ip6_route_output and ip_route_output.
>>>
>>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>>> Reported-by: Thomas Graf <tgraf@suug.ch>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Is there a compelling reason to allow the user/applications to not
>> specify the output interface and to derive it from the nexthop? If the
>> user/application intends to treat this as a recursive route then it
>> has to make sure to trigger route updates to the kernel anyway, and an
>> application should have the output interface and real nexthop close to
>> hand in that case.
>
> RTA_OIF is optional for ipv4 and ipv6 routes and we wanted to keep it
> that way for mpls routes as well (Quagga is the application in our use
> case).
> It was a simple patch...until i realized the IPV6 dependency issues (I
> will sure remember this next time).

Having read the code, I realise the nexthop isn't derived from the 
lookup. Given that this can only work for the case where a path is 
recursive via a connected nexthop, it seems to be of limited use.

I'm not familiar with the Quagga code, but is it worth adding this 
additional complexity to the kernel rather than making a change to 
Quagga instead, where presumably it already has code to derive the 
output interface in the case of having a recursive route via a 
non-connected nexthop?

>
>>
>> If there isn't a compelling reason, then perhaps the best course of
>> action is to revert the commit, instead of introducing a level of
>> config complexity that means that users/applications may not be able
>> to rely on this capability anyway?
> The config option though looks complex should not introduce any
> complexity for the user. It is on by default and always on for the
> default case.
> Only for the cases where the IPV6 is a loaded as a module and
> MPLS_ROUTING is not, the app may get family not supported errors.
> I did suggest a revert the first time. Mainly for me to fix the mistake
> i made and resubmit after proper IPV6 dependency testing.
>
> I am in the process of trying the option that hannes suggested.

If we must keep this functionality then that approach looks good to me.

Thanks,
Rob
