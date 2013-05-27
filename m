From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 1/6] net: inform NETDEV_CHANGE callbacks which flags were changed
Date: Mon, 27 May 2013 14:16:11 +0300
Message-ID: <1369653376-4731-2-git-send-email-timo.teras@iki.fi>
References: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:47015 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704Ab3E0LOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:14:42 -0400
Received: by mail-ea0-f178.google.com with SMTP id q16so3821979ead.37
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 04:14:41 -0700 (PDT)
In-Reply-To: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In certain cases (like the follow up commit to arp.c) will need to
check which flags actually changed to avoid excessive work.

Ben Hutchings nicely worded why to put these transient flags to
struct net_device for the time being:
> It's inelegant to put transient data associated with an event in a
> persistent data structure.  On the other hand, having every user cach=
e
> the old state is pretty awful as well.
>
> Really, netdev notifiers should be changed to accept a structure that
> encapsulates the changes rather than just a pointer to the net_device=
=2E
> But making such a change would be an enormous pain and error-prone
> because notifier functions aren't type-safe.
>
> As an interim solution, I think either the general flags_changed or
> old_flags would be preferable to defining extra transient flags.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h | 4 +++-
 net/core/dev.c            | 5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ea7b6bc..f336e03 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1112,7 +1112,9 @@ struct net_device {
 	/* Hardware header description */
 	const struct header_ops *header_ops;
=20
-	unsigned int		flags;	/* interface flags (a la BSD)	*/
+	unsigned int		flags;		/* interface flags (a la BSD)	*/
+	unsigned int		flags_changed;	/* flags that are being changed
+						 * valid during NETDEV_CHANGE notifier */
 	unsigned int		priv_flags; /* Like 'flags' but invisible to userspace.
 					     * See if.h for definitions. */
 	unsigned short		gflags;
diff --git a/net/core/dev.c b/net/core/dev.c
index 50c02de..bbaa3c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4742,8 +4742,11 @@ void __dev_notify_flags(struct net_device *dev, =
unsigned int old_flags)
 	}
=20
 	if (dev->flags & IFF_UP &&
-	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE))=
)
+	    (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE))=
) {
+		dev->flags_changed =3D changes;
 		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+		dev->flags_changed =3D 0;
+	}
 }
=20
 /**
--=20
1.8.2.3
