From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] [IrDA] af_irda memory leak fixes
Date: Fri, 18 Jan 2008 08:53:22 +0100
Message-ID: <20080118075322.GB3063@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesper Juhl <jesper.juhl@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.126]:21285 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756203AbYAQXu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 18:50:58 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2323.orange.fr (SMTP Server) with ESMTP id 6FC57700009E
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 00:50:56 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here goes an IrDA patch against your latest net-2.6 tree.

This patch fixes some af_irda memory leaks.
It also checks for irias_new_obect() return value.

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/af_irda.c |   30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

Index: net-2.6-davem/net/irda/af_irda.c
===================================================================
--- net-2.6-davem.orig/net/irda/af_irda.c	2008-01-17 06:00:10.000000000 +0100
+++ net-2.6-davem/net/irda/af_irda.c	2008-01-18 08:37:36.000000000 +0100
@@ -802,12 +802,18 @@
 	}
 #endif /* CONFIG_IRDA_ULTRA */
 
+	self->ias_obj = irias_new_object(addr->sir_name, jiffies);
+	if (self->ias_obj == NULL)
+		return -ENOMEM;
+
 	err = irda_open_tsap(self, addr->sir_lsap_sel, addr->sir_name);
-	if (err < 0)
+	if (err < 0) {
+		kfree(self->ias_obj->name);
+		kfree(self->ias_obj);
 		return err;
+	}
 
 	/*  Register with LM-IAS */
-	self->ias_obj = irias_new_object(addr->sir_name, jiffies);
 	irias_add_integer_attrib(self->ias_obj, "IrDA:TinyTP:LsapSel",
 				 self->stsap_sel, IAS_KERNEL_ATTR);
 	irias_insert_object(self->ias_obj);
@@ -1825,7 +1831,7 @@
 	struct irda_ias_set    *ias_opt;
 	struct ias_object      *ias_obj;
 	struct ias_attrib *	ias_attr;	/* Attribute in IAS object */
-	int opt;
+	int opt, free_ias = 0;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
@@ -1881,11 +1887,20 @@
 			/* Create a new object */
 			ias_obj = irias_new_object(ias_opt->irda_class_name,
 						   jiffies);
+			if (ias_obj == NULL) {
+				kfree(ias_opt);
+				return -ENOMEM;
+			}
+			free_ias = 1;
 		}
 
 		/* Do we have the attribute already ? */
 		if(irias_find_attrib(ias_obj, ias_opt->irda_attrib_name)) {
 			kfree(ias_opt);
+			if (free_ias) {
+				kfree(ias_obj->name);
+				kfree(ias_obj);
+			}
 			return -EINVAL;
 		}
 
@@ -1904,6 +1919,11 @@
 			if(ias_opt->attribute.irda_attrib_octet_seq.len >
 			   IAS_MAX_OCTET_STRING) {
 				kfree(ias_opt);
+				if (free_ias) {
+					kfree(ias_obj->name);
+					kfree(ias_obj);
+				}
+
 				return -EINVAL;
 			}
 			/* Add an octet sequence attribute */
@@ -1932,6 +1952,10 @@
 			break;
 		default :
 			kfree(ias_opt);
+			if (free_ias) {
+				kfree(ias_obj->name);
+				kfree(ias_obj);
+			}
 			return -EINVAL;
 		}
 		irias_insert_object(ias_obj);

