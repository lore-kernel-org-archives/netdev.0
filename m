From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: [2.6.9] Networking crash, slightly exotic setup, bridged tap/tun
 interfaces
Date: Tue, 14 Dec 2004 10:52:45 +1030
Message-ID: <20041214105245.32c9b1a6.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm playing around with using QEMU to emulate virtual routers. I'm using
Qemu (0.6.1) in full PC emulation mode, running multiple instances of a base
ubunto 4.1 install. Within Qemu, the virtual PC emulates one or more PCI
based NE2K NICs, which can be attached to tun tap/tun type devices on
the host kernel.

In each instance of Qemu, I'm running Quagga 0.97.3. At the time of the
crash I was running OSPF across the vitual PCI NE2K NICs. I don't know
if it matters to this problem, OSPF users layer 2 and 3 unicast and
multicast capabilities.

On my main host, I'd bridged together the multiple tun interfaces. I'm
also running quagga 0.97.3 on the host kernel, and had then enabled OSPF
on the bridge interface. I was also running the command line version of
ethereal, tethereal, to watch the OSPF traffic across the virtual LAN.

It seemed to be working ok, although I was having some problems with
OSPF database synchronisation across the virtual LAN. That could be a
bug in Quagga OSPF though.

I do find it a bit odd that Qemu uses tun interfaces, supposedly for IP
only, rather than tap interfaces to connect the virtual NE2K NICs to the
host.These tun interfaces seem to support layer 2 fine - I was seeing
layer 2 traffic across them, such as ARPs, IPv6 RS/ND traffic and STP BPDUs.

My kernel is only slightly modified from vanilla 2.6.9 - I've increased
the kernel log buffer size to allow me to capture boot messages I loose
because of my RAID1 arrays. I'm happy to provide a diff against vanilla
2.6.9 if people think that could be a problem.

After a while of this set up operating, I received the following Oops
from the host kernel, and thought I should report it. (As a side note,
do I need to run it through ksymoops any more ? I installed ksymoops,
however I don't have a /proc/ksyms file. I tried to use /proc/kallsyms,
that didn't work either. I've understood that the purpose of ksymoops is
to list the functions being called at the time of the Ooops, it would
appear that the kernel does that automatically now.)

If there is anything further I can do to help diagnose this problem,
please let me know.

Thanks,
Mark.

--
00:22:24 ubu kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000000
00:22:24 ubu kernel:  printing eip:
00:22:24 ubu kernel: c035322b
00:22:24 ubu kernel: *pde = 00000000
00:22:24 ubu kernel: Oops: 0002 [#1]
00:22:24 ubu kernel: PREEMPT 
00:22:24 ubu kernel: Modules linked in: dummy bridge atm snd_seq_oss snd_seq_midi snd_seq_midi_event snd_opl3_synth snd_seq_instr snd_seq_midi_emul snd_ainstr_fm snd_seq tun nls_cp437 isofs udf mga cpufreq_userspace cpufreq_powersave cpufreq_ondemand thermal fan button processor pppoe pppox ppp_generic slhc irda_usb irda crc_ccitt snd_bt87x tuner tvaudio msp3400 bttv video_buf firmware_class i2c_algo_bit v4l2_common btcx_risc videodev natsemi epic100 mii crc32 snd_es18xx snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_opl3_lib snd_timer snd_hwdep snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcore evdev eeprom i2c_sensor ir_kbd_i2c ir_common i2c_piix4 parport_pc lp parport
00:22:24 ubu kernel: CPU:    0
00:22:24 ubu kernel: EIP:    0060:[fib_release_info+139/240]    Not tainted VLI
00:22:24 ubu kernel: EFLAGS: 00210246   (2.6.9-mrs) 
00:22:24 ubu kernel: EIP is at fib_release_info+0x8b/0xf0
00:22:24 ubu kernel: eax: 00000000   ebx: ca4834a0   ecx: 00000000   edx: ca483504
00:22:24 ubu kernel: esi: ca483508   edi: 00000000   ebp: d6a32710   esp: cfe1fc60
00:22:24 ubu kernel: ds: 007b   es: 007b   ss: 0068
00:22:24 ubu kernel: Process zebra (pid: 14501, threadinfo=cfe1e000 task=d6a65560)
00:22:24 ubu kernel: Stack: 00000001 c6607bb0 d6fad5e8 c0355e3b 00000008 000000fe c6607ba0 c3435d78 
00:22:24 ubu kernel:        003c7e00 c9103ca0 00000008 d6fad5e0 c1379e20 d69a5bc0 0000000a d69a5bc0 
00:22:24 ubu kernel:        c6607bb0 c6607ba0 c1379e20 c0352a95 c6607ba0 c3435d78 c3435d40 c3435d40 
00:22:24 ubu kernel: Call Trace:
00:22:24 ubu kernel:  [fn_hash_delete+443/608] fn_hash_delete+0x1bb/0x260
00:22:24 ubu kernel:  [inet_rtm_delroute+101/128] inet_rtm_delroute+0x65/0x80
00:22:24 ubu kernel:  [inet_rtm_delroute+0/128] inet_rtm_delroute+0x0/0x80
00:22:24 ubu kernel:  [rtnetlink_rcv+719/896] rtnetlink_rcv+0x2cf/0x380
00:22:24 ubu kernel:  [copy_to_user+50/80] copy_to_user+0x32/0x50
00:22:24 ubu kernel:  [rtnetlink_rcv+0/896] rtnetlink_rcv+0x0/0x380
00:22:24 ubu kernel:  [netlink_data_ready+85/96] netlink_data_ready+0x55/0x60
00:22:24 ubu kernel:  [netlink_sendskb+33/80] netlink_sendskb+0x21/0x50
00:22:24 ubu kernel:  [netlink_sendmsg+465/720] netlink_sendmsg+0x1d1/0x2d0
00:22:24 ubu kernel:  [activate_task+90/112] activate_task+0x5a/0x70
00:22:24 ubu kernel:  [sock_sendmsg+190/224] sock_sendmsg+0xbe/0xe0
00:22:24 ubu kernel:  [group_send_sig_info+141/144] group_send_sig_info+0x8d/0x90
00:22:24 ubu kernel:  [__mod_timer+300/384] __mod_timer+0x12c/0x180
00:22:24 ubu kernel:  [recalc_task_prio+151/400] recalc_task_prio+0x97/0x190
00:22:24 ubu kernel:  [schedule+668/1248] schedule+0x29c/0x4e0
00:22:24 ubu kernel:  [__do_softirq+121/144] __do_softirq+0x79/0x90
00:22:24 ubu kernel:  [need_resched+39/50] need_resched+0x27/0x32
00:22:24 ubu kernel:  [autoremove_wake_function+0/80] autoremove_wake_function+0x0/0x50
00:22:24 ubu kernel:  [copy_from_user+52/112] copy_from_user+0x34/0x70
00:22:24 ubu kernel:  [verify_iovec+42/144] verify_iovec+0x2a/0x90
00:22:24 ubu kernel:  [sys_sendmsg+337/416] sys_sendmsg+0x151/0x1a0
00:22:24 ubu kernel:  [do_sync_write+154/208] do_sync_write+0x9a/0xd0
00:22:24 ubu kernel:  [__group_send_sig_info+119/160] __group_send_sig_info+0x77/0xa0
00:22:24 ubu kernel:  [__mod_timer+300/384] __mod_timer+0x12c/0x180
00:22:24 ubu kernel:  [autoremove_wake_function+0/80] autoremove_wake_function+0x0/0x50
00:22:24 ubu kernel:  [sys_socketcall+562/592] sys_socketcall+0x232/0x250
00:22:24 ubu kernel:  [capable+21/48] capable+0x15/0x30
00:22:24 ubu kernel:  [sysenter_past_esp+82/113] sysenter_past_esp+0x52/0x71
00:22:24 ubu kernel: Code: 00 c7 41 04 00 02 20 00 31 ff 8d 53 64 3b 7b 5c 7d 37 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 8b 42 04 8d 72 04 8b 4e 04 85 c0 <89> 01 74 03 89 48 04 c7 42 04 00 01 10 00 47 83 c2 2c c7 46 04 
00:22:24 ubu kernel:  <6>note: zebra[14501] exited with preempt_count 1
00:22:24 ubu kernel: bad: scheduling while atomic!
00:22:24 ubu kernel:  [schedule+1228/1248] schedule+0x4cc/0x4e0
00:22:24 ubu kernel:  [zap_pmd_range+75/112] zap_pmd_range+0x4b/0x70
00:22:24 ubu kernel:  [unmap_page_range+61/112] unmap_page_range+0x3d/0x70
00:22:24 ubu kernel:  [unmap_vmas+427/448] unmap_vmas+0x1ab/0x1c0
00:22:24 ubu kernel:  [exit_mmap+116/336] exit_mmap+0x74/0x150
00:22:24 ubu kernel:  [mmput+85/144] mmput+0x55/0x90
00:22:24 ubu kernel:  [do_exit+323/1008] do_exit+0x143/0x3f0
00:22:24 ubu kernel:  [die+365/368] die+0x16d/0x170
00:22:24 ubu kernel:  [do_page_fault+0/1390] do_page_fault+0x0/0x56e
00:22:24 ubu kernel:  [do_page_fault+0/1390] do_page_fault+0x0/0x56e
00:22:24 ubu kernel:  [do_page_fault+543/1390] do_page_fault+0x21f/0x56e
00:22:24 ubu kernel:  [schedule+668/1248] schedule+0x29c/0x4e0
00:22:24 ubu kernel:  [netlink_broadcast+471/656] netlink_broadcast+0x1d7/0x290
00:22:24 ubu kernel:  [do_page_fault+0/1390] do_page_fault+0x0/0x56e
00:22:24 ubu kernel:  [error_code+45/56] error_code+0x2d/0x38
00:22:24 ubu kernel:  [fib_release_info+139/240] fib_release_info+0x8b/0xf0
00:22:24 ubu kernel:  [fn_hash_delete+443/608] fn_hash_delete+0x1bb/0x260
00:22:24 ubu kernel:  [inet_rtm_delroute+101/128] inet_rtm_delroute+0x65/0x80
00:22:24 ubu kernel:  [inet_rtm_delroute+0/128] inet_rtm_delroute+0x0/0x80
00:22:24 ubu kernel:  [rtnetlink_rcv+719/896] rtnetlink_rcv+0x2cf/0x380
00:22:24 ubu kernel:  [copy_to_user+50/80] copy_to_user+0x32/0x50
00:22:24 ubu kernel:  [rtnetlink_rcv+0/896] rtnetlink_rcv+0x0/0x380
00:22:24 ubu kernel:  [netlink_data_ready+85/96] netlink_data_ready+0x55/0x60
00:22:24 ubu kernel:  [netlink_sendskb+33/80] netlink_sendskb+0x21/0x50
00:22:24 ubu kernel:  [netlink_sendmsg+465/720] netlink_sendmsg+0x1d1/0x2d0
00:22:24 ubu kernel:  [activate_task+90/112] activate_task+0x5a/0x70
00:22:24 ubu kernel:  [sock_sendmsg+190/224] sock_sendmsg+0xbe/0xe0
00:22:24 ubu kernel:  [group_send_sig_info+141/144] group_send_sig_info+0x8d/0x90
00:22:24 ubu kernel:  [__mod_timer+300/384] __mod_timer+0x12c/0x180
00:22:24 ubu kernel:  [recalc_task_prio+151/400] recalc_task_prio+0x97/0x190
00:22:24 ubu kernel:  [schedule+668/1248] schedule+0x29c/0x4e0
00:22:24 ubu kernel:  [__do_softirq+121/144] __do_softirq+0x79/0x90
00:22:24 ubu kernel:  [need_resched+39/50] need_resched+0x27/0x32
00:22:24 ubu kernel:  [autoremove_wake_function+0/80] autoremove_wake_function+0x0/0x50
00:22:24 ubu kernel:  [copy_from_user+52/112] copy_from_user+0x34/0x70
00:22:24 ubu kernel:  [verify_iovec+42/144] verify_iovec+0x2a/0x90
00:22:24 ubu kernel:  [sys_sendmsg+337/416] sys_sendmsg+0x151/0x1a0
00:22:24 ubu kernel:  [do_sync_write+154/208] do_sync_write+0x9a/0xd0
00:22:24 ubu kernel:  [__group_send_sig_info+119/160] __group_send_sig_info+0x77/0xa0
00:22:24 ubu kernel:  [__mod_timer+300/384] __mod_timer+0x12c/0x180
00:22:24 ubu kernel:  [autoremove_wake_function+0/80] autoremove_wake_function+0x0/0x50
00:22:24 ubu kernel:  [sys_socketcall+562/592] sys_socketcall+0x232/0x250
00:22:24 ubu kernel:  [capable+21/48] capable+0x15/0x30
00:22:24 ubu kernel:  [sysenter_past_esp+82/113] sysenter_past_esp+0x52/0x71
-- 
