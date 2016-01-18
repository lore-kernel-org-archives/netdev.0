From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Mon, 18 Jan 2016 12:08:44 +0100
Message-ID: <569CC7BC.9090606@iogearbox.net>
References: <1385051583.176751453111860930.JavaMail.weblogic@ep2mlwas01a>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
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
	Hak-Bong Lee <hakbong5.lee@samsung.com>
To: v.narang@samsung.com, Maninder Singh <maninder1.s@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385051583.176751453111860930.JavaMail.weblogic@ep2mlwas01a>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/18/2016 11:11 AM, Vaneet Narang wrote:
> Hi,
>
>>> __do_softirq
>>> run_ksoftirqd
>>>
>>> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
>>> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
>
>> Thanks for the fix. While it fixes the WARN_ON(), I believe some more
>> investigation is needed here on why it is happening:
>>
>> We call first into packet_release(), which removes the socket hook from
>> the kernel (unregister_prot_hook()), later calls synchronize_net() to
>> make sure no more skbs will come in. The receive queue is purged right
>> after the synchronize_net() already.
>>
>> packet_sock_destruct() will be called afterwards, when there are no more
>> refs on the socket anymore and no af_packet skbs in tx waiting for completion.
>> Only then, in sk_destruct(), we'll call into packet_sock_destruct().
>>
>> So, eventually double purging the sk_receive_queue seems not the right
>> thing to do at first look, and w/o any deeper analysis in the commit description.
>>
>> Could you look a bit further into the issue? Do you have a reproducer to
>> trigger it?
>
> It is Suspend Resume scenario and in this case close(sock_id) is
> not called and hence packet_release is also not called.
> In case of suspend, driver power down its ethernet port and release all the
> sk_buff stored in RX and TX ring. driver calls dev_kfree_skb_any to release all
> the sk_buff in tx ring and if last tx buff of socket is called then
> packet_sock_destruct() will be invoked and will result in warning if and recevive sk_buff is
> still in receive queue.

Hmm, not quite. See 2b85a34e911b ("net: No more expensive sock_hold()/sock_put()
on each tx") on how it is supposed to work.

See packet_create(): sk_alloc() inits sk_wmem_alloc to 1, sock_init_data() sets
sk_refcnt to 1. sock_hold()/__sock_put() pair in packet sock is managed when we
register/unregister proto hooks.

The other sock_put() in packet_release() to drop the final ref and call into
sk_free(), which drops the 1 ref on the sk_wmem_alloc from init time. Since you
got into __sk_free() via sock_wfree() destructor, your socket must have invoked
packet_release() prior to this (perhaps kernel destroying the process).

What kernel do you use?

> Driver calls dev_kfree_skb_any->dev_kfree_skb_irq
> and it adds buffer in completion queue to free and raises softirq NET_TX_SOFTIRQ
>
> net_tx_action->__kfree_skb->skb_release_all->skb_release_head_state->sock_wfree->
> __sk_free->packet_sock_destruct
>
> Also purging of receive queue has been taken care in other protocols.
> // IP protocol
> void inet_sock_destruct(struct sock *sk)
> {
>          struct inet_sock *inet = inet_sk(sk);
>
>          __skb_queue_purge(&sk->sk_receive_queue);   // Purge Receive queue
>          __skb_queue_purge(&sk->sk_error_queue);
>
> ....
>
>           WARN_ON(atomic_read(&sk->sk_rmem_alloc));
>          WARN_ON(atomic_read(&sk->sk_wmem_alloc));
>   }
>
> So i think it should be done in Raw sockets also.
>
>>> ---
>>>    net/packet/af_packet.c |    1 +
>>>    1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index 81b4b81..bcb37ba 100644
>
> Thanks
> Vaneet Narang
>
