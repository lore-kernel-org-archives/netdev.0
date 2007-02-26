From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [BUG][2.6.21] af_key: kernel BUG at net/core/skbuff.c:93
Date: Mon, 26 Feb 2007 23:08:41 +0100
Message-ID: <20070226220841.GA7727@dreamland.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:63325 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161277AbXBZWIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 17:08:48 -0500
Received: by ug-out-1314.google.com with SMTP id 44so935530uga
        for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 14:08:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I'm running 2.6.21 (current git, at 9654640d0af). kernel blows up at
startup, when running setkey. Kernel 2.6.20 runs fine. A couple of words
on the config: I played a bit with IPSec a while ago, then removed
AH/ESP (INET_AH and INET_ESP) from the kernel; NET_KEY was left enabled.
I think that the problem lies in this (mis)configuration, since
re-enabling AH/ESP makes the system boots fine.

Kernel is SMP with PREEMT enabled.

This the boot log (captured over serial console, unfortunately it's
intermixed with output from startup scripts):

Loading IPsec SA/SP database from /etc/ipsec-tools.conf: NET: Registered protoco
l family 15
skb_over_panic: text:f1b8a065 len:16 put:16 head:b1a3ba00 data:b1a3ba00 tail:b1a
3ba00 end:b1a3ba90 dev:<NULL>
------------[ cut here ]------------
kernel BUG at /home/kronos/src/linux-2.6.git/net/core/skbuff.c:93!
invalid opcode: 0000 [#1]
PREEMPT SMP
Modules linked in: af_key nfsd exportfs lockd sunrpc nls_iso8859_15 nls_cp850 vf
at fat nls_base cpufreq_ondemand acpi_cpufreq freq_table i2c_isa ipv6 snd_hda_in
tel snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm e100 ohci1394 snd_timer ieee
1394 uhci_hcd snd ehci_hcd intel_agp parport_pc parport agpgart i2c_i801 usbcore
 atl1 mii soundcore snd_page_alloc dm_snapshot dm_mod thermal processor fan reis
erfs xfs
CPU:    0
EIP:    0060:[<b02a4192>]    Not tainted VLI
EFLAGS: 00210282   (2.6.21-rc1-g9654640d-dirty #35)
EIP is at skb_over_panic+0x59/0x5d
eax: 00000071   ebx: b1a3ba00   ecx: eec64000   edx: 00000000
/etc/rcS.d/S37seesi: 00000000   edi: eec64dd4   ebp: eeccdb40   esp: eec64d20
tkey: line 21:  ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
4514 SegmentatioProcess setkey (pid: 4514, ti=eec64000 task=edd82ae0 task.ti=eec
64000)
n fault      $SEStack: TKEY -f $SETKEY_b03a2d1d f1b8a065 00000010 00000010 b1a3b
a00 b1a3ba00 b1a3ba00 b1a3ba90
CONF
Setting up       b038176f b1a3ba80 eec64f44 f1b8a06a ffffffff ef19ac00 00000000
edd8301c
 resolvconf...       00200046 b02f70c2 00000000 eec64dd0 b02f6ffe 00000000 00000
000 eec64e20
Call Trace:
 [<f1b8a065>] pfkey_sendmsg+0x99/0x33e [af_key]
 [<f1b8a06a>] pfkey_sendmsg+0x9e/0x33e [af_key]
 [<b02f70c2>] wait_for_completion+0x7b/0xaa
 [<b02f6ffe>] __sched_text_start+0x7d6/0x80b
 [<b02f995f>] _spin_unlock_irq+0x20/0x41
 [<b013a3fe>] trace_hardirqs_on+0x11e/0x141
 [<b02f70c2>] wait_for_completion+0x7b/0xaa
 [<b029fb67>] sock_sendmsg+0xbc/0xd4
 [<b01317f1>] autoremove_wake_function+0x0/0x35
 [<b0104f1c>] dump_trace+0x89/0x93
 [<b013a55f>] check_usage+0x24/0x245
 [<b0148676>] find_get_page+0xe/0x3b
 [<b029fe93>] sys_sendto+0x11b/0x13b
 [<b01534ab>] __handle_mm_fault+0x2a5/0x864
 [<b013a3fe>] trace_hardirqs_on+0x11e/0x141
 [<b0148676>] find_get_page+0xe/0x3b
 [<b014869e>] find_get_page+0x36/0x3b
 [<b01534ab>] __handle_mm_fault+0x2a5/0x864
 [<b02f985b>] _spin_unlock+0x25/0x3b
 [<b0153a48>] __handle_mm_fault+0x842/0x864
 [<b029feea>] sys_send+0x37/0x3b
 [<b02a0beb>] sys_socketcall+0x12d/0x242
 [<b0103fe8>] restore_nocheck+0x12/0x15
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
Code: 00 00 89 5c 24 14 8b 98 94 00 00 00 89 54 24 0c 89 5c 24 10 8b 40 60 89 4c
 24 04 c7 04 24 1d 2d 3a b0 89 44 24 08 e8 33 ce e7 ff <0f> 0b eb fe 55 89 d5 57
 56 53 83 ec 3c 89 44 24 20 8b 7c 24 50
EIP: [<b02a4192>] skb_over_panic+0x59/0x5d SS:ESP 0068:eec64d20
done.
Setting up networking....
Configuring network interfaces...BUG: at /home/kronos/src/linux-2.6.git/net/ipv6
/addrconf.c:3367 inet6_ifa_notify()
 [<f1a76132>] __ipv6_ifa_notify+0x87/0x169 [ipv6]
 [<f1a76234>] ipv6_ifa_notify+0x20/0x27 [ipv6]
 [<f1a78589>] addrconf_notify+0x4bf/0x6d9 [ipv6]
 [<b02e6c39>] fib_magic+0x8b/0x9c
 [<b02f9648>] _spin_lock_irqsave+0x43/0x4b
 [<b02f5f32>] packet_notifier+0x16/0x141
 [<b02f98d1>] _read_unlock+0x25/0x3b
 [<b02f6055>] packet_notifier+0x139/0x141
 [<b012bc2f>] notifier_call_chain+0x19/0x32
 [<b02a9994>] dev_open+0x5c/0x62
 [<b02a829c>] dev_change_flags+0x47/0xe6
 [<b02e19fd>] devinet_ioctl+0x259/0x573
 [<b01c6ba8>] copy_to_user+0x37/0x4b
 [<b029f417>] sock_ioctl+0x191/0x1b0
 [<b029f286>] sock_ioctl+0x0/0x1b0
 [<b016d4ab>] do_ioctl+0x1f/0x62
 [<b016d732>] vfs_ioctl+0x244/0x256
 [<b016d777>] sys_ioctl+0x33/0x4c
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
BUG: at /home/kronos/src/linux-2.6.git/net/ipv6/route.c:2237 inet6_rt_notify()
 [<f1a7b3b5>] inet6_rt_notify+0xd4/0x137 [ipv6]
 [<f1a7cd74>] fib6_add+0x40d/0x4cd [ipv6]
 [<b02f94ad>] _write_lock_bh+0x38/0x43
 [<f1a7a259>] __ip6_ins_rt+0x24/0x34 [ipv6]
 [<f1a76185>] __ipv6_ifa_notify+0xda/0x169 [ipv6]
 [<f1a76234>] ipv6_ifa_notify+0x20/0x27 [ipv6]
 [<f1a78589>] addrconf_notify+0x4bf/0x6d9 [ipv6]
 [<b02e6c39>] fib_magic+0x8b/0x9c
 [<b02f9648>] _spin_lock_irqsave+0x43/0x4b
 [<b02f5f32>] packet_notifier+0x16/0x141
 [<b02f98d1>] _read_unlock+0x25/0x3b
 [<b02f6055>] packet_notifier+0x139/0x141
 [<b012bc2f>] notifier_call_chain+0x19/0x32
 [<b02a9994>] dev_open+0x5c/0x62
 [<b02a829c>] dev_change_flags+0x47/0xe6
 [<b02e19fd>] devinet_ioctl+0x259/0x573
 [<b01c6ba8>] copy_to_user+0x37/0x4b
 [<b029f417>] sock_ioctl+0x191/0x1b0
 [<b029f286>] sock_ioctl+0x0/0x1b0
 [<b016d4ab>] do_ioctl+0x1f/0x62
 [<b016d732>] vfs_ioctl+0x244/0x256
 [<b016d777>] sys_ioctl+0x33/0x4c
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
BUG: at /home/kronos/src/linux-2.6.git/net/ipv6/addrconf.c:3524 inet6_ifinfo_not
ify()
 [<f1a75fc4>] inet6_ifinfo_notify+0x7c/0xc8 [ipv6]
 [<f1a786ea>] addrconf_notify+0x620/0x6d9 [ipv6]
 [<b02e6c39>] fib_magic+0x8b/0x9c
 [<b02f9648>] _spin_lock_irqsave+0x43/0x4b
 [<b02f5f32>] packet_notifier+0x16/0x141
 [<b02f98d1>] _read_unlock+0x25/0x3b
 [<b02f6055>] packet_notifier+0x139/0x141
 [<b012bc2f>] notifier_call_chain+0x19/0x32
 [<b02a9994>] dev_open+0x5c/0x62
 [<b02a829c>] dev_change_flags+0x47/0xe6
 [<b02e19fd>] devinet_ioctl+0x259/0x573
 [<b01c6ba8>] copy_to_user+0x37/0x4b
 [<b029f417>] sock_ioctl+0x191/0x1b0
 [<b029f286>] sock_ioctl+0x0/0x1b0
 [<b016d4ab>] do_ioctl+0x1f/0x62
 [<b016d732>] vfs_ioctl+0x244/0x256
 [<b016d777>] sys_ioctl+0x33/0x4c
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
BUG: at /home/kronos/src/linux-2.6.git/net/ipv6/route.c:2237 inet6_rt_notify()
 [<f1a7b3b5>] inet6_rt_notify+0xd4/0x137 [ipv6]
 [<f1a7cd74>] fib6_add+0x40d/0x4cd [ipv6]
 [<b02f94ad>] _write_lock_bh+0x38/0x43
 [<f1a7a259>] __ip6_ins_rt+0x24/0x34 [ipv6]
 [<f1a755d5>] addrconf_add_mroute+0x62/0x68 [ipv6]
 [<f1a77c77>] addrconf_add_dev+0x4a/0x59 [ipv6]
 [<f1a77cfd>] inet6_addr_add+0x77/0x13d [ipv6]
 [<f1a77e1f>] addrconf_add_ifaddr+0x5c/0x6c [ipv6]
 [<b029f417>] sock_ioctl+0x191/0x1b0
 [<b029f286>] sock_ioctl+0x0/0x1b0
 [<b016d4ab>] do_ioctl+0x1f/0x62
 [<b016d732>] vfs_ioctl+0x244/0x256
 [<b016d777>] sys_ioctl+0x33/0x4c
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
BUG: at /home/kronos/src/linux-2.6.git/net/ipv6/route.c:2237 inet6_rt_notify()
 [<f1a7b3b5>] inet6_rt_notify+0xd4/0x137 [ipv6]
 [<f1a7cd74>] fib6_add+0x40d/0x4cd [ipv6]
 [<f1a7a259>] __ip6_ins_rt+0x24/0x34 [ipv6]
 [<f1a75648>] addrconf_prefix_route+0x6d/0x75 [ipv6]
 [<f1a75692>] addrconf_add_lroute+0x42/0x46 [ipv6]
 [<f1a77c7e>] addrconf_add_dev+0x51/0x59 [ipv6]
 [<f1a77cfd>] inet6_addr_add+0x77/0x13d [ipv6]
 [<f1a77e1f>] addrconf_add_ifaddr+0x5c/0x6c [ipv6]
 [<b029f417>] sock_ioctl+0x191/0x1b0
 [<b029f286>] sock_ioctl+0x0/0x1b0
 [<b016d4ab>] do_ioctl+0x1f/0x62
 [<b016d732>] vfs_ioctl+0x244/0x256
 [<b016d777>] sys_ioctl+0x33/0x4c
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
SIOCSIFADDR: File exists
Failed to bring up lo.
e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
skb_over_panic: text:f1a79866 len:28 put:28 head:ef2a2000 data:ef2a2000 tail:ef2
a2000 end:ef2a219c dev:<NULL>
------------[ cut here ]------------
kernel BUG at /home/kronos/src/linux-2.6.git/net/core/skbuff.c:93!
invalid opcode: 0000 [#2]
PREEMPT SMP
Modules linked in: af_key nfsd exportfs lockd sunrpc nls_iso8859_15 nls_cp850 vf
at fat nls_base cpufreq_ondemand acpi_cpufreq freq_table i2c_isa ipv6 snd_hda_in
tel snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm e100 ohci1394 snd_timer ieee
1394 uhci_hcd snd ehci_hcd intel_agp parport_pc parport agpgart i2c_i801 usbcore
 atl1 mii soundcore snd_page_alloc dm_snapshot dm_mod thermal processor fan reis
erfs xfs
CPU:    1
EIP:    0060:[<b02a4192>]    Not tainted VLI
EFLAGS: 00010296   (2.6.21-rc1-g9654640d-dirty #35)
EIP is at skb_over_panic+0x59/0x5d
eax: 00000071   ebx: ef2a2000   ecx: b1b85000   edx: 00000101
esi: 00000000   edi: e2ae7ec0   ebp: ef2a2180   esp: b1b85c64
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process ifconfig (pid: 4661, ti=b1b85000 task=b19854d0 task.ti=b1b85000)
Stack: b03a2d1d f1a79866 0000001c 0000001c ef2a2000 ef2a2000 ef2a2000 ef2a219c
       b038176f 00000000 edd6c500 f1a7986b eff8f5c0 00000246 edd6c500 00000180
       00000000 00000224 b02a4ddc 00000000 00000020 b191b340 00000000 edd6c500
Call Trace:
 [<f1a79866>] rt6_fill_node+0x6c/0x33a [ipv6]
 [<f1a7986b>] rt6_fill_node+0x71/0x33a [ipv6]
 [<b02a4ddc>] __alloc_skb+0x4f/0xf6
 [<f1a7b381>] inet6_rt_notify+0xa0/0x137 [ipv6]
 [<f1a7cd74>] fib6_add+0x40d/0x4cd [ipv6]
 [<b02f94ad>] _write_lock_bh+0x38/0x43
 [<f1a7a259>] __ip6_ins_rt+0x24/0x34 [ipv6]
 [<f1a755d5>] addrconf_add_mroute+0x62/0x68 [ipv6]
 [<f1a77c77>] addrconf_add_dev+0x4a/0x59 [ipv6]
 [<f1a785fc>] addrconf_notify+0x532/0x6d9 [ipv6]
 [<b02e6c39>] fib_magic+0x8b/0x9c
 [<b02f9648>] _spin_lock_irqsave+0x43/0x4b
 [<b02f5f32>] packet_notifier+0x16/0x141
 [<b02f98d1>] _read_unlock+0x25/0x3b
 [<b02f6055>] packet_notifier+0x139/0x141
 [<b012bc2f>] notifier_call_chain+0x19/0x32
 [<b02a9994>] dev_open+0x5c/0x62
 [<b02a829c>] dev_change_flags+0x47/0xe6
 [<b02e19fd>] devinet_ioctl+0x259/0x573
 [<b01c6ba8>] copy_to_user+0x37/0x4b
 [<b029f417>] sock_ioctl+0x191/0x1b0
 [<b029f286>] sock_ioctl+0x0/0x1b0
 [<b016d4ab>] do_ioctl+0x1f/0x62
 [<b016d732>] vfs_ioctl+0x244/0x256
 [<b016d777>] sys_ioctl+0x33/0x4c
 [<b0103fa0>] syscall_call+0x7/0xb
 =======================
Code: 00 00 89 5c 24 14 8b 98 94 00 00 00 89 54 24 0c 89 5c 24 10 8b 40 60 89 4c
 24 04 c7 04 24 1d 2d 3a b0 89 44 24 08 e8 33 ce e7 ff <0f> 0b eb fe 55 89 d5 57
 56 53 83 ec 3c 89 44 24 20 8b 7c 24 50
EIP: [<b02a4192>] skb_over_panic+0x59/0x5d SS:ESP 0068:b1b85c64
Kernel panic - not syncing: Fatal exception in interrupt

.config is attached.

Luca
-- 
"L'abilita` politica e` l'abilita` di prevedere quello che
 accadra` domani, la prossima settimana, il prossimo mese e
 l'anno prossimo. E di essere cosi` abili, piu` tardi,
 da spiegare  perche' non e` accaduto."
