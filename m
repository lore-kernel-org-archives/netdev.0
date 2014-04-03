From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: on kernel 2.6.34.15, vlan and raw packets can not be received
 with gfar-enet nic
Date: Thu, 03 Apr 2014 17:11:48 +0800
Message-ID: <533D25D4.4000607@gmail.com>
References: <53310F4E.4080104@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000409010002020204030804"
To: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Tao, Yue" <Yue.Tao@windriver.com>,
 "Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
 guang.yang@windriver.com, joe@perches.com, festevam@gmail.com,
 linuxppc-dev@lists.ozlabs.org, richardcochran@gmail.com,
 clarocq@gmail.com, yongjun_wei@trendmicro.com.cn,
 Claudiu Manoil <claudiu.manoil@freescale.com>,
 w@1wt.eu, zhuyj <zyjzyj2000@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <53310F4E.4080104@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000409010002020204030804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi, Claudiu

Please help to review this patch. This patch is for kernel 2.6.x. Thanks 
a lot.

Hi, Willy

Please help to merge this patch to longterm: 2.6.32.61 since this 
problem also occurs on this kernel. Thanks a lot.

Based on kernel 2.6.x, gianfar nic driver can not work well. The root 
cause is that tx vlan of gianfar can not handle VLAN tag 0. So on kernel 
3.0+, this tx vlan feature is disabled. But on kernel 2.6.x, this 
feature is still enabled. This patch will disable this feature of 
gianfar nic driver. If this feature is enabled, gianfar nic can not 
support vlan packets and non-vlan packets at the same time. The 
following steps will reproduce this problem.

The steps are as below.

1. boot two freescale-p2020 boards with linux kernel 2.6.x, then 
connected 2 gfar-enet nic cards with a direct network line;

2. On board 1, checked the driver of eth0

ethtool -i eth0

driver: gfar-enet
version: 1.3
firmware-version: N/A
bus-info: N/A

On board 2, I checked the driver of eth1

ethtool -i eth1

driver: gfar-enet
version: 1.3
firmware-version: N/A
bus-info: N/A

3. Then configure the ip address on the above 2 nic cards.

On board 1,

ifconfig eth0 192.168.1.13/24 up

On board 2,

ifconfig eth1 192.168.1.196/24 up

4. We can access the other board on one board.
For example, on board 1, we can ping board 2.

root@p2020rdb:/root> ping 192.168.1.196
PING 192.168.1.196 (192.168.1.196) 56(84) bytes of data.
64 bytes from 192.168.1.196: icmp_req=1 ttl=64 time=2.92 ms
64 bytes from 192.168.1.196: icmp_req=2 ttl=64 time=0.096 ms

5. We configure vlan on these 2 boards. VLAN tag 0
On board 1,

modprobe 8021q
vconfig add eth0 4091
ifconfig eth0.4091 10.1.1.13/24 up

On board 2,

modprobe 8021q
vconfig add eth1 4091
ifconfig eth1.4091 10.1.1.196/24 up

6. We can access the other board on one board through vlan.
For example, on board 1, we can ping board 2 through vlan nic.

root@p2020rdb:/root> ping 10.1.1.196
PING 10.1.1.196 (10.1.1.196) 56(84) bytes of data.
64 bytes from 10.1.1.196: icmp_req=1 ttl=64 time=2.92 ms
64 bytes from 10.1.1.196: icmp_req=2 ttl=64 time=0.096 ms

But we can not access the other board on one board through raw nic.
For example, on board, we can not ping board 2.

root@p2020rdb:/root> ping 192.168.1.196
 From 192.168.1.196 icmp_seq=1 Destination Host Unreachable
 From 192.168.1.196 icmp_seq=2 Destination Host Unreachable
 From 192.168.1.196 icmp_seq=3 Destination Host Unreachable

Best Regards!
Zhu Yanjun

On 03/25/2014 01:08 PM, zhuyj wrote:
> Hi, Sandeep Gopalpet
>
> I am a developer. Now I confronted an interesting phenomena. When I 
> used linux kernel 2.6.34.15 on freescale-p2020, I can not receive raw 
> and vlan packets on gfar-enet nic. But with e1000e nic, we can make 
> vlan and raw packets work well. I looked into the source code and find 
> that maybe it is related with hardware insert and remove vlan head. 
> But I have no the specifications of gfar-enet nic. Would you like to 
> give some document or some guides?
>
> Thanks a lot.
> Zhu Yanjun
>
> The steps are as below.
>
> 1. I boot two freescale-p2020 boards with linux kernel 2.6.34.15, then 
> I connected 2 gfar-enet nic cards with a direct network line;
>
> 2. On board 1, I checked the driver of eth0
>
> ethtool -i eth0
>
> driver: gfar-enet
> version: 1.3
> firmware-version: N/A
> bus-info: N/A
>
> On board 2, I checked the driver of eth1
>
> ethtool -i eth1
>
> driver: gfar-enet
> version: 1.3
> firmware-version: N/A
> bus-info: N/A
>
> 3. Then I configure the ip address on the above 2 nic cards.
>
> On board 1,
>
> ifconfig eth0 192.168.1.13/24 up
>
> On board 2,
>
> ifconfig eth1 192.168.1.196/24 up
>
> 4. We can access the other board on one board.
> For example, on board 1, we can ping board 2.
>
> root@p2020rdb:/root> ping 192.168.1.196
> PING 192.168.1.196 (192.168.1.196) 56(84) bytes of data.
> 64 bytes from 192.168.1.196: icmp_req=1 ttl=64 time=2.92 ms
> 64 bytes from 192.168.1.196: icmp_req=2 ttl=64 time=0.096 ms
>
> 5. We configure vlan on these 2 boards. VLAN tag 0
> On board 1,
>
> modprobe 8021q
> vconfig add eth0 4091
> ifconfig eth0.4091 10.1.1.13/24 up
>
> On board 2,
>
> modprobe 8021q
> vconfig add eth1 4091
> ifconfig eth1.4091 10.1.1.196/24 up
>
> 6. We can access the other board on one board through vlan.
> For example, on board 1, we can ping board 2 through vlan nic.
>
> root@p2020rdb:/root> ping 10.1.1.196
> PING 10.1.1.196 (10.1.1.196) 56(84) bytes of data.
> 64 bytes from 10.1.1.196: icmp_req=1 ttl=64 time=2.92 ms
> 64 bytes from 10.1.1.196: icmp_req=2 ttl=64 time=0.096 ms
>
> But we can not access the other board on one board through raw nic.
> For example, on board, we can not ping board 2.
>
> root@p2020rdb:/root> ping 192.168.1.196
> From 192.168.1.196 icmp_seq=1 Destination Host Unreachable
> From 192.168.1.196 icmp_seq=2 Destination Host Unreachable
> From 192.168.1.196 icmp_seq=3 Destination Host Unreachable
>
>


--------------000409010002020204030804
Content-Type: text/x-patch;
 name="0001-gianfar-disable-TX-vlan-based-on-kernel-2.6.x.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-gianfar-disable-TX-vlan-based-on-kernel-2.6.x.patch"

>From afd48fa3ad5b15d519adeb19b2a9c00051327c68 Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Date: Thu, 3 Apr 2014 16:41:13 +0800
Subject: [PATCH 1/1] gianfar: disable TX vlan based on kernel 2.6.x

Since there is something wrong with tx vlan of gianfar nic driver,
on kernel(3.0+), tx vlan is disabled. But on kernel 2.6.x, tx vlan
is still enabled. Thus,gianfar nic driver can not support vlan
packets and non-vlan packets.

Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/gianfar.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 934a28f..8aa2cf6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -365,7 +365,7 @@ static int gfar_probe(struct of_device *ofdev,
 	priv->vlgrp = NULL;
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN)
-		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->features |= NETIF_F_HW_VLAN_RX;
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
 		priv->extended_hash = 1;
@@ -1451,12 +1451,6 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 	priv->vlgrp = grp;
 
 	if (grp) {
-		/* Enable VLAN tag insertion */
-		tempval = gfar_read(&priv->regs->tctrl);
-		tempval |= TCTRL_VLINS;
-
-		gfar_write(&priv->regs->tctrl, tempval);
-
 		/* Enable VLAN tag extraction */
 		tempval = gfar_read(&priv->regs->rctrl);
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
-- 
1.7.9.5


--------------000409010002020204030804
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--------------000409010002020204030804--
