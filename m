From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [BUG][debian-2.6.20-1-686] bridging + vlans + "vconfig rem" == stuck kernel
Date: Fri, 11 May 2007 01:49:27 -0400
Message-ID: <ECE5C33E-2B09-4231-BEC3-4F0D7C677449@mac.com>
References: <2638DE26-D672-4245-BE88-D13B7F0F34A9@mac.com> <46429ED2.10809@candelatech.com> <EE6715FC-176D-4DA3-A0B3-6BDCC16122A6@mac.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	OSDL Linux Bridging <bridge@osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.178]:60281 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568AbXEKFtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 01:49:47 -0400
In-Reply-To: <EE6715FC-176D-4DA3-A0B3-6BDCC16122A6@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On May 10, 2007, at 00:34:11, Kyle Moffett wrote:
> On May 10, 2007, at 00:25:54, Ben Greear wrote:
>> Looks like a deadlock in the vlan code.  Any chance you can run  
>> this test with lockdep enabled?
>>
>> You could also add a printk in vlan_device_event() to check which  
>> event it is hanging on, and the netdevice that is passed in.
>
> Ok, I'll try building a 2.6.21 kernel with lockdep and some  
> debugging printk()s in the vlan_device_event() function and get  
> back to you tomorrow.  Thanks for the quick response!

Progress!!!  I built a 2.6.21.1 kernel with a 1MB dmesg buffer,  
almost all of the locking debugging options on (as well as a few  
others just for kicks), a VLAN debug #define turned on in the net/ 
8021q/vlan.h file, and lots of extra debugging messages added to the  
functions in vlan.c.  My initial interpretation is that due to the  
funny order in which "ifdown -a" takes down interfaces, it tries to  
delete the VLAN interfaces before the bridges running atop them have  
been taken down.  Ordinarily this seems to work, but when the  
underlying physical ethernet is down already, the last VLAN to be  
deleted seems to hang somehow.  The full results are as follows:

The lock dependency validator at startup passes all 218 testcases,  
indicating that all the locking crap is probably working correctly  
(those debug options chew up another meg of RAM).

ifup -a brings up the interfaces in this order (See previous email  
for configuration details):
lo net0 wfi0 world0 lan lan:0 world

ifdown -a appears to bring them down in the same order (at least,  
until it gets stuck).

Attached below is filtered debugging information.  I cut out 90% of  
the crap in the syslog, but there's still a lot left over to sift  
through; sorry.  If you want my .config or the full text of the log  
then email me privately and I'll send it to you, as it's kinda big.

I appreciate any advice, thanks for all your help

Cheers,
Kyle Moffett

This first bit is the "ifup -a -v -i interfaces":
> ADDRCONF(NETDEV_UP): net0: link is not ready
> vlan_ioctl_handler: args.cmd: 6
> vlan_ioctl_handler: args.cmd: 0
> register_vlan_device: if_name -:net0:-^Ivid: 2
> About to allocate name, vlan_name_type: 3
> Allocated new name -:net0.2:-
> About to go find the group for idx: 2
> vlan_transfer_operstate: net0 state transition applies to net0.2 too:
> vlan_proc_add, device -:net0.2:- being added.
> Allocated new device successfully, returning.
> wfi0: add 33:33:00:00:00:01 mcast address to master interface
> wfi0: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): wfi0: link is not ready
> vlan_ioctl_handler: args.cmd: 6
> vlan_ioctl_handler: args.cmd: 0
> register_vlan_device: if_name -:net0:-^Ivid: 4094
> About to allocate name, vlan_name_type: 3
> Allocated new name -:net0.4094:-
> About to go find the group for idx: 2
> vlan_transfer_operstate: net0 state transition applies to net0.4094  
> too:
> vlan_proc_add, device -:net0.4094:- being added.
> Allocated new device successfully, returning.
> world0: add 33:33:00:00:00:01 mcast address to master interface
> world0: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): world0: link is not ready
> tg3: net0: Link is up at 1000 Mbps, full duplex.
> tg3: net0: Flow control is on for TX and on for RX.
> ADDRCONF(NETDEV_CHANGE): net0: link becomes ready
> Propagating NETDEV_CHANGE for device net0...
>     ... to wfi0
>         vlan_transfer_operstate: net0 state transition applies to  
> wfi0 too:
>             ...found a carrier, applying to VLAN device
>     ... to world0
>         vlan_transfer_operstate: net0 state transition applies to  
> world0 too:
>             ...found a carrier, applying to VLAN device
> lan: port 1(net0) entering listening state
> ADDRCONF(NETDEV_CHANGE): wfi0: link becomes ready
> wfi0: dev_set_promiscuity(master, 1)
> wfi0: add 33:33:ff:5f:60:92 mcast address to master interface
> lan: port 2(wfi0) entering listening state
> ADDRCONF(NETDEV_CHANGE): world0: link becomes ready
> world0: add 33:33:ff:91:e2:4c mcast address to master interface
> lan: no IPv6 routers present
> world: no IPv6 routers present
> net0: no IPv6 routers present
> world0: no IPv6 routers present
> wfi0: no IPv6 routers present
> lan: port 1(net0) entering learning state
> lan: port 2(wfi0) entering learning state
> lan: topology change detected, propagating
> lan: port 1(net0) entering forwarding state
> lan: topology change detected, propagating
> lan: port 2(wfi0) entering forwarding state

This bit is for "ifdown -a -v -i interfaces":
> Propagating NETDEV_DOWN for device net0...
>     ... to wfi0
> wfi0: del 33:33:ff:5f:60:92 mcast address from vlan interface
> wfi0: del 33:33:ff:5f:60:92 mcast address from master interface
> wfi0: del 01:00:5e:00:00:01 mcast address from vlan interface
> wfi0: del 01:00:5e:00:00:01 mcast address from master interface
> wfi0: del 33:33:00:00:00:01 mcast address from vlan interface
> wfi0: del 33:33:00:00:00:01 mcast address from master interface
> lan: port 2(wfi0) entering disabled state
>     ... to world0
> world0: del 33:33:ff:91:e2:4c mcast address from vlan interface
> world0: del 33:33:ff:91:e2:4c mcast address from master interface
> world0: del 01:00:5e:00:00:01 mcast address from vlan interface
> world0: del 01:00:5e:00:00:01 mcast address from master interface
> world0: del 33:33:00:00:00:01 mcast address from vlan interface
> world0: del 33:33:00:00:00:01 mcast address from master interface
> lan: port 1(net0) entering disabled state
> vlan_ioctl_handler: args.cmd: 1
> unregister_vlan_device: request to unregister VLAN device wfi0
>     ...found device wfi0 to remove
>     ...oh goodie, it really is a vlan
> unregister_vlan_dev: real_dev=net0 vlan_id=2
>     ...found a VLAN group on net0
>     ...found VLAN2 device wfi0 (on net0)
> vlan_proc_rem_dev: dev: eed3a800
> lan: port 2(wfi0) entering disabled state
> vlan_ioctl_handler: args.cmd: 1
> unregister_vlan_device: request to unregister VLAN device world0
>     ...found device world0 to remove
>     ...oh goodie, it really is a vlan
> unregister_vlan_dev: real_dev=net0 vlan_id=4094
>     ...found a VLAN group on net0
>     ...found VLAN4094 device world0 (on net0)
> vlan_proc_rem_dev: dev: efd10000
>     ...disabling VLAN RX function for net0

And then it hangs; ugh.  I think the disable-the-RX function callback  
is making things die horribly somehow, but I don't know how.  At that  
point these messages start every couple seconds, of course:
> unregister_netdevice: waiting for world0 to become free. Usage  
> count = 2

I managed to dump a lot of info with /proc/sysrq-trigger before I  
rebooted the box:

Locks held after vconfig hang:
> 1 lock held by racoon/2760:
> #0:  (&u->readlock){--..}, at: [<c02bac6c>] mutex_lock+0x1c/0x1f
> 1 lock held by snmpd/3652:
> #0:  (net_todo_run_mutex){--..}, at: [<c02bac6c>] mutex_lock+0x1c/0x1f
> 1 lock held by getty/4460:
> #0:  (&tty->atomic_read_lock){--..}, at: [<c02ba86d>]  
> mutex_lock_interruptible+0x1c/0x1f
> 1 lock held by getty/4462:
> #0:  (&tty->atomic_read_lock){--..}, at: [<c02ba86d>]  
> mutex_lock_interruptible+0x1c/0x1f
> 1 lock held by getty/4468:
> #0:  (&tty->atomic_read_lock){--..}, at: [<c02ba86d>]  
> mutex_lock_interruptible+0x1c/0x1f
> 1 lock held by getty/4469:
> #0:  (&tty->atomic_read_lock){--..}, at: [<c02ba86d>]  
> mutex_lock_interruptible+0x1c/0x1f
> 1 lock held by getty/4474:
> #0:  (&tty->atomic_read_lock){--..}, at: [<c02ba86d>]  
> mutex_lock_interruptible+0x1c/0x1f
> 2 locks held by bash/5276:
> #0:  (sysrq_key_table_lock){....}, at: [<c02369bd>] __handle_sysrq 
> +0x1a/0x109
> #1:  (tasklist_lock){..-?}, at: [<c013cc9b>] debug_show_all_locks 
> +0x3e/0x12c
> 1 lock held by ntpdate/14168:
> #0:  (net_todo_run_mutex){--..}, at: [<c02bac6c>] mutex_lock+0x1c/0x1f
> 2 locks held by vconfig/14440:
> #0:  (vlan_ioctl_mutex){--..}, at: [<c02bac6c>] mutex_lock+0x1c/0x1f
> #1:  (net_todo_run_mutex){--..}, at: [<c02bac6c>] mutex_lock+0x1c/0x1f

Timers active after vconfig hang:
> Timer List Version: v0.3
> HRTIMER_MAX_CLOCK_BASES: 2
> now at 843386820778 nsecs
>
> cpu: 0
> clock 0:
>   .index:      0
>   .resolution: 1 nsecs
>   .get_time:   ktime_get_real
>   .offset:     1178840350000000000 nsecs
> active timers:
> clock 1:
>   .index:      1
>   .resolution: 1 nsecs
>   .get_time:   ktime_get
>   .offset:     0 nsecs
> active timers:
> #0: <f3ae1ef4>, tick_sched_timer, S:01
> # expires at 843388000000 nsecs [in 1179222 nsecs]
> #1: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 843615749775 nsecs [in 228928997 nsecs]
> #2: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 844260242939 nsecs [in 873422161 nsecs]
> #3: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 844526938106 nsecs [in 1140117328 nsecs]
> #4: <f3ae1ef4>, it_real_fn, S:01
> # expires at 857313402669 nsecs [in 13926581891 nsecs]
> #5: <f3ae1ef4>, it_real_fn, S:01
> # expires at 864373659163 nsecs [in 20986838385 nsecs]
> #6: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 868262819523 nsecs [in 24875998745 nsecs]
> #7: <f3ae1ef4>, it_real_fn, S:01
> # expires at 869177517060 nsecs [in 25790696282 nsecs]
> #8: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 887144741534 nsecs [in 43757920756 nsecs]
> #9: <f3ae1ef4>, it_real_fn, S:01
> # expires at 1237719810874 nsecs [in 394332990096 nsecs]
> #10: <f3ae1ef4>, it_real_fn, S:01
> # expires at 3649061431571 nsecs [in 2805674610793 nsecs]
> #11: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 3653786151926 nsecs [in 2810399331148 nsecs]
> #12: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 15650596970527 nsecs [in 14807210149749 nsecs]
> #13: <f3ae1ef4>, it_real_fn, S:01
> # expires at 28838055898524 nsecs [in 27994669077746 nsecs]
>   .expires_next   : 843388000000 nsecs
>   .hres_active    : 1
>   .nr_events      : 177960
>   .nohz_mode      : 2
>   .idle_tick      : 836132000000 nsecs
>   .tick_stopped   : 0
>   .idle_jiffies   : 134035
>   .idle_calls     : 252157
>   .idle_sleeps    : 40637
>   .idle_entrytime : 843384013943 nsecs
>   .idle_sleeptime : 291305642112 nsecs
>   .last_jiffies   : 135847
>   .next_jiffies   : 135848
>   .idle_expires   : 836144000000 nsecs
> jiffies: 135847
>
> cpu: 1
> clock 0:
>   .index:      0
>   .resolution: 1 nsecs
>   .get_time:   ktime_get_real
>   .offset:     1178840350000000000 nsecs
> active timers:
> clock 1:
>   .index:      1
>   .resolution: 1 nsecs
>   .get_time:   ktime_get
>   .offset:     0 nsecs
> active timers:
> #0: <f3ae1ef4>, tick_sched_timer, S:01
> # expires at 843408000000 nsecs [in 21179222 nsecs]
> #1: <f3ae1ef4>, it_real_fn, S:01
> # expires at 844040130585 nsecs [in 653309807 nsecs]
> #2: <f3ae1ef4>, hrtimer_wakeup, S:01
> # expires at 891590009741 nsecs [in 48203188963 nsecs]
>   .expires_next   : 843408000000 nsecs
>   .hres_active    : 1
>   .nr_events      : 109759
>   .nohz_mode      : 2
>   .idle_tick      : 843344000000 nsecs
>   .tick_stopped   : 1
>   .idle_jiffies   : 135836
>   .idle_calls     : 158231
>   .idle_sleeps    : 12809
>   .idle_entrytime : 843340014823 nsecs
>   .idle_sleeptime : 448828615174 nsecs
>   .last_jiffies   : 135836
>   .next_jiffies   : 135853
>   .idle_expires   : 843408000000 nsecs
> jiffies: 135847
>
>
> Tick Device: mode:     1
> Clock Event Device: hpet
> max_delta_ns:   2147483647
> min_delta_ns:   3352
> mult:           61496110
> shift:          32
> mode:           3
> next_event:     9223372036854775807 nsecs
> set_next_event: hpet_next_event
>  set_mode:       hpet_set_mode
> event_handler:  tick_handle_oneshot_broadcast
> tick_broadcast_mask: 00000000
> tick_broadcast_oneshot_mask: 00000000
>
>
> Tick Device: mode:     1
> Clock Event Device: lapic
> max_delta_ns:   671115476
> min_delta_ns:   1200
> mult:           53684938
> shift:          32
> mode:           3
> next_event:     843388000000 nsecs
> set_next_event: lapic_next_event
> set_mode:       lapic_timer_setup
> event_handler:  hrtimer_interrupt
>
> Tick Device: mode:     1
> Clock Event Device: lapic
> max_delta_ns:   671115476
> min_delta_ns:   1200
> mult:           53684938
> shift:          32
> mode:           3
> next_event:     843408000000 nsecs
> set_next_event: lapic_next_event
> set_mode:       lapic_timer_setup
> event_handler:  hrtimer_interrupt

At that point, these tasks were blocked:
>                          free                        sibling
>   task             PC    stack   pid father child younger older
> snmpd         D F3675E20  4860  3652      1 (NOTLB)
>        f3675e34 00200082 00000002 f3675e20 f3675e1c 00000000  
> f364e030 00000000
>        00000007 f364e030 e08a8ac0 000000ae 0000ef1d f364e13c  
> c1d0d280 00000000
>        00018ef7 c013dce6 000000ff 00000000 00000000 f3675e50  
> c038c320 00200246
> Call Trace:
> [<c02bab1f>] __mutex_lock_slowpath+0x167/0x298
> [<c02bac6c>] mutex_lock+0x1c/0x1f
> [<c025d993>] netdev_run_todo+0x13/0x204
> [<c02634f5>] rtnl_unlock+0x2f/0x31
> [<c025d7da>] dev_ioctl+0x3a5/0x46e
> [<c0252aad>] sock_ioctl+0x1be/0x1c9
> [<c0178e4e>] do_ioctl+0x22/0x67
> [<c01790e5>] vfs_ioctl+0x252/0x265
> [<c0179141>] sys_ioctl+0x49/0x64
> [<c0103ea0>] syscall_call+0x7/0xb
> =======================
> ntpdate       D EDC0BCA4  6004 14168      1 (NOTLB)
>        edc0bcb8 00200082 00000002 edc0bca4 edc0bca0 00000000  
> ee177570 00000000
>        0000000a ee177570 fcb9946b 000000ac 00023add ee17767c  
> c1d0d280 00000000
>        00018709 c013dce6 000000ff 00000000 00000000 edc0bcd4  
> c038c320 00200246
> Call Trace:
> [<c02bab1f>] __mutex_lock_slowpath+0x167/0x298
> [<c02bac6c>] mutex_lock+0x1c/0x1f
> [<c025d993>] netdev_run_todo+0x13/0x204
> [<c02634bc>] rtnetlink_rcv+0x38/0x42
> [<c0271a14>] netlink_data_ready+0x15/0x56
> [<c0270aef>] netlink_sendskb+0x1f/0x37
> [<c02713df>] netlink_unicast+0x1a8/0x1c2
> [<c02719f3>] netlink_sendmsg+0x264/0x270
> [<c025325a>] sock_sendmsg+0xe7/0x104
> [<c02534f4>] sys_sendto+0xcc/0xec
> [<c025414e>] sys_socketcall+0x14e/0x222
> [<c0103ea0>] syscall_call+0x7/0xb
> =======================
> vconfig       D EEF6BE24  6440 14440  14438 (NOTLB)
>        eef6be38 00000086 00000002 eef6be24 eef6be20 00000000  
> 00000000 c012bd4a
>        00000007 edcfca70 67a281c2 000000d3 00001336 edcfcb7c  
> c1d0d280 00000000
>        00022873 c012bd4a 000000ff 00000000 00000000 eef6be48  
> 000228b4 00022834
> Call Trace:
> [<c02ba23b>] schedule_timeout+0x70/0x8e
> [<c02ba26e>] schedule_timeout_uninterruptible+0x15/0x17
> [<c012bd65>] msleep+0x10/0x16
> [<c025da91>] netdev_run_todo+0x111/0x204
> [<c02634f5>] rtnl_unlock+0x2f/0x31
> [<f8b3494d>] vlan_ioctl_handler+0x60b/0x6d0 [8021q]
> [<c0252a40>] sock_ioctl+0x151/0x1c9
> [<c0178e4e>] do_ioctl+0x22/0x67
> [<c01790e5>] vfs_ioctl+0x252/0x265
> [<c0179141>] sys_ioctl+0x49/0x64
> [<c0103ea0>] syscall_call+0x7/0xb
> =======================

As the system continues to run more processes get stuck in the  
netdev_run_todo function waiting for vconfig to release a lock, while  
vconfig appears to be waiting in the kernel for its interfaces to  
lose reference counts, which they can't do as long as vconfig holds  
random locks.

