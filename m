From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/2] ppp: fix deadlock upon recursive xmit
Date: Sat, 27 Aug 2016 22:20:34 +0200
Message-ID: <20160827202034.6rfolco57rgsstzl@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, Feng Gao <gfree.wind@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55846 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbcH0UUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 16:20:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes the issue reported by Feng where packets looping
through a ppp device makes the module deadlock:
https://marc.info/?l=linux-netdev&m=147134567319038&w=2

The problem can occur on virtual interfaces (e.g. PPP over L2TP, or
PPPoE on vxlan devices), when a PPP packet is routed back to the PPP
interface.

PPP's xmit path isn't reentrant, so patch #1 uses a per-cpu variable
to detect and break recursion. Patch #2 sets the NETIF_F_LLTX flag to
avoid lock inversion issues between ppp and txqueue locks.

There are multiple entry points to the PPP xmit path. This series has
been tested with lockdep and should address recursion issues no matter
how the packet entered the path.


A similar issue in L2TP is not covered by this series:
l2tp_xmit_skb() also isn't reentrant, and it can be called as part of
PPP's xmit path (pppol2tp_xmit()), or directly from the L2TP socket
(l2tp_ppp_sendmsg()). If a packet is sent by l2tp_ppp_sendmsg() and
routed to the parent PPP interface, then it's going to hit
l2tp_xmit_skb() again.

Breaking recursion as done in ppp_generic is not enough, because we'd
still have a lock inversion issue (locking in l2tp_xmit_skb() can
happen before or after locking in ppp_generic). The best approach would
be to use the ip_tunnel functions and remove the socket locking in
l2tp_xmit_skb(). But that'd be something for net-next.


BTW, I hope the commit messages aren't too long. Just let me know if I
should trim something.


Guillaume Nault (2):
  ppp: avoid dealock on recursive xmit
  ppp: declare PPP devices as LLTX

 drivers/net/ppp/ppp_generic.c | 54 +++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 12 deletions(-)

-- 
2.9.3
