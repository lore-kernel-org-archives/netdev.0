From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] af_packet: use spin_lock_bh() for sk_buff_head
Date: Wed, 27 Nov 2013 08:17:55 -0800
Message-ID: <1385569075.5352.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385557075-8896-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jstancek@redhat.com,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53186 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab3K0QR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 11:17:58 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so10618406pbc.5
        for <netdev@vger.kernel.org>; Wed, 27 Nov 2013 08:17:58 -0800 (PST)
In-Reply-To: <1385557075-8896-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-27 at 13:57 +0100, Veaceslav Falico wrote:
> While running a debug kernel, a warning of inconsistent lock state showed
> up for sk->sk_receive_queue->lock between packet_set_ring() (actually,
> static prb_shutdown_retire_blk_timer(), which does spin_lock()) and
> sock_queue_rcv_skb(), which does spin_lock_irqsave().
> 
> Fix this by converting the spin_lock() used in
> prb_shutdown_retire_blk_timer() to spin_lock_bh(), as it is used in
> packet_set_ring().

Patch is good, but description is slightly misleading.

Problem is not because sock_queue_rcv_skb() uses spin_lock_irqsave().

Problem is prb_retire_rx_blk_timer_expired() is called from softirq
context.

So if we do not block BH in prb_shutdown_retire_blk_timer() :

spin_lock(&rb_queue->lock); 
pkc->delete_blk_timer = 1;
spin_unlock(&rb_queue->lock); 

Timer could fire right in the middle and would spin forever trying
to acquire the same lock.

Using spin_lock_bh() prevents timer being fired on this cpu.

Thanks !
