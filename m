From: Andrew Morton <akpm@osdl.org>
Subject: Fw: unregister_netdevice(): negative refcnt, suggest patch against
 2.6.11
Date: Sun, 10 Apr 2005 03:44:46 -0700
Message-ID: <20050410034446.39e3025e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Sun__10_Apr_2005_03_44_46_-0700_Adc8qDJbGBrDBpST"
Cc: Felix Palmen <fmp@palmen.homeip.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Sun__10_Apr_2005_03_44_46_-0700_Adc8qDJbGBrDBpST
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


That sounds like a bug in appletalk or in the tap driver.  Please describe
a means by which other developers can reproduce that bug (a sequence of
shell commands would be ideal).

Thanks.



Begin forwarded message:

Date: Sun, 10 Apr 2005 11:16:25 +0200
From: Felix Palmen <fmp@palmen.homeip.net>
To: linux-kernel@vger.kernel.org
Subject: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11


Hi lkml-members,

I recently had a problem with appletalk. After starting atalkd on a TAP
interface and stopping it later, unregister_netdevice() just stated
| unregister_netdevice: waiting for tap0 to become free. Usage count = -1

So I assume there is a problem in the appletalk code, but I didn't try
reproducing that on other systems so far.

I changed my kernel to "correct" a negative refcnt to 0 and that kind
of fixes the problem. I'm not sure whether this could break anything,
but certainly waiting for a device to become free is no use when there
is a negative number of users, so I think it would be better to allow
the system to shut down cleanly in this case.

Here's m suggestion:

#v+
--- linux-2.6.11-orig/net/core/dev.c 2005-03-02 08:38:09.000000000 +0100
+++ linux-2.6.11/net/core/dev.c    2005-04-09 16:44:42.000000000 +0200
@@ -2876,7 +2876,7 @@
	unsigned long rebroadcast_time, warning_time;

	rebroadcast_time = warning_time = jiffies;
-	while (atomic_read(&dev->refcnt) != 0) {
+	while (atomic_read(&dev->refcnt) > 0) {
		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
			rtnl_shlock();

@@ -2910,6 +2910,13 @@
			warning_time = jiffies;
		}
	}
+	if (atomic_read(&dev->refcnt) != 0) {
+		printk(KERN_ERR "unregister_netdevice: "
+			"%s has negative refcnt (%d). "
+			"This should never happen! Setting refcnt to 0.\n",
+			dev->name, atomic_read(&dev->refcnt));
+		atomic_set(&dev->refcnt, 0);
+	}
 }

 /* The sequence is:
#v-

Greets, Felix

PS: Please note I'm not subscribed to lkml and CC me in replies, thanks.

-- 
 | /"\   ASCII Ribbon   | Felix M. Palmen (Zirias)    http://zirias.ath.cx/ |
 | \ / Campaign Against | fmp@palmen.homeip.net      encrypted mail welcome |
 |  X    HTML In Mail   | PGP key: http://zirias.ath.cx/pub.txt             |
 | / \     And News     | ED9B 62D0 BE39 32F9 2488 5D0C 8177 9D80 5ECF F683 |


--Multipart=_Sun__10_Apr_2005_03_44_46_-0700_Adc8qDJbGBrDBpST
Content-Type: application/pgp-signature;
 name="signature.asc"
Content-Disposition: attachment;
 filename="signature.asc"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuMi41IChHTlUv
TGludXgpCgppUUNWQXdVQlFsanU2UVNxKzNneEc5Y05BUUpHV1FQOENnSFA3NFJCRDdEQldTLzhE
MXV2U2JrOFUyaEY1TmM5CkUrQmdUT2NGYjM0NVlDVnFTUHluajBjT1IxSVNMMmVTWTdOWERKanBE
QXhGbkY1U1kvY091bGdxRkozTEhXSjQKa2l2azh1eXNUc1ZhZ2pGandUSmQ2ejRyRnhJd1IwVjR0
UmpGYk4wQkxhR3RPc2Z3T2Jqd0tkdk82WVQydEJVNwpGc0J3Tm5raWZDWT0KPUZPbU0KLS0tLS1F
TkQgUEdQIFNJR05BVFVSRS0tLS0tCgo=

--Multipart=_Sun__10_Apr_2005_03_44_46_-0700_Adc8qDJbGBrDBpST--
