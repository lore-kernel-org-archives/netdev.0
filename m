From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 1 Dec 2014 09:29:31 +0800
Message-ID: <20141201012931.GB6252@richard>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1417375668.4442.5.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, gideonn@mellanox.com,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:54308 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbaLAB3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 20:29:39 -0500
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 1 Dec 2014 11:29:37 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BFEF12BB0069
	for <netdev@vger.kernel.org>; Mon,  1 Dec 2014 12:29:34 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB11TYUP39583948
	for <netdev@vger.kernel.org>; Mon, 1 Dec 2014 12:29:34 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB11TXIq032748
	for <netdev@vger.kernel.org>; Mon, 1 Dec 2014 12:29:34 +1100
Content-Disposition: inline
In-Reply-To: <1417375668.4442.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 30, 2014 at 11:27:48AM -0800, Eric Dumazet wrote:
>On Sun, 2014-11-30 at 10:43 +0800, Wei Yang wrote:
>> In commit 6a4e812 (net/mlx4_en: Avoid calling bswap in tx fast path), we store
>> doorbell_qpn in big endian to avoid bswap(). Then we try to write it directly
>> by iowrite32() instead of iowrite32be().
>> 
>> This works fine on little endian platform, while has some problem on big
>> endian platform. Here is the definition in general:
>> 
>> 	#define iowrite32(v, addr)	writel((v), (addr))
>> 	#define writel(b,addr)		__raw_writel(__cpu_to_le32(b),addr)
>
>Oh well...
>
>> 
>> On little endian platform, the value is not swapped before write. While on big
>> endian platform, the value is swapped. This is not expected to happen.
>> 
>> This patch does the swap on big endian platform before it is written.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> CC: Eric Dumazet <edumazet@google.com>
>> CC: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 454d9fe..76f028b 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -954,7 +954,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>>  		tx_desc->ctrl.owner_opcode = op_own;
>>  		if (send_doorbell) {
>>  			wmb();
>> -			iowrite32(ring->doorbell_qpn,
>> +			iowrite32(__cpu_to_le32(ring->doorbell_qpn),
>>  				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
>>  		} else {
>>  			ring->xmit_more++;
>
>Well, whole idea of the patch was to perform the swap (if any) out of
>the fast path.

Yes, I know the it.

>
>ring->doorbell_qpn is a cache of whatever value.
>
>Have you tried to convert it to a __le32 instead of __be32 ?
>

You mean change the type of doorbell_qpn or the function __cpu_to_be32()?
I don't get your point.

>Thanks
>

-- 
Richard Yang
Help you, Help me
