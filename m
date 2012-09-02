From: y@redhat.com
Subject: [iproute2][PATCH v2] tc: mirred target: do not report non-existing devices
Date: Sun,  2 Sep 2012 13:48:02 +0300
Message-ID: <48845.6942643554$1346582919@news.gmane.org>
References: <20120902104107.GB8982@redhat.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Kenigsberg <danken@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755974Ab2IBKsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2012 06:48:25 -0400
In-Reply-To: <20120902104107.GB8982@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Kenigsberg <danken@redhat.com>

Currently, if a mirred target device is removed, `tc filter show`
does not reveal the fact. Instead, it replaces the original name of the
device with the default output of ll_map:ll_idx_n2a().

This is unfortunate, since one cannot differ between this case and a valid
mirroring target device named 'if17'.

It seems that the original code meant to report an error message in this
case, but it does not, since ll_index_to_name() never returns 0. I would
not like to bail out in case of an error, since the user would still be
interested to know what are the other details of the action.

v2: properly declare the new function ll_index_exsits()

Signed-off-by: Dan Kenigsberg <danken@redhat.com>
---
 include/ll_map.h |    1 +
 lib/ll_map.c     |   13 +++++++++++++
 tc/m_mirred.c    |   10 ++++------
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/ll_map.h b/include/ll_map.h
index 752b827..16509af 100644
--- a/include/ll_map.h
+++ b/include/ll_map.h
@@ -6,6 +6,7 @@ extern int ll_remember_index(const struct sockaddr_nl *who,
 extern int ll_init_map(struct rtnl_handle *rth);
 extern unsigned ll_name_to_index(const char *name);
 extern const char *ll_index_to_name(unsigned idx);
+extern int ll_index_exists(unsigned idx);
 extern const char *ll_idx_n2a(unsigned idx, char *buf);
 extern int ll_index_to_type(unsigned idx);
 extern unsigned ll_index_to_flags(unsigned idx);
diff --git a/lib/ll_map.c b/lib/ll_map.c
index 1ca781e..d6f1339 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -108,6 +108,19 @@ const char *ll_idx_n2a(unsigned idx, char *buf)
 	return buf;
 }
 
+int ll_index_exists(unsigned idx)
+{
+	const struct ll_cache *im;
+
+	if (idx == 0)
+		return 0;
+
+	for (im = idxhead(idx); im; im = im->idx_next)
+		if (im->index == idx)
+			return 1;
+
+	return 0;
+}
 
 const char *ll_index_to_name(unsigned idx)
 {
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 0d771bc..eba1240 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -268,13 +268,11 @@ print_mirred(struct action_util *au,FILE * f, struct rtattr *arg)
 	ll_init_map(&rth);
 	*/
 
+	dev = ll_index_to_name(p->ifindex);
 
-	if ((dev = ll_index_to_name(p->ifindex)) == 0) {
-		fprintf(stderr, "Cannot find device %d\n", p->ifindex);
-		return -1;
-	}
-
-	fprintf(f, "mirred (%s to device %s) %s", mirred_n2a(p->eaction), dev,action_n2a(p->action, b1, sizeof (b1)));
+	fprintf(f, "mirred (%s to %sdevice %s) %s", mirred_n2a(p->eaction),
+                ll_index_exists(p->ifindex) ? "" : "missing-",
+                dev, action_n2a(p->action, b1, sizeof (b1)));
 
 	fprintf(f, "\n ");
 	fprintf(f, "\tindex %d ref %d bind %d",p->index,p->refcnt,p->bindcnt);
-- 
1.7.7.6
