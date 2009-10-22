From: Xiaotian Feng <xtfeng@gmail.com>
Subject: [PATCH] isdn: fix possible circular locking dependency
Date: Thu, 22 Oct 2009 17:07:04 +0800
Message-ID: <1256202424-28314-1-git-send-email-xtfeng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tilman@imap.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Xiaotian Feng <xtfeng@gmail.com>
To: isdn@linux-pingi.de, isdn4linux@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754405AbZJVJGq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's a circular locking dependency:

---> isdn_net_get_locked_lp
=C2=A0 =C2=A0 --->lock &nd->queue_lock
=C2=A0 =C2=A0 --->lock &nd->queue->xmit_lock
=C2=A0 =C2=A0 .....................
=C2=A0 =C2=A0 ---->unlock &nd->queue_lock

---> isdn_net_writebuf_skb (called with &nd->queue->xmit_lock locked)
=C2=A0 =C2=A0 ---->isdn_net_inc_frame_cnt
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0---->isdn_net_device_busy
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ----> lock &nd->queue_=
lock

This will trigger lockdep warnings:

=C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
=C2=A0[ INFO: possible circular locking dependency detected ]
=C2=A02.6.32-rc4-testing #7
=C2=A0-------------------------------------------------------
=C2=A0ipppd/28379 is trying to acquire lock:
=C2=A0(&netdev->queue_lock){......}, at: [<e62ad0fd>] isdn_net_device_b=
usy+0x2c/0x74 [isdn]

=C2=A0but task is already holding lock:
=C2=A0(&netdev->local->xmit_lock){+.....}, at: [<e62aefc2>] isdn_net_wr=
ite_super+0x3f/0x6e [isdn]

=C2=A0which lock already depends on the new lock.
 .......

 We don't need to lock nd->queue->xmit_lock to protect single
isdn_net_lp_busy(). This can fix above lockdep warnings.

Reported-and-tested-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Xiaotian Feng <xtfeng@gmail.com>
---
 drivers/isdn/i4l/isdn_net.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.h b/drivers/isdn/i4l/isdn_net.h
index 74032d0..7511f08 100644
--- a/drivers/isdn/i4l/isdn_net.h
+++ b/drivers/isdn/i4l/isdn_net.h
@@ -83,19 +83,19 @@ static __inline__ isdn_net_local * isdn_net_get_loc=
ked_lp(isdn_net_dev *nd)
=20
 	spin_lock_irqsave(&nd->queue_lock, flags);
 	lp =3D nd->queue;         /* get lp on top of queue */
-	spin_lock(&nd->queue->xmit_lock);
 	while (isdn_net_lp_busy(nd->queue)) {
-		spin_unlock(&nd->queue->xmit_lock);
 		nd->queue =3D nd->queue->next;
 		if (nd->queue =3D=3D lp) { /* not found -- should never happen */
 			lp =3D NULL;
 			goto errout;
 		}
-		spin_lock(&nd->queue->xmit_lock);
 	}
 	lp =3D nd->queue;
 	nd->queue =3D nd->queue->next;
+	spin_unlock_irqrestore(&nd->queue_lock, flags);
+	spin_lock(&lp->xmit_lock);
 	local_bh_disable();
+	return lp;
 errout:
 	spin_unlock_irqrestore(&nd->queue_lock, flags);
 	return lp;
--=20
1.6.2.5
