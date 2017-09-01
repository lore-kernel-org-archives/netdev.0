From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/2] l2tp: session creation fixes
Date: Fri, 1 Sep 2017 17:58:45 +0200
Message-ID: <cover.1504277892.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:46012 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdIAP6x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 11:58:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The session creation process has a few issues wrt. concurrent tunnel
deletion.

Patch #1 avoids creating sessions in tunnels that are getting removed.
This prevents races where sessions could try to take tunnel resources
that were already released.

Patch #2 removes some racy l2tp_tunnel_find() calls in session creation
callbacks. Together with path #1 it ensures that sessions can only
access tunnel resources that are guaranteed to remain valid during the
session creation process.


There are other problems with how sessions are created: pseudo-wire
specific data are set after the session is added to the tunnel. So
the session can be used, or deleted, before it has been completely
initialised. Separating session allocation from session registration
would be necessary, but we'd still have circular dependencies
preventing race-free registration. I'll consider this issue in future
series.


Guillaume Nault (2):
  l2tp: prevent creation of sessions on terminated tunnels
  l2tp: pass tunnel pointer to ->session_create()

 net/l2tp/l2tp_core.c    | 41 ++++++++++++++++++++++++++++-------------
 net/l2tp/l2tp_core.h    |  8 +++++++-
 net/l2tp/l2tp_eth.c     | 11 +++--------
 net/l2tp/l2tp_netlink.c |  8 ++++----
 net/l2tp/l2tp_ppp.c     | 19 +++++++------------
 5 files changed, 49 insertions(+), 38 deletions(-)

-- 
2.14.1
