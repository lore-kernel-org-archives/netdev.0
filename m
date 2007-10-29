From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Mon, 29 Oct 2007 15:16:18 -0400
Message-ID: <47263182.8090107@hp.com>
References: <471C893F.6000306@ext.bull.net> <471F9B73.4010908@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050603040201090506090101"
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:34015 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbXJ2TQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 15:16:50 -0400
In-Reply-To: <471F9B73.4010908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050603040201090506090101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Aurelien,

This is a combination of your two patches into one, cleaned-up with all 
my complaints.  I also added an ipv6_addr_set_v4mapped() inline after 
someone else here convinced me it gets rid of a lot of cruft from the 
code.  The DCCP, etc. code can be cleaned-up later if this gets accepted.

I have only compile-tested this, hoping you can test the functionality.

-Brian


Add IPv6 support to NFS server ip_map caching code and knfsd syscall 
interface - write_getfs() and write_getfd() will now accept IPv6 addresses.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------050603040201090506090101
Content-Type: text/x-patch;
 name="nfs.ipv6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs.ipv6.patch"

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 66d0aeb..c47ba77 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -35,6 +35,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/gss_api.h>
+#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
@@ -1556,6 +1557,7 @@ exp_addclient(struct nfsctl_client *ncp)
 {
 	struct auth_domain	*dom;
 	int			i, err;
+	struct in6_addr		in6;
 
 	/* First, consistency check. */
 	err = -EINVAL;
@@ -1574,9 +1576,10 @@ exp_addclient(struct nfsctl_client *ncp)
 		goto out_unlock;
 
 	/* Insert client into hashtable. */
-	for (i = 0; i < ncp->cl_naddr; i++)
-		auth_unix_add_addr(ncp->cl_addrlist[i], dom);
-
+	for (i = 0; i < ncp->cl_naddr; i++) {
+		ipv6_addr_set_v4mapped(ncp->cl_addrlist[i].s_addr, &in6);
+		auth_unix_add_addr(&in6, dom);
+	}
 	auth_unix_forget_old(dom);
 	auth_domain_put(dom);
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 77dc989..5cb5f0d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -37,6 +37,7 @@
 #include <linux/nfsd/syscall.h>
 
 #include <asm/uaccess.h>
+#include <net/ipv6.h>
 
 /*
  *	We have a single directory with 9 nodes in it.
@@ -219,24 +220,37 @@ static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fsparm *data;
 	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
+	struct in6_addr in6;
 
 	if (size < sizeof(*data))
 		return -EINVAL;
 	data = (struct nfsctl_fsparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	switch (data->gd_addr.sa_family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&data->gd_addr;
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
+		break;
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+		ipv6_addr_copy(&in6, &sin6->sin6_addr); 
+		break;
+	default:
 		goto out;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	}
+
 	if (data->gd_maxlen > NFS3_FHSIZE)
 		data->gd_maxlen = NFS3_FHSIZE;
 
 	res = (struct knfsd_fh*)buf;
 
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -253,25 +267,41 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fdparm *data;
 	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh fh;
 	char *res;
+	struct in6_addr in6;
 
 	if (size < sizeof(*data))
 		return -EINVAL;
 	data = (struct nfsctl_fdparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	if (data->gd_addr.sa_family != AF_INET &&
+	    data->gd_addr.sa_family != AF_INET6)
 		goto out;
 	err = -EINVAL;
 	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
 		goto out;
 
 	res = buf;
-	sin = (struct sockaddr_in *)&data->gd_addr;
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+
+	switch (data->gd_addr.sa_family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&data->gd_addr;
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
+		break;
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+		ipv6_addr_copy(&in6, &sin6->sin6_addr);
+		break;
+	default:
+		goto out;
+	}
+
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 22e1ef8..64ecb93 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/hash.h>
+#include <net/ipv6.h>
 
 #define SVC_CRED_NGROUPS	32
 struct svc_cred {
@@ -120,10 +121,10 @@ extern void	svc_auth_unregister(rpc_authflavor_t flavor);
 
 extern struct auth_domain *unix_domain_find(char *name);
 extern void auth_domain_put(struct auth_domain *item);
-extern int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom);
+extern int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom);
 extern struct auth_domain *auth_domain_lookup(char *name, struct auth_domain *new);
 extern struct auth_domain *auth_domain_find(char *name);
-extern struct auth_domain *auth_unix_lookup(struct in_addr addr);
+extern struct auth_domain *auth_unix_lookup(struct in6_addr *addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 extern void svcauth_unix_info_release(void *);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ae328b6..366fdca 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -16,6 +16,7 @@
 #define _NET_IPV6_H
 
 #include <linux/ipv6.h>
+#include <linux/in.h>
 #include <linux/hardirq.h>
 #include <net/if_inet6.h>
 #include <net/ndisc.h>
@@ -400,6 +401,15 @@ static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
 		 a->s6_addr32[2] == htonl(0x0000ffff));
 }
 
+static inline void ipv6_addr_set_v4mapped(const __be32 addr,
+					  struct in6_addr *v4mapped)
+{
+	ipv6_addr_set(v4mapped,
+		      0, 0,
+		      __constant_htonl(0x0000FFFF),
+		      addr);
+}
+
 /*
  * find the first different bit between two addresses
  * length of address must be a multiple of 32bits
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 4114794..a40d769 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -11,6 +11,7 @@
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <net/sock.h>
+#include <net/ipv6.h>
 
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
@@ -84,7 +85,7 @@ static void svcauth_unix_domain_release(struct auth_domain *dom)
 struct ip_map {
 	struct cache_head	h;
 	char			m_class[8]; /* e.g. "nfsd" */
-	struct in_addr		m_addr;
+	struct in6_addr		m_addr;
 	struct unix_domain	*m_client;
 	int			m_add_change;
 };
@@ -101,7 +102,6 @@ static void ip_map_put(struct kref *kref)
 	kfree(im);
 }
 
-#if IP_HASHBITS == 8
 /* hash_long on a 64 bit machine is currently REALLY BAD for
  * IP addresses in reverse-endian (i.e. on a little-endian machine).
  * So use a trivial but reliable hash instead
@@ -111,13 +111,20 @@ static inline int hash_ip(__be32 ip)
 	int hash = (__force u32)ip ^ ((__force u32)ip>>16);
 	return (hash ^ (hash>>8)) & 0xff;
 }
-#endif
+
+static inline int hash_ip6(struct in6_addr *ip6)
+{
+	return (hash_ip(ip6->s6_addr32[0]) ^
+		hash_ip(ip6->s6_addr32[1]) ^
+		hash_ip(ip6->s6_addr32[2]) ^
+		hash_ip(ip6->s6_addr32[3]));
+}
 static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
 	struct ip_map *orig = container_of(corig, struct ip_map, h);
 	struct ip_map *new = container_of(cnew, struct ip_map, h);
 	return strcmp(orig->m_class, new->m_class) == 0
-		&& orig->m_addr.s_addr == new->m_addr.s_addr;
+		&& ipv6_addr_equal(&orig->m_addr, &new->m_addr);
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -125,7 +132,7 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
 	strcpy(new->m_class, item->m_class);
-	new->m_addr.s_addr = item->m_addr.s_addr;
+	ipv6_addr_copy(&new->m_addr, &item->m_addr);
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -149,22 +156,24 @@ static void ip_map_request(struct cache_detail *cd,
 				  struct cache_head *h,
 				  char **bpp, int *blen)
 {
-	char text_addr[20];
+	char text_addr[40];
 	struct ip_map *im = container_of(h, struct ip_map, h);
-	__be32 addr = im->m_addr.s_addr;
-
-	snprintf(text_addr, 20, "%u.%u.%u.%u",
-		 ntohl(addr) >> 24 & 0xff,
-		 ntohl(addr) >> 16 & 0xff,
-		 ntohl(addr) >>  8 & 0xff,
-		 ntohl(addr) >>  0 & 0xff);
 
+	if (ipv6_addr_v4mapped(&(im->m_addr))) {
+		snprintf(text_addr, 20, NIPQUAD_FMT,
+				ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
+				ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
+				ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
+				ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
+	} else {
+		snprintf(text_addr, 40, NIP6_FMT, NIP6(im->m_addr));
+	}
 	qword_add(bpp, blen, im->m_class);
 	qword_add(bpp, blen, text_addr);
 	(*bpp)[-1] = '\n';
 }
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr);
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr);
 static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -175,10 +184,10 @@ static int ip_map_parse(struct cache_detail *cd,
 	 * for scratch: */
 	char *buf = mesg;
 	int len;
-	int b1,b2,b3,b4;
+	int b1, b2, b3, b4, b5, b6, b7, b8;
 	char c;
 	char class[8];
-	struct in_addr addr;
+	struct in6_addr addr6;
 	int err;
 
 	struct ip_map *ipmp;
@@ -197,7 +206,23 @@ static int ip_map_parse(struct cache_detail *cd,
 	len = qword_get(&mesg, buf, mlen);
 	if (len <= 0) return -EINVAL;
 
-	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+	if (sscanf(buf, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) == 4) {
+		addr6.s6_addr32[0] = 0;
+		addr6.s6_addr32[1] = 0;
+		addr6.s6_addr32[2] = htonl(0xffff);
+		addr6.s6_addr32[3] =
+			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+       } else if (sscanf(buf, NIP6_FMT "%c",
+			&b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
+		addr6.s6_addr16[0] = htons(b1);
+		addr6.s6_addr16[1] = htons(b2);
+		addr6.s6_addr16[2] = htons(b3);
+		addr6.s6_addr16[3] = htons(b4);
+		addr6.s6_addr16[4] = htons(b5);
+		addr6.s6_addr16[5] = htons(b6);
+		addr6.s6_addr16[6] = htons(b7);
+		addr6.s6_addr16[7] = htons(b8);
+       } else
 		return -EINVAL;
 
 	expiry = get_expiry(&mesg);
@@ -215,10 +240,7 @@ static int ip_map_parse(struct cache_detail *cd,
 	} else
 		dom = NULL;
 
-	addr.s_addr =
-		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-
-	ipmp = ip_map_lookup(class,addr);
+	ipmp = ip_map_lookup(class, &addr6);
 	if (ipmp) {
 		err = ip_map_update(ipmp,
 			     container_of(dom, struct unix_domain, h),
@@ -238,7 +260,7 @@ static int ip_map_show(struct seq_file *m,
 		       struct cache_head *h)
 {
 	struct ip_map *im;
-	struct in_addr addr;
+	struct in6_addr addr6;
 	char *dom = "-no-domain-";
 
 	if (h == NULL) {
@@ -247,20 +269,24 @@ static int ip_map_show(struct seq_file *m,
 	}
 	im = container_of(h, struct ip_map, h);
 	/* class addr domain */
-	addr = im->m_addr;
+	ipv6_addr_copy(&addr6, &im->m_addr);
 
 	if (test_bit(CACHE_VALID, &h->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &h->flags))
 		dom = im->m_client->h.name;
 
-	seq_printf(m, "%s %d.%d.%d.%d %s\n",
-		   im->m_class,
-		   ntohl(addr.s_addr) >> 24 & 0xff,
-		   ntohl(addr.s_addr) >> 16 & 0xff,
-		   ntohl(addr.s_addr) >>  8 & 0xff,
-		   ntohl(addr.s_addr) >>  0 & 0xff,
-		   dom
-		   );
+	if (ipv6_addr_v4mapped(&addr6)) {
+		seq_printf(m, "%s" NIPQUAD_FMT "%s\n",
+			im->m_class,
+			ntohl(addr6.s6_addr32[3]) >> 24 & 0xff,
+			ntohl(addr6.s6_addr32[3]) >> 16 & 0xff,
+			ntohl(addr6.s6_addr32[3]) >>  8 & 0xff,
+			ntohl(addr6.s6_addr32[3]) >>  0 & 0xff,
+			dom);
+	} else {
+		seq_printf(m, "%s" NIP6_FMT "%s\n",
+			im->m_class, NIP6(addr6), dom);
+	}
 	return 0;
 }
 
@@ -280,16 +306,16 @@ struct cache_detail ip_map_cache = {
 	.alloc		= ip_map_alloc,
 };
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr)
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
 
 	strcpy(ip.m_class, class);
-	ip.m_addr = addr;
+	ipv6_addr_copy(&ip.m_addr, addr);
 	ch = sunrpc_cache_lookup(&ip_map_cache, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
-				 hash_ip(addr.s_addr));
+				 hash_ip6(addr));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -318,14 +344,14 @@ static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t ex
 	ch = sunrpc_cache_update(&ip_map_cache,
 				 &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
-				 hash_ip(ipm->m_addr.s_addr));
+				 hash_ip6(&ipm->m_addr));
 	if (!ch)
 		return -ENOMEM;
 	cache_put(ch, &ip_map_cache);
 	return 0;
 }
 
-int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
+int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom)
 {
 	struct unix_domain *udom;
 	struct ip_map *ipmp;
@@ -352,7 +378,7 @@ int auth_unix_forget_old(struct auth_domain *dom)
 	return 0;
 }
 
-struct auth_domain *auth_unix_lookup(struct in_addr addr)
+struct auth_domain *auth_unix_lookup(struct in6_addr *addr)
 {
 	struct ip_map *ipm;
 	struct auth_domain *rv;
@@ -641,9 +667,23 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *sin = svc_addr_in(rqstp);
+	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6, sin6_storage;
 	struct ip_map *ipm;
 
+	switch (rqstp->rq_addr.ss_family) {
+	case AF_INET:
+		sin = svc_addr_in(rqstp);
+		sin6 = &sin6_storage;
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &sin6->sin6_addr); 
+		break;
+	case AF_INET6:
+		sin6 = svc_addr_in6(rqstp);
+		break;
+	default:
+		BUG();
+	}
+
 	rqstp->rq_client = NULL;
 	if (rqstp->rq_proc == 0)
 		return SVC_OK;
@@ -651,7 +691,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	ipm = ip_map_cached_get(rqstp);
 	if (ipm == NULL)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-				    sin->sin_addr);
+				    &sin6->sin6_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;

--------------050603040201090506090101--
