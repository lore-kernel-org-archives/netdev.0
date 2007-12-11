From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: Re: [PATCH] IPv6 support for NFS server
Date: Tue, 11 Dec 2007 19:00:08 +0100
Message-ID: <475ED028.2010109@ext.bull.net>
References: <475D86C1.6070400@ext.bull.net> <475EBDB4.5020108@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050006040404020208000609"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	netdev ML <netdev@vger.kernel.org>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:57522 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbXLKR6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:58:00 -0500
In-Reply-To: <475EBDB4.5020108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050006040404020208000609
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Brian Haley wrote:

> In an email back on October 29th I sent-out a similar patch with a new 
> ipv6_addr_set_v4mapped() inline - it might be useful to pull that 
> piece into your patch since it cleans it up a bit to get rid of the 
> ipv6_addr_set() calls.  I can re-send you that patch off-line if you 
> can't find it.
>
> -Brian
>
>
Thanks Brian. I forgot to include your changes in my tree.
OK Bruce you can take this one.

Aurélien

-- 

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************


--------------050006040404020208000609
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="linux-2.6.24-rc4-IPv6-cache-based.diff"
Content-Disposition: inline;
 filename="linux-2.6.24-rc4-IPv6-cache-based.diff"

diff -p -u -r -N linux-2.6.24-rc4/fs/nfsd/export.c linux-2.6.24-rc4-IPv6-cache-based/fs/nfsd/export.c
--- linux-2.6.24-rc4/fs/nfsd/export.c	2007-12-10 16:11:37.000000000 +0100
+++ linux-2.6.24-rc4-IPv6-cache-based/fs/nfsd/export.c	2007-12-11 17:49:51.000000000 +0100
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
+	struct in6_addr addr6;
 
 	/* First, consistency check. */
 	err = -EINVAL;
@@ -1574,9 +1576,11 @@ exp_addclient(struct nfsctl_client *ncp)
 		goto out_unlock;
 
 	/* Insert client into hashtable. */
-	for (i = 0; i < ncp->cl_naddr; i++)
-		auth_unix_add_addr(ncp->cl_addrlist[i], dom);
-
+	for (i = 0; i < ncp->cl_naddr; i++) {
+		/* Mapping address */
+		ipv6_addr_set_v4mapped(ncp->cl_addrlist[i].s_addr, &addr6);
+		auth_unix_add_addr(&addr6, dom);
+	}
 	auth_unix_forget_old(dom);
 	auth_domain_put(dom);
 
diff -p -u -r -N linux-2.6.24-rc4/fs/nfsd/nfsctl.c linux-2.6.24-rc4-IPv6-cache-based/fs/nfsd/nfsctl.c
--- linux-2.6.24-rc4/fs/nfsd/nfsctl.c	2007-12-10 16:11:37.000000000 +0100
+++ linux-2.6.24-rc4-IPv6-cache-based/fs/nfsd/nfsctl.c	2007-12-11 18:27:24.000000000 +0100
@@ -37,6 +37,7 @@
 #include <linux/nfsd/syscall.h>
 
 #include <asm/uaccess.h>
+#include <net/ipv6.h>
 
 /*
  *	We have a single directory with 9 nodes in it.
@@ -222,6 +223,7 @@ static ssize_t write_getfs(struct file *
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
+	struct in6_addr in6;
 
 	if (size < sizeof(*data))
 		return -EINVAL;
@@ -236,7 +238,14 @@ static ssize_t write_getfs(struct file *
 	res = (struct knfsd_fh*)buf;
 
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+
+	/* IPv6 address mapping */
+	ipv6_addr_set_v4mapped(
+		(((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr), 
+		&in6
+		);
+
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -257,6 +266,7 @@ static ssize_t write_getfd(struct file *
 	int err = 0;
 	struct knfsd_fh fh;
 	char *res;
+	struct in6_addr in6;
 
 	if (size < sizeof(*data))
 		return -EINVAL;
@@ -271,7 +281,13 @@ static ssize_t write_getfd(struct file *
 	res = buf;
 	sin = (struct sockaddr_in *)&data->gd_addr;
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+	/* IPv6 address mapping */
+	ipv6_addr_set_v4mapped(
+		(((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr),
+		&in6
+		);
+
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
diff -p -u -r -N linux-2.6.24-rc4/include/linux/sunrpc/svcauth.h linux-2.6.24-rc4-IPv6-cache-based/include/linux/sunrpc/svcauth.h
--- linux-2.6.24-rc4/include/linux/sunrpc/svcauth.h	2007-12-10 16:01:43.000000000 +0100
+++ linux-2.6.24-rc4-IPv6-cache-based/include/linux/sunrpc/svcauth.h	2007-12-10 17:09:34.000000000 +0100
@@ -120,10 +120,10 @@ extern void	svc_auth_unregister(rpc_auth
 
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
diff -p -u -r -N linux-2.6.24-rc4/include/net/ipv6.h linux-2.6.24-rc4-IPv6-cache-based/include/net/ipv6.h
--- linux-2.6.24-rc4/include/net/ipv6.h	2007-12-10 16:11:38.000000000 +0100
+++ linux-2.6.24-rc4-IPv6-cache-based/include/net/ipv6.h	2007-12-11 17:52:39.000000000 +0100
@@ -400,6 +400,15 @@ static inline int ipv6_addr_v4mapped(con
 		 a->s6_addr32[2] == htonl(0x0000ffff));
 }
 
+static inline void ipv6_addr_set_v4mapped(const __be32 addr,
+					  struct in6_addr *v4mapped)
+{
+	ipv6_addr_set(v4mapped,
+			0, 0,
+			__constant_htonl(0x0000FFFF),
+			addr);
+}
+
 /*
  * find the first different bit between two addresses
  * length of address must be a multiple of 32bits
diff -p -u -r -N linux-2.6.24-rc4/net/sunrpc/svcauth_unix.c linux-2.6.24-rc4-IPv6-cache-based/net/sunrpc/svcauth_unix.c
--- linux-2.6.24-rc4/net/sunrpc/svcauth_unix.c	2007-12-10 16:01:46.000000000 +0100
+++ linux-2.6.24-rc4-IPv6-cache-based/net/sunrpc/svcauth_unix.c	2007-12-10 17:38:50.000000000 +0100
@@ -11,7 +11,8 @@
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <net/sock.h>
-
+#include <net/ipv6.h>
+#include <linux/kernel.h>
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
 
@@ -84,7 +85,7 @@ static void svcauth_unix_domain_release(
 struct ip_map {
 	struct cache_head	h;
 	char			m_class[8]; /* e.g. "nfsd" */
-	struct in_addr		m_addr;
+	struct in6_addr		m_addr;
 	struct unix_domain	*m_client;
 	int			m_add_change;
 };
@@ -112,12 +113,19 @@ static inline int hash_ip(__be32 ip)
 	return (hash ^ (hash>>8)) & 0xff;
 }
 #endif
+static inline int hash_ip6(struct in6_addr ip)
+{
+	return (hash_ip(ip.s6_addr32[0]) ^
+		hash_ip(ip.s6_addr32[1]) ^
+		hash_ip(ip.s6_addr32[2]) ^
+		hash_ip(ip.s6_addr32[3]));
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
@@ -125,7 +133,7 @@ static void ip_map_init(struct cache_hea
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
 	strcpy(new->m_class, item->m_class);
-	new->m_addr.s_addr = item->m_addr.s_addr;
+	ipv6_addr_copy(&new->m_addr, &item->m_addr);
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -149,22 +157,24 @@ static void ip_map_request(struct cache_
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
@@ -175,10 +185,10 @@ static int ip_map_parse(struct cache_det
 	 * for scratch: */
 	char *buf = mesg;
 	int len;
-	int b1,b2,b3,b4;
+	int b1, b2, b3, b4, b5, b6, b7, b8;
 	char c;
 	char class[8];
-	struct in_addr addr;
+	struct in6_addr addr;
 	int err;
 
 	struct ip_map *ipmp;
@@ -197,9 +207,26 @@ static int ip_map_parse(struct cache_det
 	len = qword_get(&mesg, buf, mlen);
 	if (len <= 0) return -EINVAL;
 
-	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+	if (sscanf(buf, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) == 4) {
+		addr.s6_addr32[0] = 0;
+		addr.s6_addr32[1] = 0;
+		addr.s6_addr32[2] = htonl(0xffff);
+		addr.s6_addr32[3] =
+			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+       } else if (sscanf(buf, NIP6_FMT "%c",
+			&b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
+		addr.s6_addr16[0] = htons(b1);
+		addr.s6_addr16[1] = htons(b2);
+		addr.s6_addr16[2] = htons(b3);
+		addr.s6_addr16[3] = htons(b4);
+		addr.s6_addr16[4] = htons(b5);
+		addr.s6_addr16[5] = htons(b6);
+		addr.s6_addr16[6] = htons(b7);
+		addr.s6_addr16[7] = htons(b8);
+       } else
 		return -EINVAL;
 
+
 	expiry = get_expiry(&mesg);
 	if (expiry ==0)
 		return -EINVAL;
@@ -215,10 +242,7 @@ static int ip_map_parse(struct cache_det
 	} else
 		dom = NULL;
 
-	addr.s_addr =
-		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-
-	ipmp = ip_map_lookup(class,addr);
+	ipmp = ip_map_lookup(class, &addr);
 	if (ipmp) {
 		err = ip_map_update(ipmp,
 			     container_of(dom, struct unix_domain, h),
@@ -238,7 +262,7 @@ static int ip_map_show(struct seq_file *
 		       struct cache_head *h)
 {
 	struct ip_map *im;
-	struct in_addr addr;
+	struct in6_addr addr;
 	char *dom = "-no-domain-";
 
 	if (h == NULL) {
@@ -247,20 +271,24 @@ static int ip_map_show(struct seq_file *
 	}
 	im = container_of(h, struct ip_map, h);
 	/* class addr domain */
-	addr = im->m_addr;
+	ipv6_addr_copy(&addr, &im->m_addr);
 
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
+	if (ipv6_addr_v4mapped(&addr)) {
+		seq_printf(m, "%s" NIPQUAD_FMT "%s\n",
+			im->m_class,
+			ntohl(addr.s6_addr32[3]) >> 24 & 0xff,
+			ntohl(addr.s6_addr32[3]) >> 16 & 0xff,
+			ntohl(addr.s6_addr32[3]) >>  8 & 0xff,
+			ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
+			dom);
+	} else {
+		seq_printf(m, "%s" NIP6_FMT "%s\n",
+			im->m_class, NIP6(addr), dom);
+	}
 	return 0;
 }
 
@@ -280,16 +308,16 @@ struct cache_detail ip_map_cache = {
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
+				 hash_ip6(*addr));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -318,14 +346,14 @@ static int ip_map_update(struct ip_map *
 	ch = sunrpc_cache_update(&ip_map_cache,
 				 &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
-				 hash_ip(ipm->m_addr.s_addr));
+				 hash_ip6(ipm->m_addr));
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
@@ -352,7 +380,7 @@ int auth_unix_forget_old(struct auth_dom
 	return 0;
 }
 
-struct auth_domain *auth_unix_lookup(struct in_addr addr)
+struct auth_domain *auth_unix_lookup(struct in6_addr *addr)
 {
 	struct ip_map *ipm;
 	struct auth_domain *rv;
@@ -641,9 +669,24 @@ static int unix_gid_find(uid_t uid, stru
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
+		ipv6_addr_set(&sin6->sin6_addr, 0, 0,
+				htonl(0x0000FFFF), sin->sin_addr.s_addr);
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
@@ -651,7 +694,7 @@ svcauth_unix_set_client(struct svc_rqst 
 	ipm = ip_map_cached_get(rqstp);
 	if (ipm == NULL)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-				    sin->sin_addr);
+				    &sin6->sin6_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;

--------------050006040404020208000609--
