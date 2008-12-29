From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 21:07:57 +1100
Message-ID: <20081229100757.GA9423@gondor.apana.org.au>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com> <20081225112658.GA7260@gondor.apana.org.au> <1230300535.9487.292.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com> <1230410308.9487.295.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57391 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751424AbYL2KII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 05:08:08 -0500
Content-Disposition: inline
In-Reply-To: <1230544927.16718.12.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2008 at 11:02:07AM +0100, Peter Zijlstra wrote:
>
> > [  435.633134]  [<ffffffff8025ffb8>] print_usage_bug+0x159/0x16a
> > [  435.633139]  [<ffffffff8026000e>] valid_state+0x45/0x52
> > [  435.633143]  [<ffffffff802601cf>] mark_lock_irq+0x1b4/0x27b
> > [  435.633148]  [<ffffffff80260339>] mark_lock+0xa3/0x110
> > [  435.633152]  [<ffffffff80260480>] mark_irqflags+0xda/0xf2
> > [  435.633157]  [<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
> > [  435.633161]  [<ffffffff80261d93>] lock_acquire+0x55/0x71
> > [  435.633166]  [<ffffffff803691ac>] ? __percpu_counter_add+0x4a/0x6d
> > [  435.633170]  [<ffffffff80564434>] _spin_lock+0x2c/0x38
> > [  435.633175]  [<ffffffff803691ac>] ? __percpu_counter_add+0x4a/0x6d
> > [  435.633179]  [<ffffffff803691ac>] __percpu_counter_add+0x4a/0x6d
> > [  435.633184]  [<ffffffff804fc827>] percpu_counter_add+0xe/0x10
> > [  435.633188]  [<ffffffff804fc837>] percpu_counter_inc+0xe/0x10
> > [  435.633193]  [<ffffffff804fdc91>] tcp_close+0x157/0x2da
> > [  435.633197]  [<ffffffff8051907e>] inet_release+0x58/0x5f
> > [  435.633204]  [<ffffffff80527c48>] inet6_release+0x30/0x35
> > [  435.633213]  [<ffffffff804c9354>] sock_release+0x1a/0x76
> > [  435.633221]  [<ffffffff804c9804>] sock_close+0x22/0x26
> > [  435.633229]  [<ffffffff802a345a>] __fput+0x82/0x110
> > [  435.633234]  [<ffffffff802a381a>] fput+0x15/0x17
> > [  435.633239]  [<ffffffff802a09c5>] filp_close+0x67/0x72
> > [  435.633246]  [<ffffffff80240ae3>] close_files+0x66/0x8d
> > [  435.633251]  [<ffffffff80240b39>] put_files_struct+0x19/0x42
> > [  435.633256]  [<ffffffff80240b98>] exit_files+0x36/0x3b
> > [  435.633260]  [<ffffffff80241eec>] do_exit+0x1b7/0x2b1
> > [  435.633265]  [<ffffffff80242087>] sys_exit_group+0x0/0x14
> > [  435.633269]  [<ffffffff80242099>] sys_exit_group+0x12/0x14
> > [  435.633275]  [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b
> 
> Afaict this is a real deadlock.

No this is the same case as before, i.e., a false positive.  The
only way we can call tcp_done in softirq context is if user-space
is not holding slock.  On the other hand, userspace never touches
the per-cpu counter without slock, QED.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
