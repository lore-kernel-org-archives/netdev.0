From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] af_packet: Raw socket destruction warning fix
Date: Wed, 10 Feb 2016 07:09:43 -0800
Message-ID: <1455116983.19473.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1455105900-15710-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, daniel@iogearbox.net,
	edumazet@google.com, al.drozdov@gmail.com, eyal.birger@gmail.com,
	tklauser@distanz.ch, fruggeri@aristanetworks.com,
	dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ajeet.y@samsung.com,
	pankaj.m@samsung.com, gh007.kim@samsung.com,
	hakbong5.lee@samsung.com, akhilesh.k@samsung.com,
	Vaneet Narang <v.narang@samsung.com>,
	Amit Nagal <amit.nagal@samsung.com>
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455105900-15710-1-git-send-email-maninder1.s@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-10 at 17:35 +0530, Maninder Singh wrote:
> This Patch fixes below warning:-
> WARNING: at net/packet/af_packet.c:xxx packet_sock_destruct
> 
> There is following race between packet_rcv and packet_close
> which keeps unfree packet in receive queue.
> 
> CPU 1					CPU2
> packet_rcv
> 
> 					packet_close                       
> skb_set_owner_r(skb, sk);
> 
> 					skb_queue_purge(&sk->sk_receive_queue);
> 
> spin_lock(&sk->sk_receive_queue.lock);
> __skb_queue_tail(&sk->sk_receive_queue, skb);
> spin_unlock(&sk->sk_receive_queue.lock);

This absolutely can not happen.

CPU 1 holds rcu read lock, so cpu 2 can not possibly call
skb_queue_purge()

(cpu 1 is blocked in synchronize_net(), waiting that all cpus are no
longer in packet_rcv())

This patch does not address the root cause of your problem, and only
slightly changes probability for the bug to trigger.
