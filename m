From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: [REGRESSION] r8169: jumbo fixes caused jumbo regressions!
Date: Tue, 13 Nov 2012 21:06:55 +0400
Message-ID: <20121113170655.GA20291@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:42156 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755252Ab2KMRGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:06:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Short description:

    I run net-next on my netbook with yukon2 ethernet controller and stable-3.0
    at work with pcie realtek network chips on several hosts. Upgrading from
    3.0.45 to 3.0.46 there revealed jumbo-related regression, because of

        r8169: jumbo fixes.

    which is

        cc669c37ba4a9c5c54c7842d0c9428aab64d62d7 at stable-3.0, and
        d58d46b5d85139d18eb939aa7279c160bab70484 upstream

    The problem is it is no longer possible to use 7200 mtu and tx checksum
    offload. Both features used to work without problems.


Details
-------

I have two machines with realtek chips in them. They are

    eth0: RTL8168cp/8111cp at 0xdffb8000, 00:18:7d:11:83:2b, XID 1cb00080 IRQ 16
    Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)

and

    eth0: RTL8168c/8111c at 0xf8062000, 00:22:15:90:7e:c6, XID 1c4000c0 IRQ 17
    Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)


Visually looking at chips, I can confirm that they are labelled as RTL8111CP
and RTL8111C accordingly.

I used to set mtu=7200 and turn tx checksum offload on on them and
transmit/receive almost gigabit traffic from/to either of them without a
problem. This worked fine until upgrade from 3.0.45 to 3.0.46 where
things broke - now for both devices r8169 driver says:

    eth0: jumbo features [frames: 6128 bytes, tx checksumming: ko]

i.e. only 6128 max mtu and no support for tx checksum offload.

Indeed, for one thing the patch says tx checksumming cannot work together with
jumbo frames:

commit cc669c37ba4a9c5c54c7842d0c9428aab64d62d7
Author:     Francois Romieu <romieu@fr.zoreil.com>
AuthorDate: Fri Oct 5 23:29:11 2012 +0200
Commit:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CommitDate: Sat Oct 13 05:28:12 2012 +0900

    r8169: jumbo fixes.
    
    commit d58d46b5d85139d18eb939aa7279c160bab70484 upstream.
    
    - fix features : jumbo frames and checksumming can not be used at the
      same time.
    
    - introduce hw_jumbo_{enable / disable} helpers. Their content has been
      creatively extracted from Realtek's own drivers. As an illustration,
      it would be nice to know how/if the MaxTxPacketSize register operates
      when the device can work with a 9k jumbo frame as its documentation
      (8168c) can not be applied beyond ~7k.
    
    - rtl_tx_performance_tweak is moved forward. No change.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Acked-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>


but again, I say that up till now I've used ~7K jumbos with tx checksum offload
just fine on those chips:

My test is to stream raw video from 8 PAL cameras to net - 4 for 720x576@25 and
4 for 360x288@25 which for YUYV format occupies ~ 860 Mbps of bandwidth. The
program to transmit/receive video is here: http://repo.or.cz/w/rawv.git

For video sources vivi.ko video driver is used with fps set to 25.  The
streams are generated with

    $ rawv -d /dev/video$X,720x576 -t 239.255.17.$X:1200$X  # X=1..4, 5834 eth framelen
    $ rawv -d /dev/video$X,360x288 -t 239.255.17.$X:1200$X  # X=5..8, 6554 eth framelen

(which is more than 6K jumbos for the second case), and also to come
close to 7K limit with

    $ rawv -d /dev/video$X,708x576 -t 239.255.17.$X:1200$X  # X=1..4, 7154 eth framelen
    $ rawv -d /dev/video$X,352x288 -t 239.255.17.$X:1200$X  # X=5..8, 7114 eth framelen

This used to work fine with mtu set to 7200 or 7152 (=7152+14+2 =7168 =1024*7
max eth framelen) and tx csum offload turned on via `ethtool -K eth0 tx on`.


Patching the driver to know "true xid"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f7a56f4..247a238 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1773,6 +1778,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
        reg = RTL_R32(TxConfig);
        while ((reg & p->mask) != p->val)
                p++;
+       dprintk("mac_version for 0x%08x (0x%08x): %i\n", reg, reg & 0x9cf0f8ff,p->mac_version);
        tp->mac_version = p->mac_version;
 
        if (tp->mac_version == RTL_GIGA_MAC_NONE) {


I've found that RTL_R32(TxConfig) is 0x3fb00080 and 0x3f4006c0 for my chips.
This gives RTL_GIGA_MAC_VER_24 and RTL_GIGA_MAC_VER_22 judging by table in
rtl8169_get_mac_version().

Then I'm now running 3.0.46 kernel with the following patch applied

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f7a56f4..247a238 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -210,11 +212,11 @@ static const struct {
        [RTL_GIGA_MAC_VER_21] =
                _R("RTL8168c/8111c",    RTL_TD_1, NULL, JUMBO_6K, false),
        [RTL_GIGA_MAC_VER_22] =
-               _R("RTL8168c/8111c",    RTL_TD_1, NULL, JUMBO_6K, false),
+               _R("RTL8168c/8111c",    RTL_TD_1, NULL, JUMBO_7K, true),
        [RTL_GIGA_MAC_VER_23] =
                _R("RTL8168cp/8111cp",  RTL_TD_1, NULL, JUMBO_6K, false),
        [RTL_GIGA_MAC_VER_24] =
-               _R("RTL8168cp/8111cp",  RTL_TD_1, NULL, JUMBO_6K, false),
+               _R("RTL8168cp/8111cp",  RTL_TD_1, NULL, JUMBO_7K, true),
        [RTL_GIGA_MAC_VER_25] =
                _R("RTL8168d/8111d",    RTL_TD_1, FIRMWARE_8168D_1,
                                                        JUMBO_9K, false),


and ~7K jumbos and tx csum offload work again.
(by the way, on atom system, without tx csum offload, half of cpu time
is spent only to calculate checksums...)


Now I wonder, where that 6K limit came from and why they say it is now
not possible to use jumbos together with tx csum offload? Is my testing
enough to justify raising the limits and allowing tx offload? If yes,
then how do we handle this regression?


Thanks,
Kirill


P.S. Just for info: I've also tried, but on both my chips 9K jumbos do
not work.
