From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: Null pointer dereference in UDP4 core on AVR32 ATNGW100
Date: Fri, 31 Jul 2015 16:51:17 +0300
Message-ID: <CAHp75VdLE9aJO1EcBFmdK00f1D+jzV240jNV_0Ka1xMQ6gmkSw@mail.gmail.com>
References: <CAHp75VdG5Ys09pmc1Qo1EHSRr1gYdLv--9NtECB_VUo5d9+USg@mail.gmail.com>
	<CAHp75VdhaZrzBrtHrFCvsckpGq=oLvCRtR21CQH7C8XduMoA_w@mail.gmail.com>
	<CANn89i+mN-ZkxFgw29OYf=d921NcOyPpYuQLHaLi-KF66+A6xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Held <drheld@google.com>,
	Hans-Christian Egtvedt <egtvedt@samfundet.no>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89i+mN-ZkxFgw29OYf=d921NcOyPpYuQLHaLi-KF66+A6xA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 31, 2015 at 4:49 PM, Eric Dumazet <edumazet@google.com> wro=
te:
> How much memory you have on this host ?
>
> dmesg | grep hash
>
>

# dmesg | grep hash
PID hash table entries: 128 (order: -3, 512 bytes)
Dentry cache hash table entries: 4096 (order: 2, 16384 bytes)
Inode-cache hash table entries: 2048 (order: 1, 8192 bytes)
Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 1024 (order: 0, 4096 bytes)
TCP bind hash table entries: 1024 (order: 0, 4096 bytes)
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
futex hash table entries: 16 (order: -5, 192 bytes)


> On Fri, Jul 31, 2015 at 3:45 PM, Andy Shevchenko
> <andy.shevchenko@gmail.com> wrote:
>> On Fri, Jul 31, 2015 at 4:25 PM, Andy Shevchenko
>> <andy.shevchenko@gmail.com> wrote:
>>> Hi!
>>>
>>> Got few weeks ago an old AVR32 board (ATNGW100).
>>> It has ethernet cards supported by macb driver.
>>>
>>> Bring it mostly back to work with recent kernel from linux-next. No=
w,
>>> when I start networking on it, I got in few seconds kernel panic.
>>
>> Seems the hack fixes this (still playing with network connected).
>>
>> # uname -a
>> Linux buildroot 4.2.0-rc4-next-20150731+ #164 Fri Jul 31 16:37:20 EE=
ST
>> 2015 avr32 GNU/Linux
>>
>>
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -1665,6 +1665,10 @@ static int __udp4_lib_mcast_deliver(struct ne=
t
>> *net, struct sk_buff *skb,
>>         unsigned int hash2 =3D 0, hash2_any =3D 0, use_hash2 =3D (hs=
lot->count > 10);
>>         bool inner_flushed =3D false;
>>
>> +#ifdef CONFIG_AVR32
>> +       use_hash2 =3D 0;
>> +#endif
>> +
>>         if (use_hash2) {
>>                 hash2_any =3D udp4_portaddr_hash(net, htonl(INADDR_A=
NY), hnum) &
>>                             udp_table.mask;
>>
>>
>>
>>>
>>> Unable to handle kernel NULL pointer dereference at virtual address=
 00000000
>>> ptbr =3D 91e42000 pgd =3D 91e4b000
>>> Oops: Kernel access of bad area, sig: 11 [#1]
>>> FRAME_POINTER chip: 0x01f:0x1e82 rev 2
>>> Modules linked in:
>>> CPU: 0 PID: 0 Comm: swapper Not tainted 4.2.0-rc4-next-20150729+ #1=
02
>>> task: 903532dc ti: 90350000 task.ti: 90350000
>>> PC is at __udp4_lib_rcv+0x300/0x660
>>> LR is at 0x15da8a2f
>>> pc : [<90233a84>]    lr : [<15da8a2f>]    Not tainted
>>> 0sp : 90351b5c  r12: 00000000  r11: 91cd4450
>>> r10: 00000000  r9 : 0000004c  r8 : 00000000
>>> r7 : 90351c80  r6 : 91db5c80  r5 : 91e4e540  r4 : 11f6a114
>>> r3 : 00000000  r2 : 91e6b224  r1 : 0000008a  r0 : 00000000
>>> Flags: qvnZc
>>> Mode bits: hjmde....g
>>> CPU Mode: Interrupt level 0
>>> Stack: (0x90351b5c to 0x90352000)
>>> =E2=80=A6
>>> Call trace:
>>> [<90233df0>] udp_rcv+0xc/0x14
>>> [<90215220>] ip_local_deliver_finish+0xac/0x15c
>>> [<902150ca>] ip_local_deliver+0x76/0x84
>>> [<90214d32>] ip_rcv_finish+0x23a/0x250
>>> [<90215004>] ip_rcv+0x2bc/0x30c
>>> [<901f5ee4>] __netif_receive_skb_core+0x548/0x570
>>> [<901f5f52>] __netif_receive_skb+0x46/0x50
>>> [<901f5f8e>] netif_receive_skb_internal+0x32/0x3c
>>> [<901f5fa0>] netif_receive_skb_sk+0x8/0xc
>>> [<901cf358>] macb_rx+0x1b0/0x1d8
>>> [<901cf4d8>] macb_poll+0x38/0xa4
>>> [<901faf9c>] net_rx_action+0x84/0x1b4
>>> [<90021e46>] __do_softirq+0x5a/0x150
>>> [<90021f86>] irq_exit+0x26/0x58
>>> [<9001a520>] do_IRQ+0x34/0x44
>>> [<90019428>] irq_level0+0x18/0x5c
>>> [<900355a4>] default_idle_call+0x1c/0x20
>>> [<9003563e>] cpu_startup_entry+0x66/0xa8
>>> [<902a16a4>] rest_init+0x48/0x70
>>> [<900007fc>] start_kernel+0x290/0x2dc
>>>
>>> Long time bisecting and reading assembly points to the
>>>
>>> commit 2dc41cff7545d55c6294525c811594576f8e119c
>>> Author: David Held <drheld@google.com>
>>> Date:   Tue Jul 15 23:28:32 2014 -0400
>>>
>>>     udp: Use hash2 for long hash1 chains in __udp*_lib_mcast_delive=
r.
>>>
>>> I don't know yet neither the package exactly makes this (tried to
>>> debug print, but bug disappears) nor should be network card driver
>>> fixed, or even compiler / binutils problems (using it from buildroo=
t,
>>> which is gcc 4.2.2). Would like to hear opinions what the root caus=
e
>>> might be and what ways we have to fix it. I'm also wondering if any
>>> other architecture with same network card has the issue.
>>>
>>> P.S.
>>> Since buildroot is not supporting anymore avr32 I use the version j=
ust
>>> before this removal. (Nicolas, does Atmel care about that?)
>>>
>>> --
>>> With Best Regards,
>>> Andy Shevchenko
>>
>>
>>
>> --
>> With Best Regards,
>> Andy Shevchenko



--=20
With Best Regards,
Andy Shevchenko
