From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6 addresses
Date: Thu, 09 Aug 2007 09:22:33 +0200
Message-ID: <46BAC0B9.1020207@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev ML <netdev@vger.kernel.org>
To: Mailing list NFSv4 <nfsv4@linux-nfs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:39371 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635AbXHIHVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 03:21:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a small part of missing pieces of IPv6 support for the server.
It deals with the ip_map caching code part.

It changes the ip_map structure to be able to store INET6 addresses.
It adds also the changes in address hashing, and mapping to test it with 
INET addresses.

Signed-off-by: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

fs/nfsd/export.c               |   12 ++++-
fs/nfsd/nfsctl.c               |   21 ++++++++-
include/linux/sunrpc/svcauth.h |    4 -
net/sunrpc/svcauth_unix.c      |   90 
++++++++++++++++++++++++++---------------
4 files changed, 87 insertions(+), 40 deletions(-)

diff -u -r -N linux-2.6.23-rc1/fs/nfsd/export.c 
linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/export.c
--- linux-2.6.23-rc1/fs/nfsd/export.c    2007-08-08 17:52:58.000000000 +0200
+++ linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/export.c    2007-08-08 
17:49:09.000000000 +0200
@@ -1558,6 +1558,7 @@
 {
     struct auth_domain    *dom;
     int            i, err;
+    struct in6_addr addr6;
 
     /* First, consistency check. */
     err = -EINVAL;
@@ -1576,9 +1577,14 @@
         goto out_unlock;
 
     /* Insert client into hashtable. */
-    for (i = 0; i < ncp->cl_naddr; i++)
-        auth_unix_add_addr(ncp->cl_addrlist[i], dom);
-
+    for (i = 0; i < ncp->cl_naddr; i++) {
+        /* Mapping address */
+            addr6.s6_addr32[0] = 0;
+            addr6.s6_addr32[1] = 0;
+            addr6.s6_addr32[2] = htonl(0xffff);
+            addr6.s6_addr32[3] = (uint32_t)ncp->cl_addrlist[i].s_addr;
+        auth_unix_add_addr(addr6, dom);
+    }
     auth_unix_forget_old(dom);
     auth_domain_put(dom);
 
diff -u -r -N linux-2.6.23-rc1/fs/nfsd/nfsctl.c 
linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/nfsctl.c
--- linux-2.6.23-rc1/fs/nfsd/nfsctl.c    2007-08-08 17:52:58.000000000 +0200
+++ linux-2.6.23-rc1-IPv6-ip_map/fs/nfsd/nfsctl.c    2007-08-08 
17:49:09.000000000 +0200
@@ -222,7 +222,7 @@
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh *res;
-
+    struct in6_addr in6;
     if (size < sizeof(*data))
         return -EINVAL;
     data = (struct nfsctl_fsparm*)buf;
@@ -236,7 +236,14 @@
     res = (struct knfsd_fh*)buf;
 
     exp_readlock();
-    if (!(clp = auth_unix_lookup(sin->sin_addr)))
+   
+    /* IPv6 address mapping */
+           in6.s6_addr32[0] = 0;
+           in6.s6_addr32[1] = 0;
+           in6.s6_addr32[2] = htonl(0xffff);
+           in6.s6_addr32[3] = (uint32_t)sin->sin_addr.s_addr;
+
+    if (!(clp = auth_unix_lookup(in6)))
         err = -EPERM;
     else {
         err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -253,6 +260,7 @@
 {
     struct nfsctl_fdparm *data;
     struct sockaddr_in *sin;
+    struct in6_addr in6;
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh fh;
@@ -271,7 +279,14 @@
     res = buf;
     sin = (struct sockaddr_in *)&data->gd_addr;
     exp_readlock();
-    if (!(clp = auth_unix_lookup(sin->sin_addr)))
+   
+    /* IPv6 address mapping */
+        in6.s6_addr32[0] = 0;
+        in6.s6_addr32[1] = 0;
+        in6.s6_addr32[2] = htonl(0xffff);
+        in6.s6_addr32[3] = (uint32_t)sin->sin_addr.s_addr;
+
+    if (!(clp = auth_unix_lookup(in6)))
         err = -EPERM;
     else {
         err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
diff -u -r -N linux-2.6.23-rc1/include/linux/sunrpc/svcauth.h 
linux-2.6.23-rc1-IPv6-ip_map/include/linux/sunrpc/svcauth.h
--- linux-2.6.23-rc1/include/linux/sunrpc/svcauth.h    2007-08-08 
17:52:59.000000000 +0200
+++ linux-2.6.23-rc1-IPv6-ip_map/include/linux/sunrpc/svcauth.h    
2007-08-08 17:48:54.000000000 +0200
@@ -120,10 +120,10 @@
 
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
diff -u -r -N linux-2.6.23-rc1/net/sunrpc/svcauth_unix.c 
linux-2.6.23-rc1-IPv6-ip_map/net/sunrpc/svcauth_unix.c
--- linux-2.6.23-rc1/net/sunrpc/svcauth_unix.c    2007-08-08 
17:53:01.000000000 +0200
+++ linux-2.6.23-rc1-IPv6-ip_map/net/sunrpc/svcauth_unix.c    2007-08-09 
08:29:27.000000000 +0200
@@ -84,7 +84,7 @@
 struct ip_map {
     struct cache_head    h;
     char            m_class[8]; /* e.g. "nfsd" */
-    struct in_addr        m_addr;
+    struct in6_addr        m_addr;
     struct unix_domain    *m_client;
     int            m_add_change;
 };
@@ -112,12 +112,16 @@
     return (hash ^ (hash>>8)) & 0xff;
 }
 #endif
+static inline int hash_ip6(struct in6_addr ip)
+{
+        return (hash_ip(ip.s6_addr32[0]) ^ hash_ip(ip.s6_addr32[1]) ^ 
hash_ip(ip.s6_addr32[2]) ^ hash_ip(ip.s6_addr32[3])) ;
+}
 static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
     struct ip_map *orig = container_of(corig, struct ip_map, h);
     struct ip_map *new = container_of(cnew, struct ip_map, h);
     return strcmp(orig->m_class, new->m_class) == 0
-        && orig->m_addr.s_addr == new->m_addr.s_addr;
+        && memcmp(orig->m_addr.s6_addr, 
new->m_addr.s6_addr,sizeof(struct in6_addr));
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -125,7 +129,7 @@
     struct ip_map *item = container_of(citem, struct ip_map, h);
 
     strcpy(new->m_class, item->m_class);
-    new->m_addr.s_addr = item->m_addr.s_addr;
+    memcpy(&new->m_addr.s6_addr, 
&item->m_addr.s6_addr,sizeof(item->m_addr.s6_addr));
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -151,20 +155,28 @@
 {
     char text_addr[20];
     struct ip_map *im = container_of(h, struct ip_map, h);
-    __be32 addr = im->m_addr.s_addr;
+   
+    __be32 addr[4];
+    int i;
+    for (i=0;i<4;i++)
+        addr[i] = im->m_addr.s6_addr[i];
 
-    snprintf(text_addr, 20, "%u.%u.%u.%u",
-         ntohl(addr) >> 24 & 0xff,
-         ntohl(addr) >> 16 & 0xff,
-         ntohl(addr) >>  8 & 0xff,
-         ntohl(addr) >>  0 & 0xff);
+    snprintf(text_addr, 20, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x",
+            ntohl(addr[3]) >> 16 & 0xff,
+            ntohl(addr[3]) >>  0 & 0xff,
+            ntohl(addr[2]) >> 16 & 0xff,
+            ntohl(addr[2]) >>  0 & 0xff,
+            ntohl(addr[1]) >> 16 & 0xff,
+            ntohl(addr[1]) >>  0 & 0xff,
+            ntohl(addr[0]) >> 16 & 0xff,
+            ntohl(addr[0]) >>  0 & 0xff);
 
     qword_add(bpp, blen, im->m_class);
     qword_add(bpp, blen, text_addr);
     (*bpp)[-1] = '\n';
 }
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr);
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr addr);
 static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, 
time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -175,10 +187,10 @@
      * for scratch: */
     char *buf = mesg;
     int len;
-    int b1,b2,b3,b4;
+    int b1,b2,b3,b4,b5,b6,b7,b8;
     char c;
     char class[8];
-    struct in_addr addr;
+    struct in6_addr addr;
     int err;
 
     struct ip_map *ipmp;
@@ -197,8 +209,21 @@
     len = qword_get(&mesg, buf, mlen);
     if (len <= 0) return -EINVAL;
 
-    if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
-        return -EINVAL;
+    if (sscanf(buf, "%d.%d.%d.%d%c", &b1, &b2, &b3, &b4, &c) == 4) {
+               addr.s6_addr32[0] = 0;
+               addr.s6_addr32[1] = 0;
+               addr.s6_addr32[2] = htonl(0xffff);
+               addr.s6_addr32[3] =
+               htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+       } else if (sscanf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x%c",
+                         &b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 
8) {
+               addr.s6_addr32[0] = htonl((b1<<16)|b2);
+               addr.s6_addr32[1] = htonl((b3<<16)|b4);
+               addr.s6_addr32[2] = htonl((b5<<16)|b6);
+               addr.s6_addr32[3] = htonl((b7<<16)|b8);
+       } else
+                return -EINVAL;
+
 
     expiry = get_expiry(&mesg);
     if (expiry ==0)
@@ -215,9 +240,6 @@
     } else
         dom = NULL;
 
-    addr.s_addr =
-        htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-
     ipmp = ip_map_lookup(class,addr);
     if (ipmp) {
         err = ip_map_update(ipmp,
@@ -238,7 +260,7 @@
                struct cache_head *h)
 {
     struct ip_map *im;
-    struct in_addr addr;
+    struct in6_addr addr;
     char *dom = "-no-domain-";
 
     if (h == NULL) {
@@ -247,18 +269,22 @@
     }
     im = container_of(h, struct ip_map, h);
     /* class addr domain */
-    addr = im->m_addr;
+    memcpy(&addr, &im->m_addr, sizeof(struct in6_addr));
 
     if (test_bit(CACHE_VALID, &h->flags) &&
         !test_bit(CACHE_NEGATIVE, &h->flags))
         dom = im->m_client->h.name;
 
-    seq_printf(m, "%s %d.%d.%d.%d %s\n",
+    seq_printf(m, "%s %04x.%04x.%04x.%04x.%04x.%04x.%04x.%04x %s\n",
            im->m_class,
-           ntohl(addr.s_addr) >> 24 & 0xff,
-           ntohl(addr.s_addr) >> 16 & 0xff,
-           ntohl(addr.s_addr) >>  8 & 0xff,
-           ntohl(addr.s_addr) >>  0 & 0xff,
+           ntohl(addr.s6_addr32[3]) >> 16 & 0xffff,
+           ntohl(addr.s6_addr32[3]) & 0xffff,
+           ntohl(addr.s6_addr32[2]) >> 16 & 0xffff,
+           ntohl(addr.s6_addr32[2]) & 0xffff,
+           ntohl(addr.s6_addr32[1]) >> 16 & 0xffff,
+           ntohl(addr.s6_addr32[1]) & 0xffff,
+           ntohl(addr.s6_addr32[0]) >> 16 & 0xffff,
+           ntohl(addr.s6_addr32[0]) & 0xffff,
            dom
            );
     return 0;
@@ -280,16 +306,16 @@
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
@@ -318,14 +344,14 @@
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
@@ -352,7 +378,7 @@
     return 0;
 }
 
-struct auth_domain *auth_unix_lookup(struct in_addr addr)
+struct auth_domain *auth_unix_lookup(struct in6_addr addr)
 {
     struct ip_map *ipm;
     struct auth_domain *rv;
@@ -641,7 +667,7 @@
 int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
-    struct sockaddr_in *sin = svc_addr_in(rqstp);
+    struct sockaddr_in6 *sin = svc_addr_in6(rqstp);
     struct ip_map *ipm;
 
     rqstp->rq_client = NULL;
@@ -651,7 +677,7 @@
     ipm = ip_map_cached_get(rqstp);
     if (ipm == NULL)
         ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-                    sin->sin_addr);
+                    sin->sin6_addr);
 
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

