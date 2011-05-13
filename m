From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 00/10] caif: rcu, refactoring and bugfixes
Date: Fri, 13 May 2011 14:43:58 +0200
Message-ID: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:41088 "EHLO
	slow2.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759023Ab1EMNCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:02:38 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow2.isp.as2116.net (Postfix) with ESMTP id 9ED1E40B12
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:03 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set introduces RCU in the CAIF stack and
fixes problems found when removing CAIF Link layer during traffic.

The pattern used for RCU is mostly this:
	rcu_read_lock();
	p =3D get();
	hold(p);
	rcu_read_unlock();
	use(p);
	put(p);

And when freeing:
	synchronize_rcu();
	wait_refcnt(p);
	kfree(p);

Sjur Br=C3=A6ndeland (10):
  caif: Use rcu_read_lock in CAIF mux layer.
  caif: Use RCU instead of spin-lock in caif_dev.c
  caif: Use RCU and lists in cfcnfg.c for managing caif link layers
  caif: Add ref-count to framing layer
  caif: Move refcount from service layer to sock and dev.
  caif: Protected in-flight packets using dev or sock refcont.
  caif: prepare support for namespaces
  caif: Handle dev_queue_xmit errors.
  caif: Bugfix debugfs directory name must be unique.
  caif: remove unesesarry exports

 include/net/caif/caif_dev.h |   43 +++--
 include/net/caif/cfcnfg.h   |   71 ++-----
 include/net/caif/cfctrl.h   |    3 +-
 include/net/caif/cffrml.h   |    7 +-
 include/net/caif/cfpkt.h    |    1 -
 include/net/caif/cfsrvl.h   |   29 ++--
 net/caif/Makefile           |    2 +-
 net/caif/caif_config_util.c |   99 ---------
 net/caif/caif_dev.c         |  349 +++++++++++++++++-------------
 net/caif/caif_socket.c      |   71 +++++--
 net/caif/cfcnfg.c           |  505 ++++++++++++++++++++++++++++-------=
--------
 net/caif/cfctrl.c           |  121 ++++++++---
 net/caif/cffrml.c           |   54 +++++-
 net/caif/cfmuxl.c           |  119 +++++++----
 net/caif/cfpkt_skbuff.c     |   27 +--
 net/caif/cfrfml.c           |    4 +-
 net/caif/cfsrvl.c           |   35 +++-
 net/caif/cfveil.c           |    8 +-
 net/caif/chnl_net.c         |   45 +++-
 19 files changed, 929 insertions(+), 664 deletions(-)
 delete mode 100644 net/caif/caif_config_util.c

