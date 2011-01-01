From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Sun, 2 Jan 2011 05:38:19 +0900
Message-ID: <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
References: <cover.1293820862.git.richard.cochran@omicron.at> <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 1, 2011 at 4:12 AM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> +#define ADJ_SETOFFSET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00x0040 =C2=A0=
/* add 'time' to current time */

As you know, it conflicts with MOD_PPSMAX.  And also, it is logically
the same as ADJ_OFFSET, unless the kernel PLL is enabled explicitly.

So here's my simple solution:

---
diff --git a/kernel/time/ntp.c b/kernel/time/ntp.c
index c631168..d492887 100644
--- a/kernel/time/ntp.c
+++ b/kernel/time/ntp.c
@@ -119,14 +119,21 @@
 	return div_s64(offset64 << (NTP_SCALE_SHIFT - SHIFT_FLL), secs);
 }

-static void ntp_update_offset(long offset)
+static void ntp_update_offset(long offset, struct timespec *ts)
 {
 	s64 freq_adj;
 	s64 offset64;
 	long secs;

-	if (!(time_status & STA_PLL))
+	if (!(time_status & STA_PLL)) {
+		offset64 =3D offset;
+		if (!(time_status & STA_NANO))
+			offset64 *=3D NSEC_PER_USEC;
+
+		set_normalized_timespec(ts, ts->tv_sec, offset64 + ts->tv_nsec);
+
 		return;
+	}

 	if (!(time_status & STA_NANO))
 		offset *=3D NSEC_PER_USEC;
@@ -430,7 +437,7 @@
 		time_tai =3D txc->constant;

 	if (txc->modes & ADJ_OFFSET)
-		ntp_update_offset(txc->offset);
+		ntp_update_offset(txc->offset, ts);

 	if (txc->modes & ADJ_TICK)
 		tick_usec =3D txc->tick;
@@ -526,6 +533,9 @@

 	write_sequnlock_irq(&xtime_lock);

+	if ((txc->modes & ADJ_OFFSET) && !(time_status & STA_PLL))
+		do_settimeofday(&ts);
+
 	txc->time.tv_sec =3D ts.tv_sec;
 	txc->time.tv_usec =3D ts.tv_nsec;
 	if (!(time_status & STA_NANO))
--
