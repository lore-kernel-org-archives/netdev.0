From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Thu, 9 Feb 2017 19:33:06 -0800
Message-ID: <20170210033306.GA770@oracle.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
 <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        philip.pettersson@gmail.com, weongyo.linux@gmail.com,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/09/17 19:19), Eric Dumazet wrote:
> 
> More likely the bug is in fanout_add(), with a buggy sequence in error
> case, and not correct locking.
> 
> kfree(po->rollover);
> po->rollover = NULL;
> 
> Two cpus entering fanout_add() (using the same af_packet socket,
> syzkaller courtesy...) might both see po->fanout being NULL.
> 
> Then they grab the mutex.  Too late...

I'm not sure I follow- aiui the panic was in acceessing the
sk_receive_queue.lock in a socket that had been closed earlier. I think
the assumption is that rcu_read_lock_bh in __dev_queue_xmit (and
rcu_read_lock in dev_queue_xmit_nit?) should make sure that the nit
packet delivery can be done safely, and the synchronize_net in
packet_release() makes sure that the Tx paths are quiesced before freeing
the socket.  What is the race-hole here? Does it have to do with the
_bh and softirq context, somehow?

--Sowmini
