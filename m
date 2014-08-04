From: Lichunhe <lichunhe@huawei.com>
Subject: RE: [PATCH net/net-next] bonding:Don't received packets if bonding
 is not up
Date: Mon, 4 Aug 2014 08:04:40 +0000
Message-ID: <ED104EF999716D4C84ED5EA6FAB8EEE128EF81B3@SZXEMA509-MBX.china.huawei.com>
References: <1407122113-3184-1-git-send-email-lichunhe@huawei.com>
 <20140804061322.GA9348@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "j.vosburgh@gmail.com" <j.vosburgh@gmail.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	Dingtianhong <dingtianhong@huawei.com>,
	"Qianhuibin (Huibin QIAN, Euler)" <qianhuibin@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:57676 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaHDIHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 04:07:25 -0400
In-Reply-To: <20140804061322.GA9348@mikrodark.usersys.redhat.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your reply.

You mean that even the bonding device is down, it also should receive packets for
refreshing slaves status by arp monitoring or 802.3ad protocol. But the bonding device is
down, the status of slaves maybe is not useful, when it is up, it could check it quickly.

>-----Original Message-----
>From: Veaceslav Falico [mailto:vfalico@gmail.com]
>Sent: Monday, August 04, 2014 2:13 PM
>To: Lichunhe
>Cc: j.vosburgh@gmail.com; andy@greyhouse.net; linux-kernel@vger.kernel.org;
>Dingtianhong; Qianhuibin (Huibin QIAN, Euler)
>Subject: Re: [PATCH net/net-next] bonding:Don't received packets if bonding is
>not up
>
>On Mon, Aug 04, 2014 at 11:15:13AM +0800, lichunhe@huawei.com wrote:
>>From: Chunhe Li <lichunhe@huawei.com>
>>
>>If the bonding device is down, it should not receive packets to network
>>stack or other upper flow stack.
>
>This breaks arp monitoring and 802.3ad modes, as they won't ever come up.
>
>Also, please cc netdev next times.
>
>>
>>Signed-off-by: Chunhe Li <lichunhe@huawei.com>
>>---
>> drivers/net/bonding/bond_main.c | 9 ++++++---
>> 1 file changed, 6 insertions(+), 3 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c
>>b/drivers/net/bonding/bond_main.c index 701f86c..48a127b 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1110,6 +1110,12 @@ static rx_handler_result_t
>bond_handle_frame(struct sk_buff **pskb)
>> 	int (*recv_probe)(const struct sk_buff *, struct bonding *,
>> 			  struct slave *);
>> 	int ret = RX_HANDLER_ANOTHER;
>>+
>>+	slave = bond_slave_get_rcu(skb->dev);
>>+	bond = slave->bond;
>>+
>>+	if (unlikely(!(bond->dev->flags & IFF_UP)))
>>+		return RX_HANDLER_PASS;
>>
>> 	skb = skb_share_check(skb, GFP_ATOMIC);
>> 	if (unlikely(!skb))
>>@@ -1117,9 +1123,6 @@ static rx_handler_result_t
>>bond_handle_frame(struct sk_buff **pskb)
>>
>> 	*pskb = skb;
>>
>>-	slave = bond_slave_get_rcu(skb->dev);
>>-	bond = slave->bond;
>>-
>> 	recv_probe = ACCESS_ONCE(bond->recv_probe);
>> 	if (recv_probe) {
>> 		ret = recv_probe(skb, bond, slave);
>>--
>>1.9.2.0
>>
>>
