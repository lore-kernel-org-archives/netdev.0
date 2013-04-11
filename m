From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 16:47:49 +0200
Message-ID: <CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
References: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20130411131333.GD1910@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Soeren Moch <smoch@web.de>, Paul Mackerras <paulus@samba.org>,
	linux-arm-kernel@lists.infradead.org,
	Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Florian Fainelli <florian@openwrt.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130411131333.GD1910@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 3:13 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Thu, Apr 11, 2013 at 02:40:23PM +0200, Sebastian Hesselbarth wrote:
>> This patch adds GRO support to mv643xx_eth by making it invoke
>> napi_gro_receive instead of netif_receive_skb.
>>
>> Signed-off-by: Soeren Moch <smoch@web.de>
>> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>> ---
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
>> Cc: Andrew Lunn <andrew@lunn.ch>
>> Cc: Jason Cooper <jason@lakedaemon.net>
>> Cc: Florian Fainelli <florian@openwrt.org>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Dale Farnsworth <dale@farnsworth.org>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linuxppc-dev@lists.ozlabs.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
>> index 305038f..c850d04 100644
>> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
>> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
>> @@ -604,7 +604,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
>>                       lro_receive_skb(&rxq->lro_mgr, skb, (void *)cmd_sts);
>>                       lro_flush_needed = 1;
>>               } else
>> -                     netif_receive_skb(skb);
>> +                     napi_gro_receive(&mp->napi, skb);
>>
>>               continue;
>
> I remember having experimented with this on 3.6 a few months ago with this
> driver and finally switching back to something like this instead which
> showed better performance on my tests :
>
>                if (skb->ip_summed == CHECKSUM_UNNECESSARY)
>                        napi_gro_receive(napi, skb);
>                else
>                        netif_receive_skb(skb);
>
> Unfortunately I don't have more details as my commit message was rather
> short due to this resulting from experimentation. Did you verify that
> you did not lose any performance in various workloads ? I was playing
> with bridges at this time, it's possible that I got better performance
> on bridging with netif_receive_skb() than with napi_gro_receive().

Hi Willy,

I did some simple tests on Dove/Cubox with 'netperf -cCD' and
gso/gro/lro options on
mv643xx_eth. The tests may not be sufficient, as I am not that into
net performance
testing.

I tried todays net-next on top of 3.9-rc6 without any gro patch, with
the initial
patch (Soeren) and your proposed patch (Willy). The results show that
both patches
allow a significant increase in throughput compared to
netif_receive_skb (!gro, !lro)
alone. Having gro with lro disabled gives some 2% more throughput
compared to lro only.

Sebastian

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.02       615.65   19.15    99.90    5.097
13.293 (3.9-rc6: gso)
 87380  16384  16384    10.02       615.82   19.05    99.90    5.067
13.289 (3.9-rc6: gso, gro)
 87380  16384  16384    10.03       747.44   23.17    99.80    5.079
10.938 (3.9-rc6: gso, lro)
 87380  16384  16384    10.02       745.28   22.57    99.80    4.963
10.970 (3.9.rc6: gso, gro, lro)

 87380  16384  16384    10.02       600.34   19.10    99.90    5.211
13.632 (3.9-rc6+soeren: gso)
 87380  16384  16384    10.02       764.23   23.42    99.80    5.021
10.698 (3.9-rc6+soeren: gso, gro)
 87380  16384  16384    10.02       749.81   23.13    99.80    5.055
10.904 (3.9-rc6+soeren: gso, lro)
 87380  16384  16384    10.02       745.84   22.34    99.80    4.907
10.962 (3.9.rc6+soeren: gso, gro, lro)

 87380  16384  16384    10.02       605.79   18.79    100.00   5.082
13.523 (3.9-rc6+willy: gso)
 87380  16384  16384    10.02       765.64   24.68    99.80    5.281
10.678 (3.9-rc6+willy: gso, gro)
 87380  16384  16384    10.02       750.30   26.02    99.80    5.682
10.897 (3.9-rc6+willy: gso, lro)
 87380  16384  16384    10.03       749.40   21.86    99.80    4.778
10.910 (3.9.rc6+willy: gso, gro, lro)
