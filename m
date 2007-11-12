From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 01/05] ipv6: RFC4214 Support (4)
Date: Mon, 12 Nov 2007 07:54:23 -0800
Message-ID: <4738772F.6040907@yahoo.com>
References: <473371B3.5030908@yahoo.com> <4734FCEF.3080301@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.plus.mail.sp1.yahoo.com ([69.147.95.73]:32830 "HELO
	smtp110.plus.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751029AbXKLSht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 13:37:49 -0500
In-Reply-To: <4734FCEF.3080301@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.24-rc2/include/linux/if.h.orig    2007-11-08 12:05:47.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/if.h 2007-11-08 08:26:44.000000000 -0800
@@ -61,6 +61,7 @@
  #define IFF_MASTER_ALB 0x10            /* bonding master, balance-alb. */
  #define IFF_BONDING    0x20            /* bonding master or slave      */
  #define IFF_SLAVE_NEEDARP 0x40         /* need ARPs for validation     */
+#define IFF_ISATAP     0x80            /* ISATAP interface (RFC4214)   */

  #define IF_GET_IFACE   0x0001          /* for querying only */
  #define IF_GET_PROTO   0x0002
--- linux-2.6.24-rc2/include/linux/in.h.orig    2007-11-09 08:00:32.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/in.h 2007-11-12 07:37:05.000000000 -0800
@@ -253,6 +253,14 @@ struct sockaddr_in {
  #define ZERONET(x)     (((x) & htonl(0xff000000)) == htonl(0x00000000))
  #define LOCAL_MCAST(x) (((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))

+/* Special-Use IPv4 Addresses (RFC3330) */
+#define PRIVATE_10(x)  (((x) & htonl(0xff000000)) == htonl(0x0A000000))
+#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) == htonl(0xA9FE0000))
+#define PRIVATE_172(x) (((x) & htonl(0xfff00000)) == htonl(0xAC100000))
+#define TEST_192(x)    (((x) & htonl(0xffffff00)) == htonl(0xC0000200))
+#define ANYCAST_6TO4(x)        (((x) & htonl(0xffffff00)) == htonl(0xC0586300))
+#define PRIVATE_192(x) (((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
+#define TEST_198(x)    (((x) & htonl(0xfffe0000)) == htonl(0xC6120000))
  #endif

  #endif /* _LINUX_IN_H */
--- linux-2.6.24-rc2/include/net/addrconf.h.orig        2007-11-08 12:06:17.000000000 -0800
+++ linux-2.6.24-rc2/include/net/addrconf.h     2007-11-09 08:12:29.000000000 -0800
@@ -241,6 +241,14 @@ static inline int ipv6_addr_is_ll_all_ro
                 addr->s6_addr32[3] == htonl(0x00000002));
  }

+#if defined(CONFIG_IPV6_ISATAP)
+/* only for IFF_ISATAP interfaces */
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+       return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
+}
+#endif
+
  #ifdef CONFIG_PROC_FS
  extern int if6_proc_init(void);
  extern void if6_proc_exit(void);




