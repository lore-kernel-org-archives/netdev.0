From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Sudden kernel panic with skge in 3.3-rc2
Date: Wed, 8 Feb 2012 11:32:23 -0500
Message-ID: <20120208163223.GA873@elliptictech.com>
References: <20120202192115.GA8480@elliptictech.com>
 <20120202124529.3e274223@s6510.linuxnetplumber.net>
 <20120203192832.GA19248@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120203192832.GA19248@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-02-03 14:28 -0500, Nick Bowler wrote:
> On 2012-02-02 12:45 -0800, Stephen Hemminger wrote:
> > On Thu, 2 Feb 2012 14:21:15 -0500
> > Nick Bowler <nbowler@elliptictech.com> wrote:
> > > I just saw this panic on 3.3-rc2 with skge.  I don't know whether it's
> > > reproducible yet -- the machine crashed while I was not actively using
> > > it.  We've had this type of card for a few years and I've never seen this
> > > before so it may be a regression, but admittedly we don't use them all
> > > that often.
> [...]
> > 
> > Try reverting this commit, it seems problematic
> > commit d0249e44432aa0ffcf710b64449b8eaa3722547e
> > Author: stephen hemminger <shemminger@vyatta.com>
> > Date:   Thu Jan 19 14:37:18 2012 +0000
> > 
> >     skge: check for PCI dma mapping errors
> 
> Thanks for the pointer, I'll try that.  Unfortunately some other stuff
> has come up so I probably won't be able to test it until next week.

Just to confirm: I can reliably reproduce the crash and reverting that
commit fixes it.

For reference, I captured the full trace over serial console:

  skge 0000:03:01.0: eth1: enabling interface
  ADDRCONF(NETDEV_UP): eth1: link is not ready
  skge 0000:03:01.0: eth1: Link is up at 1000 Mbps, full duplex, flow control none
  ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
  device eth1 entered promiscuous mode
  BUG: unable to handle kernel NULL pointer dereference at           (null)
  IP: [<ffffffffa001826e>] skge_poll+0x367/0x5cd [skge]
  PGD 0 
  Oops: 0000 [#1] PREEMPT SMP 
  CPU 0 
  Modules linked in: nfs lockd auth_rpcgss nfs_acl sunrpc autofs4 acpi_cpufreq mperf deflate zlib_deflate ctr aes_x86_64 aes_generic des_generic cbc sha512_generic sha256_generic sha1_ssse3 sha1_generic md5 hmac crypto_null af_key ipv6 loop snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_pcm snd_seq snd_timer snd_seq_device snd soundcore skge snd_page_alloc sky2 evdev i2c_i801
  
  Pid: 10, comm: kworker/0:1 Not tainted 3.3.0-rc2+ #10 LENOVO 0841A5U/LENOVO
  RIP: 0010:[<ffffffffa001826e>]  [<ffffffffa001826e>] skge_poll+0x367/0x5cd [skge]
  RSP: 0018:ffff88007f403e00  EFLAGS: 00010246
  RAX: ffff880079e3bc40 RBX: ffff88007baf3600 RCX: 0000000000000046
  RDX: ffff88007bddaf00 RSI: 0000000000000000 RDI: ffff880079e3bc40
  RBP: ffff88007f403e70 R08: 0000000000000300 R09: ffffffff812d7e11
  R10: ffff880079eb7200 R11: ffff88007baf3600 R12: ffff88007baf3000
  R13: ffff88007ae98208 R14: ffff880079eb7200 R15: 0000000000000046
  FS:  0000000000000000(0000) GS:ffff88007f400000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
  CR2: 0000000000000000 CR3: 000000007ae4d000 CR4: 00000000000406f0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
  Process kworker/0:1 (pid: 10, threadinfo ffff88007bca8000, task ffff88007c87c260)
  Stack:
   ffff88007c870600 ffff88007f403e18 ffff88007c870600 897488007f403e58
   0000004600000040 ffff88007baf3600 0046000000000001 ffff88007baf3610
   0000000000000000 ffff88007baf3610 ffff88007f411380 0000000000000000
  Call Trace:
   <IRQ> 
   [<ffffffff812e432c>] net_rx_action+0xaa/0x1c0
   [<ffffffff8102fe91>] __do_softirq+0x7e/0x125
   [<ffffffff8135ecb7>] ? _raw_spin_unlock+0x26/0x31
   [<ffffffff8136092c>] call_softirq+0x1c/0x30
   [<ffffffff8100411b>] do_softirq+0x33/0x68
   [<ffffffff8102fc7f>] irq_exit+0x3f/0xb9
   [<ffffffff81003a20>] do_IRQ+0x97/0xae
   [<ffffffff8135f02b>] common_interrupt+0x6b/0x6b
   <EOI> 
   [<ffffffff8135ed02>] ? _raw_spin_unlock_irq+0xd/0x32
   [<ffffffff8103ea56>] worker_thread+0x24b/0x255
   [<ffffffff8103e80b>] ? manage_workers+0x190/0x190
   [<ffffffff81041f31>] kthread+0x84/0x8c
   [<ffffffff81360834>] kernel_thread_helper+0x4/0x10
   [<ffffffff81041ead>] ? kthread_freezable_should_stop+0x6b/0x6b
   [<ffffffff81360830>] ? gs_change+0xb/0xb
  Code: 48 8b 40 30 48 85 c0 74 0a b9 02 00 00 00 4c 89 fa ff d0 49 8b 86 d0 00 00 00 49 8b 55 10 8b 4d b4 48 89 c7 48 8b b2 d0 00 00 00 <f3> a4 31 ff 48 8b 03 49 8b 75 18 48 8b 40 08 48 85 c0 74 13 48 
  RIP  [<ffffffffa001826e>] skge_poll+0x367/0x5cd [skge]
   RSP <ffff88007f403e00>
  CR2: 0000000000000000
  ---[ end trace 13c07164f6f205a2 ]---
  Kernel panic - not syncing: Fatal exception in interrupt
  panic occurred, switching back to text console

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
