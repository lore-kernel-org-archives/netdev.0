From: Dong Zhu <bluezhudong@gmail.com>
Subject: Re: [PATCH] ptp: add the PTP_SYS_OFFSET ioctl to the testptp
 program clock
Date: Sat, 14 Sep 2013 23:39:52 +0800
Message-ID: <20130914153952.GD23682@zhudong.nay.redhat.com>
References: <20130914080306.GC23682@zhudong.nay.redhat.com>
 <20130914143144.GA4206@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130914143144.GA4206@netboy>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 14, 2013 at 04:31:46PM +0200, Richard Cochran wrote:
> On Sat, Sep 14, 2013 at 04:03:06PM +0800, Dong Zhu wrote:
> > This patch add a method into testptp.c to measure the time offset
> > between phc and system clock through the ioctl PTP_SYS_OFFSET.
> > 
> 
> This is a nice addition to the testptp program. I do have a few
> comments, below.
> 

Thanks very much for your comments, I have modified the patch as below,
Cuold you have a look at it again ? Any comments would be appreciated.

>From 655b45785a85599d5fff5eb3b8d9b49b72f2991f Mon Sep 17 00:00:00 2001
From: Dong Zhu <bluezhudong@gmail.com> 
Date: Sat, 14 Sep 2013 23:32:14 +0800

This patch add a method into testptp.c to measure the time offset
between phc and system clock through the ioctl PTP_SYS_OFFSET.

Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
---
 Documentation/ptp/testptp.c | 40 ++++++++++++++++++++++++++++++++++++++--
 1 file changed, 38 insertions(+), 2 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index f59ded0..8acdc70 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -112,6 +112,8 @@ static void usage(char *progname)
 		" -f val     adjust the ptp clock frequency by 'val' ppb\n"
 		" -g         get the ptp clock time\n"
 		" -h         prints this message\n"
+		" -k val     measure the time offset between phc and system clock "
+		"for 'val' times (Maximum 25)\n"
 		" -p val     enable output with a period of 'val' nanoseconds\n"
 		" -P val     enable or disable (val=1|0) the system clock PPS\n"
 		" -s         set the ptp clock time from the system time\n"
@@ -133,8 +135,12 @@ int main(int argc, char *argv[])
 	struct itimerspec timeout;
 	struct sigevent sigevent;
 
+	struct ptp_clock_time *pct;
+	struct ptp_sys_offset *sysoff;
+
+
 	char *progname;
-	int c, cnt, fd;
+	int i, c, cnt, fd;
 
 	char *device = DEVICE;
 	clockid_t clkid;
@@ -144,6 +150,8 @@ int main(int argc, char *argv[])
 	int extts = 0;
 	int gettime = 0;
 	int oneshot = 0;
+	int offset = 0;
+	int n_samples = 0;
 	int periodic = 0;
 	int perout = -1;
 	int pps = -1;
@@ -151,7 +159,7 @@ int main(int argc, char *argv[])
 
 	progname = strrchr(argv[0], '/');
 	progname = progname ? 1+progname : argv[0];
-	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghp:P:sSt:v"))) {
+	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:v"))) {
 		switch (c) {
 		case 'a':
 			oneshot = atoi(optarg);
@@ -174,6 +182,10 @@ int main(int argc, char *argv[])
 		case 'g':
 			gettime = 1;
 			break;
+		case 'k':
+			offset = 1;
+			n_samples = atoi(optarg);
+			break;
 		case 'p':
 			perout = atoi(optarg);
 			break;
@@ -376,6 +388,30 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (offset) {
+		sysoff = calloc(1, sizeof(*sysoff));
+		if (!sysoff) {
+			perror("calloc");
+			return -1;
+		}
+		sysoff->n_samples = n_samples;
+
+		if (ioctl(fd, PTP_SYS_OFFSET, sysoff))
+			perror("PTP_SYS_OFFSET");
+		else
+			puts("phc and system clock time offset request okay");
+
+		pct = &sysoff->ts[0];
+		for (i = 0; i < sysoff->n_samples; i++, pct++) {
+			printf("system time: %ld.%ld\n", pct->sec, pct->nsec);
+			pct++;
+			printf("phc    time: %ld.%ld\n", pct->sec, pct->nsec);
+		}
+		printf("system time: %ld.%ld\n", pct->sec, pct->nsec);
+
+		free(sysoff);
+	}
+
 	close(fd);
 	return 0;
 }
-- 
1.7.11.7

-- 
Best Regards,
Dong Zhu
