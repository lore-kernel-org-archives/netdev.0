From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: held lock freed! - request_sock_queue::rskq_lock
Date: Thu, 11 Feb 2016 15:54:54 -0800
Message-ID: <1455234894.18740.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOi1vP9b78Y7-ddcZna2xM+vST6iuw+RmRL+BxR3HQZKbaa0ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>
To: Ilya Dryomov <idryomov@gmail.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <CAOi1vP9b78Y7-ddcZna2xM+vST6iuw+RmRL+BxR3HQZKbaa0ZA@mail.gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-02-11 at 23:43 +0100, Ilya Dryomov wrote:
> Hi Eric,
> 
> I'm hitting the following splat (attached in full):
> 
> kernel: =========================
> kernel: [ BUG: held lock freed! ]
> kernel: 4.5.0-rc1-ceph-00026-g5e0a311 #1 Not tainted
> kernel: -------------------------
> kernel: swapper/5/0 is freeing memory
> ffff880035c9d200-ffff880035c9dbff, with a lock still held there!
> kernel: (&(&queue->rskq_lock)->rlock){+.-...}, at:
> [<ffffffff816f6a88>] inet_csk_reqsk_queue_add+0x28/0xa0
> kernel: 4 locks held by swapper/5/0:
> kernel: #0:  (rcu_read_lock){......}, at: [<ffffffff8169ef6b>]
> netif_receive_skb_internal+0x4b/0x1f0
> kernel: #1:  (rcu_read_lock){......}, at: [<ffffffff816e977f>]
> ip_local_deliver_finish+0x3f/0x380
> kernel: #2:  (slock-AF_INET){+.-...}, at: [<ffffffff81685ffb>]
> sk_clone_lock+0x19b/0x440
> kernel: #3:  (&(&queue->rskq_lock)->rlock){+.-...}, at:
> [<ffffffff816f6a88>] inet_csk_reqsk_queue_add+0x28/0xa0
> 
> The first couple of occurrences were on 4.4-rc2, a couple of recent ones
> on 4.5-rc1.  I'm suspecting your ebb516af60e1 ("tcp/dccp: fix race at
> listener dismantle phase") and/or a bunch of related commits before it,
> authored in the first half of Oct 2015.
> 
> The spinlock that lockdep complains about is embedded in
> inet_connection_sock, which I think is getting freed in
> inet_child_forget(), called from inet_csk_reqsk_queue_add():
> 
> inet_csk_complete_hashdance
>   inet_csk_reqsk_queue_add
>     spin_lock(&queue->rskq_lock)
>     inet_child_forget
>       reqsk_put
>         reqsk_free
>           sock_put(req->rsk_listener)
>           # rsk_listener is sk that queue is embedded in #
> 
> Your comment in inet_csk_complete_hashdance()
> 
>                 /* Warning: caller must not call reqsk_put(req);
>                  * child stole last reference on it.
>                  */
> 
> suggests that there is only one reference to req at that point in time
> and yet ebb516af60e1 added a reqsk_put() to that path: there was one in
> inet_csk_listen_stop() before, but not in inet_csk_reqsk_queue_add().
> 
> This is from a quick and dirty git blame analysis, so don't shout if
> all of it is wrong...
> 
> Thanks,

Nice catch !

It is a bit late here, I will take a look tomorrow, as it looks
definitely tricky ;)

inet_csk_reqsk_queue_add() should probably return a status.

Even tcp_child_process() looks racy in its access to
parent->sk_data_ready(parent) if parent got freed.

Thanks !



Thanks !
 

