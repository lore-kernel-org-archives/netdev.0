From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Mon, 27 May 2013 14:52:05 +0800
Message-ID: <51A30295.5090300@huawei.com>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com> <20130511.161158.1119064774406426541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <amwang@redhat.com>, <netdev@vger.kernel.org>,
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:6230 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756499Ab3E0Gwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 02:52:45 -0400
In-Reply-To: <20130511.161158.1119064774406426541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/5/12 7:11, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed,  8 May 2013 15:41:54 +0800
>=20
>> @@ -1369,7 +1370,7 @@ static struct sk_buff *mld_newpack(struct net_=
device *dev, int size)
>> =20
>>  	skb_reserve(skb, hlen);
>> =20
>> -	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
>> +	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
>>  		/* <draft-ietf-magma-mld-source-05.txt>:
>>  		 * use unspecified address as the source address
>>  		 * when a valid link-local address is not available.
>=20
> You aren't necessarily going to be holding idev->lock, therefore you =
can't
> just do a lockless traversal of idev->addr_list here.
>=20
> Yes, you can elide the rcu_read_lock() because you have a known refer=
ence
> to 'idev' in these paths, but you can't get rid of the address list l=
ocking
> altogether.
>=20
>=20
I think the problem is clear:

mld_send_report(...){
	read_lock_bh(&idev->lock);=09
	add_grec=EF=BC=88...=EF=BC=89			=09
	read_unlock_bh(&idev->lock);
}
	--->add_grec(...){
		add_grhead(...)
	}
		--->add_grhead(...){
			mld_newpack(...)
		}
			--->mld_newpack(...){
				ipv6_get_lladdr(...)
			}
				--->ipv6_get_lladdr(...){
					read_lock_bh(&idev->lock);
					...
					read_unlock_bh(&idev->lock);
				}

so I think it is no need to lock twice and its unsafe here
