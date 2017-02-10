From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Fri, 10 Feb 2017 10:00:43 -0800
Message-ID: <CAM_iQpWtFo80Z5yDn1Mf6bcZg+OWCyeq98WF7t+bwxGOuSjXpA@mail.gmail.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
 <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com> <20170210033306.GA770@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Philip Pettersson <philip.pettersson@gmail.com>,
        weongyo.linux@gmail.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34589 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751993AbdBJSIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:08:22 -0500
In-Reply-To: <20170210033306.GA770@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 7:33 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/09/17 19:19), Eric Dumazet wrote:
>>
>> More likely the bug is in fanout_add(), with a buggy sequence in error
>> case, and not correct locking.
>>
>> kfree(po->rollover);
>> po->rollover = NULL;
>>
>> Two cpus entering fanout_add() (using the same af_packet socket,
>> syzkaller courtesy...) might both see po->fanout being NULL.
>>
>> Then they grab the mutex.  Too late...
>
> I'm not sure I follow- aiui the panic was in acceessing the
> sk_receive_queue.lock in a socket that had been closed earlier. I think
> the assumption is that rcu_read_lock_bh in __dev_queue_xmit (and
> rcu_read_lock in dev_queue_xmit_nit?) should make sure that the nit
> packet delivery can be done safely, and the synchronize_net in
> packet_release() makes sure that the Tx paths are quiesced before freeing
> the socket.  What is the race-hole here? Does it have to do with the
> _bh and softirq context, somehow?

My understanding about the race here is packet_release() doesn't
wait for flying packets correctly, which leads to a flying packet still
refers to the struct sock which is being released.

This could happen because struct packet_fanout is refcn'ted, it is
still there when this is not the last sock referring it, therefore, the
callback packet_rcv_fanout() is not removed yet. When packet_release()
tries to remove the pointer to struct sock from f->arr[i] in
__fanout_unlink(), a flying packet could race with f->arr[i]:

po = pkt_sk(f->arr[idx]);

Of course, the fix may not be as easy as just adding a synchronize_net(),
perhaps we need the spinlock too in fanout_demux_rollover().

At least I believe this explains the crash Dmitry reported.
