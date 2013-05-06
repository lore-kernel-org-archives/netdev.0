From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Mon, 6 May 2013 09:33:18 +0200
Message-ID: <20130506093318.679f5557@redhat.com>
References: <20130505145622.9351.86587.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab3EFHdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 03:33:37 -0400
In-Reply-To: <20130505145622.9351.86587.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 05 May 2013 18:56:22 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch fixes race between inet_frag_lru_move() and
> inet_frag_lru_add() which was introduced in commit
> 3ef0eb0db4bf92c6d2510fe5c4dc51852746f206 ("net: frag, move LRU list
> maintenance outside of rwlock")
> 
> One cpu already added new fragment queue into hash but not into LRU.
> Other cpu found it in hash and tries to move it to the end of LRU.
> This leads to NULL pointer dereference inside of list_move_tail().

I tried to address this in:
http://article.gmane.org/gmane.linux.network/266324 But it was never
applied, as we disagreed on other parts of the patchset and didn't think
this would happen with curr LRU scheme (which you have shown it can)


> Another possible race condition is between inet_frag_lru_move() and
> inet_frag_lru_del(): move can happens after deletion.

This should be very difficult to hit, because its protected with
the INET_FRAG_COMPLETE bit (checked in ip_frag_queue() before the LRU
move), which is set after removing it from LRU (all while protected
under the q->lock).


> This patch initializes LRU list head before adding fragment into hash
> and inet_frag_lru_move() doesn't touches it if it's empty.

This a good fix, and better than my earlier attempt at fixing this.

Thanks!

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
