From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: when the MTU interface is modified, the promiscuous mode is reset
 in gianfar driver
Date: Wed, 5 Sep 2012 16:46:20 +0300
Message-ID: <504757AC.90007@freescale.com>
References: <201208270838.AA02326@VF09040P.jp.fujitsu.com> <20120903.155332.1814926007061594344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <chikazawa.akifu@jp.fujitsu.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120903.155332.1814926007061594344.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/03/2012 10:53 PM, David Miller wrote:
> From: chikazawa.akifu@jp.fujitsu.com (近沢 哲史)
> Date: Mon, 27 Aug 2012 17:38:34 +0900
>
>>  I am using the gianfar ethernet driver. I am having a problem with the
>>  interface settings.
>>  Under promiscuous mode, when the MTU interface is modified, the promiscuous
>>  mode setting is turned off in gianfar driver when it should not be.
>> The details are as follows:
>>  After changing MTU with ifconfig, I could see that the interface flag of
>>  eth0 is still PROMISC.
>>  However, when I checked value of RCTL register with ethtool, PROM bit of
>>  RTCL register is cleared.
>>  It seems to be cause that is the gfar_init_mac() function, it doesn't set
>>  the PROM bit after the interface MTU is changed.
>>  This problem was detected on linux-2.6.32.2, but it seems to same on
>>  linux-3.6.0-rc3.
>> Is this behavior on purpose?
>>
>> I also attach the amended file,I think it would be so.
>>
>> Signed-off-by: Akifumi Chikazawa <chikazawa.akifu@jp.fujitsu.com>
> It seems like we also lose all of the multicast configurations as
> well.
>
> Therefore, the thing to do is to simply call gfar_set_multi() at the
> appropriate location.  That will take care of both the promiscuous
> bit, as well as the multicast addresses.
>
> You can then remove some of the code in gfar_init_mac() that does
> things like gfar_clear_exact_match(), because gfar_set_multi() will
> take care of that if necessary.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> .
>
Hello David,

Though apparently it would make sense to change init_mac as shown in the
patch below, I must say I could *not* reproduce the issue with the
current net-next code (just for reference:
uname -a
Linux p1020rdb 3.6.0-rc3-22396-g600e177 #8 SMP Wed Sep 5 ... 2012 ppc
GNU/Linux
)

So, having eth1 up, I configured promisc mode - then checked that this
is correctly
reflected by rctlr (with ethtool -d eth1):
300: 00 08 37 ca 00 00 00 00 00 00 00 00 00 00 00 00
then, after changing mtu (while eth1 up): ifconfig eth1 mtu 500
further checks on rctlr show that the promiscuity setting is preserved
(i.e. rctlr
has same value as above).

Though changing the mtu with the interface up results indeed in a call to
gfar_init_mac(), I found out that the ndo_set_rx_mode hook (set to
gfar_set_multi()) is being also invoked in the process, to update
the multicast and promiscuity settings. So unless there's some kind
of concurrency/timing issue(?), I don't see how the promisc mode would
be reset by changing the mtu. Maybe more details on the issue reproduction
would help (or maybe a usecase involving multicast settings?)

regards,
Claudiu

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
drivers/net/ethernet/freescale/gianfar.c | 5 +++--
1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c
b/drivers/net/ethernet/freescale/gianfar.c
index 4d5b58c..ede7efe 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -353,6 +353,9 @@ static void gfar_init_mac(struct net_device *ndev)
/* Configure the coalescing support */
gfar_configure_coalescing(priv, 0xFF, 0xFF);

+ /* update multicast configs and promiscuity of the device */
+ gfar_set_multi(ndev);
+
if (priv->rx_filer_enable) {
rctrl |= RCTRL_FILREN;
/* Program the RIR0 reg with the required distribution */
@@ -364,8 +367,6 @@ static void gfar_init_mac(struct net_device *ndev)

if (priv->extended_hash) {
rctrl |= RCTRL_EXTHASH;
-
- gfar_clear_exact_match(ndev);
rctrl |= RCTRL_EMEN;
}

-- 
1.7.6.5
