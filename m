From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/4] l2tp: register sessions atomically
Date: Fri, 27 Oct 2017 16:51:48 +0200
Message-ID: <cover.1509111405.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:59886 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJ0Ovw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:51:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently l2tp_session_create() allocates a session, partially
initialises it and finally registers it. It therefore exposes sessions
that aren't fully initialised to the rest of the system, because
pseudo-wire specific initialisation can only happen after
l2tp_session_create() returns.
This leads to several crashes when these sessions are used or deleted.

This series starts by splitting session registration out of
l2tp_session_create() (patch #1). Thus allowing pseudo-wires code to
terminate the initialisation phase before registration.

Then patch #2 fixes the eth pseudo-wire code. This requires protecting
the session's netdevice pointer with RCU, because it still needs to be
updated concurrently after the session got registered.

Remaining patches take care of ppp pseudo-wires. RCU protection is
needed there too, for the same reasons. This time it's the pppol2tp
socket pointer that gets protected. For clarity, and since the
conversion requires more modifications, introducing RCU is done in
its own patch (#3). Then patch #4 only has to take care of fixing
sessions initialisation and registration (and adapting part of the
deletion process).


Guillaume Nault (4):
  l2tp: don't register sessions in l2tp_session_create()
  l2tp: initialise l2tp_eth sessions before registering them
  l2tp: protect sock pointer of struct pppol2tp_session with RCU
  l2tp: initialise PPP sessions before registering them

 net/l2tp/l2tp_core.c |  21 ++---
 net/l2tp/l2tp_core.h |   3 +
 net/l2tp/l2tp_eth.c  |  99 ++++++++++++++++-----
 net/l2tp/l2tp_ppp.c  | 238 ++++++++++++++++++++++++++++++++-------------------
 4 files changed, 238 insertions(+), 123 deletions(-)

-- 
2.15.0.rc2
