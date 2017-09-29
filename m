From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/3] Check user supplied interface name
 lengths
Date: Fri, 29 Sep 2017 10:31:07 -0700
Message-ID: <20170929103107.456efb11@xeon-e3>
References: <20170926163548.24347-1-phil@nwl.cc>
        <20170927084249.0591ee3a@shemminger-XPS-13-9360>
        <20170927160528.GN32305@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:43422 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751830AbdI2RbP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:31:15 -0400
Received: by mail-pg0-f53.google.com with SMTP id y17so31447pgc.0
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 10:31:15 -0700 (PDT)
In-Reply-To: <20170927160528.GN32305@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Sep 2017 18:05:28 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Wed, Sep 27, 2017 at 08:42:49AM +0100, Stephen Hemminger wrote:
> > On Tue, 26 Sep 2017 18:35:45 +0200
> > Phil Sutter <phil@nwl.cc> wrote:
> >   
> > > This series adds explicit checks for user-supplied interface names to
> > > make sure their length fits Linux's requirements.
> > > 
> > > The first two patches simplify interface name parsing in some places -
> > > these are side-effects of working on the actual implementation provided
> > > in patch three.
> > > 
> > > Changes since v1:
> > > - Patches 1 and 2 introduced.
> > > - Changes to patch 3 are listed in there.
> > > 
> > > Phil Sutter (3):
> > >   ip{6,}tunnel: Avoid copying user-supplied interface name around
> > >   tc: flower: No need to cache indev arg
> > >   Check user supplied interface name lengths
> > > 
> > >  include/utils.h |  1 +
> > >  ip/ip6tunnel.c  |  9 +++++----
> > >  ip/ipl2tp.c     |  3 ++-
> > >  ip/iplink.c     | 27 ++++++++-------------------
> > >  ip/ipmaddr.c    |  1 +
> > >  ip/iprule.c     |  4 ++++
> > >  ip/iptunnel.c   | 27 +++++++++++++--------------
> > >  ip/iptuntap.c   |  4 +++-
> > >  lib/utils.c     | 10 ++++++++++
> > >  misc/arpd.c     |  1 +
> > >  tc/f_flower.c   |  6 ++----
> > >  11 files changed, 50 insertions(+), 43 deletions(-)
> > >   
> > 
> > I like the idea, and checking arguments is good.  
> 
> Cool!

I was thinking something like:



diff --git a/include/utils.h b/include/utils.h
index c9ed230b9604..e2702b56f2e0 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -105,6 +105,8 @@ int get_be64(__be64 *val, const char *arg, int base);
 int get_be32(__be32 *val, const char *arg, int base);
 int get_be16(__be16 *val, const char *arg, int base);
 int get_addr64(__u64 *ap, const char *cp);
+int check_ifname(const char *arg);
+int get_ifname(char *buf, const char *arg);
 
 int hex2mem(const char *buf, uint8_t *mem, int count);
 char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index b4a7def14422..a6f0e99bdc21 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -180,7 +180,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 			memcpy(&p->laddr, &laddr.data, sizeof(p->laddr));
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ - 1);
+			if (get_ifname(medium, *argv))
+				invarg("\"medium\" not a valid ifname", *argv);
 		} else if (strcmp(*argv, "encaplimit") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0) {
diff --git a/ip/iplink.c b/ip/iplink.c
index ff5b56c038d2..89aa51ed3b40 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1265,6 +1265,8 @@ static int do_set(int argc, char **argv)
 			flags &= ~IFF_UP;
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
+			if (check_ifname(*argv))
+				invarg("Invalid \"name\"\n", *argv);
 			newname = *argv;
 		} else if (matches(*argv, "address") == 0) {
 			NEXT_ARG();
@@ -1383,9 +1385,6 @@ static int do_set(int argc, char **argv)
 	}
 
 	if (newname && strcmp(dev, newname)) {
-		if (strlen(newname) == 0)
-			invarg("\"\" is not a valid device identifier\n",
-			       "name");
 		if (do_changename(dev, newname) < 0)
 			return -1;
 		dev = newname;
diff --git a/lib/utils.c b/lib/utils.c
index bbd3cbc46a0e..a93b45b51a3b 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -20,6 +20,7 @@
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <string.h>
+#include <ctype.h>
 #include <netdb.h>
 #include <arpa/inet.h>
 #include <asm/types.h>
@@ -465,6 +466,34 @@ int get_addr64(__u64 *ap, const char *cp)
 	return 1;
 }
 
+int check_ifname(const char *name)
+{
+	/* These check mimic kernel checks in dev_valid_name */
+	if (*name == '\0')
+		return -1;
+	if (strlen(name) >= IFNAMSIZ)
+		return -1;
+
+	while (*name) {
+		if (*name == '/' || isspace(*name))
+			return -1;
+		++name;
+	}
+	return 0;
+}
+		
+/* buf is assumed to be IFNAMSIZ */
+int get_ifname(char *buf, const char *name)
+{
+	int ret;
+
+	ret = check_ifname(name);
+	if (ret == 0)
+		strncpy(buf, name, IFNAMSIZ - 1);
+
+	return ret;
+}
+
 int get_addr_1(inet_prefix *addr, const char *name, int family)
 {
 	memset(addr, 0, sizeof(*addr));
-- 
2.11.0
