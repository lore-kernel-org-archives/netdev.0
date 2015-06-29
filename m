From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] sock: honor GFP_ATOMIC when allocating send skbs
Date: Mon, 29 Jun 2015 16:00:42 +0200
Message-ID: <CAHmME9rZuQdWtAfiQUw9UG-P4TwhKNkSjajXM_S+0sKY7BiQpQ@mail.gmail.com>
References: <1435583216-19877-1-git-send-email-Jason@zx2c4.com>
	<1435584965.4110.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:38446 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbbF2OAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 10:00:46 -0400
In-Reply-To: <1435584965.4110.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for your feedback on this. The precise problem is a BUG in the
scheduler code when sleep is called from atomic context, due to having
to wait on that allocation. This is triggered by a module I'm writing.

I'm probably doing something I shouldn't... I'm calling udp_sendmsg
from atomic context: bad news bears, right? Really what I'd like to do
is create an skb with headroom, fill it with data, and then hand it
off to the udp/ip stack to prepend the udp and ip headers and
calculate the flowi4 and correct dev and checksums for the skb. But I
can't seem to find a correct API for this. So instead I'm using a
socket and calling sendmsg on it, which unfortunately winds up in an
extra allocation and a memcpy when sending. Might there be a better
way to do what I want? That is: pass a buffer off to the networking
stack, a) with zero copies [without having to use sendpage], and b)
from atomic context. I'd like to avoid using workqueues/kthreads/etc
if possible.

Thanks,
Jason
