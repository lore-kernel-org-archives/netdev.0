From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v3 0/10] bonding: rebuild the lock use for bond
 monitor
Date: Mon, 11 Nov 2013 22:01:45 +0800
Message-ID: <5280E349.4090800@gmail.com>
References: <5280CF34.20703@huawei.com> <20131111130617.GY19702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59444 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab3KKOMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 09:12:42 -0500
Received: by mail-pd0-f174.google.com with SMTP id z10so5263296pdj.19
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 06:12:42 -0800 (PST)
In-Reply-To: <20131111130617.GY19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/11 21:06, Veaceslav Falico =E5=86=99=E9=81=93:
> On Mon, Nov 11, 2013 at 08:36:04PM +0800, Ding Tianhong wrote:
>> Now the bond slave list is not protected by bond lock, only by RTNL,
>> but the monitor still use the bond lock to protect the slave list,
>> it is useless, according to the Veaceslav's opinion, there were
>> three way to fix the protect problem:
>>
>> 1. add bond_master_upper_dev_link() and bond_upper_dev_unlink()
>> in bond->lock, but it is unsafe to call call_netdevice_notifiers()
>> in write lock.
>> 2. remove unused bond->lock for monitor function, only use the exist
>> rtnl lock(), it will take performance loss in fast path.
>> 3. use RCU to protect the slave list, of course, performance is bett=
er,
>> but in slow path, it is ignored.
>>
>> obviously the solution 1 is not fit here, I will consider the 2 and =
3
>> solution. My principle is simple, if in fast path, RCU is better,
>> otherwise in slow path, both is well, but according to the Jay=20
>> Vosburgh's
>> opinion, the monitor will loss performace if use RTNL to protect the=
 all
>> slave list, so remove the bond lock and replace with RCU.
>>
>> The second problem is the curr_slave_lock for bond, it is too old an=
d
>> unwanted in many place, because the curr_active_slave would only be
>> changed in 3 place:
>>
>> 1. enslave slave.
>> 2. release slave.
>> 3. change active slave.
>>
>> all above were already holding bond lock, RTNL and curr_slave_lock
>> together, it is tedious and no need to add so mach lock, when change
>> the curr_active_slave, you have to hold the RTNL and curr_slave_lock
>> together, and when you read the curr_active_slave, RTNL or=20
>> curr_slave_lock,
>> any one of them is no problem.
>
> Boot-test *with the same parameters as before* gave me the following
> trace[1], which is inevitable in case of mode 1 bonding. So that you'=
ve
> either ignored this warning or didn't actually test mode 1, even thou=
gh
> your last patchset was reverted because of a regression in the same m=
ode.
>
> How was this tested?
>
yes, you are right, it is my fault. I miss a CONFIG SET for RCU,=20
CONFIG_PROVE_RCU,
althrough I test bond several times for every mode, but I still miss it=
=2E

The bond_should_notify_peers in bond_select_active_slave did not in hav=
e=20
rcu-read
critical sector.

> And btw - net-next is closed.
>
yes, I know, but I still need widely solicited opinions, it is really a=
=20
big patchset for me.
I am afraid of missing something.

Regards.
Ding

> [1]:
> [ 13.847032] bonding: bond0: link status definitely up for interface=20
> eth2.
> [ 13.848732] bonding: bond0: making interface eth2 the new active one=
=2E
> [ 13.850429] device eth2 entered promiscuous mode
> [ 13.852168] [ 13.853833] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ 13.855410] [ INFO: suspicious RCU usage. ]
> [ 13.857017] 3.12.0-bond+ #314 Tainted: G I [ 13.858690]=20
> -------------------------------
> [ 13.860404] drivers/net/bonding/bond_main.c:818 suspicious=20
> rcu_dereference_check() usage!
> [ 13.862006] [ 13.862006] other info that might help us debug this:
> [ 13.862006] [ 13.866334] [ 13.866334] rcu_scheduler_active =3D 1,=20
> debug_locks =3D 0
> [ 13.869296] 4 locks held by kworker/u8:3/57:
> [ 13.870841] #0: (%s#4){.+.+..}, at: [<ffffffff810cfec9>]=20
> process_one_work+0x189/0x580
> [ 13.872353] #1: ((&(&bond->arp_work)->work)){+.+...}, at:=20
> [<ffffffff810cfec9>] process_one_work+0x189/0x580
> [ 13.873967] #2: (rtnl_mutex){+.+.+.}, at: [<ffffffff8169e765>]=20
> rtnl_trylock+0x15/0x20
> [ 13.875569] #3: (&bond->curr_slave_lock){++.+..}, at:=20
> [<ffffffffa00b922e>] bond_ab_arp_commit+0x12e/0x200 [bonding]
> [ 13.877167] [ 13.877167] stack backtrace:
> [ 13.880287] CPU: 1 PID: 57 Comm: kworker/u8:3 Tainted: G I=20
> 3.12.0-bond+ #314
> [ 13.882011] Hardware name: Hewlett-Packard HP xw4600=20
> Workstation/0AA0h, BIOS 786F3 v01.15 08/28/2008
> [ 13.883585] Workqueue: bond0 bond_activebackup_arp_mon [bonding]
> [ 13.885011] 0000000000000001 ffff880079e89be8 ffffffff817a9df8=20
> 0000000000000002
> [ 13.886564] ffff880079e80000 ffff880079e89c18 ffffffff81128d23=20
> ffff8800790d4b40
> [ 13.888179] ffff88007980a400 ffff8800790d4bb8 ffff8800790d4b40=20
> ffff880079e89c38
> [ 13.889837] Call Trace:
> [ 13.891417] [<ffffffff817a9df8>] dump_stack+0x59/0x81
> [ 13.892881] [<ffffffff81128d23>] lockdep_rcu_suspicious+0x103/0x140
> [ 13.894290] [<ffffffffa00b8b61>] bond_should_notify_peers+0xb1/0x110=
=20
> [bonding]
> [ 13.895686] [<ffffffffa00b8e59>] bond_change_active_slave+0x299/0x37=
0=20
> [bonding]
> [ 13.897118] [<ffffffffa00b9027>] bond_select_active_slave+0xf7/0x1d0=
=20
> [bonding]
> [ 13.898672] [<ffffffffa00b9236>] bond_ab_arp_commit+0x136/0x200=20
> [bonding]
> [ 13.900165] [<ffffffffa00bb98d>]=20
> bond_activebackup_arp_mon+0x10d/0x340 [bonding]
> [ 13.901709] [<ffffffffa00bb8d3>] ?=20
> bond_activebackup_arp_mon+0x53/0x340 [bonding]
> [ 13.903125] [<ffffffff810cff3a>] process_one_work+0x1fa/0x580
> [ 13.904554] [<ffffffff810cfec9>] ? process_one_work+0x189/0x580
> [ 13.906023] [<ffffffff810d231f>] worker_thread+0x11f/0x3a0
> [ 13.907506] [<ffffffff810d2200>] ? manage_workers+0x170/0x170
> [ 13.908931] [<ffffffff810dbdfe>] kthread+0xee/0x100
> [ 13.910327] [<ffffffff8112d99b>] ? __lock_release+0x13b/0x1b0
> [ 13.911677] [<ffffffff810dbd10>] ? __init_kthread_worker+0x70/0x70
> [ 13.913082] [<ffffffff817ba16c>] ret_from_fork+0x7c/0xb0
> [ 13.914478] [<ffffffff810dbd10>] ? __init_kthread_worker+0x70/0x70
> [ 13.915860] bonding: bond0: first active interface up!
> [ 13.917294] bridge0: port 1(bond0) entered forwarding state
> [ 13.918632] bridge0: port 1(bond0) entered forwarding state
> [ 14.017018] bonding: bond0: link status definitely up for interface=20
> eth0.
>


>>
>> for the stability, I did not change the logic for the monitor,
>> all change is clear and simple, I have test the patch set for lockde=
p,
>> it work well and stability.
>>
>> v2. accept the Jay Vosburgh's opinion, remove the RTNL and replace=20
>> with RCU,
>> also add some rcu function for bond use, so the patch set reach 10.
>>
>> v3. accept the Nikolay Aleksandrov's opinion, remove no needed=20
>> bond_has_slave_rcu(),
>> add protection for several 3ad mode handler functions and=20
>> current_arp_slave.
>> rebuild the bond_first_slave_rcu(), make it more clear.
>>
>> Best Regards
>> Ding Tianhong
>>
>> Ding Tianhong (10):
>> bonding: remove the no effect lock for bond_select_active_slave()
>> bonding: rebuild the lock use for bond_mii_monitor()
>> bonding: rebuild the lock use for bond_alb_monitor()
>> bonding: rebuild the lock use for bond_loadbalance_arp_mon()
>> bonding: create bond_first_slave_rcu()
>> bonding: rebuild the lock use for bond_activebackup_arp_mon()
>> bonding: rebuild the lock use for bond_3ad_state_machine_handler()
>> bonding: remove unwanted lock for bond_option_active_slave_set()
>> bonding: remove unwanted lock for bond enslave and release
>> bonding: remove unwanted lock for bond_store_primaryxxx()
>>
>> drivers/net/bonding/bond_3ad.c | 53 +++++++------
>> drivers/net/bonding/bond_alb.c | 34 +++------
>> drivers/net/bonding/bond_main.c | 147=20
>> ++++++++++++++++---------------------
>> drivers/net/bonding/bond_options.c | 2 -
>> drivers/net/bonding/bond_sysfs.c | 4 -
>> drivers/net/bonding/bonding.h | 9 +++
>> include/linux/netdevice.h | 16 ++++
>> net/core/dev.c | 16 ----
>> 8 files changed, 132 insertions(+), 149 deletions(-)
>>
>> --=20
>> 1.8.2.1
>>
>>
>>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
