From: Greg KH <gregkh@suse.de>
Subject: [097/127] Limit sysctl_tcp_mem and sysctl_udp_mem initializers to prevent integer overflows.
Date: Tue, 07 Dec 2010 16:44:43 -0800
Message-ID: <20101208004434.013045349@clark.site>
References: <20101208004456.GA23578@kroah.com>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Robin Holt <holt@sgi.com>, Willy Tarreau <w@1wt.eu>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101208004456.GA23578@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.32-stable review patch.  If anyone has any objections, please let us know.

------------------


From: Robin Holt <holt@sgi.com>

[ Upstream fixed this in a different way. -DaveM ]

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
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 net/ipv4/tcp.c      |    4 +++-
 net/ipv4/udp.c      |    4 +++-
 net/sctp/protocol.c |    4 +++-
 3 files changed, 9 insertions(+), 3 deletions(-)

--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2940,12 +2940,14 @@ void __init tcp_init(void)
 
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
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1832,12 +1832,14 @@ void __init udp_init(void)
 	udp_table_init(&udp_table);
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
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1157,7 +1157,8 @@ SCTP_STATIC __init int sctp_init(void)
 
 	/* Set the pressure threshold to be a fraction of global memory that
 	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
-	 * memory, with a floor of 128 pages.
+	 * memory, with a floor of 128 pages, and a ceiling that prevents an
+	 * integer overflow.
 	 * Note this initalizes the data in sctpv6_prot too
 	 * Unabashedly stolen from tcp_init
 	 */
@@ -1165,6 +1166,7 @@ SCTP_STATIC __init int sctp_init(void)
 	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
 	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
+	limit = min(limit, INT_MAX * 4UL / 3 / 2);
 	sysctl_sctp_mem[0] = limit / 4 * 3;
 	sysctl_sctp_mem[1] = limit;
 	sysctl_sctp_mem[2] = sysctl_sctp_mem[0] * 2;
