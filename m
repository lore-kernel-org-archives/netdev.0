From: eran ben elisha <eranlinuxmellanox@gmail.com>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Add port attribute when
 tracking counters"
Date: Thu, 3 Sep 2015 15:09:55 +0300
Message-ID: <CAKHjkjkLK2TJiKTxZ17jb0YH=oT-mBdKoYNb9aRQJm_vme_KkA@mail.gmail.com>
References: <1440770776-27951-1-git-send-email-aik@ozlabs.ru>
	<CAJ3xEMjbTFSKxURSuqFsjQNS6gJfdvgwo4NfYPrv2PrkgCt5YQ@mail.gmail.com>
	<55E3BE76.60801@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Richard Yang <weiyang@linux.vnet.ibm.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f196.google.com ([209.85.212.196]:35592 "EHLO
	mail-wi0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830AbbICMJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 08:09:57 -0400
Received: by wibz8 with SMTP id z8so7890343wib.2
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 05:09:55 -0700 (PDT)
In-Reply-To: <55E3BE76.60801@ozlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2015 at 5:39 AM, Alexey Kardashevskiy <aik@ozlabs.ru> wrote:
> On 08/30/2015 04:28 PM, Or Gerlitz wrote:
>>
>> On Fri, Aug 28, 2015 at 7:06 AM, Alexey Kardashevskiy <aik@ozlabs.ru>
>> wrote:
>>>
>>> 68230242cdb breaks SRIOV on POWER8 system. I am not really suggesting
>>> reverting the patch, rather asking for a fix.
>>
>>
>> thanks for the detailed report, we will look into that.
>>
>> Just to be sure, when going back in time, what is the latest upstream
>> version where
>> this system/config works okay? is that 4.1 or later?
>
>
> 4.1 is good, 4.2 is not.
>
>
>
>>
>>>
>>> To reproduce it:
>>>
>>> 1. boot latest upstream kernel (v4.2-rc8 sha1 4941b8f, ppc64le)
>>>
>>> 2. Run:
>>> sudo rmmod mlx4_en mlx4_ib mlx4_core
>>> sudo modprobe mlx4_core num_vfs=4 probe_vf=4 port_type_array=2,2
>>> debug_level=1
>>>
>>> 3. Run QEMU (just to give a complete picture):
>>> /home/aik/qemu-system-ppc64 -enable-kvm -m 2048 -machine pseries \
>>> -nodefaults \
>>> -chardev stdio,id=id0,signal=off,mux=on \
>>> -device spapr-vty,id=id1,chardev=id0,reg=0x71000100 \
>>> -mon id=id2,chardev=id0,mode=readline -nographic -vga none \
>>> -initrd dhclient.cpio -kernel vml400bedbg \
>>> -device vfio-pci,id=id3,host=0003:03:00.1
>>> What guest is used does not matter at all.
>>>
>>> 4. Wait till guest boots and then run:
>>> dhclient
>>> This assigns IPs to both interfaces just fine. This is essential -
>>> if interface was not brought up since guest started, the bug does not
>>> appear.
>>> If interface was up and then down, this still causes the problem
>>> (less likely though).
>>>
>>> 5. Run in the guest: shutdown -h 0
>>> Guest prints:
>>> mlx4_en: eth0: Close port called
>>> mlx4_en: eth1: Close port called
>>> mlx4_core 0000:00:00.0: mlx4_shutdown was called
>>> And then the host hangs. After 10-30 seconds the host console prints:
>>> NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s!
>>> [qemu-system-ppc:5095]
>>> OR
>>> INFO: rcu_sched detected stalls on CPUs/tasks:
>>> or some other random stuff but always related to some sort of lockup.
>>> Backtraces are like these:
>>>
>>> [c000001e492a7ac0] [c000000000135b84]
>>> smp_call_function_many+0x2f4/0x3fable)
>>> [c000001e492a7b40] [c000000000135db8] kick_all_cpus_sync+0x38/0x50
>>> [c000001e492a7b60] [c000000000048f38] pmdp_huge_get_and_clear+0x48/0x70
>>> [c000001e492a7b90] [c00000000023181c] change_huge_pmd+0xac/0x210
>>> [c000001e492a7bf0] [c0000000001fb9e8] change_protection+0x678/0x720
>>> [c000001e492a7d00] [c000000000217d38] change_prot_numa+0x28/0xa0
>>> [c000001e492a7d30] [c0000000000e0e40] task_numa_work+0x2a0/0x370
>>> [c000001e492a7db0] [c0000000000c5fb4] task_work_run+0xe4/0x160
>>> [c000001e492a7e00] [c0000000000169a4] do_notify_resume+0x84/0x90
>>> [c000001e492a7e30] [c0000000000098b8] ret_from_except_lite+0x64/0x68
>>>
>>> OR
>>>
>>> [c000001def1b7280] [c000000ff941d368] 0xc000000ff941d368 (unreliable)
>>> [c000001def1b7450] [c00000000001512c] __switch_to+0x1fc/0x350
>>> [c000001def1b7490] [c000001def1b74e0] 0xc000001def1b74e0
>>> [c000001def1b74e0] [c00000000011a50c] try_to_del_timer_sync+0x5c/0x90
>>> [c000001def1b7520] [c00000000011a590] del_timer_sync+0x50/0x70
>>> [c000001def1b7550] [c0000000009136fc] schedule_timeout+0x15c/0x2b0
>>> [c000001def1b7620] [c000000000910e6c] wait_for_common+0x12c/0x230
>>> [c000001def1b7660] [c0000000000fa22c] up+0x4c/0x80
>>> [c000001def1b76a0] [d000000016323e60] __mlx4_cmd+0x320/0x940 [mlx4_core]
>>> [c000001def1b7760] [c000001def1b77a0] 0xc000001def1b77a0
>>> [c000001def1b77f0] [d0000000163528b4] mlx4_2RST_QP_wrapper+0x154/0x1e0
>>> [mlx4_core]
>>> [c000001def1b7860] [d000000016324934]
>>> mlx4_master_process_vhcr+0x1b4/0x6c0 [mlx4_core]
>>> [c000001def1b7930] [d000000016324170] __mlx4_cmd+0x630/0x940 [mlx4_core]
>>> [c000001def1b79f0] [d000000016346fec]
>>> __mlx4_qp_modify.constprop.8+0x1ec/0x350 [mlx4_core]
>>> [c000001def1b7ac0] [d000000016292228] mlx4_ib_destroy_qp+0xd8/0x5d0
>>> [mlx4_ib]
>>> [c000001def1b7b60] [d000000013c7305c] ib_destroy_qp+0x1cc/0x290 [ib_core]
>>> [c000001def1b7bb0] [d000000016284548]
>>> destroy_pv_resources.isra.14.part.15+0x48/0xf0 [mlx4_ib]
>>> [c000001def1b7be0] [d000000016284d28] mlx4_ib_tunnels_update+0x168/0x170
>>> [mlx4_ib]
>>> [c000001def1b7c20] [d0000000162876e0]
>>> mlx4_ib_tunnels_update_work+0x30/0x50 [mlx4_ib]
>>> [c000001def1b7c50] [c0000000000c0d34] process_one_work+0x194/0x490
>>> [c000001def1b7ce0] [c0000000000c11b0] worker_thread+0x180/0x5a0
>>> [c000001def1b7d80] [c0000000000c8a0c] kthread+0x10c/0x130
>>> [c000001def1b7e30] [c0000000000095a8] ret_from_kernel_thread+0x5c/0xb4
>>>
>>> i.e. may or may not mention mlx4.
>>> The issue may not happen on a first try but maximum on the second.
>>
>>
>> so when you revert commit 68230242cdb on the host all works just fine?
>> what guest driver are you running?
>
>
> To be precise, I did checkout 68230242cdb, checked that it does not work,
> then reverted 68230242cdb right there and checked that it works. I did not
> try reverting later revisions yet.
>
> My guest kernel in this test has tag v4.0. I get the same effect with some
> 3.18 from Ubuntu 14.04 LTS so the guest kernel version does not make a
> difference afaict.
>
>
>> This needs a fix, I don't think the right thing to do is just go and
>> revert the commit, if the right fix misses 4.2 we will get it there
>> through -stable
>
>
> v4.2 was just released :)
>
>
> --
> Alexey

Hi Alexey,
So far, I failed to reproduce the issue on my setup. However, I found
a small error flow bug. can you please try to reproduce with this
patch.
BTW, are you using CX3/CX3pro or CX2?

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 731423c..f377550 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -905,8 +905,10 @@ static int handle_existing_counter(struct
mlx4_dev *dev, u8 slave, int port,

        spin_lock_irq(mlx4_tlock(dev));
        r = find_res(dev, counter_index, RES_COUNTER);
-   if (!r || r->owner != slave)
-           ret = -EINVAL;
+ if (!r || r->owner != slave) {
+         spin_unlock_irq(mlx4_tlock(dev));
+         return -EINVAL;
+ }
        counter = container_of(r, struct res_counter, com);
        if (!counter->port)
                counter->port = port;


--
Thanks,
Eran
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
