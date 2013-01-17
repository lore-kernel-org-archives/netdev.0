From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 1/2] net/mlx4_en: Fix bridged vSwitch configuration
 for non SRIOV mode
Date: Thu, 17 Jan 2013 18:32:31 +0200
Message-ID: <50F8279F.5030403@mellanox.com>
References: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>  <1358436643-1326-2-git-send-email-ogerlitz@mellanox.com> <1358439708.29723.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <jackm@dev.mellanox.co.il>,
	<yevgenyp@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:60785 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757082Ab3AQQb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 11:31:57 -0500
In-Reply-To: <1358439708.29723.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/2013 18:21, Eric Dumazet wrote:
> On Thu, 2013-01-17 at 17:30 +0200, Or Gerlitz wrote:
>> From: Yan Burman <yanb@mellanox.com>
>>
>> Commit 5b4c4d36860e "mlx4_en: Allow communication between functions on
>> same host" introduced a regression under which a bridge acting as vSwitch
>> whose uplink is an mlx4 Ethernet device become non-operative in native
>> (non sriov) mode. This happens since broadcast ARP requests sent by VMs
>> were loopback-ed by the HW and hence the bridge learned VM source MACs
>> on both the VM and the uplink ports.
>>
>> The fix is to place the DMAC in the send WQE only under SRIOV/eSwitch
>> configuration or when the device is in selftest.
>>
>> Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Signed-off-by: Yan Burman <yanb@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_tx.c |   13 +++++++++----
>>   1 files changed, 9 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 2b799f4..6771b69 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -630,10 +630,15 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>>   		ring->tx_csum++;
>>   	}
>>   
>> -	/* Copy dst mac address to wqe */
>> -	ethh = (struct ethhdr *)skb->data;
>> -	tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
>> -	tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
>> +	if (mlx4_is_mfunc(mdev->dev) || priv->validate_loopback) {
>> +		/* Copy dst mac address to wqe. This allows loopback in eSwitch,
>> +		 * so that VFs and PF can communicate with each other
>> +		 */
>> +		ethh = (struct ethhdr *)skb->data;
>> +		tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
>> +		tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
>> +	}
>> +
>>   	/* Handle LSO (TSO) packets */
>>   	if (lso_header_size) {
>>   		/* Mark opcode as LSO */
> Isn't this bug could explain why mlx4 had to filter incoming frames ?

yes and no...

when in multi-function -- eSwitch mode we DO need to always put the DMAC 
in the TX WQE
since this is a hint for the HW to optionally conduct loopback (e.g if 
this DMAC is
registered with the HW for another VF). For net / 3.8 we wanted a pure 
bug fix 1st and most,
we have more patches that reduce checks related to loopback but they can 
have a better fit
to net-next.

Also, there's another patch set coming from Yan that enables bridge and 
macvlan over
VFs, this is new functionality, adding support to ndo_fdb entries and 
IFF_UNICAST_FLT,
will be submitted to net-next soon (next week I believe) too.

All in all, the check on the RX mode was intentionally not removed by this
patch and will be optimized and enhanced in more patches which are 
coming for
net-next.

Hope this makes things clearer.

Or.





>
> It seems you also could remove this chunk ?
>
> (I don't really understand why mlx4_en_mac_to_u64() is done... its
> horribly expensive...).
> matching 6 bytes can be done in 3 x86_64 instructions using the right
> helper (ether_addr_equal_64bits())
>
> vi +613 drivers/net/ethernet/mellanox/mlx4/en_rx.c
>
>                 ethh = (struct ethhdr *)(page_address(frags[0].page) +
>                                           frags[0].offset);
>                  s_mac = mlx4_en_mac_to_u64(ethh->h_source);
>
>                  /* If source MAC is equal to our own MAC and not performing
>                   * the selftest or flb disabled - drop the packet */
>                  if (s_mac == priv->mac &&
>                      !((dev->features & NETIF_F_LOOPBACK) ||
>                        priv->validate_loopback))
>                          goto next;
>
>
