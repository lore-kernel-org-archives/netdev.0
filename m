From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/3] Interface to query tun/tap features.
Date: Thu, 24 Jan 2008 01:14:18 +1100
Message-ID: <200801240114.18571.rusty@rustcorp.com.au>
References: <200801240107.38929.rusty@rustcorp.com.au> <200801240110.45178.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60227 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504AbYAWOXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 09:23:40 -0500
In-Reply-To: <200801240110.45178.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(No real change, just updated with new bits)

The problem with introducing IFF_RECV_CSUM and IFF_RECV_GSO is that
they need to set dev->features to enable GSO and/or checksumming,
which is supposed to be done before register_netdevice(), ie. as part
of TUNSETIFF.

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
	{ IFF_VIRTIO_HDR, "VIRTIO_HDR" },
	{ IFF_RECV_CSUM, "RECV_CSUM" },
	{ IFF_RECV_GSO, "RECV_GSO" },
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
 drivers/net/tun.c      |    9 +++++++++
 include/linux/if_tun.h |    3 +++
 2 files changed, 12 insertions(+)

diff -r c0e7a8b99325 drivers/net/tun.c
--- a/drivers/net/tun.c	Wed Jan 23 20:12:51 2008 +1100
+++ b/drivers/net/tun.c	Wed Jan 23 20:17:28 2008 +1100
@@ -790,6 +790,15 @@ static int tun_chr_ioctl(struct inode *i
 		return 0;
 	}
 
+	if (cmd == TUNGETFEATURES) {
+		/* Currently this just means: "what IFF flags are valid?".
+		 * This is needed because we never checked for invalid flags on
+		 * TUNSETIFF.  This was introduced with IFF_GSO_HDR, so if a
+		 * kernel doesn't have this ioctl, it doesn't have GSO header
+		 * support. */
+		return put_user(IFF_ALL_FLAGS, (unsigned int __user*)argp);
+	}
+
 	if (!tun)
 		return -EBADFD;
 
diff -r c0e7a8b99325 include/linux/if_tun.h
--- a/include/linux/if_tun.h	Wed Jan 23 20:12:51 2008 +1100
+++ b/include/linux/if_tun.h	Wed Jan 23 20:17:28 2008 +1100
@@ -82,6 +82,7 @@ struct tun_struct {
 #define TUNSETOWNER   _IOW('T', 204, int)
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
+#define TUNGETFEATURES _IOR('T', 207, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
@@ -91,6 +92,8 @@ struct tun_struct {
 #define IFF_VIRTIO_HDR	0x4000
 #define IFF_RECV_CSUM	0x8000
 #define IFF_RECV_GSO	0x0800
+#define IFF_ALL_FLAGS (IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE | \
+		       IFF_VIRTIO_HDR | IFF_RECV_CSUM | IFF_RECV_GSO)
 
 struct tun_pi {
 	unsigned short flags;
