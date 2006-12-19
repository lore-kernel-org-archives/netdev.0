From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] irda: handle out of memory errors
Date: Tue, 19 Dec 2006 17:55:09 +0900
Message-ID: <20061219085509.GK4049@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:56532 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932694AbWLSI4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 03:56:04 -0500
Received: by an-out-0708.google.com with SMTP id b33so497353ana
        for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 00:56:02 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch checks return value of memory allocation functions
for irda subsystem and fixes memory leaks in error cases.

Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 net/irda/irias_object.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

Index: 2.6-mm/net/irda/irias_object.c
===================================================================
--- 2.6-mm.orig/net/irda/irias_object.c
+++ 2.6-mm/net/irda/irias_object.c
@@ -91,6 +91,12 @@ struct ias_object *irias_new_object( cha
 
 	obj->magic = IAS_OBJECT_MAGIC;
 	obj->name = strndup(name, IAS_MAX_CLASSNAME);
+	if (!obj->name) {
+		IRDA_WARNING("%s(), Unable to allocate name!\n",
+			     __FUNCTION__);
+		kfree(obj);
+		return NULL;
+	}
 	obj->id = id;
 
 	/* Locking notes : the attrib spinlock has lower precendence
@@ -101,6 +107,7 @@ struct ias_object *irias_new_object( cha
 	if (obj->attribs == NULL) {
 		IRDA_WARNING("%s(), Unable to allocate attribs!\n",
 			     __FUNCTION__);
+		kfree(obj->name);
 		kfree(obj);
 		return NULL;
 	}
@@ -357,6 +364,15 @@ void irias_add_integer_attrib(struct ias
 
 	/* Insert value */
 	attrib->value = irias_new_integer_value(value);
+	if (!attrib->name || !attrib->value) {
+		IRDA_WARNING("%s: Unable to allocate attribute!\n",
+			     __FUNCTION__);
+		if (attrib->value)
+			irias_delete_value(attrib->value);
+		kfree(attrib->name);
+		kfree(attrib);
+		return;
+	}
 
 	irias_add_attrib(obj, attrib, owner);
 }
@@ -391,6 +407,15 @@ void irias_add_octseq_attrib(struct ias_
 	attrib->name = strndup(name, IAS_MAX_ATTRIBNAME);
 
 	attrib->value = irias_new_octseq_value( octets, len);
+	if (!attrib->name || !attrib->value) {
+		IRDA_WARNING("%s: Unable to allocate attribute!\n",
+			     __FUNCTION__);
+		if (attrib->value)
+			irias_delete_value(attrib->value);
+		kfree(attrib->name);
+		kfree(attrib);
+		return;
+	}
 
 	irias_add_attrib(obj, attrib, owner);
 }
@@ -424,6 +449,15 @@ void irias_add_string_attrib(struct ias_
 	attrib->name = strndup(name, IAS_MAX_ATTRIBNAME);
 
 	attrib->value = irias_new_string_value(value);
+	if (!attrib->name || !attrib->value) {
+		IRDA_WARNING("%s: Unable to allocate attribute!\n",
+			     __FUNCTION__);
+		if (attrib->value)
+			irias_delete_value(attrib->value);
+		kfree(attrib->name);
+		kfree(attrib);
+		return;
+	}
 
 	irias_add_attrib(obj, attrib, owner);
 }
@@ -473,6 +507,12 @@ struct ias_value *irias_new_string_value
 	value->type = IAS_STRING;
 	value->charset = CS_ASCII;
 	value->t.string = strndup(string, IAS_MAX_STRING);
+	if (!value->t.string) {
+		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
+		kfree(value);
+		return NULL;
+	}
+
 	value->len = strlen(value->t.string);
 
 	return value;
