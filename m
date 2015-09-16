From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 0/3] Allow postponed netfilter handling for socket matches
Date: Wed, 16 Sep 2015 17:42:57 +0200
Message-ID: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47602 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbbIPPu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 11:50:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm re-addressing the issue of matching socket meta information for
non-established sockets that has been discussed a while ago:

  http://article.gmane.org/gmane.comp.security.firewalls.netfilter.devel/56877

Being able to reliably match on net_cls cgroup ids is crucial in
order to build a per-application or per-container firewall rules
which don't leak ingress packets. Such a feature would be very
useful to have.

A previous attempt to fix the currently existing issues was to call
out to the early demuxing helper functions from the meta matching
callbacks, but that doesn't suffice because it doesn't address the
case of multicast UDP and other, more complex lookup methods 
implemented in various protocol handlers.

This patch set outlines a different approach by adding a flag to
'struct sk_buff' called 'nf_postponed'. This flag is set by
nft_meta_get_eval() in case a decision cannot be made due to a missing
skb->sk. skbs flagged that way will then be ran through the netfilter
chain processor again after the protocol handlers did the real socket
lookup. A small addition to 'struct nft_pktinfo' is needed so that the
matching callbacks can access the socket that was passed into
nf_hook().

Note that the new flag does not actually bloat 'struct skb_buff',
because it still fits into the 'flags1' bitfield. Also, the extra
netfilter chain iteration will not be done by any subsequent packet in
the same stream, as for those, the early demux code will set skb->sk.

The patch set is obviously not yet finished, because a lot more
protocol handlers need to be patched. Right now, I only addressed
tcp_ipv4. Before I do that, I want to get some feedback on the
approach, so please let me know what you think.


Thanks,
Daniel


Daniel Mack (3):
  netfilter: add socket to struct nft_pktinfo
  netfilter: nft_meta: mark skbs for postponed filter processing
  net: tcp_ipv4: re-run netfilter chains for marked skbs

 include/linux/skbuff.h            |  3 ++-
 include/net/netfilter/nf_tables.h |  2 ++
 net/ipv4/tcp_ipv4.c               | 10 ++++++++++
 net/netfilter/nft_meta.c          |  9 ++++++---
 4 files changed, 20 insertions(+), 4 deletions(-)

-- 
2.5.0
