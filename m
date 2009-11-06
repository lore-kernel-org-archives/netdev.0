From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/7] =?utf-8?q?appletalk:=C2=A0handle=20SIOCATALKDIFADDR=20compat=20ioctl?=
Date: Fri,  6 Nov 2009 19:09:06 +0100
Message-ID: <1257530949-9695-5-git-send-email-arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759546AbZKFSJz@vger.kernel.org>
In-Reply-To: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must not have a compat ioctl handler for SIOCATALKDIFADDR
in common code, because the same number is used in other protocols
with different data structures.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/compat_ioctl.c   |    1 -
 net/appletalk/ddp.c |   12 +++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index f4a5a01..50d2a5f 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -2536,7 +2536,6 @@ HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
 HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
 
 /* ioctls used by appletalk ddp.c */
-HANDLE_IOCTL(SIOCATALKDIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCDIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSARP, dev_ifsioc)
 HANDLE_IOCTL(SIOCDARP, dev_ifsioc)
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index b1a4290..db9c75a 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1810,12 +1810,14 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 static int atalk_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	/*
-	 * All Appletalk ioctls except SIOCATALKDIFADDR are standard.  And
-	 * SIOCATALKDIFADDR is handled by upper layer as well, so there is
-	 * nothing to do.  Eventually SIOCATALKDIFADDR should be moved
-	 * here so there is no generic SIOCPROTOPRIVATE translation in the
-	 * system.
+	 * SIOCATALKDIFADDR is a SIOCPROTOPRIVATE ioctl number, so we
+	 * cannot handle it in common code. The data we access if ifreq
+	 * here is compatible, so we can simply call the native
+	 * handler.
 	 */
+	if (cmd == SIOCATALKDIFADDR)
+		return atalk_ioctl(sock, cmd, (unsigned long)compat_ptr(arg));
+
 	return -ENOIOCTLCMD;
 }
 #endif
-- 
1.6.3.3
