From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [BUG] rmmod bfin_mac netdev driver module will cause system crash.
Date: Tue, 4 Nov 2008 19:13:12 +0800
Message-ID: <386072610811040313k4b1f931fm5056b6e62681bbb6@mail.gmail.com>
References: <386072610811040045w2944a856jd55809f0a7532dbd@mail.gmail.com>
	 <386072610811040224u1545b110ida9de3f56a5ab9a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Andy Fleming" <afleming@freescale.com>,
	"Byron Bradley" <byron.bbradley@gmail.com>,
	"Tim Ellis" <tim.ellis@mac.com>, "Imre Kaloz" <kaloz@openwrt.org>,
	"Nicolas Pitre" <nico@cam.org>, "Dirk Teurlings" <dirk@upexia.nl>,
	"Peter van Valderen" <p.v.valderen@gmail.com>
To: "Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:45828 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbYKDLNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 06:13:13 -0500
Received: by yw-out-2324.google.com with SMTP id 9so1148079ywe.1
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2008 03:13:12 -0800 (PST)
In-Reply-To: <386072610811040224u1545b110ida9de3f56a5ab9a7@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2008 at 6:24 PM, Bryan Wu <cooloney@kernel.org> wrote:
> On Tue, Nov 4, 2008 at 4:45 PM, Bryan Wu <cooloney@kernel.org> wrote:
>> Hi Lennert,
>>
>> I got a regression since I update our blackfin kernel to the lastest
>> 2.6.28-rc2 which includes your phylib patches.
>> Please find the tracker here:
>> https://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_id=141&tracker_item_id=4595
>>
>> Briefly, the calling chain is:
>> in bfin_mac_remove(), mdiobus_unregister() ->
>> device_unregister(&bus->dev); -> put_device() -> kobject_put() ->
>> kref_put(&kobj->kref, kobject_release); -> kobject_release() ->
>> kobject_cleanup() -> mdiobus_release().
>> So in mdiobus_unregister() bus->state = MDIOBUS_UNREGISTERED; but in
>> mdiobus_release(), this BUG_ON will fire:
>> BUG_ON(bus->state != MDIOBUS_RELEASED);
>>
>> How about this patch?
>>
>> ---
>> Index: drivers/net/phy/mdio_bus.c
>> ===================================================================
>> --- drivers/net/phy/mdio_bus.c  (revision 5575)
>> +++ drivers/net/phy/mdio_bus.c  (working copy)
>> @@ -134,13 +134,16 @@
>>        int i;
>>
>>        BUG_ON(bus->state != MDIOBUS_REGISTERED);
>> -       bus->state = MDIOBUS_UNREGISTERED;
>>
>> +       bus->state = MDIOBUS_RELEASED;
>> +
>>        device_unregister(&bus->dev);
>>        for (i = 0; i < PHY_MAX_ADDR; i++) {
>>                if (bus->phy_map[i])
>>                        device_unregister(&bus->phy_map[i]->dev);
>>        }
>> +
>> +       bus->state = MDIOBUS_UNREGISTERED;
>>  }
>>  EXPORT_SYMBOL(mdiobus_unregister);
>> ---
>>
>> This regression is gone, but I'm not sure whether there is some side effect.
>> Please review.
>>
>> Thanks a lot
>> -Bryan
>>
>
> Oh, after applying this patch, I met a new WARN_ON issue:
> ---
> root:/> rmmod bfin_mac
> ------------[ cut here ]------------
> WARNING: at lib/kobject.c:593 _kobject_put+0x4e/0x58()
> kobject: '<NULL>' (0098f6a4): is not initialized, yet kobject_put() is
> being called.
> Modules linked in: bfin_mac(-)
> Hardware Trace:
>   0 Target : <0x0000485c> { _dump_stack + 0x0 }
>     Source : <0x0000e2fc> { _warn_slowpath + 0x58 } CALL pcrel
>   1 Target : <0x0000e2fc> { _warn_slowpath + 0x58 }
>     Source : <0x000294aa> { _print_modules + 0x7a } RTS
>   2 Target : <0x000294a4> { _print_modules + 0x74 }
>     Source : <0x0000e9b6> { _printk + 0x16 } RTS
>   3 Target : <0x0000e9b2> { _printk + 0x12 }
>     Source : <0x0000f1e8> { _vprintk + 0x130 } RTS
>   4 Target : <0x0000f1c8> { _vprintk + 0x110 }
>     Source : <0x0000f30c> { _vprintk + 0x254 } JUMP.S
>   5 Target : <0x0000f30c> { _vprintk + 0x254 }
>     Source : <0x0000e826> { _wake_up_klogd + 0x1a } RTS
>   6 Target : <0x0000e826> { _wake_up_klogd + 0x1a }
>     Source : <0x0000e818> { _wake_up_klogd + 0xc } IF !CC JUMP
>   7 Target : <0x0000e80c> { _wake_up_klogd + 0x0 }
>     Source : <0x0000ec40> { _release_console_sem + 0x1b0 } JUMP.L
>   8 Target : <0x0000ec38> { _release_console_sem + 0x1a8 }
>     Source : <0x0000ec2c> { _release_console_sem + 0x19c } IF !CC JUMP
>   9 Target : <0x0000ec28> { _release_console_sem + 0x198 }
>     Source : <0x0000ec1a> { _release_console_sem + 0x18a } IF !CC JUMP
>  10 Target : <0x0000ec14> { _release_console_sem + 0x184 }
>     Source : <0x00021de8> { _up + 0x3c } RTS
>  11 Target : <0x00021de2> { _up + 0x36 }
>     Source : <0x00021dd4> { _up + 0x28 } IF !CC JUMP
>  12 Target : <0x00021dac> { _up + 0x0 }
>     Source : <0x0000ec10> { _release_console_sem + 0x180 } CALL pcrel
>  13 Target : <0x0000ebfc> { _release_console_sem + 0x16c }
>     Source : <0x0000eae2> { _release_console_sem + 0x52 } IF !CC JUMP
>  14 Target : <0x0000eab2> { _release_console_sem + 0x22 }
>     Source : <0x0000ebde> { _release_console_sem + 0x14e } IF !CC JUMP
>  15 Target : <0x0000ebd8> { _release_console_sem + 0x148 }
>     Source : <0x0000e776> { __call_console_drivers + 0x7e } RTS
> Stack info:
>  SP: [0x00203cfc] <0x00203cfc> /* kernel dynamic memory */
>  FP: (0x00203db4)
>  Memory from 0x00203cf0 to 00204000
> 00203cf0: ffffff16  00203cfc  001725e4 [0000e2fc]<0000e300> 00203d1c
> 00142380  0016d044
> 00203d10: 00142380  00000251  00203d1c  626f6b5f  7463656a  7475705f
> 3478302b  78302f65
> 00203d30: 00003835  0098e190  00c63fb0  002e9e9c <0000eb62> 0016d068
> 0016d068  0016d040
> 00203d50:<0000ebd8><0000ec14> 000032ea  00203df8 <0008e546> 00162b74
> 0000e9a0  0000001f
> 00203d70: fffffff1  0016d070 <0000f30c> 00162b74  0000e9a0  00162b80
> 00000004  0000000f
> 00203d90: 10624dd3  0097d4c4  00c63fb0  000000d0  000000d0  00203e34
> 00203db0  0000ffff
> 00203db0: 00000000 (00000000)<00089f68><00089f7e> 0017b070  0017b070
> 001725e4  0017b070
> 00203dd0: 00000000 <0009f7fa> 0098f76c <0004da72> 037f5000  00c63f58
> <0009f828> 0098f76c
> 00203df0: 0098f600  0017b008  002e9e9c  00203e20 <00089f16> 0098f6a4
> 00975800  000000ac
> 00203e10: 00000002  00000002  0000002e  00203e2c  00000000  0098f6a4
> <0097cd34> 00975b80
> 00203e30: 00000002  00000001  0000001f <000a141a> 0016c084  0097def4
> 0016c130  00000068
> 00203e50: 00000001  00203e64 <000a14b6> 0016c084  0097def4 <000a08f2>
> 0097e000  0097def4
> 00203e70:<000a08f8> 0097e000  0097def4  00000000  00000880  002e9e9c
> <00109720> 0000001f
> 00203e90:<0002a0e2> 0097e000  00000081  0000004c  001e9b94 <00043122>
> 0017be00  6e696662
> 00203eb0: 63616d5f  00000000  00000000  00000000  00000000  00000000
> 00000000  00000000
> 00203ed0: 00000000  00000000  00000000  00000000  00000000  00000000
> 0097e000  00000880
> 00203ef0: 00203ef4  00000000 <ffa008d4> 00029f80  00000081  00000000
> ffffe000  0017c776
> 00203f10: 00c68de0  0015e23c  00000000  0000002e  00000002  002821ac
> 00008000  00000000
> 00203f30: 00000000  00204000  002821ac  002821ac <0029d3c2><ffa00e3c>
> 02002020  00192d99
> 00203f50: 0028cf9f  00192d92  0028cf96  00000000  0000000f  00000000
> 00000000  00000000
> 00203f70: 00000000  00000000  00000000  00000000  00000000  00000000
> 00000000  00000000
> 00203f90: 00000000  00000000  00000000  00000000  00000000  00000000
> 00000000  002d5f50
> 00203fb0: 002e9fe6  002e9e90  002e9e9c  00000001  002e9f80  0000004c
> 002e0664  002e0664
> 00203fd0: 00000081  00000880  00000000  00000002  0000002e  00000000
> 002e065c  00000880
> 00203ff0: 002e065c  002e065c  00000081  00000006  00000000
> Return addresses in stack:
>    address : <0x0000e2fc> { _warn_slowpath + 0x58 }
>    address : <0x0000e300> { _warn_slowpath + 0x5c }
>    address : <0x0000eb62> { _release_console_sem + 0xd2 }
>    address : <0x0000ebd8> { _release_console_sem + 0x148 }
>    address : <0x0000ec14> { _release_console_sem + 0x184 }
>    address : <0x0008e546> { _vscnprintf + 0x16 }
>    address : <0x0000f30c> { _vprintk + 0x254 }
>   frame  1 : <0x00089f68> { _kobject_del + 0x10 }
>    address : <0x00089f7e> { _kobject_del + 0x26 }
>    address : <0x0009f7fa> { _device_del + 0x10a }
>    address : <0x0004da72> { _ilookup5 + 0x2e }
>    address : <0x0009f828> { _device_unregister + 0xc }
>    address : <0x00089f16> { _kobject_put + 0x4e }
>    address : <0x0097cd34> { :bfin_mac:_cleanup_module + 0x68 }
>    address : <0x000a141a> { ___device_release_driver + 0x5e }
>    address : <0x000a14b6> { _driver_detach + 0x72 }
>    address : <0x000a08f2> { _bus_remove_driver + 0x6a }
>    address : <0x000a08f8> { _bus_remove_driver + 0x70 }
>    address : <0x00109720> { _mutex_lock_interruptible + 0xc }
>    address : <0x0002a0e2> { _sys_delete_module + 0x162 }
>    address : <0x00043122> { _free_bprm + 0x12 }
>    address : <0xffa008d4> { _system_call + 0x68 }
>    address : <0x0029d3c2> [ rmmod + 0x1d382 ]
>    address : <0xffa00e3c> { _evt_system_call + 0x64 }
> ---[ end trace 96c9ba4ee8d1eb27 ]
>
> This WARN was fired by this calling chain: mdiobus_unregister() ->
> put_device() -> kobject_put();
> IMO, mdiobus_release should be called after mdiobus_free, right. So my
> patch is not a good way to solve this bug.
> Any idea about this?
>
> -Bryan
>

Hi guys,

I guess I fixed this bug. we need to call
device_unregister(&bus->dev); in mdiobus_free() not in
mdiobus_unregister().
---
Index: drivers/net/phy/mdio_bus.c
===================================================================
--- drivers/net/phy/mdio_bus.c	(revision 5577)
+++ drivers/net/phy/mdio_bus.c	(working copy)
@@ -136,7 +136,6 @@
 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
 	bus->state = MDIOBUS_UNREGISTERED;

-	device_unregister(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
@@ -165,6 +164,7 @@
 	BUG_ON(bus->state != MDIOBUS_UNREGISTERED);
 	bus->state = MDIOBUS_RELEASED;

+	device_unregister(&bus->dev);
 	put_device(&bus->dev);
 }
 EXPORT_SYMBOL(mdiobus_free);
---

If it is OK, I will send out a git patch for merge.

-Bryan
