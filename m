From: Alexander Holler <holler@ahsoftware.de>
Subject: Bug(s) with netconsole (using mv643xx_eth on Kirkwood)
Date: Thu, 03 Apr 2014 19:58:03 +0200
Message-ID: <533DA12B.8090904@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de> <533D8207.2050108@gmail.com> <533D8518.1010306@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	David Miller <davem@davemloft.net>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533D8518.1010306@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(I've changed the topic and removed stable@ from the cc-list to reflect 
the current status)

(Long mail, but hopefully a good problem description)

I already knew about problems with netconsole and mv643xx_eth since
4 years, but didn't care a lot because everything else worked flawless,
I even had forgotten that I've enabled netconsole. (But the bugs I've
experienced 4 years ago, seeing no msgs remotely from netconsole seem to
have disappeared).

But now, using 3.14, I hit a bug which killed the ethernet with a 100%
success rate, and, after digging a bit, I've come to the conclusion
that netconsole (together with a maybe broken initialization of the PHY) 
is the source of the problem.

The kernel is 3.14 (mainline) with one reverted patch (7cd1463). This 
patch changed the initialization of the PHY such, that the ethernet dies 
100% reproducible on a Kirkwood 88F6281 based machine. Reverting that 
patch gives me a oneline bug-enabler:

------
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c 
b/drivers/net/ethernet/marvell/mv643xx_eth.c
index e891b48..246f065 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2095,7 +2095,8 @@ static void port_start(struct mv643xx_eth_private *mp)
                 struct ethtool_cmd cmd;

                 mv643xx_eth_get_settings(mp->dev, &cmd);
-               phy_reset(mp);
+               //phy_reset(mp);
+               phy_init_hw(mp->phy);
                 mv643xx_eth_set_settings(mp->dev, &cmd);
                 phy_start(mp->phy);
         }
------

First I describe what happens at boot:

- Bootloader (U-Boot) enables (somehow) the network such that is usable 
as a console for the bootloader,
- Kernel is loaded and started with netconsole enabled through the 
kernel command line (netconsole=...),
- eth driver probe => PHY reset
- netconsole initializes the network (netpoll_setup) => PHY reset,
- userland starts,
- userland configures network (ip addr add fixedIP ..., a hack used for 
a very early ntpdate before the rootfs becomes rw), I'm not sure if 
that's end up again in a PHY reset.
- userland starts network by using dhcpcd => PHY reset

Now several use cases:

Case 1:
Using plain 3.14 the last step fails with no carrier, because the PHY 
ends up in a never ending reset (BMCR_RESET always set) in 
m88e1111_config_init() called by phy_init_hw() in port_start() in 
mv643xx_eth.

Case 2:
Without enabling netconsole through the kernel command line, I see no 
problems.

Case 3:
If I enable the old phy_reset() in mv643xx_eth, I see no problems.

Case 4:
If I reduce the time the newly used reset in phy_init_hw() spends in
calling mdelay(500) twice to some milliseconds m88e1111_config_init by 
polling for a cleared BMCR_RESET, I see no problems.

Case 5:
If I disable the initialization of the network in the bootloader, 
netconsole even worked 4 years ago. But I haven't looked into that case 
further, because I always want to use the network as a console for the 
bootloader.


Current assumption:

So, after having spend too much time into diagnosing the above stuff (so 
I was right in ignoring the non-working netconsole for 4 years), I've 
comed to the conclusion that some synchronization between 
netconsole/netpoll and the normal network stack or mv643xx_eth is 
missing. That would explain why the PHY ends up in a never ending reset 
and why this only happens reproducible if the PHY reset needs a whole 
second by using mdelay(500) twice (which likely is used to switch
the task to netconsole inbetween). It might be a hw problem too (I 
haven't read the datasheet or looked for any erratas).

I hope everyone who missed some more information is happy now, otherwise
I (again) wasted time to type a problem description (not to speak about 
the already spent time trying to diagnose the problem)

So go on and try to take the almost low hanging fruit. I'm not sure if I
will spend more time on that topic as I already have a working 
patch/workaround and the discussion has become a bit tiresome. Sorry.

Regards,

Alexander Holler
