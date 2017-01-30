From: Theuns Verwoerd <Theuns.Verwoerd@alliedtelesis.co.nz>
Subject: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when processing
 rtnl_newlink
Date: Mon, 30 Jan 2017 22:28:05 +0000
Message-ID: <38fc316c-a522-a8ca-d029-25fa5335a954@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsa@cumulusnetworks.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:57634 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdA3WjT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 17:39:19 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id B53DD8604A
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 11:28:06 +1300 (NZDT)
Content-Language: en-US
Content-ID: <B66D2E82BDECF54B9AE260CC4BE100B6@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnetlink: Handle IFLA_MASTER parameter when processing rtnl_newlink

Allow a master interface to be specified as one of the parameters when
creating a new interface via rtnl_newlink.  Previously this would
require invoking interface creation, waiting for it to complete, and
then separately binding that new interface to a master.

In particular, this is used when creating a macvlan child interface for
VRRP in a VRF configuration, allowing the interface creator to specify
directly what master interface should be inherited by the child,
without having to deal with asynchronous complications and potential
race conditions.

Signed-off-by: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 75e3ea7bda08..a24719c98238 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2571,7 +2571,7 @@ static int rtnl_newlink(struct sk_buff *skb,=20
struct nlmsghdr *nlh)
                         return -ENODEV;
                 }

-               if (tb[IFLA_MAP] || tb[IFLA_MASTER] || tb[IFLA_PROTINFO])
+               if (tb[IFLA_MAP] || tb[IFLA_PROTINFO])
                         return -EOPNOTSUPP;

                 if (!ops) {
@@ -2653,6 +2653,11 @@ static int rtnl_newlink(struct sk_buff *skb,=20
struct nlmsghdr *nlh)
                         if (err < 0)
                                 goto out_unregister;
                 }
+               if (tb[IFLA_MASTER]) {
+                       err =3D do_set_master(dev,=20
nla_get_u32(tb[IFLA_MASTER]));
+                       if (err)
+                               goto out_unregister;
+               }
  out:
                 if (link_net)
                         put_net(link_net);
