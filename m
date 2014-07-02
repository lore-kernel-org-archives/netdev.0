From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] igmp: fix the problem when mc leave group
Date: Wed, 2 Jul 2014 09:43:45 +0800
Message-ID: <53B363D1.20707@huawei.com>
References: <53B0D06D.30908@huawei.com> <53B14F66.4030306@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:21864 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaGBBoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 21:44:12 -0400
In-Reply-To: <53B14F66.4030306@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/6/30 19:52, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> Ding Tianhong wrote:
>> The problem was triggered by these steps:
>>
>> 1) create socket, bind and then setsockopt for add mc group.
>>     mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
>>     mreq.imr_interface.s_addr = inet_addr("192.168.1.2");
>>     setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
>>
>> 2) drop the mc group for this socket.
>>     mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
>>     mreq.imr_interface.s_addr = inet_addr("0.0.0.0");
>>     setsockopt(sockfd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &mreq, sizeof(mreq));
>>
>> 3) and then drop the socket, I found the mc group was still used by the dev:
>>
>>     netstat -g
>>
>>     Interface       RefCnt Group
>>     --------------- ------ ---------------------
>>     eth2           1      255.0.0.37
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
>> Fix this by checking the ifindex when polling the mc_list in ip_mc_leave_group(), don't
>> release the mc group from the inet->mc_list if the index is 0, leave this work to
>> ip_mc_drop_socket().
>>
> 
> No, we should make it aligned with IPv6 (RFC3493) and BSDs,
> so...
> 
Ok, I will check it and then think about this problem.

>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   net/ipv4/igmp.c | 5 ++---
>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
>> index 6748d42..03e0629 100644
>> --- a/net/ipv4/igmp.c
>> +++ b/net/ipv4/igmp.c
>> @@ -1950,10 +1950,9 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
>>            imlp = &iml->next_rcu) {
>>           if (iml->multi.imr_multiaddr.s_addr != group)
>>               continue;
>> -        if (ifindex) {
>> -            if (iml->multi.imr_ifindex != ifindex)
>> +        if (ifindex || iml->multi.imr_ifindex != ifindex)
> 
> ifindex && iml->multi.imr_ifindex != ifindex
> 
yes, my solution looks get another problem, thanks for your advise, I will fix it.

Ding

>>                   continue;
> 
> Fix indentation.
> 
>> -        } else if (imr->imr_address.s_addr && imr->imr_address.s_addr !=
>> +        else if (imr->imr_address.s_addr && imr->imr_address.s_addr !=
>>                   iml->multi.imr_address.s_addr)
>>               continue;
>>
>>
> 
> Regarads,
> 
