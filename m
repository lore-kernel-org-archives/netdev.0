From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: BUG: null dereference in __skb_recv_datagram
Date: Mon, 3 Aug 2015 22:34:02 -0700
Message-ID: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
References: <CAMUH3-VQaWdxnGUuJamGXQZN+Pq-4YBFcr6Yq3R6qD0=8cjG_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, khlebnikov@yandex-team.ru
To: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35785 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbHDFeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:34:22 -0400
Received: by ykdu72 with SMTP id u72so129218934ykd.2
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:34:22 -0700 (PDT)
In-Reply-To: <CAMUH3-VQaWdxnGUuJamGXQZN+Pq-4YBFcr6Yq3R6qD0=8cjG_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [  318.244596] BUG: unable to handle kernel NULL pointer dereference
> at 000000000000008e
> [  318.245182] IP: [<ffffffff81455e7c>] __skb_recv_datagram+0xbc/0x5a0

Replying to myself, and adding commit interested parties...

I went through the git log for the function in question, and
positively identified that the following commit introduces the crash:

738ac1e net: Clone skb before setting peeked flag

Null dereference is at line 224 of net/core/datagram.c (according to
my objdump dis-assembly):

                spin_lock_irqsave(&queue->lock, cpu_flags);
                skb_queue_walk(queue, skb) {
                        last = skb;
                        *peeked = skb->peeked;

^-----------------------------------
                        if (flags & MSG_PEEK) {
                                if (_off >= skb->len && (skb->len || _off ||
                                                         skb->peeked)) {

Beyond that, I'm probably out of my comfort zone, so if anyone has a
bright idea of a patch to try, I will gladly test it.
