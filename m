From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: problem with 'net: Partially allow skb destructors to be used on
 receive path'
Date: Sat, 20 Jun 2009 15:17:36 +0200
Message-ID: <4A3CE170.8030604@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:41899 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbZFTNRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 09:17:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

i got a feedback on the SocketCAN users ML from Michel Marti that the can-raw
socket option CAN_RAW_RECV_OWN_MSGS is out of order since 2.6.30.

https://lists.berlios.de/pipermail/socketcan-users/2009-June/000959.html

Usually the user application does not get CAN frames back through the socket
it was originally sent:

static void raw_rcv(struct sk_buff *skb, void *data)
{
        struct sock *sk = (struct sock *)data;
        struct raw_sock *ro = raw_sk(sk);
        struct sockaddr_can *addr;

        /* check the received tx sock reference */
        if (!ro->recv_own_msgs && skb->sk == sk)
                return;

...

For another detail see can_send() at net/can/af_can.c

The needed sk reference in the rx path for omitting the own received messages
is killed by a new skb_orphan() call in net/core/dev.c introduced in 2.6.30:

"net: Partially allow skb destructors to be used on receive path"

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=9a279bcbe347496799711155ed41a89bc40f79c5

I tried to follow your comment of the commit which looks mostly associated to
IP networking.

Do you have any idea how this currently killed functionality that bases on the
originator skb->sk could be fixed?

Suggestions:

1. omit the skb_orphan() for ARPHRD_CAN skbs
2. put the sk value in cb[]
3. anything else ???

Thanks,
Oliver

