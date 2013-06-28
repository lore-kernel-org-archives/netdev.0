From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Fri, 28 Jun 2013 14:26:07 +0800
Message-ID: <51CD2C7F.5060200@huawei.com>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com> <20130626225809.GB26180@order.stressinduktion.org> <1372302584.26333.2.camel@cr0> <20130627034204.GB18553@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Cong Wang <amwang@redhat.com>, <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:38928 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550Ab3F1G0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 02:26:22 -0400
In-Reply-To: <20130627034204.GB18553@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/6/27 11:42, Hannes Frederic Sowa wrote:
> On Thu, Jun 27, 2013 at 11:09:44AM +0800, Cong Wang wrote:
>> On Thu, 2013-06-27 at 00:58 +0200, Hannes Frederic Sowa wrote:
>>> I do confirm that if this last hunk is applied the idev->addr_list
>>> traversal
>>> is safe.
>>>
>>> Please let me know if no one is working on this, I would rebase it
>>> then.=20
>>
>> I will rebase my patch on latest net-next. I am assuming this patch
>> looks good to you...
>=20
> Yes, I am fine with the apporach you took. Perhaps you could describe
> why the non-idev-locked call to__ipv6_get_lladdr-call is ok in that p=
lace.
>=20
> Thanks a lot,
>=20
>   Hannes
>=20
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
				--__ipv6_get_lladdr(..)		(after the patch, so it is protect by the =
idev->lock)
			compare
				--->ipv6_get_lladdr(...){	(before the patch)
					read_lock_bh(&idev->lock);
					...
					read_unlock_bh(&idev->lock);
				}

					=09
so i think it is clear to describe the reason.
