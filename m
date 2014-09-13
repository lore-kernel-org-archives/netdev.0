From: shakil A Khan <shakilk1729@gmail.com>
Subject: Re: [PATCH] Freeing dst when the reference count <0 causes general protection fault, it could be a major security flaw as rogue app can modify dst to crash kernel.
Date: Sat, 13 Sep 2014 11:35:26 -0700
Message-ID: <1723887.mNMu0nmDbO@localhost.localdomain>
References: <1410596833-2548-1-git-send-email-shakilk1729@gmail.com> <1410609022.7106.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410609022.7106.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 13, 2014 04:50:22 AM Eric Dumazet wrote:
> On Sat, 2014-09-13 at 01:27 -0700, Shakil A Khan wrote:
> > Signed-off-by: Shakil A Khan <shakilk1729@gmail.com>
> > ---
> > 
> >  net/core/dst.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/core/dst.c b/net/core/dst.c
> > index a028409..6a848b0 100644
> > --- a/net/core/dst.c
> > +++ b/net/core/dst.c
> > @@ -284,7 +284,10 @@ void dst_release(struct dst_entry *dst)
> > 
> >  		int newrefcnt;
> >  		
> >  		newrefcnt = atomic_dec_return(&dst->__refcnt);
> > 
> > -		WARN_ON(newrefcnt < 0);
> > +
> > +		if (WARN(newrefcnt < 0, "dst reference count less than zero"))
> > +			return;
> > +
> > 
> >  		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
> >  		
> >  			call_rcu(&dst->rcu_head, dst_destroy_rcu);
> >  	
> >  	}
> 
> A rogue application can not do trigger this, unless a major bug in the
> kernel exists.

Please check this kernel trace. It is able to crash the kernel.

general protection fault: 0000 [#1] PREEMPT SMP
Modules linked in: nfsv3 nfs_acl rpcsec_gss_krb5 auth_rpcgss oid_registry 
nfsv4 nfs fscache lockd sunrpc tun nbd ipmi_si ipmi_watchdog ipmi_devintf 
ipmi_msghandler xt_mark xt_owner ipt_MASQUERADE xt_physdev xt_state xt_LOG 
iptable_mangle iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat 
nf_conntrack iptable_filter ip_tables xen_acpi_processor xen_pciback 
xen_netback xen_blkback xen_gntalloc xen_gntdev xenfs xen_privcmd bridge stp 
llc ipv6 ext4 jbd2 freq_table mperf coretemp crc32c_intel ghash_clmulni_intel 
microcode pcspkr sb_edac edac_core lpc_ich mfd_core i2c_i801 sg ioatdma igb 
dca i2c_algo_bit i2c_core ptp pps_core ext3 jbd mbcache sd_mod crc_t10dif 
aesni_intel ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 ahci 
libahci isci libsas scsi_transport_sas megaraid_sas wmi dm_mirror 
dm_region_hash dm_log dm_mod [last unloaded: iTCO_vendor_support]
CPU: 6 PID: 15324 Comm: XXXX Not tainted 3.10.45-xen.322.17.41238 #1
Hardware name: McAfee, Inc. ATD-6000/S4600LH...., BIOS 
SE5C600.86B.02.01.0002.082220131453 08/22/2013
task: ffff882bc6255000 ti: ffff882bc61aa000 task.ti: ffff882bc61aa000
RIP: e030:[<ffffffff8148473f>]  [<ffffffff8148473f>] ipv4_dst_destroy+0x3b/0x77
RSP: e02b:ffff882bc61abb48  EFLAGS: 00010296
RAX: dead000000200200 RBX: ffff882bc625bc80 RCX: 0001338a9b7110db
RDX: dead000000100100 RSI: ffffffff82267e30 RDI: 00000000000003f4
RBP: ffff882bc61abb58 R08: 00000000d5d6df8b R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff820e5880 R14: ffff88070e584b80 R15: 0000000000000000
FS:  00007f8d3fff2700(0000) GS:ffff88081e6c0000(0000) knlGS:0000000000000000
CS:  e033 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000031d0e36ac0 CR3: 0000002db0165000 CR4: 0000000000042660
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffff882bc61abb58 ffff882bc625bc80 ffff882bc61abb88 ffffffff8145bfc5
 ffff882bc61abba8 ffff882bc625bc80 0000000000000000 ffff882bc625bc80
 ffff882bc61abba8 ffffffff8145c2c5 ffff88070e584b80 ffff882b991c2300
Call Trace:
 [<ffffffff8145bfc5>] dst_destroy+0x29/0xbd
 [<ffffffff8145c2c5>] dst_release+0x58/0x67
 [<ffffffff814ad539>] tcp_v4_do_rcv+0x11b/0x287
 [<ffffffff81443e24>] __release_sock+0x7c/0xe7
 [<ffffffff81443ebd>] release_sock+0x2e/0x7c
 [<ffffffff81499cdf>] tcp_sendmsg+0xe0/0xd41
 [<ffffffff814bf369>] inet_sendmsg+0x7d/0xa0
 [<ffffffff8143d794>] sock_aio_write+0x159/0x17d
 [<ffffffff81005859>] ? __raw_callee_save_xen_pmd_val+0x11/0x1e
 [<ffffffff8116d12b>] do_sync_write+0x7f/0xa7
 [<ffffffff8116d392>] ? rw_verify_area+0x56/0xd5
 [<ffffffff8116d555>] vfs_write+0x144/0x170
 [<ffffffff8116d977>] SyS_write+0x54/0x8f
 [<ffffffff810d078f>] ? __audit_syscall_exit+0x20c/0x29c
 [<ffffffff8151e959>] system_call_fastpath+0x16/0x1b
Code: fb 48 8d 87 b0 00 00 00 48 39 87 b0 00 00 00 74 4f 48 c7 c7 04 8f 3c 82 
e8 32 23 09 00 48 8b 93 b0 00 00 00 48 8b 83 b8 00 00 00 <48> 89 42 08 48 89 
10 48 b9 00 01 10 00 00 00 ad de 48 89 8b b0
RIP  [<ffffffff8148473f>] ipv4_dst_destroy+0x3b/0x77
 RSP <ffff882bc61abb48>
---[ end trace d56f90482c47af91 ]---
Kernel panic - not syncing: Fatal exception in interrupt

 
> 
> Instead of trying to hide the kernel bug, we need to fix it.
    There are two problems with this. First the list has somehow got out of 
sync in terms of number of delete and allocate, so we need to fix that.
But at the same time refcount if <0 signifies its been already freed so we need 
not free up.
We need fix for both and my patch targets later as my system works fine with 
this patch.
> 
> Can you describe how this could trigger with a pristine kernel ?
This is triggered with custom software to imitate malware traffic(Kernel was not 
having any custom patch whatsoever, it was a pristine kernel 3.10.45).
Point is if an application can crash this, then it would be big security flaw 
not exactly similar but like SSL love bug, which can be exploited to bring 
down systems.
