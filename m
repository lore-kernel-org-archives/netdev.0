From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Wed, 22 Aug 2012 13:13:46 +0200
Message-ID: <1345634026.5158.1084.camel@edumazet-glaptop>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52902 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098Ab2HVLNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 07:13:52 -0400
Received: by bkwj10 with SMTP id j10so248825bkw.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 04:13:50 -0700 (PDT)
In-Reply-To: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 12:53 +0200, Sylvain Munaut wrote:
> Hi again, a bit more detail:
> 
> > I'm trying to use the netconsole to feed kernel message to the outside
> > but this lead to a stall ...
> >
> > This only happens in a fairly specific configuration where you have a
> > bridge over vlan over bonding.
> > I tested with only (bridge over vlan) and (vlan over bonding) and
> > those work fine.
> >
> > [snip ... see original mail for all details]
> 
> I was previously testing under Xen.
> 
> For this round of test, I tried the kernel natively. And I also
> included Dave Miller pending series ( e0e3cea4... ) since there was
> patch related to netconsole and bridging / ...
> So in the end, it's a 3.6-rc2 + Dave Miller tree (commit  e0e3cea4 ) +
> pf malloc patch  + ip pmtu patch from Eric Dumazet.
> 
> I am now seeing more debug when I load netconsole in that config:
> 
> [   88.705138] netpoll: netconsole: local port 8888
> [   88.705140] netpoll: netconsole: local IP 10.208.1.30
> [   88.705141] netpoll: netconsole: interface 'mgmt'
> [   88.705142] netpoll: netconsole: remote port 8000
> [   88.705143] netpoll: netconsole: remote IP 10.208.1.3
> [   88.705144] netpoll: netconsole: remote ethernet address 00:16:3e:1a:37:37
> [   88.705469] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000008
> [   88.705475] IP: [<ffffffffa0006653>] bnx2_start_xmit+0x20b/0x539 [bnx2]
> [   88.705476] PGD 0
> [   88.705478] Oops: 0002 [#1] PREEMPT SMP
> [   88.705509] Modules linked in: netconsole(+) configfs nfsd
> auth_rpcgss nfs_acl nfs lockd fscache sunrpc bridge 8021q garp stp llc
> bonding ext2 iTCO_wdt iTCO_vendor_support lpc_ich mfd_core coretemp
> joydev kvm evdev crc32c_intel ghash_clmulni_intel aesni_intel
> aes_x86_64 aes_generic acpi_power_meter psmouse serio_raw dcdbas
> processor ablk_helper i7core_edac pcspkr cryptd edac_core microcode
> button hid_generic ext4 crc16 jbd2 mbcache dm_mod raid10 raid456
> async_raid6_recov async_memcpy async_pq async_xor xor async_tx
> raid6_pq raid1 raid0 multipath linear md_mod sr_mod usbhid cdrom hid
> ses sd_mod enclosure crc_t10dif usb_storage ata_generic pata_acpi uas
> uhci_hcd megaraid_sas ata_piix ehci_hcd libata usbcore scsi_mod
> usb_common bnx2
> [   88.705511] CPU 2
> [   88.705512] Pid: 3017, comm: modprobe Not tainted
> 3.6.0-rc2-00092-g9040592-dirty #6 Dell Inc. PowerEdge R610/0F0XJ6
> [   88.705515] RIP: 0010:[<ffffffffa0006653>]  [<ffffffffa0006653>]
> bnx2_start_xmit+0x20b/0x539 [bnx2]
> [   88.705516] RSP: 0018:ffff88061e8fda28  EFLAGS: 00010002
> [   88.705517] RAX: 0000000000000000 RBX: ffff8803200f2300 RCX: 0000000000000000
> [   88.705519] RDX: 0000000320a95c02 RSI: 0000000000000003 RDI: ffff8800cb36f000
> [   88.705519] RBP: ffff88031f814000 R08: 0000000000000054 R09: 0000000000000000
> [   88.705520] R10: 000000000000ffff R11: 0000000000000000 R12: ffff8803215d52c0
> [   88.705521] R13: ffff8803210e13c0 R14: 0000000000010008 R15: 0000000000000000
> [   88.705522] FS:  00007fe9d0854700(0000) GS:ffff88062fc20000(0000)
> knlGS:0000000000000000
> [   88.705523] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   88.705524] CR2: 0000000000000008 CR3: 0000000619ccb000 CR4: 00000000000007e0
> [   88.705525] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   88.705526] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   88.705528] Process modprobe (pid: 3017, threadinfo
> ffff88061e8fc000, task ffff8806205e8000)
> [   88.705528] Stack:
> [   88.705530]  ffff88062ffecd80 0000000320a95c02 0000000000000054
> ffffffff00000000
> [   88.705532]  0000000000000041 ffff8803215d55f8 ffff88031f8167d8
> ffffffff00000000
> [   88.705534]  0000000000000000 0000000100000000 ffff88062ffedb08
> ffff8803200f2300
> [   88.705534] Call Trace:
> [   88.705542]  [<ffffffff81280a76>] ? netpoll_send_skb_on_dev+0x201/0x31d
> [   88.705546]  [<ffffffffa007fc4c>] ? bond_dev_queue_xmit+0x62/0x7f [bonding]
> [   88.705549]  [<ffffffffa0084588>] ? bond_3ad_xmit_xor+0xe7/0x10c [bonding]
> [   88.705552]  [<ffffffffa007fffd>] ? bond_start_xmit+0x394/0x3ff [bonding]
> [   88.705554]  [<ffffffff81280a76>] ? netpoll_send_skb_on_dev+0x201/0x31d
> [   88.705558]  [<ffffffffa004afd5>] ?
> vlan_dev_hard_start_xmit+0xab/0xf6 [8021q]
> [   88.705559]  [<ffffffff81280a76>] ? netpoll_send_skb_on_dev+0x201/0x31d
> [   88.705564]  [<ffffffffa00938e8>] ? __br_deliver+0x93/0xbe [bridge]
> [   88.705567]  [<ffffffffa009237d>] ? br_dev_xmit+0x14a/0x16b [bridge]
> [   88.705569]  [<ffffffff81280a76>] ? netpoll_send_skb_on_dev+0x201/0x31d
> [   88.705570]  [<ffffffff81280372>] ? find_skb.isra.23+0x31/0x78
> [   88.705572]  [<ffffffff81280bbe>] ? netpoll_send_skb+0x2c/0x39
> [   88.705574]  [<ffffffffa00a222a>] ? write_msg+0x98/0xf3 [netconsole]
> [   88.705579]  [<ffffffff81037db2>] ?
> call_console_drivers.constprop.17+0x6e/0x7d
> [   88.705580]  [<ffffffff81038248>] ? console_unlock+0x2ab/0x351
> [   88.705582]  [<ffffffff81039112>] ? register_console+0x273/0x303
> [   88.705584]  [<ffffffffa00fa182>] ? init_netconsole+0x182/0x210 [netconsole]
> [   88.705586]  [<ffffffffa00fa000>] ? 0xffffffffa00f9fff
> [   88.705588]  [<ffffffff81002085>] ? do_one_initcall+0x75/0x12c
> [   88.705590]  [<ffffffff81077b35>] ? sys_init_module+0x80/0x1c5
> [   88.705593]  [<ffffffff813319b9>] ? system_call_fastpath+0x16/0x1b
> [   88.705606] Code: 41 c1 e1 10 48 89 d6 48 6b c8 18 48 c1 e0 04 48
> c1 ee 20 49 03 8c 24 50 03 00 00 45 09 c8 44 89 4c 24 38 c7 44 24 24
> 00 00 00 00 <48> 89 51 08 48 89 19 49 03 84 24 48 03 00 00 89 50 04 44
> 89 f2
> [   88.705608] RIP  [<ffffffffa0006653>] bnx2_start_xmit+0x20b/0x539 [bnx2]
> [   88.705609]  RSP <ffff88061e8fda28>
> [   88.705609] CR2: 0000000000000008
> [   88.705611] ---[ end trace 24b75fe520341c20 ]---
> [   88.705985] note: modprobe[3017] exited with preempt_count 6
> [   88.706135] Dead loop on virtual device mgmt, fix it urgently!
> [   88.706201] Dead loop on virtual device mgmt, fix it urgently!
> [  148.557967] INFO: rcu_preempt detected stalls on CPUs/tasks: {}
> (detected by 0, t=60002 jiffies)
> [  148.557967] INFO: Stall ended before state dump start
> [  328.112761] INFO: rcu_preempt detected stalls on CPUs/tasks: {}
> (detected by 2, t=240007 jiffies)
> [  328.112761] INFO: Stall ended before state dump start
> 
> 
> And when trying on another machine that has Intel network cards, it
> just completely freezes the machine ... nothing even gets printed on
> the screen or anywhere I can see.
> 
> Also note that this also doesn't work in 3.5.1 so it's not a new
> behavior. 3.2.x don't support netconsole over vlan at all so can't
> test on it.
> 
> Cheers,
> 
>   

Could be the infamous slave_dev_queue_mapping striking again.

Could you please try :

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 346b1eb..df731a0 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -335,8 +335,11 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	/* don't get messages out of order, and no recursion */
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
+		int queue_index = skb_get_queue_mapping(skb);
 
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		if (queue_index >= dev->real_num_tx_queues)
+			queue_index = 0;
+		txq = netdev_get_tx_queue(dev, queue_index);
 
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
