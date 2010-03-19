From: Ed Ravin <eravin@panix.com>
Subject: Re: recent e100 fixes cause kernel panic?
Date: Fri, 19 Mar 2010 16:46:00 -0400
Message-ID: <20100319204600.GA5259@panix.com>
References: <12968172.251031268372359953.JavaMail.root@tahiti.vyatta.com>
	<1269027740.3029.33.camel@jbrandeb-mobl3.amr.corp.intel.com>
	<20100319131639.733c53bf@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, roger.oksanen@cs.helsinki.fi
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20100319131639.733c53bf@nehalam>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Mar 19, 2010 at 01:16:39PM -0700, Stephen Hemminger wrote:
> On Fri, 19 Mar 2010 12:42:20 -0700
> Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:
> 
> > Added netdev, the place to talk about in-kernel driver problems.
> > 
> > On Thu, 2010-03-11 at 22:39 -0700, Stephen Hemminger wrote:
> > > ----- "Ed Ravin" <eravin@panix.com> wrote:
> > > 
> > > > I'm using the Vyatta "kenwood" Linux distribution, which is currently
> > > > at 2.6.31-1.  I upgraded to their latest version, and began seeing
> > > > kernel
> > > > panics shortly after starting to use ssh/scp on the network connected
> > > > to
> > > > an e100 NIC.  I was able to reproduce the problem immediately after
> > > > booting up - sometimes it even crashed during the boot.
> > > > 
> > > > One of the crash logs is attached.
> > 
> > Ed, thanks for the report, looks like these patches introduced a new
> > problem.  e100 hardware has a tricky data structure that seems to cause
> > some problems for (particularly arm) some cpu architectures.
> > 
> > > > 
> > > > Since the problem seemed to be related to e100.c, I reverted the two
> > > > commits to e100.c that had taken place since I last built the kernel
> > > > for this box:
> > > > 
> > > >   Author: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
> > > >   Date:   Fri Dec 18 20:18:21 2009 -0800
> > > >   e100: Fix broken cbs accounting due to missing memset.
> > > > 
> > > >   Author: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
> > > >   Date:   Sun Nov 29 17:17:29 2009 -0800
> > > >   e100: Use pci pool to work around GFP_ATOMIC order 5 memory
> > > > allocation failu
> > > > 
> > > > I rebuilt the kernel and it's not panicking anymore.
> > 
> > so you just reverted both, and its good news things are working again,
> > but can you try one or the other and let us know if things still break
> > for you?
> > 
> > > The Vyatta kernel for 2.6.31 is based on the 2.6.31.10 + unionfs.
> > > These two patches came from the 2.6.31.10 -stable update.
> > 
> > This is the only report of this issue I have heard so far, so something
> > must be a little unique to your system or workload such that the driver
> > works mostly.
> > 
> > I'm looking more closely into the panic trace now, maybe I can figure it
> > out from there.
> > 
> 
> Davem found one thing, the memset wasn't initializing the whole maximum possible
> tx ring.

I think that was it.  Good catch!

I was running "ethtool -G rx 4096 tx 512" at startup on all the interfaces
in the system.  That was meant for the e1000 / e1000e NICs, but it ended
up also getting run on the e100 in my elderly test box.  This appears to be
the equivalent of setting the e100 rings to their maximum sizes of 256 for
both rx and tx.

I haven't had the chance yet to try the patch.

But I did reboot back to the buggy kernel and ran:

   ethtool -G rx 128 tx 128 eth1

I then copied a 150 MB file via scp back and forth, no problems.  Usually
I'd get the panic as soon as I started heavy data transfer, sometimes
sooner.

I then ran 'ethtool -G rx 256 tx 256 eth1" and started the scp again -
instant panic.  Trace below.

------------------
# ethtool -G eth1 rx 256 tx 256
# [  239.331360] BUG: unable to handle kernel NULL pointer
dereference at (null)
[  239.335284] IP: [<(null)>] (null)
[  239.335284] *pde = 00000000 
[  239.335284] Thread overran stack, or stack corrupted
[  239.335284] Oops: 0000 [#1] SMP 
[  239.335284] last sysfs file: /sys/class/i2c-adapter/i2c-0/name
[  239.335284] Modules linked in: ip_gre xt_comment iptable_nat
iptable_filter ip6table_filter ip6table_raw ip6_tables xt_NOTRACK
iptable_raw ip_tables x_tables nf_nat_pptp nf_conntrack_pptp
nf_conntrack_proto_gre nf_nat_h323 nf_conntrack_h323 nf_nat_sip
nf_conntrack_sip nf_nat_proto_gre nf_nat_tftp nf_nat_ftp nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_tftp nf_conntrack_ftp
nf_conntrack ipv6 pcspkr parport_pc parport button processor i2c_viapro
i2c_core via_agp shpchp pci_hotplug agpgart evdev vfat fat ext2 battery
ohci_hcd ehci_hcd squashfs loop unionfs ext3 jbd mbcache raid6_pq async_xor
async_memcpy async_tx xor md_mod sg sr_mod sd_mod cdrom crc_t10dif
usb_storage pata_via pata_acpi ata_generic pata_pdc202xx_old uhci_hcd
libata usbcore e100 mii nls_base e1000 scsi_mod thermal fan thermal_sys
[last unloaded: raid10]
[  239.335284] 
[  239.335284] Pid: 0, comm: swapper Tainted: G        W
(2.6.31-1-586-vyatta #1) System Name
[  239.335284] EIP: 0060:[<00000000>] EFLAGS: 00010016 CPU: 0
[  239.335284] EIP is at 0x0
[  239.335284] EAX: ef441c20 EBX: ef441c20 ECX: 00000001 EDX: 00000001
[  239.335284] ESI: fffffff4 EDI: 00000001 EBP: 00000000 ESP: c12d1dd4
[  239.335284]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  239.335284] Process swapper (pid: 0, ti=c12d0000 task=c12febc0
task.ti=c12d0000)
[  239.335284] Stack:
[  239.335284]  c101c590 000000c1 00000001 efe04eb4 00000282 efe04eb0
000000c1 00000001
[  239.335284] <0> c101e86c 00000001 000000c1 00000001 efe04eb0 f66d0940
f66d0940 f66d0940
[  239.335284] <0> c1199d84 000000c1 f66d32e0 00000000 c11d646e 036ac000
f66d32e0 f66ac000
[  239.335284] Call Trace:
[  239.335284]  [<c101c590>] ? __wake_up_common+0x34/0x59
[  239.335284]  [<c101e86c>] ? __wake_up_sync_key+0x33/0x49
[  239.335284]  [<c1199d84>] ? sock_def_readable+0x34/0x5e
[  239.335284]  [<c11d646e>] ? tcp_child_process+0x46/0x83
[  239.335284]  [<c11d5191>] ? tcp_v4_do_rcv+0x240/0x2a1
[  239.335284]  [<c11d5592>] ? tcp_v4_rcv+0x3a0/0x594
[  239.335284]  [<c11be22e>] ? ip_local_deliver_finish+0xca/0x14e
[  239.335284]  [<c11bdeb5>] ? ip_rcv_finish+0x295/0x2a9
[  239.335284]  [<c11a3168>] ? netif_receive_skb+0x3cb/0x3e6
[  239.335284]  [<f7cefafb>] ? e100_poll+0x184/0x29d [e100]
[  239.335284]  [<c11a36b9>] ? net_rx_action+0x91/0x173
[  239.335284]  [<c102e431>] ? __do_softirq+0xa5/0x147
[  239.335284]  [<c102e4f6>] ? do_softirq+0x23/0x27
[  239.335284]  [<c102e5d3>] ? irq_exit+0x26/0x53
[  239.335284]  [<c10043fd>] ? do_IRQ+0x78/0x89
[  239.335284]  [<c1002fe9>] ? common_interrupt+0x29/0x30
[  239.335284]  [<c10085ae>] ? default_idle+0x3e/0x5c
[  239.335284]  [<c1001c5c>] ? cpu_idle+0x41/0x5d
[  239.335284]  [<c132e744>] ? start_kernel+0x29c/0x29f
[  239.335284] Code:  Bad EIP value.
[  239.335284] EIP: [<00000000>] 0x0 SS:ESP 0068:c12d1dd4
[  239.335284] CR2: 0000000000000000
[  239.335284] ---[ end trace 4eaa2a86a8e2da24 ]---
[  239.335284] Kernel panic - not syncing: Fatal exception in interrupt
[  239.335284] Pid: 0, comm: swapper Tainted: G      D W
2.6.31-1-586-vyatta #1
[  239.335284] Call Trace:
[  239.335284]  [<c120bee2>] ? panic+0x38/0xd1
[  239.335284]  [<c100581c>] ? oops_end+0x6c/0x76
[  239.335284]  [<c1017f6a>] ? no_context+0x105/0x10e
[  239.335284]  [<c101809b>] ? __bad_area_nosemaphore+0x128/0x133
[  239.335284]  [<c11a3bb8>] ? dev_hard_start_xmit+0x205/0x298
[  239.335284]  [<c11bc136>] ? ip_route_output_flow+0x72/0x1ad
[  239.335284]  [<c11df3e1>] ? inet_sk_rebuild_header+0x18/0x387
[  239.335284]  [<c10180b0>] ? bad_area_nosemaphore+0xa/0xc
[  239.335284]  [<c120dac6>] ? error_code+0x66/0x70
[  239.335284]  [<c10181ce>] ? do_page_fault+0x0/0x270
[  239.335284]  [<c101c590>] ? __wake_up_common+0x34/0x59
[  239.335284]  [<c101e86c>] ? __wake_up_sync_key+0x33/0x49
[  239.335284]  [<c1199d84>] ? sock_def_readable+0x34/0x5e
[  239.335284]  [<c11d646e>] ? tcp_child_process+0x46/0x83
[  239.335284]  [<c11d5191>] ? tcp_v4_do_rcv+0x240/0x2a1
[  239.335284]  [<c11d5592>] ? tcp_v4_rcv+0x3a0/0x594
[  239.335284]  [<c11be22e>] ? ip_local_deliver_finish+0xca/0x14e
[  239.335284]  [<c11bdeb5>] ? ip_rcv_finish+0x295/0x2a9
[  239.335284]  [<c11a3168>] ? netif_receive_skb+0x3cb/0x3e6
[  239.335284]  [<f7cefafb>] ? e100_poll+0x184/0x29d [e100]
[  239.335284]  [<c11a36b9>] ? net_rx_action+0x91/0x173
[  239.335284]  [<c102e431>] ? __do_softirq+0xa5/0x147
[  239.335284]  [<c102e4f6>] ? do_softirq+0x23/0x27
[  239.335284]  [<c102e5d3>] ? irq_exit+0x26/0x53
[  239.335284]  [<c10043fd>] ? do_IRQ+0x78/0x89
[  239.335284]  [<c1002fe9>] ? common_interrupt+0x29/0x30
[  239.335284]  [<c10085ae>] ? default_idle+0x3e/0x5c
[  239.335284]  [<c1001c5c>] ? cpu_idle+0x41/0x5d
[  239.335284]  [<c132e744>] ? start_kernel+0x29c/0x29f
[  239.335284] Rebooting in 60 seconds..

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
