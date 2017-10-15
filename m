From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 5/6] rtnetlink: check DO_SETLINK_NOTIFY correctly in do_setlink
Date: Sun, 15 Oct 2017 18:13:45 +0800
Message-ID: <22c0aefe18d4451166c5f12714d8520346a63f2b.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
 <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:52190 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbdJOKOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:14:35 -0400
Received: by mail-pg0-f65.google.com with SMTP id k70so3527529pgc.8
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:14:35 -0700 (PDT)
In-Reply-To: <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check 'status & DO_SETLINK_NOTIFY' in do_setlink doesn't really
work after status & DO_SETLINK_MODIFIED, as:

  DO_SETLINK_MODIFIED 0x1
  DO_SETLINK_NOTIFY 0x3

Considering that notifications are suppposed to be sent only when
status have the flag DO_SETLINK_NOTIFY, the right check would be:

  (status & DO_SETLINK_NOTIFY) == DO_SETLINK_NOTIFY

This would avoid lots of duplicated notifications when setting some
properties of a link.

Fixes: ba9989069f4e ("rtnl/do_setlink(): notify when a netdev is modified")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ab98c1c..3e98fb5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2248,7 +2248,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
-		if (status & DO_SETLINK_NOTIFY)
+		if ((status & DO_SETLINK_NOTIFY) == DO_SETLINK_NOTIFY)
 			netdev_state_change(dev);
 
 		if (err < 0)
-- 
2.1.0
