From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 07:02:25 -0800
Message-ID: <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E905C8.1060408@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:51676 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbaA2PC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 10:02:26 -0500
Received: by mail-pb0-f49.google.com with SMTP id up15so1845294pbc.36
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 07:02:26 -0800 (PST)
In-Reply-To: <52E905C8.1060408@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 14:44 +0100, Oliver Hartkopp wrote:
> Commit 376c7311bdb6 (net: add a temporary sanity check in skb_orphan())
> leads to a BUG in can_put_echo_skb() when skb_orphan() is executed.
> 
> The use of skb->sk to detect the originating socket can lead to side effects
> in net/core and net/sched. Therefore the reference needed in net/can/raw.c is
> now stored in a CAN private skbuff space in struct can_skb_priv.
> 
> The reference which comes with the CAN frame is only needed in raw_rcv() and
> checked against his own sock pointer and does only special things if it
> matches. So removing the socket does not hurt as the in-flight skbs are
> removed and the receive filters are purged anyway when the socket disappears.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> ---
> 
> Here's my idea to fix up the original skb->sk handling concept for detecting
> the originating socket instance. The patch applies properly down to 3.11.
> 
> Eric please take a look if I used sock_alloc_send_skb() correctly in bcm.c.
> Andre please check if you see any functional differences on your machine.

I think this is opening yet another can of bugs.

CAN calls dev_queue_xmit()  : This layer can zap skb->cb[] totally.

Please hold a reference on the socket instead. Thats a 10 lines patch,
instead of yet another complex patch.

void can_destructor(struct sk_buff *skb)
{
	sock_put(skb->sk);
}

void can_set_owner(struct sk_buff *skb, struct sock *sk)
{
	skb_orphan(skb);
	skb->destructor = can_skb_destructor;
	skb->sk = sk;
	sock_hold(sk);
}

Thats how every protocol does this, with variants.

Check l2tp_sock_wfree()/l2tp_skb_set_owner_w() for an example
