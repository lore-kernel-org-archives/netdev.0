From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Fri, 05 Feb 2016 03:26:57 -0800
Message-ID: <1454671617.7627.315.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453099068-39022-1-git-send-email-maninder1.s@samsung.com>
	 <569CB419.6050102@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maninder Singh <maninder1.s@samsung.com>, davem@davemloft.net,
	willemb@google.com, edumazet@google.com, eyal.birger@gmail.com,
	tklauser@distanz.ch, fruggeri@aristanetworks.com,
	dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pankaj.m@samsung.com,
	gh007.kim@samsung.com, hakbong5.lee@samsung.com,
	Vaneet Narang <v.narang@samsung.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <569CB419.6050102@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-18 at 10:44 +0100, Daniel Borkmann wrote:
> On 01/18/2016 07:37 AM, Maninder Singh wrote:
> > Receieve queue is not purged when socket dectruction is called
> > results in kernel warning because of non zero sk_rmem_alloc.
> >
> > WARNING: at net/packet/af_packet.c:1142 packet_sock_destruct
> >
> > Backtrace:
> > WARN_ON(atomic_read(&sk->sk_rmem_alloc)
> > packet_sock_destruct
> > __sk_free
> > sock_wfree
> > skb_release_head_state
> > skb_release_all
> > __kfree_skb
> > net_tx_action
> > __do_softirq
> > run_ksoftirqd
> >
> > Signed-off-by: Vaneet Narang <v.narang@samsung.com>
> > Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> 
> Thanks for the fix. While it fixes the WARN_ON(), I believe some more
> investigation is needed here on why it is happening:
> 
> We call first into packet_release(), which removes the socket hook from
> the kernel (unregister_prot_hook()), later calls synchronize_net() to
> make sure no more skbs will come in. The receive queue is purged right
> after the synchronize_net() already.
> 
> packet_sock_destruct() will be called afterwards, when there are no more
> refs on the socket anymore and no af_packet skbs in tx waiting for completion.
> Only then, in sk_destruct(), we'll call into packet_sock_destruct().
> 
> So, eventually double purging the sk_receive_queue seems not the right
> thing to do at first look, and w/o any deeper analysis in the commit description.
> 
> Could you look a bit further into the issue? Do you have a reproducer to
> trigger it?

So while synchronize_net() makes sure no packets can be delivered from
normal packet processing (through packet hook, if driver is not horribly
buggy (like delivering packets while IFF_UPP is not there...)), we still
might have some TX packet in a cpu completion_queue (fed in
dev_kfree_skb_irq())

This can happen if the cpu having these TX skbs had to schedule
ksoftirqd under stress. RCU quiescent period is ended before ksoftirqd
could perform its work.

If sock_queue_err_skb() is called from __skb_complete_tx_timestamp() at
the wrong time, we might get into this state.

sock_queue_err_skb() might need to be more careful ?
