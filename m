From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 11:16:17 +0100
Message-ID: <1230545777.16718.16.camel@twins>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
	 <20081225112658.GA7260@gondor.apana.org.au>
	 <1230300535.9487.292.camel@twins>
	 <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com>
	 <1230410308.9487.295.camel@twins>
	 <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com>
	 <1230544927.16718.12.camel@twins>
	 <20081229100757.GA9423@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([62.179.121.38]:28814 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750945AbYL2KQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 05:16:12 -0500
In-Reply-To: <20081229100757.GA9423@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-29 at 21:07 +1100, Herbert Xu wrote:
> On Mon, Dec 29, 2008 at 11:02:07AM +0100, Peter Zijlstra wrote:
> >
> > > [  435.633134]  [<ffffffff8025ffb8>] print_usage_bug+0x159/0x16a
> > > [  435.633139]  [<ffffffff8026000e>] valid_state+0x45/0x52
> > > [  435.633143]  [<ffffffff802601cf>] mark_lock_irq+0x1b4/0x27b
> > > [  435.633148]  [<ffffffff80260339>] mark_lock+0xa3/0x110
> > > [  435.633152]  [<ffffffff80260480>] mark_irqflags+0xda/0xf2
> > > [  435.633157]  [<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
> > > [  435.633161]  [<ffffffff80261d93>] lock_acquire+0x55/0x71
> > > [  435.633166]  [<ffffffff803691ac>] ? __percpu_counter_add+0x4a/0x6d
> > > [  435.633170]  [<ffffffff80564434>] _spin_lock+0x2c/0x38
> > > [  435.633175]  [<ffffffff803691ac>] ? __percpu_counter_add+0x4a/0x6d
> > > [  435.633179]  [<ffffffff803691ac>] __percpu_counter_add+0x4a/0x6d
> > > [  435.633184]  [<ffffffff804fc827>] percpu_counter_add+0xe/0x10
> > > [  435.633188]  [<ffffffff804fc837>] percpu_counter_inc+0xe/0x10
> > > [  435.633193]  [<ffffffff804fdc91>] tcp_close+0x157/0x2da
> > > [  435.633197]  [<ffffffff8051907e>] inet_release+0x58/0x5f
> > > [  435.633204]  [<ffffffff80527c48>] inet6_release+0x30/0x35
> > > [  435.633213]  [<ffffffff804c9354>] sock_release+0x1a/0x76
> > > [  435.633221]  [<ffffffff804c9804>] sock_close+0x22/0x26
> > > [  435.633229]  [<ffffffff802a345a>] __fput+0x82/0x110
> > > [  435.633234]  [<ffffffff802a381a>] fput+0x15/0x17
> > > [  435.633239]  [<ffffffff802a09c5>] filp_close+0x67/0x72
> > > [  435.633246]  [<ffffffff80240ae3>] close_files+0x66/0x8d
> > > [  435.633251]  [<ffffffff80240b39>] put_files_struct+0x19/0x42
> > > [  435.633256]  [<ffffffff80240b98>] exit_files+0x36/0x3b
> > > [  435.633260]  [<ffffffff80241eec>] do_exit+0x1b7/0x2b1
> > > [  435.633265]  [<ffffffff80242087>] sys_exit_group+0x0/0x14
> > > [  435.633269]  [<ffffffff80242099>] sys_exit_group+0x12/0x14
> > > [  435.633275]  [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
> > 
> > Afaict this is a real deadlock.
> 
> No this is the same case as before, i.e., a false positive.  The
> only way we can call tcp_done in softirq context is if user-space
> is not holding slock.  On the other hand, userspace never touches
> the per-cpu counter without slock, QED.

Its a protocol wide counter, therefore not protected by slock.

 sk1                          sk2

close()
  tcp_close()
    lock_sock(sk1)
    perpcu_counter_inc()
      spin_lock(sk1->sk_prot->orphan_count->lock);

          -----> softirq

                             bh_lock_sock(sk2)
                             percpu_counter_foo()
                               spin_lock(sk2->sk_prot->orphan_count->lock);

last time I checked that spelled deadlock.

Stop smoking crack -- its _NOT_ ok to let lockdep splats into mainline
without considerable effort to either fix or annotate them.

