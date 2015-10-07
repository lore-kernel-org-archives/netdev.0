From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/3] switchdev: change locking
Date: Wed,  7 Oct 2015 20:30:49 +0200
Message-ID: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36294 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbbJGSa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:30:57 -0400
Received: by wicgb1 with SMTP id gb1so223808174wic.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 11:30:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is something which I'm currently struggling with.
Callers of attr_set and obj_add/del often hold not only RTNL, but also
spinlock (bridge). So in that case, the driver implementing the op cannot sleep.

The way rocker is dealing with this now is just to invoke driver operation
and go out, without any checking or reporting of the operation status.

Since it would be nice to at least put a warning in case the operation fails,
it might make sense to do this in delayed work directly in switchdev core
instead of implementing this in separate drivers. And that is what this patchset
is introducing. (The part of removing "nowait" from rocker is not implemented
in this patchset, but it is straightforward).

Does this make sense. Any ideas?

Jiri Pirko (3):
  switchdev: assert rtnl in switchdev_port_obj_del
  switchdev: allow caller to explicitly use deferred attr_set version
  switchdev: introduce deferred variants of obj_add/del helpers

 include/net/switchdev.h   |   6 ++
 net/bridge/br_fdb.c       |   2 +-
 net/bridge/br_stp.c       |   4 +-
 net/switchdev/switchdev.c | 203 ++++++++++++++++++++++++++++++++++------------
 4 files changed, 160 insertions(+), 55 deletions(-)

-- 
1.9.3
