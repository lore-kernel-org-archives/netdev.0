From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net 1/3] net: hns: Add TX CSUM check when fill TX
 description
Date: Wed, 5 Jul 2017 16:28:13 +0800
Message-ID: <3fca563b-b6c5-962a-f843-d8115a83cb5a@huawei.com>
References: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
 <1499165253-184543-2-git-send-email-linyunsheng@huawei.com>
 <20170704.032833.2030036660842556798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <tremyfr@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170704.032833.2030036660842556798.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, David

On 2017/7/4 18:28, David Miller wrote:
> From: Lin Yun Sheng <linyunsheng@huawei.com>
> Date: Tue, 4 Jul 2017 18:47:31 +0800
> 
>> From: Yunsheng Lin <linyunsheng@huawei.com>
>>
>> If driver support checksum offload, should check netdev feature
>> before fill TX description and get CSUM err bit from RX
>> description. HNS driver do the check in RX derction but it doesn't
>> do the check in TX direction.
>>
>> Signed-off-by: lipeng <lipeng321@huawei.com>
>> Reviewed-by: Daode Huang <huangdaode@hisilicon.com>
>> Reviewed-by: Yunsheng Lin <linyunsheng@huawei.com>
> 
> This is not correct.
> 
> You should be checking the skb->checksum field to decide if you should
> offload the TX checksum of the packet or not.
> 
> Correct drivers, as far as I am aware, do not check the feature flags
> so I wonder where you got this idea from.  Always use other well
> established existing drivers as a model for how to handle things like
> this.
> 
> And this makes sense.  An SKB can have it's checksumming determination
> made first, then the netdev feature change is made afterwards.  For
> correctness you still need to TX checksum offload that SKB otherwise
> it will be emitted without a correctly computed checksum.
> 
You are right, thanks for pointing out.
driver/net/ethernet/hisilicon/hns/hns_enet.c
fill_desc:
		if (skb->ip_summed == CHECKSUM_PARTIAL) {
			protocol = skb->protocol;
			ip_offset = ETH_HLEN;

			/*if it is a SW VLAN check the next protocol*/
			if (protocol == htons(ETH_P_8021Q)) {
				ip_offset += VLAN_HLEN;
				protocol = vlan_get_protocol(skb);
				skb->protocol = protocol;
			}

			if (skb->protocol == htons(ETH_P_IP)) {
				flag_ipoffset |= 1 << HNS_TXD_L3CS_B;
				/* check for tcp/udp header */
				flag_ipoffset |= 1 << HNS_TXD_L4CS_B;

			} else if (skb->protocol == htons(ETH_P_IPV6)) {
				/* ipv6 has not l3 cs, check for L4 header */
				flag_ipoffset |= 1 << HNS_TXD_L4CS_B;
			}

			flag_ipoffset |= ip_offset << HNS_TXD_IPOFFSET_S;
		}

the hns driver has already check the skb->ip_summed, and checking the ndev->feature is
not correct.

Will remove this patch next revision.

Best Regards
Yunsheng Lin
