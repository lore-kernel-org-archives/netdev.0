From: Jason Lin <kernel.jason@gmail.com>
Subject: Re: [RFC] net:phy:phylib: phy shares the same interrupt with mac
Date: Fri, 6 Apr 2012 13:53:26 +0800
Message-ID: <CAGCDX1mVk-4JpjDhWxJdsssmXCM+NM8sPOPyjKBZwbqMj-UTvA@mail.gmail.com>
References: <CAGCDX1nndpdGHZzhh_Y+2OMLZvvUmAqkAsmgHu9hdUXTJFE--Q@mail.gmail.com>
	<4F7AB9AC.8000708@openwrt.org>
	<CAGCDX1=EHJY1C=-w_YazeC9ByP=4T+hj8bjvZ=cizziSfa1J3g@mail.gmail.com>
	<CAGCDX1kZo5f8_BpMgq75o0EoTRh9X=VbH2-rXDBYoKdCosO+VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39785 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab2DFFx1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 01:53:27 -0400
Received: by iagz16 with SMTP id z16so2710088iag.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 22:53:26 -0700 (PDT)
In-Reply-To: <CAGCDX1kZo5f8_BpMgq75o0EoTRh9X=VbH2-rXDBYoKdCosO+VQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear:
In include/linux/phy.h
There has some comments:
/*
 * Set phydev->irq to PHY_POLL if interrupts are not supported,
 * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
 * the attached driver handles the interrupt
 */
=46lorian, you are right.
I have to set phydev->irq to PHY_IGNORE_INTERRUPT.
This seems to work if one MAC driver is stick to specific PHY driver.
So one can use phywrite() and phyread() to control the PHY.
In my case, MAC driver handles the interrupt, but not to stick to the
specific PHY driver. So MAC driver needs a set of general functions
to set PHY's registers to enable and ack PHY's interrupts.
Dose it make sense?

=D4=DA 2012=C4=EA4=D4=C26=C8=D5=C9=CF=CE=E710:24=A3=ACJason Lin <kernel=
=2Ejason@gmail.com> =8C=91=B5=C0=A3=BA
> Should phy_enable_interrupts() and phy_disable_interrupts() open
> to MAC driver?
> And MAC driver should initialize a workqueue to ack PHY's interrupt.
> Is this a better way?
>
> =D4=DA 2012=C4=EA4=D4=C25=C8=D5=C9=CF=CE=E79:30=A3=ACJason Lin <kerne=
l.jason@gmail.com> =8C=91=B5=C0=A3=BA
>> But, I need to enable PHY's interrupt by setting PHY's registers.
>> And after producing a interrupt, there needs a workqueue
>> to ack the PHY's interrupt.
>> The phy_start_interrupts() can enable PHY's interrupt.
>> If I do the following:
>> 1) set phydev->irq =3D PHY_IGNORE_INTERRUPT;
>> 2) invoke phy_connect();
>> 3) phy_conenct() -> phy_connect_direct() ->
>>    if (phydev->irq > 0)
>>         phy_start_interrupts(phydev);
>> 4) PHY_IGNORE_INTERRUPT =3D -2, it will not enable PHY's interrupt.
>> 5) phy_start_interrupts() will connect to a callback function
>>    config_intr() of each PHY library.
>>
>> For example, drivers/net/phy/marvell.c, marvell_config_intr()
>> Need to set register 0x12 to 0x6400 to enable corresponding interrup=
ts.
>>
>> Any comments are appreciated.
>> Thanks.
>>
>> =D4=DA 2012=C4=EA4=D4=C23=C8=D5=CF=C2=CE=E74:49=A3=ACFlorian Fainell=
i <florian@openwrt.org> =8C=91=B5=C0=A3=BA
>>> Hi,
>>>
>>> Le 04/03/12 04:11, Jason Lin a =A8=A6crit :
>>>
>>>> 1)  Add a new definition PHY_MAC if phy shares the same
>>>>      interrupt with mac.
>>>> 2)  Add do_phy_workqueue(), that mac can invoke this function
>>>>      in its ISR when link status changed or other conditions.
>>>>
>>>> Does this seems reasonable?
>>>
>>>
>>> No, I think this is well handled by the PHY_IGNORE_INTERRUPT case
>>> (documented in Documentation/networking/phy.txt) by doing the follo=
wing:
>>>
>>> - distinguish between MAC and PHY interrupts in your MAC interrupt =
handler
>>> (most likely you have separate bits for PHY interrupts)
>>> - once you see a PHY interrupt, call the appropriate PHY state mach=
ine
>>> callbacks to update the PHY state machine
>>>
>>>>
>>>>
>>>> ---------------------------
>>>>  drivers/net/phy/phy.c        |   27 +++++++++++++++++++++++++++
>>>>  drivers/net/phy/phy_device.c |    4 ++--
>>>>  include/linux/phy.h          |    3 +++
>>>>  3 files changed, 32 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>>>> index 7670aac..c8009e9 100644
>>>> --- a/drivers/net/phy/phy.c
>>>> +++ b/drivers/net/phy/phy.c
>>>> @@ -527,6 +527,28 @@ static irqreturn_t phy_interrupt(int irq, voi=
d
>>>> *phy_dat)
>>>>     return IRQ_HANDLED;
>>>>  }
>>>>
>>>> +/*
>>>> + * do_phy_workqueue - PHY interrupt handler used by MAC
>>>> + * @irq: interrupt line
>>>> + * @phydev: phy_device pointer
>>>> + *
>>>> + * Description: When a PHY use the same interrupt with MAC,
>>>> + * the handler is invoked by MAC, and schedules  a work task
>>>> + * to clear the PHY's interrupt.
>>>> + * This handler is invoked only in MAC's ISR.
>>>> + */
>>>> +irqreturn_t do_phy_workqueue(int irq, struct phy_device *phydev) =
{
>>>> +
>>>> +   BUG_ON(!in_interrupt());
>>>> +
>>>> +   if (PHY_HALTED =3D=3D phydev->state)
>>>> +       return IRQ_NONE;
>>>> +
>>>> +   schedule_work(&phydev->phy_queue);
>>>> +   return IRQ_HANDLED;
>>>> +}
>>>> +EXPORT_SYMBOL(do_phy_workqueue);
>>>> +
>>>>  /**
>>>>   * phy_enable_interrupts - Enable the interrupts from the PHY sid=
e
>>>>   * @phydev: target phy_device struct
>>>> @@ -589,6 +611,11 @@ int phy_start_interrupts(struct phy_device *p=
hydev)
>>>>
>>>>     INIT_WORK(&phydev->phy_queue, phy_change);
>>>>
>>>> +   if (phydev->irq =3D=3D PHY_MAC) {
>>>> +       err =3D phy_enable_interrupts(phydev);
>>>> +       return err;
>>>> +   }
>>>> +
>>>>     atomic_set(&phydev->irq_disable, 0);
>>>>     if (request_irq(phydev->irq, phy_interrupt,
>>>>                 IRQF_SHARED,
>>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_de=
vice.c
>>>> index 993c52c..1857097 100644
>>>> --- a/drivers/net/phy/phy_device.c
>>>> +++ b/drivers/net/phy/phy_device.c
>>>> @@ -345,7 +345,7 @@ int phy_connect_direct(struct net_device *dev,
>>>> struct phy_device *phydev,
>>>>
>>>>     phy_prepare_link(phydev, handler);
>>>>     phy_start_machine(phydev, NULL);
>>>> -   if (phydev->irq>  0)
>>>> +   if ((phydev->irq>  0) || (phydev->irq =3D=3D PHY_MAC))
>>>>         phy_start_interrupts(phydev);
>>>>
>>>>     return 0;
>>>> @@ -399,7 +399,7 @@ EXPORT_SYMBOL(phy_connect);
>>>>   */
>>>>  void phy_disconnect(struct phy_device *phydev)
>>>>  {
>>>> -   if (phydev->irq>  0)
>>>> +   if ((phydev->irq>  0) || (phydev->irq =3D=3D PHY_MAC))
>>>>         phy_stop_interrupts(phydev);
>>>>
>>>>     phy_stop_machine(phydev);
>>>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>>>> index 7da5fa8..155822c 100644
>>>> --- a/include/linux/phy.h
>>>> +++ b/include/linux/phy.h
>>>> @@ -44,9 +44,11 @@
>>>>   * Set phydev->irq to PHY_POLL if interrupts are not supported,
>>>>   * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
>>>>   * the attached driver handles the interrupt
>>>> + * Set to PHY_MAC if using the same interrupt with MAC
>>>>   */
>>>>  #define PHY_POLL       -1
>>>>  #define PHY_IGNORE_INTERRUPT   -2
>>>> +#define PHY_MAC        -3
>>>>
>>>>  #define PHY_HAS_INTERRUPT  0x00000001
>>>>  #define PHY_HAS_MAGICANEG  0x00000002
>>>> @@ -510,6 +512,7 @@ int phy_ethtool_sset(struct phy_device *phydev=
,
>>>> struct ethtool_cmd *cmd);
>>>>  int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cm=
d *cmd);
>>>>  int phy_mii_ioctl(struct phy_device *phydev,
>>>>         struct ifreq *ifr, int cmd);
>>>> +irqreturn_t do_phy_workqueue(int irq, struct phy_device *phydev);
>>>>  int phy_start_interrupts(struct phy_device *phydev);
>>>>  void phy_print_status(struct phy_device *phydev);
>>>>  void phy_device_free(struct phy_device *phydev);
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
