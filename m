From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Bonding driver fails to enable second interface if updelay is non-zero
Date: Mon, 24 Jul 2017 13:53:48 -0700
Message-ID: <CAM_iQpU+gGsPsUC-ku7sHnJxPsUTxdrTXu6zzS_q9BPjotRZ3w@mail.gmail.com>
References: <CAD3VwcpLXxk_r+4AX47gKdu=5vg7y9PnEdwUeOpSAhOLncqeeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35216 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753359AbdGXUyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:54:10 -0400
Received: by mail-wm0-f68.google.com with SMTP id r77so896627wmd.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 13:54:09 -0700 (PDT)
In-Reply-To: <CAD3VwcpLXxk_r+4AX47gKdu=5vg7y9PnEdwUeOpSAhOLncqeeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 7:07 PM, Benjamin Gilbert
<benjamin.gilbert@coreos.com> wrote:
> [resend]
>
> Hello,
>
> Starting with commit de77ecd4ef02ca783f7762e04e92b3d0964be66b, and
> through 4.12.2, the bonding driver in 802.3ad mode fails to enable the
> second interface on a bond device if updelay is non-zero.  dmesg says:
>
> [   35.825227] bond0: Setting xmit hash policy to layer3+4 (1)
> [   35.825259] bond0: Setting MII monitoring interval to 100
> [   35.825303] bond0: Setting down delay to 200
> [   35.825328] bond0: Setting up delay to 200
> [   35.827414] bond0: Adding slave eth0
> [   35.949205] bond0: Enslaving eth0 as a backup interface with a down link
> [   35.950812] bond0: Adding slave eth1
> [   36.073764] bond0: Enslaving eth1 as a backup interface with a down link
> [   36.076808] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
> [   39.327423] igb 0000:01:00.0 eth0: igb: eth0 NIC Link is Up 1000
> Mbps Full Duplex, Flow Control: RX
> [   39.405580] bond0: link status up for interface eth0, enabling it in 0 ms
> [   39.405607] bond0: link status definitely up for interface eth0,
> 1000 Mbps full duplex
> [   39.405608] bond0: Warning: No 802.3ad response from the link
> partner for any adapters in the bond
> [   39.405613] bond0: first active interface up!
> [   39.406186] IPv6: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> [   39.551391] igb 0000:01:00.1 eth1: igb: eth1 NIC Link is Up 1000
> Mbps Full Duplex, Flow Control: RX
> [   39.613590] bond0: link status up for interface eth1, enabling it in 200 ms
> [   39.717575] bond0: link status up for interface eth1, enabling it in 200 ms
> [   39.821395] bond0: link status up for interface eth1, enabling it in 200 ms
> [   39.925584] bond0: link status up for interface eth1, enabling it in 200 ms
> [   40.029288] bond0: link status up for interface eth1, enabling it in 200 ms
> [   40.133388] bond0: link status up for interface eth1, enabling it in 200 ms
>
> ...and so on every 100 ms.  The bug doesn't trigger 100% reliably, but
> can be provoked by removing and re-adding interfaces to the bond via
> sysfs.
>
> While the problem is occurring, networking appears to be unreliable.
> Setting the updelay to 0 fixes it:
>
> [  345.472559] bond0: link status up for interface eth1, enabling it in 200 ms
> [  345.576558] bond0: link status up for interface eth1, enabling it in 200 ms
> [  345.607614] bond0: Setting up delay to 0
> [  345.680396] bond0: link status definitely up for interface eth1,
> 1000 Mbps full duplex
>
> I'd be happy to provide further details or to test patches.

A quick glance seems Mahesh missed the following piece:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 181839d6fbea..9bee6c1c70cc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2050,6 +2050,7 @@ static int bond_miimon_inspect(struct bonding *bond)
                                continue;

                        bond_propose_link_state(slave, BOND_LINK_FAIL);
+                       commit++;
                        slave->delay = bond->params.downdelay;
                        if (slave->delay) {
                                netdev_info(bond->dev, "link status
down for %sinterface %s, disabling it in %d ms\n",
@@ -2088,6 +2089,7 @@ static int bond_miimon_inspect(struct bonding *bond)
                                continue;

                        bond_propose_link_state(slave, BOND_LINK_BACK);
+                       commit++;
                        slave->delay = bond->params.updelay;

                        if (slave->delay) {
