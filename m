From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 04 Dec 2013 10:37:45 +0800
Message-ID: <529E9579.7090201@cn.fujitsu.com>
References: <529DE13D.2070509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Joe Perches <joe@perches.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:7177 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753776Ab3LDCvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 21:51:49 -0500
In-Reply-To: <529DE13D.2070509@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2013 09:48 PM, Ding Tianhong wrote:
> I have met the oops in Suse11 SP2, the kernel is 2.6.32.59-0.7-default:
> 
> [64306.089036] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> [64306.089343] IP: [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
> [64306.089535] PGD 0
> [64306.089706] Oops: 0000 [#1] SMP
> [64306.089935] last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/host0/target0:1:0/0:1:0:0/scsi_generic/sg0/dev
> [64306.090142] Die func triggered, code:1
> [64306.090147] CPU 1
> [64306.090258] Supported: Yes, External
> [64306.090262] Pid: 58359, comm: socknal_cd04 Tainted: P          N  2.6.32.59-0.7-default #1 T3500 G3
> [64306.090266] RIP: 0010:[<ffffffff812f8e36>]  [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
> [64306.090272] RSP: 0018:ffff880c273499d8  EFLAGS: 00010206
> [64306.090275] RAX: 0000000000000000 RBX: ffff8801cddf1500 RCX: ffff8801cddf14f2
> [64306.090278] RDX: 0000000000000000 RSI: ffff8805e40d3a28 RDI: ffff8801cddf1500
> [64306.090281] RBP: ffff8805e40d3a28 R08: ffff8801cddf1530 R09: ffff880c27349b17
> [64306.090284] R10: 000000000000000e R11: ffffffff812f8e22 R12: ffff880185c0e840
> [64306.090287] R13: 0000000000000000 R14: ffff8805e40d3a60 R15: 0000000003484560
> [64306.090291] FS:  00007f081210e700(0000) GS:ffff880036420000(0000) knlGS:0000000000000000
> [64306.090295] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [64306.090297] CR2: 0000000000000008 CR3: 0000000001804000 CR4: 00000000000406e0
> [64306.090301] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [64306.090304] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [64306.090308] Process socknal_cd04 (pid: 58359, threadinfo ffff880c27348000, task ffff880c25d02300)
> [64306.090310] Stack:
> [64306.090426]  ffffffff8131f8e0 0000000000000003 ffff8801c189eb40 000000000000000a
> [64306.090437] <0> ffffffff00000000 0000000000000002 ffff880c27349a30 ffffffffa304790c
> [64306.090444] <0> 0000000000000246 000051010a010000 ffffffff81318357 31312d3300007fff
> [64306.090450] <0> ffff880c27349bb8 0248456003484560 ffff8801c189eb40 ffffffff81869300
> [64306.090456] <0> ffff880185c0e840 ffff8801cddf1514 ffff8805e40d3a28 00000000000000d0
> [64306.090464] Call Trace:
> 
> --------------------------- cut here -------------------------------------
> 
> I found the NULL place int the neigh_timer_handler, the neigh->ops is NULL,
> so the calling of neigh->ops->solicit(neigh, skb) will panic, I found the
> neigh has been freed via the kdump, the so I think the neigh was kfreed while
> the neigh timer handler is running.
> 
> The situation is that there are several server in the local lan:
> A: 128.5.10.83
> B: 128.5.10.85
> C: 128.5.10.xx
> 
> I panic the A by manual, and set B's IP to 128.5.10.83, so send broadcast to tell
> the lan that B is 128.5.10.83, then the B panic, it is hard to appeared again, so
> I only met once.
> 
> I think the reason is that:
> 
> 	CPU0					CPU1
> 	-----					-----
> 						<SOFTIRQ>
> 						call_timer_fn();
> 						base->running_timer = neigh->timer;
> 						neigh_timer_handler();
> 	neigh_release();
> 	write_lock(&neigh->lock);
> 	del_timer(neigh->timer);
> 	write_unlock(&neigh->lock);
> 						write_lock(&neigh->lock);
> 	kfree(neigh);
>  						neigh->ops->solicit();
> 
> --------------------------------------------------------------------------
> 
> The reason is : besides deactivating the timer it also makes sure the handler
> has finished executing on other CPUs, But the del_timer() just only detach the
> timer and not wait for the timer finish executing on other CPUs.
> 

the neigh->timer has the reference to the neigh, and this reference is
released at the end of neigh_timer_handler. so the neigh should not be
freed before the timer handler finished.

As your description, some logic ignores the reference of neigh and calls
neigh_destroy directly.

You should find out the incorrect destroying of the neigh.

> According to the David's opinion, the del_timer_sync() should belongs in
> neigh_del_timer(), but the neigh_del_timer() will be called in
> write_lock(&neigh->lock), it will occur deadlock if the timer is calling the same
> lock, so del_timer_sync() should not be used in neigh_del_timer().
> 
> I fix the problem by add neigh->dead check in neigh_timer_handler(), because
> if the neigh is in release path, the neigh is already in dead state, if the
> timer is running on other CPUs, the timer will be finished and no problems
> will occur when kfree the neighbour.
> 
> I think the latest kernel still has the problem and make the patch for it.
> 
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  net/core/neighbour.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index ca15f32..38f3d23 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -888,6 +888,11 @@ static void neigh_timer_handler(unsigned long arg)
>  
>  	write_lock(&neigh->lock);
>  
> +	if (neigh->dead) {
> +		pr_warn("neighbour is dead and should be destroyed\n");
> +		goto out;
> +	}
> +
>  	state = neigh->nud_state;
>  	now = jiffies;
>  	next = now + HZ;
> 
