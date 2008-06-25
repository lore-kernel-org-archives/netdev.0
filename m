From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/4] tun: Interface to query tun/tap features.
Date: Thu, 26 Jun 2008 00:28:07 +1000
Message-ID: <200806260028.07883.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39641 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbYFYO3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 10:29:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem with introducing checksum offload and gso to tun is they
need to set dev->features to enable GSO and/or checksumming, which is
supposed to be done before register_netdevice(), ie. as part of
TUNSETIFF.

Unfortunately, TUNSETIFF has always just ignored flags it doesn't
understand, so there's no good way of detecting whether the kernel
supports new IFF_ flags.

This patch implements a TUNGETFEATURES ioctl which returns all the valid IFF
flags.  It could be extended later to include other features.

Here's an example program which uses it:

#include <linux/if_tun.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <err.h>
#include <stdio.h>

static struct {
	unsigned int flag;
	const char *name;
} known_flags[] = {
	{ IFF_TUN, "TUN" },
	{ IFF_TAP, "TAP" },
	{ IFF_NO_PI, "NO_PI" },
	{ IFF_ONE_QUEUE, "ONE_QUEUE" },
};

int main()
{
	unsigned int features, i;

	int netfd = open("/dev/net/tun", O_RDWR);
	if (netfd < 0)
		err(1, "Opening /dev/net/tun");

	if (ioctl(netfd, TUNGETFEATURES, &features) != 0) {
		printf("Kernel does not support TUNGETFEATURES, guessing\n");
		features = (IFF_TUN|IFF_TAP|IFF_NO_PI|IFF_ONE_QUEUE);
	}
	printf("Available features are: ");
	for (i = 0; i < sizeof(known_flags)/sizeof(known_flags[0]); i++) {
		if (features & known_flags[i].flag) {
			features &= ~known_flags[i].flag;
			printf("%s ", known_flags[i].name);
		}
	}
	if (features)
		printf("(UNKNOWN %#x)", features);
	printf("\n");
	return 0;
}

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/tun.c      |    8 ++++++++
 include/linux/if_tun.h |    1 +
 2 files changed, 9 insertions(+)

diff -r 8414a579e106 drivers/net/tun.c
--- a/drivers/net/tun.c	Tue Apr 22 07:36:45 2008 +1000
+++ b/drivers/net/tun.c	Tue Apr 22 07:37:33 2008 +1000
@@ -625,6 +625,14 @@ static int tun_chr_ioctl(struct inode *i
 		return 0;
 	}
 
+	if (cmd == TUNGETFEATURES) {
+		/* Currently this just means: "what IFF flags are valid?".
+		 * This is needed because we never checked for invalid flags on
+		 * TUNSETIFF. */
+		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE,
+				(unsigned int __user*)argp);
+	}
+
 	if (!tun)
 		return -EBADFD;
 
diff -r 8414a579e106 include/linux/if_tun.h
--- a/include/linux/if_tun.h	Tue Apr 22 07:36:45 2008 +1000
+++ b/include/linux/if_tun.h	Tue Apr 22 07:37:33 2008 +1000
@@ -42,6 +42,7 @@
 #define TUNSETOWNER   _IOW('T', 204, int)
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
+#define TUNGETFEATURES _IOR('T', 207, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
