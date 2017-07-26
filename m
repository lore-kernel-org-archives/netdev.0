From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2] net: check dev->addr_len for dev_set_mac_address()
Date: Wed, 26 Jul 2017 15:22:06 -0700
Message-ID: <20170726222207.5922-1-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36919 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdGZWWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 18:22:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id y25so9078101pfk.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 15:22:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Historically, dev_ifsioc() uses struct sockaddr as mac
address definition, this is why dev_set_mac_address()
accepts a struct sockaddr pointer as input but now we
have various types of mac addresse whose lengths
are up to MAX_ADDR_LEN, longer than struct sockaddr,
and saved in dev->addr_len.

It is too late to fix dev_ifsioc() due to API
compatibility, so just reject those larger than
sizeof(struct sockaddr), otherwise we would read
and use some random bytes from kernel stack.

Fortunately, only a few IPv6 tunnel devices have addr_len
larger than sizeof(struct sockaddr) and they don't support
ndo_set_mac_addr(). But with team driver, in lb mode, they
can still be enslaved to a team master and make its mac addr
length as the same.

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/dev_ioctl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 06b147d7d9e2..709a4e6fb447 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -263,6 +263,8 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		return dev_set_mtu(dev, ifr->ifr_mtu);
 
 	case SIOCSIFHWADDR:
+		if (dev->addr_len > sizeof(struct sockaddr))
+			return -EINVAL;
 		return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
 
 	case SIOCSIFHWBROADCAST:
-- 
2.13.0
