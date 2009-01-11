From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] net: ppp_generic - fix broken userspace
Date: Sun, 11 Jan 2009 10:32:52 +0300
Message-ID: <20090111073252.GA7686@localhost>
References: <20090110202802.GF29349@localhost> <20090110203112.GG29349@localhost> <18793.15831.279207.252421@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	James Chapman <jchapman@katalix.com>,
	LKML <linux-kernel@vger.kernel.org>,
	NKML <netdev@vger.kernel.org>
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:43701 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbZAKHc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:32:57 -0500
Content-Disposition: inline
In-Reply-To: <18793.15831.279207.252421@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Paul Mackerras - Sun, Jan 11, 2009 at 11:31:19AM +1100]
| Cyrill Gorcunov writes:
| 
| > Ugh, forgot to CC Paul...
| > ...
| > 
| > 		- Cyrill -
| 
| Forgot to cc me on what?
| 
| Judging by the subject, it sounds like I'm not going to like it...
| 
| Paul.
| 

On this http://lkml.org/lkml/2009/1/10/185
I stripped the patch body since I thought
you're subscribed to LKML. Here is the patch
so you don't need to search it.

		- Cyrill -
---
Subject: [PATCH] net: ppp_generic - fix broken userspace

The commits:

	7a95d267fb62cd6b80ef73be0592bbbe1dbd5df7
	ab5024ab23b78c86a0a1425defcdde48710fe449

introduced usage of IDR functionality but broke
userspace side.

Before this commits it was possible to allocate new ppp
interface with specified number. Now it fails with EINVAL.
Fix it by trying to allocate interface with specified unit
number and return EEXIST if fail which allow pppd to ask
us to allocate new unit number.

And fix messages on memory allocation fails - add details
that it's PPP module who is complaining.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

If this is not a right way to fix this issue maybe better
would be to just revert the commits mentioned. Please
review carefully. Thanks!

 drivers/net/ppp_generic.c |   43 +++++++++++++++++++++++++++++++++++++------
 1 file changed, 37 insertions(+), 6 deletions(-)

Index: linux-2.6.git/drivers/net/ppp_generic.c
===================================================================
--- linux-2.6.git.orig/drivers/net/ppp_generic.c
+++ linux-2.6.git/drivers/net/ppp_generic.c
@@ -250,6 +250,7 @@ static int ppp_connect_channel(struct ch
 static int ppp_disconnect_channel(struct channel *pch);
 static void ppp_destroy_channel(struct channel *pch);
 static int unit_get(struct idr *p, void *ptr);
+static int unit_set(struct idr *p, void *ptr, int n);
 static void unit_put(struct idr *p, int n);
 static void *unit_find(struct idr *p, int n);
 
@@ -2432,11 +2433,18 @@ ppp_create_interface(int unit, int *retp
 	} else {
 		if (unit_find(&ppp_units_idr, unit))
 			goto out2; /* unit already exists */
-		else {
-			/* darn, someone is cheating us? */
-			*retp = -EINVAL;
+		/*
+		 * if caller need a specified unit number
+		 * lets try to satisfy him, otherwise --
+		 * he should better ask us for new unit number
+		 *
+		 * NOTE: yes I know that returning EEXIST it's not
+		 * fair but at least pppd will ask us to allocate
+		 * new unit in this case so user is happy :)
+		 */
+		unit = unit_set(&ppp_units_idr, ppp, unit);
+		if (unit < 0)
 			goto out2;
-		}
 	}
 
 	/* Initialize the new ppp unit */
@@ -2677,14 +2685,37 @@ static void __exit ppp_cleanup(void)
  * by holding all_ppp_mutex
  */
 
+/* associate pointer with specified number */
+static int unit_set(struct idr *p, void *ptr, int n)
+{
+	int unit, err;
+
+again:
+	if (!idr_pre_get(p, GFP_KERNEL)) {
+		printk(KERN_ERR "PPP: No free memory for idr\n");
+		return -ENOMEM;
+	}
+
+	err = idr_get_new_above(p, ptr, n, &unit);
+	if (err == -EAGAIN)
+		goto again;
+
+	if (unit != n) {
+		idr_remove(p, unit);
+		return -EINVAL;
+	}
+
+	return unit;
+}
+
 /* get new free unit number and associate pointer with it */
 static int unit_get(struct idr *p, void *ptr)
 {
 	int unit, err;
 
 again:
-	if (idr_pre_get(p, GFP_KERNEL) == 0) {
-		printk(KERN_ERR "Out of memory expanding drawable idr\n");
+	if (!idr_pre_get(p, GFP_KERNEL)) {
+		printk(KERN_ERR "PPP: No free memory for idr\n");
 		return -ENOMEM;
 	}
 
