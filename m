From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Interface to query tun/tap features.
Date: Wed, 16 Jan 2008 23:07:43 +1100
Message-ID: <200801162307.43829.rusty@rustcorp.com.au>
References: <200801162306.27767.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Max Krasnyansky <maxk@qualcomm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53457 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbYAPMIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 07:08:18 -0500
In-Reply-To: <200801162306.27767.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem with introducing IFF_GSO_HDR is that it needs to set dev->features
(to enable GSO, checksumming, etc), which is supposed to be done before
register_netdevice(), ie. as part of TUNSETIFF.

Unfortunately, TUNSETIFF has always just ignored flags it doesn't understand,
so there's no good way of detecting whether the kernel supports IFF_GSO_HDR.

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
	{ IFF_GSO_HDR, "GSO_HDR" },
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
---
 drivers/net/tun.c      |    9 +++++++++
 include/linux/if_tun.h |    2 ++
 2 files changed, 11 insertions(+)

diff -r ba3c0eb8741a drivers/net/tun.c
--- a/drivers/net/tun.c	Wed Jan 16 17:35:25 2008 +1100
+++ b/drivers/net/tun.c	Wed Jan 16 22:11:11 2008 +1100
@@ -583,6 +779,15 @@ static int tun_chr_ioctl(struct inode *i
 		if (copy_to_user(argp, &ifr, sizeof(ifr)))
 			return -EFAULT;
 		return 0;
+	}
+
+	if (cmd == TUNGETFEATURES) {
+		/* Currently this just means: "what IFF flags are valid?".
+		 * This is needed because we never checked for invalid flags on
+		 * TUNSETIFF.  This was introduced with IFF_GSO_HDR, so if a
+		 * kernel doesn't have this ioctl, it doesn't have GSO header
+		 * support. */
+		return put_user(IFF_ALL_FLAGS, (unsigned int __user*)argp);
 	}
 
 	if (!tun)
diff -r ba3c0eb8741a include/linux/if_tun.h
--- a/include/linux/if_tun.h	Wed Jan 16 17:35:25 2008 +1100
+++ b/include/linux/if_tun.h	Wed Jan 16 22:11:11 2008 +1100
@@ -79,13 +80,15 @@ struct tun_struct {
 #define TUNSETOWNER   _IOW('T', 204, int)
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
+#define TUNGETFEATURES _IOR('T', 207, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
 #define IFF_TAP		0x0002
 #define IFF_NO_PI	0x1000
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_GSO_HDR	0x4000
+#define IFF_ALL_FLAGS (IFF_TUN|IFF_TAP|IFF_NO_PI|IFF_ONE_QUEUE|IFF_GSO_HDR)
 
 struct tun_pi {
 	unsigned short flags;
