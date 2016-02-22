From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/5] ppp: fix locking issues related to ppp_ioctl()
Date: Mon, 22 Feb 2016 20:47:11 +0100
Message-ID: <cover.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53798 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742AbcBVUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:49:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes unprotected accesses to several struct ppp fields.
Only fields used in ppp_ioctl() have been considered, though.

Locking of the xstate and rstate fields remains incomplete: although a
side effect of patch #2 provides protection in ppp_ioctl(), xstate and
rstate can still be modified without appropriate locking by
ppp_ccp_peek(). Taking the missing locks in ppp_ccp_peek() isn't
possible as this would lead to lock inversion (when protecting xstate
with ppp_xmit_lock() while ppp_ccp_peek() is called in the Rx path).

Using a workqueue to run ppp_ccp_peek() might be a solution, but this
is left for another series.

Guillaume Nault (5):
  ppp: lock ppp structure before modifying mru in ppp_ioctl()
  ppp: fix unprotected accesses to ppp->flags and ppp->n_channels
  ppp: protect ppp->debug in ppp_ioctl()
  ppp: protect access to ppp->last{xmit,recv} in ppp_ioctl()
  ppp: protect ppp->npmode

 drivers/net/ppp/ppp_generic.c | 42 +++++++++++++++++++++++++++++++++++++++---
 1 file changed, 39 insertions(+), 3 deletions(-)

-- 
2.7.0
