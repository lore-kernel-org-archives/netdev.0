From: Wang Jian <lark@linux.net.cn>
Subject: Re: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Tue, 30 Sep 2008 20:11:11 +0800
Message-ID: <48E2175F.1000306@linux.net.cn>
References: <20080929133305.GA10554@debian> <2acbd3e40809291314t41b6f765k9aa7809ca21bd88d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexandr Smirnov <asmirnov@ru.mvista.com>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:33888 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbYI3MLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 08:11:15 -0400
In-Reply-To: <2acbd3e40809291314t41b6f765k9aa7809ca21bd88d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> On Mon, Sep 29, 2008 at 8:33 AM, Wang Jian <lark@linux.net.cn> wrote:
>> Hi,
>>
>> During my testing, I found that 88e1111 can't get out of sleep mode
>> (Energy detect+) in certain condition.
>>
>> I am working on a mpc8541 board, with TSEC (gianfar) connected to 88e1111
>> phy chip. The kenrel is 2.6.26-rc8 with several patches.
>>
>> The following steps can 100% trigger the problem
>>
>> 1. unplug cable from tsec interfaces (eth0/eth1 in my case)
>> 2. boot up and waiting for 6+ seconds
>> 3. ifconfig eth0 up
>> 4. plug in cable, the link can't be established and no way to bring it
>>   up
> 
> 
> Is anything printed out to the log?
> 
> Are you polling or using an interrupt?

I am using polling

> 
> If you are using an interrupt, is it firing?
> 
> If you are polling, can you print out some debug information to see if
> it is successfully reading the PHY status?
> 

Ok, I use the following code to print out phy register. Note I print out 32bit,
bit 31 = 1 means error

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 4aa5479..77a9e18 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -312,7 +312,12 @@ static int marvell_read_status(struct phy_device *phydev)
                 return err;

         if (AUTONEG_ENABLE == phydev->autoneg) {
+               status = phy_read(phydev, MII_BMCR);
+               printk(KERN_ERR "MII_BMCR=%08x, ", status);
+               status = phy_read(phydev, MII_BMSR);
+               printk("MII_BMSR=%08x, ", status);
                 status = phy_read(phydev, MII_M1011_PHY_STATUS);
+               printk("MII_M1011_PHY_STATUS=%08x\n", status);
                 if (status < 0)
                         return status;


Test 1: boot up with cable plugged in eth0

--- bootup with cable plugged in eth0 ---
/ $ ifconfig eth0 up
/ $ [    7.804582] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008110
[    8.811583] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00007d00
[    8.819151] PHY: e0024520:04 - Link is Up - 100/Full
[   10.823581] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   12.830578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   14.837578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   16.844578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   18.851578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   20.858578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   22.865578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   24.872578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   26.879578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   28.886578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   30.893578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   32.900578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   34.907578] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
ifconfig eth0[   36.914585] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
  down
--- 6+ seconds elapsed ---
/ $ ifconfig eth1 up
/ $ [   48.462582] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110
[   49.469583] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008150
[   50.476579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110
[   51.483578] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008150
--- plug cable to eth1 ---
[   52.490579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008150
[   53.497579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110
[   54.504579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110
[   55.511579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008150
[   56.518579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110
[   57.525579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008150
[   58.532578] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110
[   59.539579] MII_BMCR=00001040, MII_BMSR=00000149, MII_M1011_PHY_STATUS=00008110

Test 2: before ifconfig eth0 up, unplug cable, ifconfig eth0 up within 6 seconds
window

/ $ ifconfig eth0 up
/ $ [    7.568589] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008110
[    8.575588] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008150
[    9.582585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008100
[   10.589585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008100
[   11.596585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008140
[   12.603585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008150
[   13.610585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008150
[   14.617585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00009110
[   15.624585] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   15.632148] PHY: e0024520:04 - Link is Up - 100/Full
[   17.636586] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   19.643584] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   21.650585] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   23.657585] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   25.664588] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00
[   27.671585] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d00

In test 1 and 2, eth0 is used to transfer cuImage in u-boot

Test 3: plug cable to eth1 with 6 seconds window and unplug, then ifconfig eth1 up

/ $ ifconfig eth1 up
/ $ [   12.469584] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008150
[   13.476585] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008110
[   14.483581] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008140
[   15.490581] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008140
[   16.497581] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008100
[   17.504580] MII_BMCR=00001000, MII_BMSR=00007949, MII_M1011_PHY_STATUS=00008140
--- plug cable ---
[   18.511581] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00007d40
[   18.519142] PHY: e0024520:05 - Link is Up - 100/Full
[   20.523583] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d40
[   22.530580] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d40
[   24.537580] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d40
[   26.544580] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d40
[   28.551580] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d40
[   30.558580] MII_BMCR=00001000, MII_BMSR=0000796d, MII_M1011_PHY_STATUS=00006d40


Hmm, I remove my debug code from m88e1111_config_init(), do you need this?

I have an idea that if the phy is in sleep mode, flip flop energy detect mode to
leave sleep mode. This is done every 6 seconds, not so intrusive. I will try it
later.

> 
> Andy
> 
> 

