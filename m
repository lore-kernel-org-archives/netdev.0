From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Thu, 26 Nov 2009 23:54:53 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
References: <20091028151313.ba4a4d23.akpm@linux-foundation.org> <4AE9298C.1000204@gmail.com> <4AE92F4D.6070101@gmail.com> <20091029.010009.175904855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-504701655-1259272493=:24189"
Cc: eric.dumazet@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, kolo@albatani.cz,
	bugzilla-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48859 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbZKZVys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 16:54:48 -0500
In-Reply-To: <20091029.010009.175904855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-504701655-1259272493=:24189
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Thu, 29 Oct 2009, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 29 Oct 2009 06:59:41 +0100
> 
> > [PATCH] tcp: clear retrans hints in tcp_send_synack()
> > 
> > There is a small possibility the skb we unlink from write queue 
> > is still referenced by retrans hints.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> So, this would only be true if we were dealing with a data
> packet here.  We're not, this is a SYN+ACK which happens to
> be cloned in the write queue.
> 
> The hint SKBs pointers can only point to real data packets.
> 
> And we're only dealing with data packets once we enter established
> state, and when we enter established by definition we have unlinked
> and freed up any SYN and SYN+ACK SKBs in the write queue.

How about this then... Does the original reporter have NFS in use?

[PATCH] tcp: clear hints to avoid a stale one (nfs only affected?)

Eric Dumazet mentioned in a context of another problem:

"Well, it seems NFS reuses its socket, so maybe we miss some
cleaning as spotted in this old patch"

I've not check under which conditions that actually happens but
if true, we need to make sure we don't accidently leave stale
hints behind when the write queue had to be purged (whether reusing
with NFS can actually happen if purging took place is something I'm
not sure of).

...At least it compiles.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..6b13faa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1228,6 +1228,7 @@ static inline void tcp_write_queue_purge(struct sock *sk)
 	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
 		sk_wmem_free_skb(sk, skb);
 	sk_mem_reclaim(sk);
+	tcp_clear_all_retrans_hints(tcp_sk(sk));
 }
 
 static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
-- 
1.5.6.5

---696230645-504701655-1259272493=:24189--
