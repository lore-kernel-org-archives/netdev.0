From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] ipvs: Remove unused variable ret from
 sync_thread_master()
Date: Tue, 12 Nov 2013 15:13:14 +0100
Message-ID: <20131112141314.GQ5056@laptop.programming.kicks-ass.net>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1384264396-14550-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 02:53:16PM +0100, Geert Uytterhoeven wrote:
> net/netfilter/ipvs/ip_vs_sync.c: In function 'sync_thread_master':
> net/netfilter/ipvs/ip_vs_sync.c:1640:8: warning: unused variable 'ret' [-Wunused-variable]
> 
> Introduced by commit 35a2af94c7ce7130ca292c68b1d27fcfdb648f6b ("sched/wait:
> Make the __wait_event*() interface more friendly")
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index f63c2388f38d..d258125c4202 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
>  			continue;
>  		}
>  		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
> -			int ret = __wait_event_interruptible(*sk_sleep(sk),

So ideally there's be a comment here why we're using interruptible but
then ignore interruptions.

Julian said (
http://lkml.kernel.org/r/alpine.LFD.2.00.1310012245020.1782@ja.ssi.bg ):

" Yes, your patch looks ok to me. In the past
we used ssleep() but IPVS users were confused why
IPVS threads increase the load average. So, we
switched to _interruptible calls and later the socket
polling was added.  "

So maybe add something like

			/*
			 * (Ab)use interruptible sleep to avoid increasing
			 * the load avg.
			 */

> +			__wait_event_interruptible(*sk_sleep(sk),
>  						   sock_writeable(sk) ||
>  						   kthread_should_stop());
>  			if (unlikely(kthread_should_stop()))
> -- 
> 1.7.9.5
> 
