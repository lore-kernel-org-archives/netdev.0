From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Wed, 10 Feb 2016 06:56:01 -0800
Message-ID: <1455116161.19473.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <230561650.749911455108197509.JavaMail.weblogic@epmlwas05a>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Maninder Singh <maninder1.s@samsung.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"willemb@google.com" <willemb@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"eyal.birger@gmail.com" <eyal.birger@gmail.com>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>,
	"fruggeri@aristanetworks.com" <fruggeri@aristanetworks.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>,
	Geon-ho Kim <gh007.kim@samsung.com>,
	Hak-Bong Lee <hakbong5.lee@samsung.com>,
	"ajeet.y@samsung.com" <ajeet.y@samsung.com>,
	AKHILESH KUMAR <akhilesh.k@samsung.com>,
	AMIT NAGAL <amit.nagal@samsung.com>
To: v.narang@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <230561650.749911455108197509.JavaMail.weblogic@epmlwas05a>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-10 at 12:43 +0000, Vaneet Narang wrote:
> Hi,
> 
> >What driver are you using (is that in-tree)? Can you reproduce the same issue
> >with a latest -net kernel, for example (or, a 'reasonably' recent one like 4.3 or
> >4.4)? There has been quite a bit of changes in err queue handling (which also
> >accounts rmem) as well. How reliably can you trigger the issue? Does it trigger
> >with a completely different in-tree network driver as well with your tests? Would
> >be useful to track/debug sk_rmem_alloc increases/decreases to see from which path
> >new rmem is being charged in the time between packet_release() and packet_sock_destruct()
> >for that socket ...
> >
> It seems race condition to us between packet_rcv and packet_close, we have tried to reproduce
> this issue by adding delay in skb_set_owner_r and issue gets reproduced quite frequently. 
> we have added some traces and on analyzing we have realised following possible race condition.



Even if you add a delay in skb_set_owner_r(), this should not allow the
dismantle phase to complete, since at least one cpu is still in a
rcu_read_lock() section.

synchronize_rcu() must complete only when all cpus pass an rcu quiescent
point.

packet_close() should certainly not be called while another cpu is still
in the middle of packet_rcv()

Your patch does not address the root cause.
