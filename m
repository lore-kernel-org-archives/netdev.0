From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Tue, 29 Dec 2015 19:42:36 +0000
Message-ID: <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:56460 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753612AbbL2Tm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 14:42:58 -0500
In-Reply-To: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	(Jacob Siverskog's message of "Tue, 29 Dec 2015 20:10:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jacob Siverskog <jacob@teenage.engineering> writes:
> This should fix a NULL pointer dereference I encountered (dump
> below). Since __skb_unlink is called while walking,
> skb_queue_walk_safe should be used.

The code in question is:

skb_queue_walk(queue, skb) {
	*last = skb;
	*peeked = skb->peeked;
	if (flags & MSG_PEEK) {
		if (_off >= skb->len && (skb->len || _off ||
					 skb->peeked)) {
			_off -= skb->len;
			continue;
		}

		skb = skb_set_peeked(skb);
		error = PTR_ERR(skb);
		if (IS_ERR(skb)) {
			spin_unlock_irqrestore(&queue->lock,
					       cpu_flags);
			goto no_packet;
		}
                
		atomic_inc(&skb->users);
	}  else
		__skb_unlink(skb, queue);

	spin_unlock_irqrestore(&queue->lock, cpu_flags);
	*off = _off;
	return skb;
}

__skb_unlink is only called prior to returning from the function.
Consequently, it won't affect the skb_queue_walk code.
