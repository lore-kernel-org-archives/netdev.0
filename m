From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: [PATCH 2.6.X] SIOCSIFNAME wilcard support
Date: Mon, 12 Jan 2004 15:43:32 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040112234332.GA1785@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

	Hi Jeff & Dave,

	The trivial patch below implement SIOCSIFNAME wilcard
support. With the appropriate version of nameif (please ask me), you
can do binding of this kind :

------------------------------------------------
# AMD Lance cards (pcnet32)
amd*		00:10:83:*
# Intersil PrismGT cards (prism54)
wlan*		00:04:E2:*
------------------------------------------------
	Of course, this make sense mostly for wireless cards. There is
currently lot's od debate about the use of 'ethX' and 'wlanX' names
for wireless driver, and some confusion resulting from that. Each
driver use a different naming style, and some have module parameters
to change the name prefix. Therefore, I think most distro and driver
authors would benefit from such a feature.
	It would also enable to emulate the naming conventions of
*BSD, but I don't know if I should list that as an argument ;-)

	I've run this patch for a while without any adverse
effect. Please forward upstream ;-)

	Jean

P.S. : Don't miss the second part of the change, we absolutely need to
return the new name to user space.

-------------------------------------------------------------

diff -u -p linux/net/core/dev.j1.c linux/net/core/dev.c
--- linux/net/core/dev.j1.c	Wed Dec  3 18:39:09 2003
+++ linux/net/core/dev.c	Wed Dec  3 18:54:36 2003
@@ -2344,15 +2344,29 @@ static int dev_ifsioc(struct ifreq *ifr,
 			if (dev->flags & IFF_UP)
 				return -EBUSY;
 			ifr->ifr_newname[IFNAMSIZ-1] = '\0';
-			if (__dev_get_by_name(ifr->ifr_newname))
-				return -EEXIST;
-			err = class_device_rename(&dev->class_dev, 
-						  ifr->ifr_newname);
-			if (!err) {
+			/* Check if name contains a wildcard */
+			if (strchr(ifr->ifr_newname, '%')) {
+				int ret;
+				/* Find a free name based on format.
+				 * dev_alloc_name() replaces "%d" with at max
+				 * 2 digits, so no name overflow. - Jean II */
+				ret = dev_alloc_name(dev, ifr->ifr_newname);
+				if (ret < 0)
+					return ret;
+				/* Copy the new name back to caller. */
+				strncpy(ifr->ifr_newname, dev->name, IFNAMSIZ);
+			} else {
+				if (__dev_get_by_name(ifr->ifr_newname))
+					return -EEXIST;
 				strlcpy(dev->name, ifr->ifr_newname, IFNAMSIZ);
-
+			}
+			err = class_device_rename(&dev->class_dev, dev->name);
+			if (!err) {
 				notifier_call_chain(&netdev_chain,
 						    NETDEV_CHANGENAME, dev);
+			} else {
+				/* Restore original name */
+				strlcpy(dev->name, ifr->ifr_name, IFNAMSIZ);
 			}
 			return err;
 
@@ -2485,6 +2499,7 @@ int dev_ioctl(unsigned int cmd, void *ar
 		 *	- require strict serialization.
 		 *	- return a value
 		 */
+		case SIOCSIFNAME:
 		case SIOCGMIIPHY:
 		case SIOCGMIIREG:
 			if (!capable(CAP_NET_ADMIN))
@@ -2518,7 +2533,6 @@ int dev_ioctl(unsigned int cmd, void *ar
 		case SIOCDELMULTI:
 		case SIOCSIFHWBROADCAST:
 		case SIOCSIFTXQLEN:
-		case SIOCSIFNAME:
 		case SIOCSMIIREG:
 		case SIOCBONDENSLAVE:
 		case SIOCBONDRELEASE:
