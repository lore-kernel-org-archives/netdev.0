From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v4 net-next 01/12] bonding: remove bond->lock from bond_arp_rcv
Date: Tue, 18 Feb 2014 15:07:46 +0800
Message-ID: <530306C2.1050003@huawei.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com> <1392648088-21336-2-git-send-email-vfalico@redhat.com> <5302DB61.4070505@huawei.com> <20140218061222.GA18373@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:29077 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbaBRHIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 02:08:09 -0500
In-Reply-To: <20140218061222.GA18373@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/18 14:12, Veaceslav Falico wrote:
> On Tue, Feb 18, 2014 at 12:02:41PM +0800, Ding Tianhong wrote:
>> On 2014/2/17 22:41, Veaceslav Falico wrote:
>>> We're always called with rcu_read_lock() held (bond_arp_rcv() is on=
ly
>>> called from bond_handle_frame(), which is rx_handler and always cal=
led
>>> under rcu from __netif_receive_skb_core() ).
>>>
>>> The slave active/passive and/or bonding params can change in-flight=
, however
>>> we don't really care about that - we only modify the last time pack=
et was
>>> received, which is harmless.
>>>
>>> CC: Jay Vosburgh <fubar@us.ibm.com>
>>> CC: Andy Gospodarek <andy@greyhouse.net>
>>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>> ---
>>>  drivers/net/bonding/bond_main.c | 3 ---
>>>  1 file changed, 3 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index 3bce855..3c50bec 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -2260,8 +2260,6 @@ int bond_arp_rcv(const struct sk_buff *skb, s=
truct bonding *bond,
>>>      if (skb->protocol !=3D __cpu_to_be16(ETH_P_ARP))
>>>          return RX_HANDLER_ANOTHER;
>>>
>>> -    read_lock(&bond->lock);
>>> -
>>>      if (!slave_do_arp_validate(bond, slave))
>>>          goto out_unlock;
>>>
>>> @@ -2318,7 +2316,6 @@ int bond_arp_rcv(const struct sk_buff *skb, s=
truct bonding *bond,
>>>          bond_validate_arp(bond, slave, tip, sip);
>>>
>>>  out_unlock:
>>> -    read_unlock(&bond->lock);
>>>      if (arp !=3D (struct arphdr *)skb->data)
>>>          kfree(arp);
>>>      return RX_HANDLER_ANOTHER;
>>>
>>
>> I think it is not enough, you should add rcu_dereference for bond->c=
urr_active_slave, it may be changed during
>> the recv processing.
>=20
> bond->lock has absolutely nothing to du with bond->curr_active_slave =
=2E
>=20
Yep, this problem is introduced by commit aeea64ac7=EF=BC=8C there is n=
o way to protect the curr_active_slave, so
I think you could fix it in this patch together.
=20
	else if (bond->curr_active_slave &&
		 time_after(slave_last_rx(bond, bond->curr_active_slave),
			    bond->curr_active_slave->jiffies))
>>
>> Regards
>> Ding
>>
>>
>=20
>=20
