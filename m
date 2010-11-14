From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] net: ipv4: tcp_probe: cleanup snprintf() use
Date: Sun, 14 Nov 2010 20:06:08 +0300
Message-ID: <1289754368-31660-1-git-send-email-segoon@openwall.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

snprintf() returns number of bytes that were copied if there is no overflow.
This code uses return value as number of copied bytes.  Theoretically format
string '%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u\n' may be expanded
up to 163 bytes.  In reality tv.tv_sec is just few bytes instead of 20, 2 ports
are just 5 bytes each instead of 10, length is 5 bytes instead of 10.  The rest
is an unstrusted input.  Theoretically if tv_sec is big then copy_to_user() would
overflow tbuf.

tbuf was increased to fit in 163 bytes.  snprintf() is used to follow return
value semantic.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested.

Format length:
	20 for '%lu'
	1 for '.'
	9 for '%09lu'
	1 for ' '
	15 for '%pI4'
	1 for ':'
	10 for '%u'
	1 for ' '
	15 for '%pI4'
	1 for ':'
	10 for '%u'
	1 for ' '
	11 for '%d'
	1 for ' '
	10 for '%#x'
	1 for ' '
	10 for '%#x'
	1 for ' '
	10 for '%u'
	1 for ' '
	10 for '%u'
	1 for ' '
	10 for '%u'
	1 for ' '
	10 for '%u'
	1 for '\n'
163 for '%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u\n'

 net/ipv4/tcp_probe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 6211e21..3b7bf19 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -154,7 +154,7 @@ static int tcpprobe_sprint(char *tbuf, int n)
 	struct timespec tv
 		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
 
-	return snprintf(tbuf, n,
+	return scnprintf(tbuf, n,
 			"%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u\n",
 			(unsigned long) tv.tv_sec,
 			(unsigned long) tv.tv_nsec,
@@ -174,7 +174,7 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 		return -EINVAL;
 
 	while (cnt < len) {
-		char tbuf[128];
+		char tbuf[164];
 		int width;
 
 		/* Wait for data in buffer */
-- 
1.7.0.4
