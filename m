From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 10 Dec 2012 17:31:32 -0500 (EST)
Message-ID: <20121210.173132.1705832618971554116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Netlink socket dumping had several missing verifications and
   checks.

   In particular, address comparisons in the request byte code
   interpreter could access past the end of the address in the
   inet_request_sock.

   Also, address family and address prefix lengths were not
   validated properly at all.

   This means arbitrary applications can read past the end of
   certain kernel data structures.

   Fixes from Neal Cardwell.

2) ip_check_defrag() operates in contexts where we're in the
   process of, or about to, input the packet into the real
   protocols (specifically macvlan and AF_PACKET snooping).

   Unfortunately, it does a pskb_may_pull() which can modify
   the backing packet data which is not legal if the SKB is
   shared.  It very much can be shared in this context.

   Deal with the possibility that the SKB is segmented by
   using skb_copy_bits().

   Fix from Johannes Berg based upon a report by Eric Leblond.

Please pull, thanks a lot!

The following changes since commit ed23ec4f0a510528e0ffe415f9394107418ae854:

  mm: vmscan: fix inappropriate zone congestion clearing (2012-12-08 08:41:18 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 1bf3751ec90cc3174e01f0d701e8449ce163d113:

  ipv4: ip_check_defrag must not modify skb before unsharing (2012-12-10 13:51:44 -0500)

----------------------------------------------------------------
Johannes Berg (1):
      ipv4: ip_check_defrag must not modify skb before unsharing

Neal Cardwell (4):
      inet_diag: fix oops for IPv4 AF_INET6 TCP SYN-RECV state
      inet_diag: validate byte code to prevent oops in inet_diag_bc_run()
      inet_diag: avoid unsafe and nonsensical prefix matches in inet_diag_bc_run()
      inet_diag: validate port comparison byte code to prevent unsafe reads

 net/ipv4/inet_diag.c   | 154 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
 net/ipv4/ip_fragment.c |  19 ++++++-------
 2 files changed, 131 insertions(+), 42 deletions(-)
