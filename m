From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/3] tun: Interface to query tun/tap features.
Date: Thu, 3 Jul 2008 11:32:12 +1000
Message-ID: <200807031132.12810.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

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
