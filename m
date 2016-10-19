From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: tg3 BUG: spinlock lockup suspected
Date: Wed, 19 Oct 2016 10:18:09 +0530
Message-ID: <CAMet4B60wAi0oqEXDdGdw4UV-bCsbprm9xQqkLMznSyxO3Z-Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        sparclinux@vger.kernel.org,
        Linux Kernel list <linux-kernel@vger.kernel.org>,
        Deepak Khungar <deepak.khungar@broadcom.com>
To: Meelis Roos <mroos@linux.ee>
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 17, 2016 at 6:35 PM, Meelis Roos <mroos@linux.ee> wrote:
>> > Now I reproduced the bug even with 4.7-rc1 so it is older than 4.7. Will
>> > test further.
>>
>> It gets stranger and stranger - my old 4.7 image worked fine, freshly
>> compiled 4.7 exhibits the same problem.
>>
>> Toolchain has not changed, that I know for sure.
>>
>> What may have changed is kernel .config. My old conf was with whatever I
>> had during 4.7. Then I upgraded to 4.8-rc3 and then 4.8 and selected
>> values for "make oldconfig" new entries. Then went back to 4.7-rc1 and
>> then to 4.7 with this config, answering quiestion about new options when
>> any appeared. Diff is not available since I do not have the old configs
>> archived.
>
> I did some more digging. Found an older configuration that is working
> and recreated a newer one that is bad, for the same 4.7 kernel. This is
> reproducible now, from "make clean" state.
>
> Working config from 4.7-rc4 attached as config-4.7, broken config from
> 4.7 attached as config-4.7-bad.
>
> Will try to bisect the configs as time permits. But looking at the
> stack traces, the issue is probably timing related, when ip and dhclient
> do something with the same lock. seq_read that outputs stats could be
> reading /proc/net/dev that reads counters from each interface.
>
> ifupdown seems to use the following for dhcp interfaces:
>   up
>     [[/bin/ip link set dev %iface% address %hwaddress%]]
>     /sbin/dhclient -v -pf /run/dhclient.%iface%.pid -lf /var/lib/dhcp/dhclient.%iface%.leases -I -df /var/lib/dhcp/dhclient6.%iface%.leases %iface% \
> ...
>
> so ip link is setting link up, this creates some work for the
> background, and the dhclient goes adn reads /proc/net/dev, and lockup is
> suspected but not proven?
>
> I started a loop for test, doing cat /proc/net/dev in a loop and at the
> same link link up and down from console, but up and down is slow process
> and the loop did not seem to trigger the warning over night, so it was
> not so simple.
>
I am busy with other priority tasks. One of my colleague Deepak will
work this with you.
I added him to CC list.
Thanks.
>
>> > > [   83.716570] BUG: spinlock lockup suspected on CPU#0, dhclient/1014
>> > > [   83.797819]  lock: 0xfff000123c8e4a08, .magic: dead4ead, .owner: ip/1001, .owner_cpu: 1
>> > > [   83.903130] CPU: 0 PID: 1014 Comm: dhclient Not tainted 4.8.0 #4
>> > > [   83.982129] Call Trace:
>> > > [   84.014160]  [00000000004b7220] spin_dump+0x60/0xa0
>> > > [   84.078203]  [00000000004b73a0] do_raw_spin_lock+0xa0/0x120
>> > > [   84.106344] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> > > [   84.107193] ip (1001) used greatest stack depth: 2168 bytes left
>> > > [   84.306955]  [000000000092c0d0] _raw_spin_lock_bh+0x30/0x40
>> > > [   84.380188]  [00000000100822cc] tg3_get_stats64+0xc/0x80 [tg3]
>> > > [   84.456885]  [00000000007fac8c] dev_get_stats+0x2c/0xc0
>> > > [   84.525506]  [000000000081a4e8] dev_seq_printf_stats+0x8/0xe0
>> > > [   84.600986]  [000000000081a5e4] dev_seq_show+0x24/0x40
>> > > [   84.668467]  [00000000005cb6c4] seq_read+0x2c4/0x440
>> > > [   84.733656]  [000000000060b97c] proc_reg_read+0x3c/0x80
>> > > [   84.802282]  [00000000005a219c] __vfs_read+0x1c/0x140
>> > > [   84.868613]  [00000000005a2310] vfs_read+0x50/0x100
>> > > [   84.932662]  [00000000005a265c] SyS_read+0x3c/0xa0
>> > > [   84.995573]  [00000000004061d4] linux_sparc_syscall32+0x34/0x60
>> > > [   85.073748] * CPU[  0]: TSTATE[00000044f0001a22] TPC[00000000f79a16b0] TNPC[00000000f79a16b4] TASK[dhclient:1014]
>> > > [   85.208732]              TPC[f79a16b0] O7[f79405c8] I7[0] RPC[0]
>> > > [   85.287633]   CPU[  1]: TSTATE[0000004480001605] TPC[00000000004b26f0] TNPC[00000000004d0b0c] TASK[swapper/1:0]
>> > > [   85.420338]              TPC[trace_hardirqs_off+0x10/0x20] O7[rcu_idle_enter+0x64/0xa0] I7[cpu_startup_entry+0x1b0/0x240] RPC[rest_init+0x178/0x1a0]
>> > > [   85.664600] tg3 0000:00:02.0 eth0: Link is up at 100 Mbps, full duplex
>> > > [   85.750515] tg3 0000:00:02.0 eth0: Flow control is off for TX and off for RX
>> > > [   85.843994] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>
> --
> Meelis Roos (mroos@linux.ee)
