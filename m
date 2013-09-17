From: Dong Zhu <bluezhudong@gmail.com>
Subject: Re: [PATCH net-next v4] ptp: add the PTP_SYS_OFFSET ioctl to the
 testptp program
Date: Tue, 17 Sep 2013 15:32:35 +0800
Message-ID: <20130917073235.GG23682@zhudong.nay.redhat.com>
References: <20130914080306.GC23682@zhudong.nay.redhat.com>
 <20130914143144.GA4206@netboy>
 <20130914153952.GD23682@zhudong.nay.redhat.com>
 <20130915084811.GA10163@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130915084811.GA10163@netboy>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

I developed a new patch and added a method to estimate the time offset
between system and phc clock.

Could you help reviewing it again ? If it do make sense I hope it could
be accepted.

Thanks !

>From e524e3b68f3df3cd91acd814490d092bad05386b Mon Sep 17 00:00:00 2001

This patch add a method into testptp.c to measure the time offset
between phc and system clock through the ioctl PTP_SYS_OFFSET.

Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
---
 Documentation/ptp/testptp.c | 65 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index f59ded0..a74d0a8 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -100,6 +100,11 @@ static long ppb_to_scaled_ppm(int ppb)
 	return (long) (ppb * 65.536);
 }
 
+static int64_t pctns(struct ptp_clock_time *t)
+{
+	return t->sec * 1000000000LL + t->nsec;
+}
+
 static void usage(char *progname)
 {
 	fprintf(stderr,
@@ -112,6 +117,8 @@ static void usage(char *progname)
 		" -f val     adjust the ptp clock frequency by 'val' ppb\n"
 		" -g         get the ptp clock time\n"
 		" -h         prints this message\n"
+		" -k val     measure the time offset between system and phc clock\n"
+		"            for 'val' times (Maximum 25)\n"
 		" -p val     enable output with a period of 'val' nanoseconds\n"
 		" -P val     enable or disable (val=1|0) the system clock PPS\n"
 		" -s         set the ptp clock time from the system time\n"
@@ -133,8 +140,12 @@ int main(int argc, char *argv[])
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
@@ -144,14 +155,19 @@ int main(int argc, char *argv[])
 	int extts = 0;
 	int gettime = 0;
 	int oneshot = 0;
+	int pct_offset = 0;
+	int n_samples = 0;
 	int periodic = 0;
 	int perout = -1;
 	int pps = -1;
 	int settime = 0;
 
+	int64_t t1, t2, tp;
+	int64_t interval, offset;
+
 	progname = strrchr(argv[0], '/');
 	progname = progname ? 1+progname : argv[0];
-	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghp:P:sSt:v"))) {
+	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:v"))) {
 		switch (c) {
 		case 'a':
 			oneshot = atoi(optarg);
@@ -174,6 +190,10 @@ int main(int argc, char *argv[])
 		case 'g':
 			gettime = 1;
 			break;
+		case 'k':
+			pct_offset = 1;
+			n_samples = atoi(optarg);
+			break;
 		case 'p':
 			perout = atoi(optarg);
 			break;
@@ -376,6 +396,47 @@ int main(int argc, char *argv[])
 		}
 	}
 
+	if (pct_offset) {
+		if (n_samples <= 0 || n_samples > 25) {
+			puts("n_samples should be between 1 and 25");
+			usage(progname);
+			return -1;
+		}
+
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
+			puts("system and phc clock time offset request okay");
+
+		pct = &sysoff->ts[0];
+		for (i = 0; i < sysoff->n_samples; i++) {
+			t1 = pctns(pct+2*i);
+			tp = pctns(pct+2*i+1);
+			t2 = pctns(pct+2*i+2);
+			interval = t2 - t1;
+			offset = (t2 + t1) / 2 - tp;
+
+			printf("system time: %ld.%ld\n",
+				(pct+2*i)->sec, (pct+2*i)->nsec);
+			printf("phc    time: %ld.%ld\n",
+				(pct+2*i+1)->sec, (pct+2*i+1)->nsec);
+			printf("system time: %ld.%ld\n",
+				(pct+2*i+2)->sec, (pct+2*i+2)->nsec);
+			printf("system/phc clock time offset is %ld ns\n"
+				"system     clock time delay  is %ld ns\n",
+				offset, interval);
+		}
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
