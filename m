From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [BK PATCH] 2.6 SCTP updates
Date: Sun, 15 Feb 2004 21:55:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402152147290.18317@localhost.localdomain>
References: <Pine.LNX.4.58.0402131443350.2190@localhost.localdomain>
 <20040213215227.270a8147.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040213215227.270a8147.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 13 Feb 2004, David S. Miller wrote:

> On Fri, 13 Feb 2004 16:07:05 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> > Please do a
> > 	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
> > to get the following fixes to SCTP on top of linux 2.6.2.
>
> I am pulling this, however I strongly disagree with this change:
>
> > # 04/02/12      sri@us.ibm.com  1.1552
> > # [SCTP] Use __get_free_pages() to allocate ssnmap.
> > #
> > # This is needed to avoid kmalloc()'s 128K limit when an association is
> > # initialized with a large no. of streams(more than 65000 inbound +
> > # outbound streams).
>
> This is madness because it means that every assosciation created eats
> at least PAGE_SIZE bytes of memory, even if the ssnmap is tiny.
>
> Maybe you should just brance between two allocation schemes based upon
> what sctp_ssnmap_size() returns.

Yes, I didn't realize that this will waste lots of memory for associations
with a few streams. Here is a patch that fixes it by reverting back to
kmalloc() for allocs < 128K.

I have pushed it to both 2.6 and 2.4 bk trees. You can pull them from
	http://linux-lksctp.bkbits.net/lksctp-2.5.work
	http://linux-lksctp.bkbits.net/lksctp-2.4.work

# This patch includes the following deltas:
#	           ChangeSet	1.1554  -> 1.1555
#	   net/sctp/ssnmap.c	1.3     -> 1.4
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/15	sri@us.ibm.com	1.1555
# [SCTP] Revert back to use kmalloc() for ssnmap allocs of sizes < 128K.
# --------------------------------------------
#
diff -Nru a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
--- a/net/sctp/ssnmap.c	Sun Feb 15 21:34:49 2004
+++ b/net/sctp/ssnmap.c	Sun Feb 15 21:34:49 2004
@@ -40,6 +40,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>

+#define MAX_KMALLOC_SIZE	131072

 /* Storage size needed for map includes 2 headers and then the
  * specific needs of in or out streams.
@@ -56,11 +57,14 @@
 struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out, int gfp)
 {
 	struct sctp_ssnmap *retval;
-	int order;
-
-	order = get_order(sctp_ssnmap_size(in,out));
-	retval = (struct sctp_ssnmap *)__get_free_pages(gfp, order);
+	int size;

+	size = sctp_ssnmap_size(in, out);
+	if (size <= MAX_KMALLOC_SIZE)
+		retval = kmalloc(size, gfp);
+	else
+		retval = (struct sctp_ssnmap *)
+			  __get_free_pages(gfp, get_order(size));
 	if (!retval)
 		goto fail;

@@ -73,7 +77,10 @@
 	return retval;

 fail_map:
-	free_pages((unsigned long)retval, order);
+	if (size <= MAX_KMALLOC_SIZE)
+		kfree(retval);
+	else
+		free_pages((unsigned long)retval, get_order(size));
 fail:
 	return NULL;
 }
@@ -109,9 +116,13 @@
 void sctp_ssnmap_free(struct sctp_ssnmap *map)
 {
 	if (map && map->malloced) {
-		free_pages((unsigned long)map,
-			   get_order(sctp_ssnmap_size(map->in.len,
-						      map->out.len)));
+		int size;
+
+		size = sctp_ssnmap_size(map->in.len, map->out.len);
+		if (size <= MAX_KMALLOC_SIZE)
+			kfree(map);
+		else
+			free_pages((unsigned long)map, get_order(size));
 		SCTP_DBG_OBJCNT_DEC(ssnmap);
 	}
 }

Thanks
Sridhar
