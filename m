From: Robin Holt <holt@sgi.com>
Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers to prevent integer overflows.
Date: Wed, 20 Oct 2010 07:03:37 -0500
Message-ID: <20101020120345.436404838@gulag1.americas.sgi.com>
References: <20101020120336.967805943@gulag1.americas.sgi.com>
Cc: Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sysctl_tcp_udp_mem_max_overflows
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers to prevent integer overflows.

On a 16TB x86_64 machine, sysctl_tcp_mem[2], sysctl_udp_mem[2], and
sysctl_sctp_mem[2] can integer overflow.  Set limit such that they are
maximized without overflowing.

Signed-off-by: Robin Holt <holt@sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Cc: Willy Tarreau <w@1wt.eu>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-sctp@vger.kernel.org
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>

---

David, I believe this is also intended for stable.  If you agree, please
add the stable maintainers to the Cc: list.

 net/ipv4/tcp.c      |    4 +++-
 net/ipv4/udp.c      |    4 +++-
 net/sctp/protocol.c |    4 +++-
 3 files changed, 9 insertions(+), 3 deletions(-)

Index: pv1010932/net/ipv4/tcp.c
===================================================================
--- pv1010932.orig/net/ipv4/tcp.c	2010-10-02 06:11:59.737449853 -0500
+++ pv1010932/net/ipv4/tcp.c	2010-10-02 06:12:35.445454593 -0500
@@ -3271,12 +3271,14 @@ void __init tcp_init(void)
 
 	/* Set the pressure threshold to be a fraction of global memory that
 	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
-	 * memory, with a floor of 128 pages.
+	 * memory, with a floor of 128 pages, and a ceiling that prevents an
+	 * integer overflow.
 	 */
 	nr_pages = totalram_pages - totalhigh_pages;
 	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
 	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
+	limit = min(limit, INT_MAX * 4UL / 3 / 2);
 	sysctl_tcp_mem[0] = limit / 4 * 3;
 	sysctl_tcp_mem[1] = limit;
 	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
Index: pv1010932/net/ipv4/udp.c
===================================================================
--- pv1010932.orig/net/ipv4/udp.c	2010-10-02 06:11:59.737449853 -0500
+++ pv1010932/net/ipv4/udp.c	2010-10-02 06:12:35.453453784 -0500
@@ -2167,12 +2167,14 @@ void __init udp_init(void)
 	udp_table_init(&udp_table, "UDP");
 	/* Set the pressure threshold up by the same strategy of TCP. It is a
 	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
-	 * toward zero with the amount of memory, with a floor of 128 pages.
+	 * toward zero with the amount of memory, with a floor of 128 pages,
+	 * and a ceiling that prevents an integer overflow.
 	 */
 	nr_pages = totalram_pages - totalhigh_pages;
 	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
 	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
+	limit = min(limit, INT_MAX * 4UL / 3 / 2);
 	sysctl_udp_mem[0] = limit / 4 * 3;
 	sysctl_udp_mem[1] = limit;
 	sysctl_udp_mem[2] = sysctl_udp_mem[0] * 2;
Index: pv1010932/net/sctp/protocol.c
===================================================================
--- pv1010932.orig/net/sctp/protocol.c	2010-10-02 06:11:59.000000000 -0500
+++ pv1010932/net/sctp/protocol.c	2010-10-02 06:13:17.727949810 -0500
@@ -1162,7 +1162,8 @@ SCTP_STATIC __init int sctp_init(void)
 
 	/* Set the pressure threshold to be a fraction of global memory that
 	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
-	 * memory, with a floor of 128 pages.
+	 * memory, with a floor of 128 pages, and a ceiling that prevents an
+	 * integer overflow.
 	 * Note this initializes the data in sctpv6_prot too
 	 * Unabashedly stolen from tcp_init
 	 */
@@ -1170,6 +1171,7 @@ SCTP_STATIC __init int sctp_init(void)
 	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
 	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
+	limit = min(limit, INT_MAX * 4UL / 3 / 2);
 	sysctl_sctp_mem[0] = limit / 4 * 3;
 	sysctl_sctp_mem[1] = limit;
 	sysctl_sctp_mem[2] = sysctl_sctp_mem[0] * 2;
