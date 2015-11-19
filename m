From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT v2] sh_eth: fix kernel oops in skb_put()
Date: Thu, 19 Nov 2015 20:53:39 +0300
Message-ID: <564E0CA3.3020304@cogentembedded.com>
References: <2611049.bTOQ0T0Nsl@wasted.cogentembedded.com>
 <87pp01jl9g.wl@dns1.atmark-techno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Yasushi SHOJI <yashi@atmark-techno.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36487 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757405AbbKSRxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:53:44 -0500
Received: by lbblt2 with SMTP id lt2so48382913lbb.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 09:53:42 -0800 (PST)
In-Reply-To: <87pp01jl9g.wl@dns1.atmark-techno.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/27/2015 01:52 AM, Yasushi SHOJI wrote:

>> In a low memory situation the following kernel oops occurs:
>>
>> Unable to handle kernel NULL pointer dereference at virtual address 00000050
>> pgd = 8490c000
>> [00000050] *pgd=4651e831, *pte=00000000, *ppte=00000000
>> Internal error: Oops: 17 [#1] PREEMPT ARM
>> Modules linked in:
>> CPU: 0    Not tainted  (3.4-at16 #9)
>> PC is at skb_put+0x10/0x98
>> LR is at sh_eth_poll+0x2c8/0xa10
>> pc : [<8035f780>]    lr : [<8028bf50>]    psr: 60000113
>> sp : 84eb1a90  ip : 84eb1ac8  fp : 84eb1ac4
>> r10: 0000003f  r9 : 000005ea  r8 : 00000000
>> r7 : 00000000  r6 : 940453b0  r5 : 00030000  r4 : 9381b180
>> r3 : 00000000  r2 : 00000000  r1 : 000005ea  r0 : 00000000
>> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
>> Control: 10c53c7d  Table: 4248c059  DAC: 00000015
>> Process klogd (pid: 2046, stack limit = 0x84eb02e8)
>> [...]
>>
>> This is because netdev_alloc_skb() fails and 'mdp->rx_skbuff[entry]' is left
>> NULL but sh_eth_rx() later uses it without checking. Add such check...
>>
>> Reported-by: Yasushi SHOJI <yashi@atmark-techno.com>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>> This patch is against DaveM's 'net.git' repo.
>>
>>   drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> Index: net/drivers/net/ethernet/renesas/sh_eth.c
>> ===================================================================
>> --- net.orig/drivers/net/ethernet/renesas/sh_eth.c
>> +++ net/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -1481,6 +1481,7 @@ static int sh_eth_rx(struct net_device *
>>   		if (mdp->cd->shift_rd0)
>>   			desc_status >>= 16;
>>
>> +		skb = mdp->rx_skbuff[entry];
>>   		if (desc_status & (RD_RFS1 | RD_RFS2 | RD_RFS3 | RD_RFS4 |
>>   				   RD_RFS5 | RD_RFS6 | RD_RFS10)) {
>>   			ndev->stats.rx_errors++;
>> @@ -1496,12 +1497,11 @@ static int sh_eth_rx(struct net_device *
>>   				ndev->stats.rx_missed_errors++;
>>   			if (desc_status & RD_RFS10)
>>   				ndev->stats.rx_over_errors++;
>> -		} else {
>> +		} else	if (skb) {
>>   			if (!mdp->cd->hw_swap)
>>   				sh_eth_soft_swap(
>>   					phys_to_virt(ALIGN(rxdesc->addr, 4)),
>>   					pkt_len + 2);
>> -			skb = mdp->rx_skbuff[entry];
>>   			mdp->rx_skbuff[entry] = NULL;
>>   			if (mdp->cd->rpadir)
>>   				skb_reserve(skb, NET_IP_ALIGN);
>>
>
> This certainly prevents from a bad access, however, some odd thing is
> going on.  Once I hit a low memory situation with this patch, network
> thorough-put and response is very bad.

> telnet, ping, wget takes loong time.
>
> PING 172.16.2.13 (172.16.2.13) 56(84) bytes of data.
> 64 bytes from 172.16.2.13: icmp_seq=5 ttl=64 time=0.223 ms
> 64 bytes from 172.16.2.13: icmp_seq=6 ttl=64 time=0.195 ms
> 64 bytes from 172.16.2.13: icmp_seq=7 ttl=64 time=0.203 ms
> 64 bytes from 172.16.2.13: icmp_seq=8 ttl=64 time=0.219 ms
> 64 bytes from 172.16.2.13: icmp_seq=9 ttl=64 time=0.165 ms
> 64 bytes from 172.16.2.13: icmp_seq=10 ttl=64 time=0.171 ms
> 64 bytes from 172.16.2.13: icmp_seq=1 ttl=64 time=9023 ms
> 64 bytes from 172.16.2.13: icmp_seq=2 ttl=64 time=8022 ms
> 64 bytes from 172.16.2.13: icmp_seq=3 ttl=64 time=7014 ms
> 64 bytes from 172.16.2.13: icmp_seq=4 ttl=64 time=6006 ms
>
> I'll investigate it.

    Shoji-san, can I push this patch to net.git? I doubt that it has ill 
effects in itself -- the reason of the slowdown you're seeing should be 
somewhere else...

MBR, Sergei
