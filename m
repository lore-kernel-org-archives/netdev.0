From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] scm: lower SCM_MAX_FD
Date: Wed, 24 Nov 2010 01:09:15 +0100
Message-ID: <1290557355.2866.117.camel@edumazet-laptop>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
	 <1290553918.2866.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:44063 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312Ab0KXAJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 19:09:21 -0500
In-Reply-To: <1290553918.2866.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> David, commit f8d570a4 added one "struct list_head list;" to struct
> scm_fp_list, enlarging it by a two factor because of power of two
> kmalloc() sizes.  (2048 bytes on 64bit arches instead of 1024
> previously)
> 
> We might lower SCM_MAX_FD from 255 to 253 ?
> 
> 

This wont correct Vegard reported problem yet, but following patch
should reduce ram usage a lot (32 bytes instead of 2048 bytes per scm in
Vegard test program)

Thanks

[PATCH net-next-2.6] net: scm: lower SCM_MAX_FD

Lower SCM_MAX_FD from 255 to 253 so that allocations for scm_fp_list are
halved. (commit f8d570a4 added two pointers in this structure)

scm_fp_dup() should not copy whole structure (and trigger kmemcheck
warnings), but only the used part. While we are at it, only allocate
needed size.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/scm.h |    5 +++--
 net/core/scm.c    |   10 ++++++----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 3165650..745460f 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -10,11 +10,12 @@
 /* Well, we should have at least one descriptor open
  * to accept passed FDs 8)
  */
-#define SCM_MAX_FD	255
+#define SCM_MAX_FD	253
 
 struct scm_fp_list {
 	struct list_head	list;
-	int			count;
+	short			count;
+	short			max;
 	struct file		*fp[SCM_MAX_FD];
 };
 
diff --git a/net/core/scm.c b/net/core/scm.c
index 413cab8..bbe4544 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -79,10 +79,11 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 			return -ENOMEM;
 		*fplp = fpl;
 		fpl->count = 0;
+		fpl->max = SCM_MAX_FD;
 	}
 	fpp = &fpl->fp[fpl->count];
 
-	if (fpl->count + num > SCM_MAX_FD)
+	if (fpl->count + num > fpl->max)
 		return -EINVAL;
 
 	/*
@@ -331,11 +332,12 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 	if (!fpl)
 		return NULL;
 
-	new_fpl = kmalloc(sizeof(*fpl), GFP_KERNEL);
+	new_fpl = kmemdup(fpl, offsetof(struct scm_fp_list, fp[fpl->count]),
+			  GFP_KERNEL);
 	if (new_fpl) {
-		for (i=fpl->count-1; i>=0; i--)
+		for (i = 0; i < fpl->count; i++)
 			get_file(fpl->fp[i]);
-		memcpy(new_fpl, fpl, sizeof(*fpl));
+		new_fpl->max = new_fpl->count;
 	}
 	return new_fpl;
 }


