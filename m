From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: RE: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 11:02:07 +0100
Message-ID: <1230544927.16718.12.camel@twins>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
	 <20081225112658.GA7260@gondor.apana.org.au>
	 <1230300535.9487.292.camel@twins>
	 <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com>
	 <1230410308.9487.295.camel@twins>
	 <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep16-int.chello.at ([62.179.121.36]:14871 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754705AbYL2KCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 05:02:04 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-12-27 at 17:54 -0700, Tantilov, Emil S wrote:
> Peter Zijlstra wrote:
> > On Sat, 2008-12-27 at 12:38 -0700, Tantilov, Emil S wrote:
> >> Peter Zijlstra wrote:
> >
> >>> index 9007ccd..a074d77 100644
> >>> --- a/include/linux/percpu_counter.h
> >>> +++ b/include/linux/percpu_counter.h
> >>> @@ -30,8 +30,16 @@ struct percpu_counter {
> >>>  #define FBC_BATCH    (NR_CPUS*4)
> >>>  #endif
> >>>
> >>> -int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
> >>> -int percpu_counter_init_irq(struct percpu_counter *fbc, s64
> >>> amount); +int __percpu_counter_init(struct percpu_counter *fbc, s64
> >>> amount, +                       struct lock_class_key *key); +
> >>> +#define percpu_counter_init(fbc, value)
> >>> \ +     do {
> >>> \ +             static struct lock_class_key __key;
> >>> \ +
> >>> \ +             __percpu_counter_init(fbc, value, &__key);
> >>> \ +     } while (0) +
> >>>  void percpu_counter_destroy(struct percpu_counter *fbc);
> >>>  void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
> >>>  void __percpu_counter_add(struct percpu_counter *fbc, s64 amount,
> >
> >> This patch fails to compile:
> >>
> >> mm/backing-dev.c: In function 'bdi_init':
> >> mm/backing-dev.c:226: error: expected expression bedore 'do'
> >
> > Ah indeed, stupid me...
> >
> > Please try something like this instead of the above hunk:
> >
> > @@ -30,8 +30,16 @@ struct percpu_counter {
> >  #define FBC_BATCH      (NR_CPUS*4)
> >  #endif
> >
> > -int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
> > -int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount);
> > +int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
> > +                         struct lock_class_key *key);
> > +
> > +#define percpu_counter_init(fbc, value)
> > \ +       ({
> > \ +               static struct lock_class_key __key;
> > \ +
> > \ +               __percpu_counter_init(fbc, value, &__key);
> > \ +       })
> > +
> >  void percpu_counter_destroy(struct percpu_counter *fbc);
> >  void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
> >  void __percpu_counter_add(struct percpu_counter *fbc, s64 amount,
> > s32 batch)
> 
> With this compiled, but I still get the following:
> 
> [  435.632627] =================================
> [  435.633030] [ INFO: inconsistent lock state ]
> [  435.633037] 2.6.28-rc8-net-next-igbL #14
> [  435.633040] ---------------------------------
> [  435.633044] inconsistent {in-softirq-W} -> {softirq-on-W} usage.
> [  435.633049] netperf/12669 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [  435.633053]  (key#8){-+..}, at: [<ffffffff803691ac>] __percpu_counter_add+0x4a/0x6d
> [  435.633068] {in-softirq-W} state was registered at:
> [  435.633070]   [<ffffffffffffffff>] 0xffffffffffffffff
> [  435.633078] irq event stamp: 988533
> [  435.633080] hardirqs last  enabled at (988533): [<ffffffff80243712>] _local_bh_enable_ip+0xc8/0xcd
> [  435.633088] hardirqs last disabled at (988531): [<ffffffff8024369e>] _local_bh_enable_ip+0x54/0xcd
> [  435.633093] softirqs last  enabled at (988532): [<ffffffff804fc814>] sock_orphan+0x3f/0x44
> [  435.633100] softirqs last disabled at (988530): [<ffffffff8056454d>] _write_lock_bh+0x11/0x3d
> [  435.633107]
> [  435.633108] other info that might help us debug this:
> [  435.633110] 1 lock held by netperf/12669:
> [  435.633112]  #0:  (sk_lock-AF_INET6){--..}, at: [<ffffffff804fc544>] lock_sock+0xb/0xd
> [  435.633119]
> [  435.633120] stack backtrace:
> [  435.633124] Pid: 12669, comm: netperf Not tainted 2.6.28-rc8-net-next-igbL #14
> [  435.633127] Call Trace:
> [  435.633134]  [<ffffffff8025ffb8>] print_usage_bug+0x159/0x16a
> [  435.633139]  [<ffffffff8026000e>] valid_state+0x45/0x52
> [  435.633143]  [<ffffffff802601cf>] mark_lock_irq+0x1b4/0x27b
> [  435.633148]  [<ffffffff80260339>] mark_lock+0xa3/0x110
> [  435.633152]  [<ffffffff80260480>] mark_irqflags+0xda/0xf2
> [  435.633157]  [<ffffffff8026122e>] __lock_acquire+0x1c3/0x2ee
> [  435.633161]  [<ffffffff80261d93>] lock_acquire+0x55/0x71
> [  435.633166]  [<ffffffff803691ac>] ? __percpu_counter_add+0x4a/0x6d
> [  435.633170]  [<ffffffff80564434>] _spin_lock+0x2c/0x38
> [  435.633175]  [<ffffffff803691ac>] ? __percpu_counter_add+0x4a/0x6d
> [  435.633179]  [<ffffffff803691ac>] __percpu_counter_add+0x4a/0x6d
> [  435.633184]  [<ffffffff804fc827>] percpu_counter_add+0xe/0x10
> [  435.633188]  [<ffffffff804fc837>] percpu_counter_inc+0xe/0x10
> [  435.633193]  [<ffffffff804fdc91>] tcp_close+0x157/0x2da
> [  435.633197]  [<ffffffff8051907e>] inet_release+0x58/0x5f
> [  435.633204]  [<ffffffff80527c48>] inet6_release+0x30/0x35
> [  435.633213]  [<ffffffff804c9354>] sock_release+0x1a/0x76
> [  435.633221]  [<ffffffff804c9804>] sock_close+0x22/0x26
> [  435.633229]  [<ffffffff802a345a>] __fput+0x82/0x110
> [  435.633234]  [<ffffffff802a381a>] fput+0x15/0x17
> [  435.633239]  [<ffffffff802a09c5>] filp_close+0x67/0x72
> [  435.633246]  [<ffffffff80240ae3>] close_files+0x66/0x8d
> [  435.633251]  [<ffffffff80240b39>] put_files_struct+0x19/0x42
> [  435.633256]  [<ffffffff80240b98>] exit_files+0x36/0x3b
> [  435.633260]  [<ffffffff80241eec>] do_exit+0x1b7/0x2b1
> [  435.633265]  [<ffffffff80242087>] sys_exit_group+0x0/0x14
> [  435.633269]  [<ffffffff80242099>] sys_exit_group+0x12/0x14
> [  435.633275]  [<ffffffff8020b9cb>] system_call_fastpath+0x16/0x1b

Afaict this is a real deadlock.

All the code around that percpu_counter_inc() in tcp_close() seems to
disabled softirqs, which suggests a softirq can really happen there.

So either we disable softirqs around the percpu op, or we move it a few
lines down, like:

---
Subject: net: fix tcp deadlock

Lockdep spotted that the percpu counter op takes a lock so that softirq
recursion deadlocks can occur. Delay the op until we've disabled
softirqs to avoid this.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/ipv4/tcp.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 564d3a9..03eddf1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1835,12 +1835,10 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	percpu_counter_inc(sk->sk_prot->orphan_count);
 
 	/* It is the last release_sock in its life. It will remove backlog. */
 	release_sock(sk);
 
-
 	/* Now socket is owned by kernel and we acquire BH lock
 	   to finish close. No need to check for user refs.
 	 */
@@ -1848,6 +1846,9 @@ adjudge_to_death:
 	bh_lock_sock(sk);
 	WARN_ON(sock_owned_by_user(sk));
 
+	/* account the orphan state now that we have softirqs disabled.  */
+	percpu_counter_inc(sk->sk_prot->orphan_count);
+
 	/* Have we already been destroyed by a softirq or backlog? */
 	if (state != TCP_CLOSE && sk->sk_state == TCP_CLOSE)
 		goto out;


