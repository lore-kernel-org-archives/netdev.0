From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/5] l2tp: fix usage of l2tp_session_find()
Date: Fri, 31 Mar 2017 13:02:23 +0200
Message-ID: <cover.1490955471.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>, Bill Hong <bhong@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51738 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932879AbdCaLC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:02:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_session_find() doesn't take a reference on the session returned to
its caller. Virtually all l2tp_session_find() users are racy, either
because the session can disappear from under them or because they take
a reference too late. This leads to bugs like 'use after free' or
failure to notice duplicate session creations.

In some cases, taking a reference on the session is not enough. The
special callbacks .ref() and .deref() also have to be called in cases
where the PPP pseudo-wire uses the socket associated with the session.
Therefore, when looking up a session, we also have to pass a flag
indicating if the .ref() callback has to be called.

In the future, we probably could drop the .ref() and .deref() callbacks
entirely by protecting the .sock field of struct pppol2tp_session with
RCU, thus allowing it to be freed and set to NULL even if the L2TP
session is still alive.

Guillaume Nault (5):
  l2tp: fix race in l2tp_recv_common()
  l2tp: ensure session can't get removed during pppol2tp_session_ioctl()
  l2tp: fix duplicate session creation
  l2tp: hold session while sending creation notifications
  l2tp: take a reference on sessions used in genetlink handlers

 net/l2tp/l2tp_core.c    | 152 ++++++++++++++++++++++++++++++++++++++----------
 net/l2tp/l2tp_core.h    |   6 +-
 net/l2tp/l2tp_eth.c     |  10 +---
 net/l2tp/l2tp_ip.c      |  17 ++++--
 net/l2tp/l2tp_ip6.c     |  18 ++++--
 net/l2tp/l2tp_netlink.c |  45 +++++++++-----
 net/l2tp/l2tp_ppp.c     |  75 +++++++++++++-----------
 7 files changed, 222 insertions(+), 101 deletions(-)

-- 
2.11.0
