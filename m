From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6 addresses
Date: Thu, 23 Aug 2007 15:18:04 +0200
Message-ID: <46CD890C.2040502@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50204 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758085AbXHWNQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 09:16:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to Neil's comments, I have tried to correct the mistakes of my first sending
Thank you for these comments Neil.

This is a small part of missing pieces of IPv6 support for the server.
It deals with the ip_map caching code part.

It changes the ip_map structure to be able to store INET6 addresses.
It adds also the changes in address hashing, and mapping to test it with INET addresses.

Signed-off-by: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfsd/export.c               |   10 ++-
 fs/nfsd/nfsctl.c               |   21 ++++++-
 include/linux/sunrpc/svcauth.h |    4 -
 include/net/ipv6.h             |   17 +++++
 net/sunrpc/svcauth_unix.c      |  121 
++++++++++++++++++++++++++++-------------
 5 files changed, 129 insertions(+), 44 deletions(-)


diff -p -u -r -N linux-2.6.23-rc3/fs/nfsd/export.c 
linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/export.c
--- linux-2.6.23-rc3/fs/nfsd/export.c    2007-08-23 13:18:16.000000000 +0200
+++ linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/export.c    2007-08-23 
13:51:08.000000000 +0200
@@ -35,6 +35,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/gss_api.h>
+#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY    NFSDDBG_EXPORT
 
@@ -1559,6 +1560,7 @@ exp_addclient(struct nfsctl_client *ncp)
 {
     struct auth_domain    *dom;
     int            i, err;
+    struct in6_addr addr6;
 
     /* First, consistency check. */
     err = -EINVAL;
@@ -1577,9 +1579,11 @@ exp_addclient(struct nfsctl_client *ncp)
         goto out_unlock;
 
     /* Insert client into hashtable. */
-    for (i = 0; i < ncp->cl_naddr; i++)
-        auth_unix_add_addr(ncp->cl_addrlist[i], dom);
-
+    for (i = 0; i < ncp->cl_naddr; i++) {
+        /* Mapping address */
+        ipv6_addr_map(ncp->cl_addrlist[i], addr6);
+        auth_unix_add_addr(addr6, dom);
+    }
     auth_unix_forget_old(dom);
     auth_domain_put(dom);
 
diff -p -u -r -N linux-2.6.23-rc3/fs/nfsd/nfsctl.c 
linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/nfsctl.c
--- linux-2.6.23-rc3/fs/nfsd/nfsctl.c    2007-08-23 13:18:16.000000000 +0200
+++ linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/nfsctl.c    2007-08-23 
13:25:28.000000000 +0200
@@ -222,7 +222,7 @@ static ssize_t write_getfs(struct file *
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh *res;
-
+    struct in6_addr in6;
     if (size < sizeof(*data))
         return -EINVAL;
     data = (struct nfsctl_fsparm*)buf;
@@ -236,7 +236,14 @@ static ssize_t write_getfs(struct file *
     res = (struct knfsd_fh*)buf;
 
     exp_readlock();
-    if (!(clp = auth_unix_lookup(sin->sin_addr)))
+
+    /* IPv6 address mapping */
+    in6.s6_addr32[0] = 0;
+    in6.s6_addr32[1] = 0;
+    in6.s6_addr32[2] = htonl(0xffff);
+    in6.s6_addr32[3] = (uint32_t)sin->sin_addr.s_addr;
+
+    if (!(clp = auth_unix_lookup(in6)))
         err = -EPERM;
     else {
         err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -253,6 +260,7 @@ static ssize_t write_getfd(struct file *
 {
     struct nfsctl_fdparm *data;
     struct sockaddr_in *sin;
+    struct in6_addr in6;
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh fh;
@@ -271,7 +279,14 @@ static ssize_t write_getfd(struct file *
     res = buf;
     sin = (struct sockaddr_in *)&data->gd_addr;
     exp_readlock();
-    if (!(clp = auth_unix_lookup(sin->sin_addr)))
+
+    /* IPv6 address mapping */
+    in6.s6_addr32[0] = 0;
+    in6.s6_addr32[1] = 0;
+    in6.s6_addr32[2] = htonl(0xffff);
+    in6.s6_addr32[3] = (uint32_t)sin->sin_addr.s_addr;
+
+    if (!(clp = auth_unix_lookup(in6)))
         err = -EPERM;
     else {
         err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
diff -p -u -r -N linux-2.6.23-rc3/include/linux/sunrpc/svcauth.h 
linux-2.6.23-rc3-IPv6-ipmap-cache/include/linux/sunrpc/svcauth.h
--- linux-2.6.23-rc3/include/linux/sunrpc/svcauth.h    2007-08-23 
13:18:21.000000000 +0200
+++ linux-2.6.23-rc3-IPv6-ipmap-cache/include/linux/sunrpc/svcauth.h    
2007-08-23 13:25:28.000000000 +0200
@@ -120,10 +120,10 @@ extern void    svc_auth_unregister(rpc_auth
 
 extern struct auth_domain *unix_domain_find(char *name);
 extern void auth_domain_put(struct auth_domain *item);
-extern int auth_unix_add_addr(struct in_addr addr, struct auth_domain 
*dom);
+extern int auth_unix_add_addr(struct in6_addr addr, struct auth_domain 
*dom);
 extern struct auth_domain *auth_domain_lookup(char *name, struct 
auth_domain *new);
 extern struct auth_domain *auth_domain_find(char *name);
-extern struct auth_domain *auth_unix_lookup(struct in_addr addr);
+extern struct auth_domain *auth_unix_lookup(struct in6_addr addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 extern void svcauth_unix_info_release(void *);
diff -p -u -r -N linux-2.6.23-rc3/include/net/ipv6.h 
linux-2.6.23-rc3-IPv6-ipmap-cache/include/net/ipv6.h
--- linux-2.6.23-rc3/include/net/ipv6.h    2007-08-23 13:18:23.000000000 
+0200
+++ linux-2.6.23-rc3-IPv6-ipmap-cache/include/net/ipv6.h    2007-08-23 
13:25:28.000000000 +0200
@@ -21,6 +21,7 @@
 #include <net/ndisc.h>
 #include <net/flow.h>
 #include <net/snmp.h>
+#include <linux/in.h>
 
 #define SIN6_LEN_RFC2133    24
 
@@ -167,6 +168,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplit
     if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, 
field);         \
     else        SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
 
+#define IS_ADDR_MAPPED(a) \
+    (((uint32_t *) (a))[0] == 0            \
+    && ((uint32_t *) (a))[1] == 0            \
+    && (((uint32_t *) (a))[2] == 0            \
+    || ((uint32_t *) (a))[2] == htonl(0xffff)))
+
 struct ip6_ra_chain
 {
     struct ip6_ra_chain    *next;
@@ -377,6 +384,16 @@ static inline int ipv6_addr_any(const st
          a->s6_addr32[2] | a->s6_addr32[3] ) == 0);
 }
 
+/* Maps a IPv4 address into a wright IPv6 address */
+static inline int ipv6_addr_map(const struct in_addr a1, struct 
in6_addr a2)
+{
+    a2.s6_addr32[0] = 0;
+    a2.s6_addr32[1] = 0;
+    a2.s6_addr32[2] = htonl(0xffff);
+    a2.s6_addr32[3] = (uint32_t)a1.s_addr;
+    return 0;
+}
+
 /*
  * find the first different bit between two addresses
  * length of address must be a multiple of 32bits
diff -p -u -r -N linux-2.6.23-rc3/net/sunrpc/svcauth_unix.c 
linux-2.6.23-rc3-IPv6-ipmap-cache/net/sunrpc/svcauth_unix.c
--- linux-2.6.23-rc3/net/sunrpc/svcauth_unix.c    2007-08-23 
13:18:24.000000000 +0200
+++ linux-2.6.23-rc3-IPv6-ipmap-cache/net/sunrpc/svcauth_unix.c    
2007-08-23 13:52:02.000000000 +0200
@@ -11,7 +11,8 @@
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <net/sock.h>
-
+#include <net/ipv6.h>
+#include <linux/kernel.h>
 #define RPCDBG_FACILITY    RPCDBG_AUTH
 
 
@@ -84,7 +85,7 @@ static void svcauth_unix_domain_release(
 struct ip_map {
     struct cache_head    h;
     char            m_class[8]; /* e.g. "nfsd" */
-    struct in_addr        m_addr;
+    struct in6_addr        m_addr;
     struct unix_domain    *m_client;
     int            m_add_change;
 };
@@ -112,12 +113,19 @@ static inline int hash_ip(__be32 ip)
     return (hash ^ (hash>>8)) & 0xff;
 }
 #endif
+static inline int hash_ip6(struct in6_addr ip)
+{
+    return (hash_ip(ip.s6_addr32[0]) ^
+        hash_ip(ip.s6_addr32[1]) ^
+        hash_ip(ip.s6_addr32[2]) ^
+        hash_ip(ip.s6_addr32[3]));
+}
 static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
     struct ip_map *orig = container_of(corig, struct ip_map, h);
     struct ip_map *new = container_of(cnew, struct ip_map, h);
     return strcmp(orig->m_class, new->m_class) == 0
-        && orig->m_addr.s_addr == new->m_addr.s_addr;
+        && ipv6_addr_equal(&orig->m_addr, &new->m_addr);
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -125,7 +133,7 @@ static void ip_map_init(struct cache_hea
     struct ip_map *item = container_of(citem, struct ip_map, h);
 
     strcpy(new->m_class, item->m_class);
-    new->m_addr.s_addr = item->m_addr.s_addr;
+    memcpy(&(new->m_addr), &(item->m_addr), sizeof(struct in6_addr));
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -151,20 +159,22 @@ static void ip_map_request(struct cache_
 {
     char text_addr[20];
     struct ip_map *im = container_of(h, struct ip_map, h);
-    __be32 addr = im->m_addr.s_addr;
-
-    snprintf(text_addr, 20, "%u.%u.%u.%u",
-         ntohl(addr) >> 24 & 0xff,
-         ntohl(addr) >> 16 & 0xff,
-         ntohl(addr) >>  8 & 0xff,
-         ntohl(addr) >>  0 & 0xff);
 
+    if (IS_ADDR_MAPPED(im->m_addr.s6_addr32)) {
+        snprintf(text_addr, 20, NIPQUAD_FMT,
+                ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
+                ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
+                ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
+                ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
+    } else {
+        snprintf(text_addr, 20, NIP6_FMT, NIP6(im->m_addr));
+    }
     qword_add(bpp, blen, im->m_class);
     qword_add(bpp, blen, text_addr);
     (*bpp)[-1] = '\n';
 }
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr);
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr addr);
 static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, 
time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -175,10 +185,10 @@ static int ip_map_parse(struct cache_det
      * for scratch: */
     char *buf = mesg;
     int len;
-    int b1,b2,b3,b4;
+    int b1, b2, b3, b4, b5, b6, b7, b8;
     char c;
     char class[8];
-    struct in_addr addr;
+    struct in6_addr addr;
     int err;
 
     struct ip_map *ipmp;
@@ -197,9 +207,26 @@ static int ip_map_parse(struct cache_det
     len = qword_get(&mesg, buf, mlen);
     if (len <= 0) return -EINVAL;
 
-    if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+    if (sscanf(buf, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) == 4) {
+        addr.s6_addr32[0] = 0;
+        addr.s6_addr32[1] = 0;
+        addr.s6_addr32[2] = htonl(0xffff);
+        addr.s6_addr32[3] =
+            htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+       } else if (sscanf(buf, NIP6_FMT "%c",
+            &b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
+        addr.s6_addr16[7] = htons(b1);
+        addr.s6_addr16[6] = htons(b2);
+        addr.s6_addr16[5] = htons(b3);
+        addr.s6_addr16[4] = htons(b4);
+        addr.s6_addr16[3] = htons(b5);
+        addr.s6_addr16[2] = htons(b6);
+        addr.s6_addr16[1] = htons(b7);
+        addr.s6_addr16[0] = htons(b8);
+       } else
         return -EINVAL;
 
+
     expiry = get_expiry(&mesg);
     if (expiry ==0)
         return -EINVAL;
@@ -215,9 +242,6 @@ static int ip_map_parse(struct cache_det
     } else
         dom = NULL;
 
-    addr.s_addr =
-        htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-
     ipmp = ip_map_lookup(class,addr);
     if (ipmp) {
         err = ip_map_update(ipmp,
@@ -238,7 +262,7 @@ static int ip_map_show(struct seq_file *
                struct cache_head *h)
 {
     struct ip_map *im;
-    struct in_addr addr;
+    struct in6_addr addr;
     char *dom = "-no-domain-";
 
     if (h == NULL) {
@@ -247,20 +271,33 @@ static int ip_map_show(struct seq_file *
     }
     im = container_of(h, struct ip_map, h);
     /* class addr domain */
-    addr = im->m_addr;
+    memcpy(&addr, &im->m_addr, sizeof(struct in6_addr));
 
     if (test_bit(CACHE_VALID, &h->flags) &&
         !test_bit(CACHE_NEGATIVE, &h->flags))
         dom = im->m_client->h.name;
 
-    seq_printf(m, "%s %d.%d.%d.%d %s\n",
-           im->m_class,
-           ntohl(addr.s_addr) >> 24 & 0xff,
-           ntohl(addr.s_addr) >> 16 & 0xff,
-           ntohl(addr.s_addr) >>  8 & 0xff,
-           ntohl(addr.s_addr) >>  0 & 0xff,
-           dom
-           );
+    if (IS_ADDR_MAPPED(addr.s6_addr32)) {
+        seq_printf(m, "%s" NIPQUAD_FMT "%s\n",
+            im->m_class,
+            ntohl(addr.s6_addr32[3]) >> 24 & 0xff,
+            ntohl(addr.s6_addr32[3]) >> 16 & 0xff,
+            ntohl(addr.s6_addr32[3]) >>  8 & 0xff,
+            ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
+            dom);
+    } else {
+        seq_printf(m, "%s" NIP6_FMT "%s\n",
+            im->m_class,
+            ntohl(addr.s6_addr16[7]),
+            ntohl(addr.s6_addr16[6]),
+            ntohl(addr.s6_addr16[5]),
+            ntohl(addr.s6_addr16[4]),
+            ntohl(addr.s6_addr16[3]),
+            ntohl(addr.s6_addr16[2]),
+            ntohl(addr.s6_addr16[1]),
+            ntohl(addr.s6_addr16[0]),
+            dom);
+    }
     return 0;
 }
 
@@ -280,16 +317,16 @@ struct cache_detail ip_map_cache = {
     .alloc        = ip_map_alloc,
 };
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr)
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr addr)
 {
     struct ip_map ip;
     struct cache_head *ch;
 
     strcpy(ip.m_class, class);
-    ip.m_addr = addr;
+    memcpy(&ip.m_addr, &addr, sizeof(struct in6_addr));
     ch = sunrpc_cache_lookup(&ip_map_cache, &ip.h,
                  hash_str(class, IP_HASHBITS) ^
-                 hash_ip(addr.s_addr));
+                 hash_ip6(addr));
 
     if (ch)
         return container_of(ch, struct ip_map, h);
@@ -318,14 +355,14 @@ static int ip_map_update(struct ip_map *
     ch = sunrpc_cache_update(&ip_map_cache,
                  &ip.h, &ipm->h,
                  hash_str(ipm->m_class, IP_HASHBITS) ^
-                 hash_ip(ipm->m_addr.s_addr));
+                 hash_ip6(ipm->m_addr));
     if (!ch)
         return -ENOMEM;
     cache_put(ch, &ip_map_cache);
     return 0;
 }
 
-int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
+int auth_unix_add_addr(struct in6_addr addr, struct auth_domain *dom)
 {
     struct unix_domain *udom;
     struct ip_map *ipmp;
@@ -352,7 +389,7 @@ int auth_unix_forget_old(struct auth_dom
     return 0;
 }
 
-struct auth_domain *auth_unix_lookup(struct in_addr addr)
+struct auth_domain *auth_unix_lookup(struct in6_addr addr)
 {
     struct ip_map *ipm;
     struct auth_domain *rv;
@@ -641,7 +678,19 @@ static int unix_gid_find(uid_t uid, stru
 int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
-    struct sockaddr_in *sin = svc_addr_in(rqstp);
+    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin6;
+
+    switch (rqstp->rq_addr.ss_family) {
+    default:
+        BUG();
+    case AF_INET:
+        sin = svc_addr_in(rqstp);
+        ipv6_addr_map(sin->sin_addr, sin6->sin6_addr);
+    case AF_INET6:
+        sin6 = svc_addr_in6(rqstp);
+    }
+
     struct ip_map *ipm;
 
     rqstp->rq_client = NULL;
@@ -651,7 +700,7 @@ svcauth_unix_set_client(struct svc_rqst
     ipm = ip_map_cached_get(rqstp);
     if (ipm == NULL)
         ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-                    sin->sin_addr);
+                    sin6->sin6_addr);
 
     if (ipm == NULL)
         return SVC_DENIED;

-- 

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************

