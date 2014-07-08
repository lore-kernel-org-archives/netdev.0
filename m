From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] igmp: fix the problem when mc leave group
Date: Tue, 8 Jul 2014 12:47:16 +0800
Message-ID: <53BB77D4.5000505@huawei.com>
References: <53B39DB8.2060306@huawei.com> <20140707.213132.448071496887411114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33925 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaGHEre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:47:34 -0400
In-Reply-To: <20140707.213132.448071496887411114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/7/8 12:31, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Wed, 2 Jul 2014 13:50:48 +0800
> 
>> The problem was triggered by these steps:
>>
>> 1) create socket, bind and then setsockopt for add mc group.
>>    mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
>>    mreq.imr_interface.s_addr = inet_addr("192.168.1.2");
>>    setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
>>
>> 2) drop the mc group for this socket.
>>    mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
>>    mreq.imr_interface.s_addr = inet_addr("0.0.0.0");
>>    setsockopt(sockfd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &mreq, sizeof(mreq));
>>
>> 3) and then drop the socket, I found the mc group was still used by the dev:
>>
>>    netstat -g
>>
>>    Interface       RefCnt Group
>>    --------------- ------ ---------------------
>>    eth2		   1	  255.0.0.37
>>
>> Normally even though the IP_DROP_MEMBERSHIP return error, the mc group still need
>> to be released for the netdev when drop the socket, but this process was broken when
>> route default is NULL, the reason is that:
>>
>> The ip_mc_leave_group() will choose the in_dev by the imr_interface.s_addr, if input addr
>> is NULL, the default route dev will be chosen, then the ifindex is got from the dev,
>> then polling the inet->mc_list and return -ENODEV, but if the default route dev is NULL,
>> the in_dev and ifIndex is both NULL, when polling the inet->mc_list, the mc group will be
>> released from the mc_list, but the dev didn't dec the refcnt for this mc group, so
>> when dropping the socket, the mc_list is NULL and the dev still keep this group.
>>
>> v1->v2: According Hideaki's suggestion, we should align with IPv6 (RFC3493) and BSDs,
>> 	so I add the checking for the in_dev before polling the mc_list, make sure when
>> 	we remove the mc group, dec the refcnt to the real dev which was using the mc address.
>> 	The problem would never happened again.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> Applied, thank you.
> 
Hi david:

Can you queue this patch to stable, this problem is existed in every earlier kernel version, and could be triggered 
easily, I think we should fix it for every stable tree.

Ding 

> .
> 
