From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 15 Jun 2010 15:29:54 +0200
Message-ID: <1276608594.2541.119.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <1276596856.2541.84.camel@edumazet-laptop> <20100615102541.GH6138@laptop>
	 <1276598605.2541.96.camel@edumazet-laptop>  <20100615110413.GJ6138@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34337 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab0FONaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 09:30:01 -0400
Received: by mail-ww0-f46.google.com with SMTP id 18so4770359wwb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 06:30:00 -0700 (PDT)
In-Reply-To: <20100615110413.GJ6138@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 21:04 +1000, Nick Piggin a =C3=A9crit :
> On Tue, Jun 15, 2010 at 12:43:25PM +0200, Eric Dumazet wrote:

> > I'll submit a v2 patch after my lunch to add all your comments, bec=
ause
> > all clarifications are indeed very very welcomed !
>=20
> Thanks!

Here is second version of the patch, with infrastructure only.

I chose to add a new include file, and document API in same file instea=
d
of Documentation/somefile

Once accepted, I'll provide the loopback driver update.

Thanks !

[PATCH net-next-2.6 v2] net: Introduce u64_stats_sync infrastructure

To properly implement 64bits network statistics on 32bit or 64bit hosts=
,
we provide one new type and four methods, to ease conversions.

Stats producer should use following template granted it already got an
exclusive access to counters (include/linux/u64_stats_sync.h contains
some documentation about details)

    u64_stats_update_begin(&stats->syncp);
    stats->bytes64 +=3D len;
    stats->packets64++;
    u64_stats_update_end(&stats->syncp);

While a consumer should use following template to get consistent
snapshot :

    u64 tbytes, tpackets;
    unsigned int start;

    do {
        start =3D u64_stats_fetch_begin(&stats->syncp);
        tbytes =3D stats->bytes64;
        tpackets =3D stats->packets64;
    } while (u64_stats_fetch_retry(&stats->lock, syncp));


Suggested by David Miller, and comments courtesy of Nick Piggin.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Nick Piggin <npiggin@suse.de>
---
 include/linux/u64_stats_sync.h |  107 +++++++++++++++++++++++++++++++
 1 file changed, 107 insertions(+)

diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_s=
ync.h
index e69de29..5a4f318 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -0,0 +1,107 @@
+#ifndef _LINUX_U64_STATS_SYNC_H
+#define _LINUX_U64_STATS_SYNC_H
+
+/*
+ * To properly implement 64bits network statistics on 32bit and 64bit =
hosts,
+ * we provide a synchronization point, that is a noop on 64bit or UP k=
ernels.
+ *
+ * Key points :
+ * 1) Use a seqcount on SMP 32bits, with low overhead.
+ * 2) Whole thing is a noop on 64bit arches or UP kernels.
+ * 3) Write side must ensure mutual exclusion or one seqcount update c=
ould
+ *    be lost, thus blocking readers forever.
+ *    If this synchronization point is not a mutex, but a spinlock or=20
+ *    spinlock_bh() or disable_bh() :
+ * 3.1) Write side should not sleep.
+ * 3.2) Write side should not allow preemption.
+ * 3.3) If applicable, interrupts should be disabled.
+ *
+ * 4) If reader fetches several counters, there is no guarantee the wh=
ole values
+ *    are consistent (remember point 1) : this is a noop on 64bit arch=
es anyway)
+ *
+ * 5) readers are allowed to sleep or be preempted/interrupted : They =
perform
+ *    pure reads. But if they have to fetch many values, it's better t=
o not allow
+ *    preemptions/interruptions to avoid many retries.
+ *
+ * Usage :
+ *
+ * Stats producer (writer) should use following template granted it al=
ready got
+ * an exclusive access to counters (a lock is already taken, or per cp=
u
+ * data is used [in a non preemptable context])
+ *=20
+ *   spin_lock_bh(...) or other synchronization to get exclusive acces=
s
+ *   ...
+ *   u64_stats_update_begin(&stats->syncp);
+ *   stats->bytes64 +=3D len; // non atomic operation
+ *   stats->packets64++;    // non atomic operation=20
+ *   u64_stats_update_end(&stats->syncp);
+ *
+ * While a consumer (reader) should use following template to get cons=
istent
+ * snapshot for each variable (but no guarantee on several ones)
+ *
+ * u64 tbytes, tpackets;
+ * unsigned int start;
+ *
+ * do {
+ *         start =3D u64_stats_fetch_begin(&stats->syncp);
+ *         tbytes =3D stats->bytes64; // non atomic operation
+ *         tpackets =3D stats->packets64; // non atomic operation
+ * } while (u64_stats_fetch_retry(&stats->lock, syncp));
+ *
+ *
+ * Example of use in drivers/net/loopback.c, using per_cpu containers,
+ * in BH disabled context.
+ */
+#include <linux/seqlock.h>
+
+#if BITS_PER_LONG=3D=3D32 && defined(CONFIG_SMP)
+struct u64_stats_sync {
+	seqcount_t	seq;
+};
+
+static void inline u64_stats_update_begin(struct u64_stats_sync *syncp=
)
+{
+	write_seqcount_begin(&syncp->seq);
+}
+
+static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
+{
+	write_seqcount_end(&syncp->seq);
+}
+
+static unsigned int inline u64_stats_fetch_begin(const struct u64_stat=
s_sync *syncp)
+{
+	return read_seqcount_begin(&syncp->seq);
+}
+
+static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *=
syncp,
+					 unsigned int start)
+{
+	return read_seqcount_retry(&syncp->seq, start);
+}
+
+#else
+struct u64_stats_sync {
+};
+
+static void inline u64_stats_update_begin(struct u64_stats_sync *syncp=
)
+{
+}
+
+static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
+{
+}
+
+static unsigned int inline u64_stats_fetch_begin(const struct u64_stat=
s_sync *syncp)
+{
+	return 0;
+}
+
+static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *=
syncp,
+					 unsigned int start)
+{
+	return false;
+}
+#endif
+
+#endif /* _LINUX_U64_STATS_SYNC_H */


