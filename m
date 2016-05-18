From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Crashes in -next due to 'phy: add support for a reset-gpio
 specification'
Date: Tue, 17 May 2016 23:52:34 -0700
Message-ID: <573C1132.8080000@roeck-us.net>
References: <573BF177.6090507@roeck-us.net> <573BF731.4090002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <573BF731.4090002@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2016 10:01 PM, Florian Fainelli wrote:
> Le 17/05/2016 21:37, Guenter Roeck a =C3=A9crit :
>> Hi,
>>
>> my xtensa qemu tests crash in -next as follows.
>>
>> [ ... ]
>>
>> [    9.366256] libphy: ethoc-mdio: probed
>> [    9.367389]  (null): could not attach to PHY
>> [    9.368555]  (null): failed to probe MDIO bus
>> [    9.371540] Unable to handle kernel paging request at virtual add=
ress
>> 0000001c
>> [    9.371540]  pc =3D d0320926, ra =3D 903209d1
>> [    9.375358] Oops: sig: 11 [#1]
>> [    9.376081] PREEMPT
>> [    9.377080] CPU: 0 PID: 1 Comm: swapper Not tainted
>> 4.6.0-next-20160517 #1
>> [    9.378397] task: d7c2c000 ti: d7c30000 task.ti: d7c30000
>> [    9.379394] a00: 903209d1 d7c31bd0 d7fb5810 00000001 00000000
>> 00000000 d7f45c00 d7c31bd0
>> [    9.382298] a08: 00000000 00000000 00000000 00000000 00060100
>> d04b0c10 d7f45dfc d7c31bb0
>> [    9.385732] pc: d0320926, ps: 00060110, depc: 00000018, excvaddr:
>> 0000001c
>> [    9.387061] lbeg: d0322e35, lend: d0322e57 lcount: 00000000, sar:
>> 00000011
>> [    9.388173]
>> Stack: d7c31be0 00060700 d7f45c00 d7c31bd0 9021d509 d7c31c30 d7f45c0=
0
>> 00000000
>>         d0485dcc d0485dcc d7fb5810 d7c2c000 00000000 d7c31c30 d7f45c=
00
>> d025befc
>>         d0485dcc d7c30000 d7f45c34 d7c31bf0 9021c985 d7c31c50 d7f45c=
00
>> d7f45c34
>> [    9.396652] Call Trace:
>> [    9.397469]  [<d021d4d9>] __device_release_driver+0x7d/0x98
>> [    9.398869]  [<d021d509>] device_release_driver+0x15/0x20
>> [    9.400247]  [<d021c985>] bus_remove_device+0xc1/0xd4
>> [    9.401569]  [<d021a935>] device_del+0x109/0x15c
>> [    9.402794]  [<d025c3f9>] phy_mdio_device_remove+0xd/0x18
>> [    9.404124]  [<d025d264>] mdiobus_unregister+0x40/0x5c
>> [    9.405444]  [<d025ff44>] ethoc_probe+0x534/0x5b8
>> [    9.406742]  [<d021e2e0>] platform_drv_probe+0x28/0x48
>> [    9.408122]  [<d021d1e5>] driver_probe_device+0x101/0x234
>> [    9.409499]  [<d021d395>] __driver_attach+0x7d/0x98
>> [    9.410809]  [<d021bd80>] bus_for_each_dev+0x30/0x5c
>> [    9.412104]  [<d021cdf0>] driver_attach+0x14/0x18
>> [    9.413385]  [<d021ca61>] bus_add_driver+0xc9/0x198
>> [    9.414686]  [<d021d7d4>] driver_register+0x70/0xa0
>> [    9.416001]  [<d021e2b4>] __platform_driver_register+0x24/0x28
>> [    9.417463]  [<d04a1d34>] ethoc_driver_init+0x10/0x14
>> [    9.418824]  [<d00032c8>] do_one_initcall+0x80/0x1ac
>> [    9.420083]  [<d049386d>] kernel_init_freeable+0x131/0x198
>> [    9.421504]  [<d03236e8>] kernel_init+0xc/0xb0
>> [    9.422693]  [<d000482c>] ret_from_kernel_thread+0x8/0xc
>>
>> Bisect points to commit da47b4572056 ("phy: add support for a reset-=
gpio
>> specification").
>> Bisect log is attached. Reverting the patch fixes the problem.
>
> Aside from what you pointed out, this patch was still in dicussion wh=
en
> it got merged, since we got a concurrent patch from Sergei which trie=
s
> to deal with the same kind of problem.
>
> Do you mind sending a revert, or I can do that first thing in the mor=
ning.
>
>>
>> I think there may be a number of problems, all of them exposed by th=
e patch
>> but really separate.
>>
>> GPIOLIB is not configured in my test case, meaning gpiod_get_optiona=
l()
>> returns -ENOSYS, and phy_probe() thus returns an error. Question her=
e is if
>> it is really appropriate for the XXX_optional() gpiolib functions to=
 return
>> an error if GPIOLIB is not configured. Either case, result is that p=
retty
>> much all phy registrations will now fail if GPIOLIB is not configure=
d.
>>

Coincidentally, turns out that Uwe had objected to having gpiod_get_opt=
ional()
return NULL if GPIOLIB is not configured [1], meaning gpiod_get_optiona=
l()
and friends are intentionally not really optional, and the patch breaks
non-GPIOLIB configurations for good.

With that in mind, I agree, the patch should be reverted. It would be g=
reat if
you can do it; too late for me tonight.

Guenter

---
[1] https://patchwork.ozlabs.org/patch/441801/
