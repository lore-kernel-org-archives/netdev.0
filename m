From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH 2/2] irda: avoid potential memory leak in irda_setsockopt()
Date: Sun, 13 Jan 2008 01:34:44 +0100 (CET)
Message-ID: <alpine.LNX.1.00.0801130107240.2235@dragon.funnycrock.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dag Brattli <dagb@cs.uit.no>, Jean Tourrilhes <jt@hpl.hp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Jesper Juhl <jesper.juhl@gmail.com>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:34354 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbYAMAjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 19:39:51 -0500
Received: by ug-out-1314.google.com with SMTP id z38so662369ugc.16
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 16:39:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There are paths through the irda_setsockopt() function where we return and 
may or may not have allocated a new ias_obj but in any case have not used 
it for anything yet and we end up leaking memory.

As far as I can tell, in the case where we didn't allocate a new ias_ob 
but simply were planning to use one already available then we should not 
free it before returning. But when we have allocated a brand new ias_obj 
but have not yet used it or put it on any lists etc and then return, 
that's a memory leak.

There are two cases:

1)
   switch (optname) {
   case IRLMP_IAS_SET:
     ...
     if(ias_obj == (struct ias_object *) NULL) {
             /* Create a new object */
--[alloc]--> ias_obj = irias_new_object(ias_opt->irda_class_name,
                                        jiffies);
     ...
     switch(ias_opt->irda_attrib_type) {
     case IAS_OCT_SEQ:
       /* Check length */
       if(ias_opt->attribute.irda_attrib_octet_seq.len >
          IAS_MAX_OCTET_STRING) {
               kfree(ias_opt);
--[leak]-->    return -EINVAL;
     ...
     }
     irias_insert_object(ias_obj);

The allocated object isn't referenced at all until we get outside the 
inner switch, so clearly we leak it (if we took the path that allocated it 
that is).


2)
The second case is the same as the above, except it's the default: case in 
the inner switch instead of case IAS_OCT_SEQ:

       default :
         kfree(ias_opt);
         return -EINVAL;


The way I propose to fix this is with a new variable that keeps track of 
whether or not we found an existing ias_obj to use or if we took the 
allocation path, then use that variable to determine if we should free 
ias_obj before returning from the function.

I'm not very intimate with this code, so if there's a better solution I'd 
very much like to hear it. It's also entirely possible that someone with 
more knowledge of this code can prove that these cases can't actually ever 
happen - if that's the case then please let me know.

This patch is meant to be applied on top of 
  [PATCH 1/2] irda: return -ENOMEM upon failure to allocate new ias_obj

The Coverity checker gets credit for pointing its finger towards this.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 af_irda.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index e33f0a5..352e8a7 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1824,7 +1824,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 	struct irda_sock *self = irda_sk(sk);
 	struct irda_ias_set    *ias_opt;
 	struct ias_object      *ias_obj;
-	struct ias_attrib *	ias_attr;	/* Attribute in IAS object */
+	struct ias_attrib      *ias_attr;	/* Attribute in IAS object */
+	int alloc_new_obj = 0;
 	int opt;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
@@ -1885,6 +1886,7 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 				kfree(ias_opt);
 				return -ENOMEM;
 			}
+			alloc_new_obj = 1;
 		}
 
 		/* Do we have the attribute already ? */
@@ -1908,6 +1910,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 			if(ias_opt->attribute.irda_attrib_octet_seq.len >
 			   IAS_MAX_OCTET_STRING) {
 				kfree(ias_opt);
+				if (alloc_new_obj)
+					kfree(ias_obj);
 				return -EINVAL;
 			}
 			/* Add an octet sequence attribute */
@@ -1936,6 +1940,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 			break;
 		default :
 			kfree(ias_opt);
+			if (alloc_new_obj)
+				kfree(ias_obj);
 			return -EINVAL;
 		}
 		irias_insert_object(ias_obj);



