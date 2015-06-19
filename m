From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 18:17:45 +0100
Message-ID: <55844EB9.6040107@brocade.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <558432F1.5040209@brocade.com> <55843522.7060804@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <tgraf@suug.ch>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:54351 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755136AbbFSRSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 13:18:12 -0400
In-Reply-To: <55843522.7060804@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/15 16:28, roopa wrote:
> On 6/19/15, 8:19 AM, Robert Shearman wrote:
>> On 19/06/15 05:49, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> Introduces two netlink attributes RTA_ENCAP_TYPE and
>>> RTA_ENCAP to support attaching encap information to ipv4 routes.
>>
>> Surely RTA_ENCAP_TYPE should be part of RTA_ENCAP, since the type
>> doesn't make sense without the data and vice versa?
> I went back and forth on this. And started with what you are saying
> above. But then I wanted RTA_ENCAP netlink policy to be declared by
> individual lwtunnel drivers.
> And to determine which RTA_ENCAP netlink policy to pick, you need to
> know the RTA_ENCAP policy type (or lwtunnel type)
> which is encoded in RTA_ENCAP_TYPE. And I did not want to introduce
> another level of nest in RTA_ENCAP (because for nexthops we are already
> 2 levels deep when parsing RTA_ENCAP).

No need for that - use the example of how RTA_MULTIPATH is used for 
ipv4/ipv6:

+----------------------+
| RTA_MULTIPATH        |
+----------------------+
| +------------------+ |
| | struct rtnexthop | |
| +------------------+ |
| | RTA_GATEWAY, etc.| |
| +------------------+ |
+----------------------+

You could do similar for RTA_ENCAP where the type is stored in the data 
prior to the nested attributes starting. E.g.:

+----------------------+
| RTA_ENCAP            |
+----------------------+
| +------------------+ |
| | struct rtencap   | |
| +------------------+ |
| | MPLS_IPTUNNEL_DST| |
| +------------------+ |
+----------------------+

struct rtencap {
	__u16 rte_type;
};

>
> Hence, fib code first looks for RTA_ENCAP and if RTA_ENCAP is specified,
> RTA_ENCAP_TYPE is a required attribute. My iproute2 patches handles this
> and makes sure
> there is an  RTA_ENCAP_TYPE specified with RTA_ENCAP.

No doubt, but surely it's better to present an unambiguous API to 
userspace if possible?

Thanks,
Rob
