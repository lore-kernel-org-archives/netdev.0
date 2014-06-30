From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net] igmp: fix the problem when mc leave group
Date: Mon, 30 Jun 2014 20:52:06 +0900
Message-ID: <53B14F66.4030306@miraclelinux.com>
References: <53B0D06D.30908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og120.obsmtp.com ([64.18.2.18]:48983 "HELO
	exprod7og120.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751246AbaF3LwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 07:52:09 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so8502178pad.21
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 04:52:09 -0700 (PDT)
In-Reply-To: <53B0D06D.30908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ding Tianhong wrote:
> The problem was triggered by these steps:
>
> 1) create socket, bind and then setsockopt for add mc group.
>     mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
>     mreq.imr_interface.s_addr = inet_addr("192.168.1.2");
>     setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
>
> 2) drop the mc group for this socket.
>     mreq.imr_multiaddr.s_addr = inet_addr("255.0.0.37");
>     mreq.imr_interface.s_addr = inet_addr("0.0.0.0");
>     setsockopt(sockfd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &mreq, sizeof(mreq));
>
> 3) and then drop the socket, I found the mc group was still used by the dev:
>
>     netstat -g
>
>     Interface       RefCnt Group
>     --------------- ------ ---------------------
>     eth2		   1	  255.0.0.37
>
> Normally even though the IP_DROP_MEMBERSHIP return error, the mc group still need
> to be released for the netdev when drop the socket, but this process was broken when
> route default is NULL, the reason is that:
>
> The ip_mc_leave_group() will choose the in_dev by the imr_interface.s_addr, if input addr
> is NULL, the default route dev will be chosen, then the ifindex is got from the dev,
> then polling the inet->mc_list and return -ENODEV, but if the default route dev is NULL,
> the in_dev and ifIndex is both NULL, when polling the inet->mc_list, the mc group will be
> released from the mc_list, but the dev didn't dec the refcnt for this mc group, so
> when dropping the socket, the mc_list is NULL and the dev still keep this group.
>
> Fix this by checking the ifindex when polling the mc_list in ip_mc_leave_group(), don't
> release the mc group from the inet->mc_list if the index is 0, leave this work to
> ip_mc_drop_socket().
>

No, we should make it aligned with IPv6 (RFC3493) and BSDs,
so...

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   net/ipv4/igmp.c | 5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 6748d42..03e0629 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1950,10 +1950,9 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
>   	     imlp = &iml->next_rcu) {
>   		if (iml->multi.imr_multiaddr.s_addr != group)
>   			continue;
> -		if (ifindex) {
> -			if (iml->multi.imr_ifindex != ifindex)
> +		if (ifindex || iml->multi.imr_ifindex != ifindex)

ifindex && iml->multi.imr_ifindex != ifindex

>   				continue;

Fix indentation.

> -		} else if (imr->imr_address.s_addr && imr->imr_address.s_addr !=
> +		else if (imr->imr_address.s_addr && imr->imr_address.s_addr !=
>   				iml->multi.imr_address.s_addr)
>   			continue;
>
>

Regarads,

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
