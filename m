From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: freeze with interface rename & SIOCGIFNAME
Date: Tue, 25 Jun 2013 09:15:51 -0700
Message-ID: <1372176951.3301.103.camel@edumazet-glaptop>
References: <51C9BB9C.4050405@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:59429 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3FYQPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 12:15:45 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so6907448eek.31
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 09:15:42 -0700 (PDT)
In-Reply-To: <51C9BB9C.4050405@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 17:47 +0200, Nicolas Schichan wrote:
> Hi,
> 
> I have been experiencing a kernel freeze during interface rename while another 
> process is doing SIOCGIFNAME.
> 
> I have a userland process that spins on SIOCGIFNAME with a valid ifindex.
> 
> I have also a shell script running:
> 
> ======
> vconfig add eth0 142
> while :; do
>        ip link set eth0.142 name renamed
>        ip link set renamed name eth0.142
> done
> ======
> 
> The vlan 142 on eth0 is here just to have an interface that I can freely rename.
> 
> Almost immediately after running the rename loop, all userland freezes (ssh 
> becomes unresponsive, no interactive program response on the serial console).
> 
> SysRq is still responsive though.
> 
> Output of SysRq + 'w':
> 
> ======
> [   28.405037] SysRq : Show Blocked State
> [   28.406037]   task                PC stack   pid father
> [   28.406037] kworker/u2:2    D 105b732e  6028   643      2 0x00000000
> [   28.406037] Workqueue: khelper __call_usermodehelper
> [   28.406037]  cf8b3e10 00000046 c1060c1e 105b732e 00000002 04c82810 00000006 
> c19f3580
> [   28.406037]  cfb00000 c19f3580 cfde6580 cf929950 cf986370 00000000 00000015 
> cf8b3df8
> [   28.406037]  c1061c14 cf9863b0 cf984a54 00000000 cf8b3df8 c1061e40 cfde65c8 
> cfde65f0
> [   28.406037] Call Trace:
> [   28.406037]  [<c1060c1e>] ? sched_clock_local+0xae/0x1a0
> [   28.406037]  [<c1061c14>] ? update_cfs_rq_blocked_load+0x164/0x1e0
> [   28.406037]  [<c1061e40>] ? __enqueue_entity+0x70/0x80
> [   28.406037]  [<c1064a0f>] ? enqueue_task_fair+0xc5f/0x11c0
> [   28.406037]  [<c16ba51e>] schedule+0x1e/0x50
> [   28.406037]  [<c16b872d>] schedule_timeout+0x15d/0x220
> [   28.406037]  [<c1060e5f>] ? sched_clock_cpu+0xdf/0x180
> [   28.406037]  [<c10fe774>] ? kmem_cache_alloc+0x24/0x100
> [   28.406037]  [<c106347c>] ? check_preempt_wakeup+0x16c/0x260
> [   28.406037]  [<c16ba10d>] wait_for_completion_killable+0x7d/0x100
> [   28.406037]  [<c105f180>] ? try_to_wake_up+0x220/0x220
> [   28.406037]  [<c10329ec>] do_fork+0x10c/0x2f0
> [   28.406037]  [<c16b99b9>] ? __schedule+0x349/0x760
> [   28.406037]  [<c104a1c0>] ? ____call_usermodehelper+0xf0/0xf0
> [   28.406037]  [<c1032bf8>] kernel_thread+0x28/0x30
> [   35.080945] SysRq : Show Blocked State
> [   35.081028]   task                PC stack   pid father
> [   35.081028] kworker/u2:2    D 105b732e  6028   643      2 0x00000000
> [   35.081028] Workqueue: khelper __call_usermodehelper
> [   35.081028]  cf8b3e10 00000046 c1060c1e 105b732e 00000002 04c82810 00000006 
> c19f3580
> [   35.081028]  cfb00000 c19f3580 cfde6580 cf929950 cf986370 00000000 00000015 
> cf8b3df8
> [   35.081028]  c1061c14 cf9863b0 cf984a54 00000000 cf8b3df8 c1061e40 cfde65c8 
> cfde65f0
> [   35.081028] Call Trace:
> [   35.081028]  [<c1060c1e>] ? sched_clock_local+0xae/0x1a0
> [   35.081028]  [<c1061c14>] ? update_cfs_rq_blocked_load+0x164/0x1e0
> [   35.081028]  [<c1061e40>] ? __enqueue_entity+0x70/0x80
> [   35.081028]  [<c1064a0f>] ? enqueue_task_fair+0xc5f/0x11c0
> [   35.081028]  [<c16ba51e>] schedule+0x1e/0x50
> [   35.081028]  [<c16b872d>] schedule_timeout+0x15d/0x220
> [   35.081028]  [<c1060e5f>] ? sched_clock_cpu+0xdf/0x180
> [   35.081028]  [<c10fe774>] ? kmem_cache_alloc+0x24/0x100
> [   35.081028]  [<c106347c>] ? check_preempt_wakeup+0x16c/0x260
> [   35.081028]  [<c16ba10d>] wait_for_completion_killable+0x7d/0x100
> [   35.081028]  [<c105f180>] ? try_to_wake_up+0x220/0x220
> [   35.081028]  [<c10329ec>] do_fork+0x10c/0x2f0
> [   35.081028]  [<c16b99b9>] ? __schedule+0x349/0x760
> [   35.081028]  [<c104a1c0>] ? ____call_usermodehelper+0xf0/0xf0
> [   35.081028]  [<c1032bf8>] kernel_thread+0x28/0x30
> [   35.081028]  [<c1049a3a>] __call_usermodehelper+0x2a/0x90
> [   35.081028]  [<c104cae7>] process_one_work+0x117/0x370
> [   35.081028]  [<c104c31d>] ? manage_workers.isra.24+0x1ad/0x260
> [   35.081028]  [<c104d109>] worker_thread+0xf9/0x310
> [   35.081028]  [<c104d010>] ? rescuer_thread+0x2a0/0x2a0
> [   35.081028]  [<c105249f>] kthread+0x8f/0xa0
> [   35.081028]  [<c1050000>] ? param_get_ulong+0x20/0x30
> [   35.081028]  [<c16c1a37>] ret_from_kernel_thread+0x1b/0x28
> [   35.081028]  [<c1052410>] ? kthread_create_on_node+0xc0/0xc0
> [   35.081028] ip              D cf929984  5676   850    845 0x00000000
> [   35.081028]  cfb7f960 00000082 94f4efa8 cf929984 cf984f64 04d6e8c2 00000006 
> c19f3580
> [   35.081028]  cf854000 c19f3580 cfde6580 cf984f30 cf848a20 c16c84c0 cfb7f928 
> c105d04a
> [   35.081028]  cf929950 cfde6580 cf929950 cfb7f940 c105d073 cfde6580 cf929950 
> cfde6580
> [   35.081028] Call Trace:
> [   35.081028]  [<c105d04a>] ? check_preempt_curr+0x6a/0x80
> [   35.081028]  [<c105d073>] ? ttwu_do_wakeup+0x13/0x100
> [   35.081028]  [<c16ba51e>] schedule+0x1e/0x50
> [   35.081028]  [<c16b872d>] schedule_timeout+0x15d/0x220
> [   35.081028]  [<c105f1ba>] ? wake_up_process+0x1a/0x30
> [   35.081028]  [<c104a579>] ? wake_up_worker+0x19/0x20
> [   35.081028]  [<c104bdc4>] ? insert_work+0x54/0x90
> [   35.081028]  [<c104c4cc>] ? __queue_work+0xfc/0x2a0
> [   35.081028]  [<c16b9eac>] wait_for_completion+0x6c/0xb0
> [   35.081028]  [<c105f180>] ? try_to_wake_up+0x220/0x220
> [   35.081028]  [<c10499b8>] call_usermodehelper_exec+0x108/0x130
> [   35.081028]  [<c1049d64>] call_usermodehelper+0x44/0x60
> [   35.081028]  [<c12389a4>] kobject_uevent_env+0x434/0x470
> [   35.081028]  [<c1237d2e>] kobject_rename+0xee/0x110
> [   35.081028]  [<c134eb30>] device_rename+0x90/0xb0
> [   35.081028]  [<c1538bf7>] dev_change_name+0x177/0x210
> [   35.081028]  [<c1545d11>] do_setlink+0x211/0x800
> [   35.081028]  [<c15450c4>] ? rtnl_fill_ifinfo+0x7a4/0x9f0
> [   35.081028]  [<c124deed>] ? nla_strlcpy+0x4d/0x60
> [   35.081028]  [<c1546989>] rtnl_newlink+0x369/0x550
> [   35.081028]  [<c1546491>] rtnetlink_rcv_msg+0x81/0x210
> [   35.081028]  [<c1100425>] ? __kmalloc_track_caller+0xa5/0x140
> [   35.081028]  [<c152af95>] ? skb_free_head+0x45/0x50
> [   35.081028]  [<c152d913>] ? __alloc_skb+0x63/0x250
> [   35.081028]  [<c1546410>] ? __rtnl_unlock+0x10/0x10
> [   35.081028]  [<c155b1fe>] netlink_rcv_skb+0x8e/0xa0
> [   35.081028]  [<c15435a7>] rtnetlink_rcv+0x17/0x20
> [   35.081028]  [<c155abe4>] netlink_unicast+0x134/0x1a0
> [   35.081028]  [<c155ae5d>] netlink_sendmsg+0x20d/0x370
> [   35.081028]  [<c152529a>] sock_sendmsg+0x8a/0xc0
> [   35.081028]  [<c1525539>] ___sys_sendmsg+0x269/0x270
> [   35.081028]  [<c1235b25>] ? cpumask_any_but+0x25/0x40
> [   35.081028]  [<c10d3e8e>] ? lru_cache_add_lru+0x1e/0x40
> [   35.081028]  [<c10f009c>] ? page_add_new_anon_rmap+0x6c/0xd0
> [   35.081028]  [<c10e761e>] ? do_wp_page+0x1de/0x650
> [   35.081028]  [<c10e928b>] ? handle_pte_fault+0x37b/0x680
> [   35.081028]  [<c1523ab0>] ? sockfd_lookup_light+0x20/0x70
> [   35.081028]  [<c15261c9>] __sys_sendmsg+0x39/0x70
> [   35.081028]  [<c1526211>] SyS_sendmsg+0x11/0x20
> [   35.081028]  [<c1526903>] SyS_socketcall+0x2d3/0x300
> [   35.081028]  [<c16bbdb0>] ? do_debug+0x160/0x160
> [   35.081028]  [<c16c1aba>] sysenter_do_call+0x12/0x22
> ======
> 
> kworker/u2:2 (pid 2) is seemingly trying to invoke /sbin/hotplug to notify 
> userland of the interface name change. It is waiting for the child process to 
> have invoked execve (vfork semantic is used here)
> 
> ip (pid 850) is waiting for kworker/u2:2 (pid 2) to have effectively invoked 
> /sbin/hotplug.
> 
> SysRq + p always shows the process spinning on SIOCGIFNAME ("gifname" here):
> 
> ======
> [  175.422073] SysRq : Show Regs
> [  175.422712] CPU: 0 PID: 844 Comm: gifname Not tainted 3.10.0-rc7+ #14
> [  175.423023] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS 
> VirtualBox 12/01/2006
> [  175.423023] task: cf986370 ti: cf808000 task.ti: cfb00000
> [  175.423023] EIP: 0060:[<c103ae2b>] EFLAGS: 00000206 CPU: 0
> [  175.423023] EIP is at __do_softirq+0x6b/0x1e0
> [  175.423023] EAX: 00000000 EBX: 00000000 ECX: fffff000 EDX: 00000002
> [  175.423023] ESI: cfde1640 EDI: 00000002 EBP: cfb01e3c ESP: cfb01e00
> [  175.423023]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [  175.423023] CR0: 80050033 CR2: 0807c634 CR3: 0fadf000 CR4: 000006d0
> [  175.423023] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [  175.423023] DR6: ffff0ff0 DR7: 00000400
> [  175.423023] Stack:
> [  175.423023]  00000028 cfde1b28 cfde1af8 cfde1ac8 00000003 d7f797b4 00406000 
> fffe1960
> [  175.423023]  00000000 0000000a 00000028 c18f7a00 00000000 cfde1640 fffffdfd 
> cfb01e44
> [  175.423023]  c103b0c5 cfb01e5c c10208d9 cfb01e64 00000001 00000001 c193ab00 
> cfb01ee8
> [  175.423023] Call Trace:
> [  175.423023]  [<c103b0c5>] irq_exit+0x85/0x90
> [  175.423023]  [<c10208d9>] smp_apic_timer_interrupt+0x59/0x90
> [  175.423023]  [<c16bb59d>] apic_timer_interrupt+0x2d/0x34
> [  175.423023]  [<c12400d8>] ? insn_get_opcode+0x8/0x170
> [  175.423023]  [<c1549397>] ? dev_ioctl+0x4b7/0x4c0
> [  175.423023]  [<c1523eb2>] sock_ioctl+0x72/0x280
> [  175.423023]  [<c1061d6e>] ? set_next_entity+0x9e/0xc0
> [  175.423023]  [<c1523e40>] ? sock_fasync+0x80/0x80
> [  175.423023]  [<c1112bf2>] do_vfs_ioctl+0x72/0x590
> [  175.423023]  [<c16b99b9>] ? __schedule+0x349/0x760
> [  175.423023]  [<c10208d9>] ? smp_apic_timer_interrupt+0x59/0x90
> [  175.423023]  [<c120b5d4>] ? security_file_ioctl+0x4/0x20
> [  175.423023]  [<c1113180>] SyS_ioctl+0x70/0x80
> [  175.423023]  [<c16c1aba>] sysenter_do_call+0x12/0x22
> [  175.423023] Code: 8b 15 40 0e 9f c1 64 a1 10 d0 9e c1 89 d7 89 45 e4 c7 45 
> e8 0a 00 00 00 64 c7 05 40 0e 9f c1 00 00 00 00 fb c7 45 f0 00 7a 8f c1 <eb> 
> 0b 8d 76 00 83 45 f0 04 d1 ef 74 6b f7 c7 01 00 00 00 74 f0
> ======
> 
> Looking at the disassembled code, location "dev_ioctl+0x4b7" seems to be the 
> inlined code for the function read_seqcount_begin(). Subsequent calls of SysRq 
> + w always show the same process being at the more or less the same location.
> 
> The read_seqcount_begin() is the one in dev_ifname() inlined in dev_ioctl().
> 
> The seqcoun_t structure taken by the read_seqcount_begin call is 
> devnet_rename_seq.
> 
> The platform is a VirtualBox x86 VM, but this is bug is also visible on a 
> platform with a Marvell 88f6282 CPU.
> 
> The kernel showing this behaviour is v3.10-rc7 (but this problem might have 
> been present in earlier versions).
> 
> The kernel configuration is an x86_defconfig, with SELinux disabled and with 
> vlan support enabled.
> 
> My understanding of that is that once the dev_ifname is trying to acquire the 
> devnet_rename_seq seqcount_t the kernel won't schedule to permit the do_fork() 
> call to finish.
> 
> I have been able to work-around this by replacing the read_seqcount_begin() 
> call with a raw_seqcount_begin() call and adding a cond_resched() call before 
> the "goto retry;" statement.
> 
> Here is a crude patch for that (the printk is here just for debug). If it is 
> an accepted solution I will submit a cleaner version with the appropriate 
> signed-off-by:
> 
> diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
> index 6cc0481..7f4fe2f 100644
> --- a/net/core/dev_ioctl.c
> +++ b/net/core/dev_ioctl.c
> @@ -31,7 +31,7 @@ static int dev_ifname(struct net *net, struct ifreq __user *arg)
>   		return -EFAULT;
> 
>   retry:
> -	seq = read_seqcount_begin(&devnet_rename_seq);
> +	seq = raw_seqcount_begin(&devnet_rename_seq);
>   	rcu_read_lock();
>   	dev = dev_get_by_index_rcu(net, ifr.ifr_ifindex);
>   	if (!dev) {
> @@ -41,8 +41,11 @@ retry:
> 
>   	strcpy(ifr.ifr_name, dev->name);
>   	rcu_read_unlock();
> -	if (read_seqcount_retry(&devnet_rename_seq, seq))
> +	if (read_seqcount_retry(&devnet_rename_seq, seq)) {
> +		printk("%s: dev_ifname: retry.\n", current->comm);
> +		cond_resched();
>   		goto retry;
> +	}
> 
>   	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
>   		return -EFAULT;
> 
> Regards,
> 

Nice catch !

Please add a helper so that we can use it as well from
sock_getbindtodevice(), and submit an official patch ?

int netdev_get_name(char *name, int ifindex)
{
	struct net_device *dev;
	unsigned int seq;

retry:
        seq = read_seqcount_begin(&devnet_rename_seq);
        rcu_read_lock();
        dev = dev_get_by_index_rcu(net, ifindex);
        if (!dev) {
                rcu_read_unlock();
                return -ENODEV;
        }

        strcpy(name, dev->name);
        rcu_read_unlock();
        if (read_seqcount_retry(&devnet_rename_seq, seq)) {
		cond_resched();
                goto retry;
	}
}


Thanks !
