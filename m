From: "Adam J. Richter" <adam@yggdrasil.com>
Subject: Patch: linux-2.5.45/net/core/dev.c netdev_finish_unregister could read freed memory
Date: Sun, 3 Nov 2002 00:24:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021103002410.A513@baldur.yggdrasil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

	I just changed a network driver to use net_device.destructor
because it now embeds a struct net_device in a larger private data
structure (to reduce rarely tested memory allocation error branches).
Looking at netdev_finish_unregister, I see that after dev->destructor()
has been called, netdev_finish_unregister still atttempts to read
dev->features to check for NETIF_F_DYNALLOC.

	The following patch causes the NETIF_F_DYNALLOC test not to
be done if dev->destructor is provided.

	Alternatively, I'd be willing to make a patch to eliminate
NETIF_F_DYNALLOC (replacing it with "dev->destructor = (cast...) kfree;"),
as I think reference counting is done regardless of the value of
that flag.  I don't know why it is checked in net/core/dst.c though.

	Also, please do not eliminate netdev.destructor.  I have a
legitimate use for it that I can explain more if necessary.  Thanks.

-- 
Adam J. Richter     __     ______________   575 Oroville Road
adam@yggdrasil.com     \ /                  Milpitas, California 95035
+1 408 309-6081         | g g d r a s i l   United States of America
                         "Free Software For The Rest Of Us."

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dynalloc.diff"

--- linux-2.5.45/net/core/dev.c	2002-10-30 16:42:56.000000000 -0800
+++ linux/net/core/dev.c	2002-11-03 00:01:07.000000000 -0800
@@ -2511,7 +2511,7 @@
 #endif
 	if (dev->destructor)
 		dev->destructor(dev);
-	if (dev->features & NETIF_F_DYNALLOC)
+	else if (dev->features & NETIF_F_DYNALLOC)
 		kfree(dev);
 	return 0;
 }

--bp/iNruPH9dso1Pn--
