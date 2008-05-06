From: Ben Greear <greearb@candelatech.com>
Subject: Re: Detected Tx Unit Hang in ixgbe, kernel 2.6.25
Date: Tue, 06 May 2008 13:58:31 -0700
Message-ID: <4820C677.100@candelatech.com>
References: <48208F9D.1080608@candelatech.com> <36D9DB17C6DE9E40B059440DB8D95F52051AB2FF@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:49994 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757666AbYEFU7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:59:15 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52051AB2FF@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> Ben Greear wrote:
>> I'm using a 10Gbps copper(CX4) dual-port NIC from silicomusa.com.
>> It uses the Intel chipset and ixgbe driver.  I'm using
>> kernel 2.6.25 plus some hacks (no patches to ixgbe).
>>
>> This particular test case was to create 500 mac-vlans on
>> each of the two ports and generate UDP traffic between
>> them (I have a version of the send-to-self patch applied
>> to my kernel and enabled.)
>>
>> During the setup for this test, the interfaces would have
>> been bounced (effectively ifdown, ifup), so that is the
>> reason for the link going up and down.
>>
>> I noticed 90%+ drop rate when I first started the test,
>> and then after maybe 1-2 minutes, things calmed down and
>> started working.  I checked /var/log/messages and saw the
>> messages below.
> 
> do you have ipv6 enabled?  I've seen this behavior that if a port is
> flooded before the events/X thread finishes, lots of packets get dropped
> and the events/X thread takes a long time to complete.  Not sure if it
> is related.

It is enabled, though I wasn't particularly using it (on purpose).

> hm, snipped above to demonstrate my point.  These appear to be false
> hangs.  TDH is still moving (indicating the hardware is still processing
> packets.)  Do you have flow control enabled?  Can you try with fewer
> descriptors?  It is truly unlikely you need more than 512, usually.
> 
> The driver (incorrectly, will patch soon) defaults to flow control
> enabled.  I suggest you disable it with ethtool -A
> 
> You might be able to just comment out the detect_tx_hung variable being
> set, see if the problem goes away (false hang for sure then)

Ok, I also noticed that softirqd was at around 100% CPU (2 of them in fact, on
this 2 x 4-core system.  But, the NICs were not obviously transmitting
many packets (as determined by looking at the tx/rx packet counters).

In subsequent tests, I see softirqd CPU usage go quite high when adding
mac-vlans, before I ever start traffic.  But, other applications (ntp, etc)
do seem to listen for new devices and open sockets per interface and probably
attempt to send some frames.

Also, this is a 64-bit kernel, with 8GB RAM, in case that matters.

Finally, I hit this a bit later.  I have no idea of the root cause here...it
seems mac-vlans are implicated, but it could be something else.  It is tainted
by my module, but this module was supposedly not really doing anything.  I
will also run some more tests w/out it loaded.

BUG: soft lockup - CPU#7 stuck for 61s! [ksoftirqd/7:25]
CPU 7:
Modules linked in: arc4 michael_mic wanlink(P) e1000e e1000 8021q redirdev macvlan pktgen rfcomm l2cap bluetooth autofs4 nfs lockd nfs_acl sunrpc ipv6 loop dm_multipath i5000_edac edac_core iTCO_wdt ixgbe i2c_i801 i2c_core pcspkr button iTCO_vendor_support sg sr_mod cdrom floppy dm_snapshot dm_zero dm_mirror dm_mod ata_generic pata_acpi ata_piix libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ssb ehci_hcd [last unloaded: x_tables]
Pid: 25, comm: ksoftirqd/7 Tainted: P         2.6.25 #1
RIP: 0010:[<ffffffff8120163d>]  [<ffffffff8120163d>] skb_clone+0x5a/0x5e
RSP: 0018:ffff81022f207d98  EFLAGS: 00000202
RAX: ffff81012173f300 RBX: ffff81022f207da8 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff810131b0f168 RDI: ffff81012173f368
RBP: ffff81022f207d10 R08: ffff81012173f300 R09: ffff810131b0f100
R10: 0000000000000040 R11: 0000000000000000 R12: ffffffff8100cb56
R13: ffff81022f207d10 R14: ffff810131b0f100 R15: ffff81022d5b6000
FS:  0000000000000000(0000) GS:ffff81022f0b8c80(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007faf08544a90 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
  <IRQ>  [<ffffffff8120163d>] ? skb_clone+0x5a/0x5e
  [<ffffffff8827f54a>] ? :macvlan:macvlan_handle_frame+0x102/0x222
  [<ffffffff81094817>] ? add_partial+0x49/0x51
  [<ffffffff81206db1>] ? netif_receive_skb+0x346/0x4f3
  [<ffffffff88123ed2>] ? :ixgbe:ixgbe_clean_rx_irq+0x467/0x666
  [<ffffffff881266b7>] ? :ixgbe:ixgbe_clean_rxonly+0x4a/0xa4
  [<ffffffff8120931e>] ? net_rx_action+0xb0/0x1c6
  [<ffffffff8103a030>] ? __do_softirq+0x4a/0xa5
  [<ffffffff8103a3b8>] ? ksoftirqd+0x0/0x11e
  [<ffffffff8100d0ac>] ? call_softirq+0x1c/0x28
  <EOI>  [<ffffffff8100e978>] ? do_softirq+0x34/0x72
  [<ffffffff8103a41c>] ? ksoftirqd+0x64/0x11e
  [<ffffffff81048088>] ? kthread+0x49/0x79
  [<ffffffff8100cd38>] ? child_rip+0xa/0x12
  [<ffffffff8104803f>] ? kthread+0x0/0x79
  [<ffffffff8100cd2e>] ? child_rip+0x0/0x12

unregister_netdevice: waiting for eth3#352 to become free. Usage count = 3
unregister_netdevice: waiting for eth3#352 to become free. Usage count = 3
unregister_netdevice: waiting for eth3#352 to become free. Usage count = 3
unregister_netdevice: waiting for eth3#352 to become free. Usage count = 3
unregister_netdevice: waiting for eth3#352 to become free. Usage count = 3


I'll try disabling the flow-control, and if that doesn't help,
will compile out ipv6 and try that too.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

