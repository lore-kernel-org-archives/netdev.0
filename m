From: "David S. Miller" <davem@davemloft.net>
Subject: issue with new TCP TSO stuff
Date: Wed, 11 May 2005 22:30:36 -0700 (PDT)
Message-ID: <20050511.223036.39664020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It's more expensive than the old code.  And I know the main reason.

There is a higher cost now because we do a large number of page
refcount grabs and releases now, that never occurred before.  Before,
we just cloned and thus grabbed a ref to the whole TSO data area in
one go.

This shows up in testing where the connection is application limited.
For example, an "scp" goes more slowly over TSO now, there are less
cpu cycles available for the encryption.

It's tricky to come up with a scheme to fix this.  I would love to be
able to not do the page grabs/releases in the actual TSO frame.  I
really haven't come up with a clean way to do that however.

Basically, if we could somehow delay the freeing of the actual SKBs in
the socket write queue until the device frees up the TSO frame, we
could avoid the page gets and puts.  Almost all the time, this delay
would never actually be needed, because the ACKs come back _long_
after the device liberates the TSO frame.  But it can due to packet
taps, packet reordering, and other reasons.  So we do have to handle
it.

I don't know, maybe we can do something clever with the
skb_shinfo(skb)->frag_list pointer.

Any bright ideas? :-)
