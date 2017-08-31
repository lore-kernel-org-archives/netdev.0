From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v2] net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()
Date: Wed, 30 Aug 2017 17:52:47 -0700
Message-ID: <6607b397-8240-ea34-81ab-3d4f95abbc6f@gmail.com>
References: <20170728185836.28759-1-f.fainelli@gmail.com>
 <20170731.172818.1505741655348122155.davem@davemloft.net>
 <57dfe1c5-1816-cf94-7676-293a9dcd343c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, slash.tmp@free.fr,
        marc_gonzalez@sigmadesigns.com, rmk+kernel@armlinux.org.uk,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: David Daney <ddaney.cavm@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35462 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdHaAwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:52:55 -0400
Received: by mail-qk0-f196.google.com with SMTP id p67so6508620qkd.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:52:55 -0700 (PDT)
In-Reply-To: <57dfe1c5-1816-cf94-7676-293a9dcd343c@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2017 05:13 PM, David Daney wrote:
> On 07/31/2017 05:28 PM, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Fri, 28 Jul 2017 11:58:36 -0700
>>
>>> Marc reported that he was not getting the PHY library adjust_link()
>>> callback function to run when calling phy_stop() + phy_disconnect()
>>> which does not indeed happen because we set the state machine to
>>> PHY_HALTED but we don't get to run it to process this state past that
>>> point.
>>>
>>> Fix this with a synchronous call to phy_state_machine() in order to have
>>> the state machine actually act on PHY_HALTED, set the PHY device's link
>>> down, turn the network device's carrier off and finally call the
>>> adjust_link() function.
>>>
>>> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>> Changes in v2:
>>>
>>> - reword subject and commit message based on changes
>>> - dropped flush_scheduled_work() since it is redundant
>>
>> Applied and queued up for -stable, thanks.
>>
> 
> 
> This is broken.  Please revert.
> 
> Upstream commit 7ad813f20853 and in the stable branches as well.
> 
> When ndo_stop() is called we call:
> 
> 
>  phy_disconnect()
>     +---> phy_stop_interrupts() implies: phydev->irq = PHY_POLL;
>     +---> phy_stop_machine()
>     |      +---> phy_stop_machine()
>     |              +----> queue_delayed_work(): Work queued.
>     +--->phy_detach() implies: phydev->attached_dev = NULL;
> 
> Now at a later time the queued work does:
> 
>  phy_state_machine()
>     +---->netif_carrier_off(phydev->attached_dev): Oh no! It is NULL:

How about the following instead of a revert (which I have queued locally
as well along with your correct call graph). This still would not fix
Geert's problem where with this change, we do actually call back into
adjust_link after a phy_stop() which may be problematic for him so I
think the revert is just easier and Marc, we'll figure out something for
nb8800?

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..78168e19bd5d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1234,7 +1234,7 @@ void phy_state_machine(struct work_struct *work)
         * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
         * between states from phy_mac_interrupt()
         */
-       if (phydev->irq == PHY_POLL)
+       if (phydev->irq == PHY_POLL && phydev->state != PHY_HALTED)
                queue_delayed_work(system_power_efficient_wq,
&phydev->state_queue,
                                   PHY_STATE_TIME * HZ);
 }
> 
> 
>  CPU 12 Unable to handle kernel paging request at virtual address
> 0000000000000048, epc == ffffffff80de37ec, ra == ffffffff80c7c
> Oops[#1]:
> CPU: 12 PID: 1502 Comm: kworker/12:1 Not tainted 4.9.43-Cavium-Octeon+ #1
> Workqueue: events_power_efficient phy_state_machine
> task: 80000004021ed100 task.stack: 8000000409d70000
> $ 0   : 0000000000000000 ffffffff84720060 0000000000000048 0000000000000004
> $ 4   : 0000000000000000 0000000000000001 0000000000000004 0000000000000000
> $ 8   : 0000000000000000 0000000000000000 00000000ffff98f3 0000000000000000
> $12   : 8000000409d73fe0 0000000000009c00 ffffffff846547c8 000000000000af3b
> $16   : 80000004096bab68 80000004096babd0 0000000000000000 80000004096ba800
> $20   : 0000000000000000 0000000000000000 ffffffff81090000 0000000000000008
> $24   : 0000000000000061 ffffffff808637b0
> $28   : 8000000409d70000 8000000409d73cf0 80000000271bd300 ffffffff80c7804c
> Hi    : 000000000000002a
> Lo    : 000000000000003f
> epc   : ffffffff80de37ec netif_carrier_off+0xc/0x58
> ra    : ffffffff80c7804c phy_state_machine+0x48c/0x4f8
> Status: 14009ce3        KX SX UX KERNEL EXL IE
> Cause : 00800008 (ExcCode 02)
> BadVA : 0000000000000048
> PrId  : 000d9501 (Cavium Octeon III)
> Modules linked in:
> Process kworker/12:1 (pid: 1502, threadinfo=8000000409d70000,
> task=80000004021ed100, tls=0000000000000000)
> Stack : 8000000409a54000 80000004096bab68 80000000271bd300 80000000271c1e00
>         0000000000000000 ffffffff808a1708 8000000409a54000 80000000271bd300
>         80000000271bd320 8000000409a54030 ffffffff80ff0f00 0000000000000001
>         ffffffff81090000 ffffffff808a1ac0 8000000402182080 ffffffff84650000
>         8000000402182080 ffffffff84650000 ffffffff80ff0000 8000000409a54000
>         ffffffff808a1970 0000000000000000 80000004099e8000 8000000402099240
>         0000000000000000 ffffffff808a8598 0000000000000000 8000000408eeeb00
>         8000000409a54000 00000000810a1d00 0000000000000000 8000000409d73de8
>         8000000409d73de8 0000000000000088 000000000c009c00 8000000409d73e08
>         8000000409d73e08 8000000402182080 ffffffff808a84d0 8000000402182080
>         ...
> Call Trace:
> [<ffffffff80de37ec>] netif_carrier_off+0xc/0x58
> [<ffffffff80c7804c>] phy_state_machine+0x48c/0x4f8
> [<ffffffff808a1708>] process_one_work+0x158/0x368
> [<ffffffff808a1ac0>] worker_thread+0x150/0x4c0
> [<ffffffff808a8598>] kthread+0xc8/0xe0
> [<ffffffff808617f0>] ret_from_kernel_thread+0x14/0x1c


-- 
Florian
