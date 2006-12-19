From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH] irda: handle out of memory errors
Date: Wed, 20 Dec 2006 00:44:22 +0200
Message-ID: <20061219224422.GB4274@sortiz.org>
References: <20061219085509.GK4049@APFDCB5C>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.orange.fr ([193.252.22.25]:15044 "EHLO smtp6.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932982AbWLSXPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 18:15:16 -0500
Received: from smtp6.orange.fr (mwinf0607 [172.22.137.37])
	by mwinf0610.orange.fr (SMTP Server) with ESMTP id D7F0181D768
	for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 23:44:49 +0100 (CET)
To: Akinobu Mita <akinobu.mita@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061219085509.GK4049@APFDCB5C>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 19, 2006 at 05:55:09PM +0900, Akinobu Mita wrote:
> This patch checks return value of memory allocation functions
> for irda subsystem and fixes memory leaks in error cases.
> 
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
That looks correct, thanks for the patch.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Cheers,
Samuel.


> 
> ---
>  net/irda/irias_object.c |   40 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 40 insertions(+)
> 
> Index: 2.6-mm/net/irda/irias_object.c
> ===================================================================
> --- 2.6-mm.orig/net/irda/irias_object.c
> +++ 2.6-mm/net/irda/irias_object.c
> @@ -91,6 +91,12 @@ struct ias_object *irias_new_object( cha
>  
>  	obj->magic = IAS_OBJECT_MAGIC;
>  	obj->name = strndup(name, IAS_MAX_CLASSNAME);
> +	if (!obj->name) {
> +		IRDA_WARNING("%s(), Unable to allocate name!\n",
> +			     __FUNCTION__);
> +		kfree(obj);
> +		return NULL;
> +	}
>  	obj->id = id;
>  
>  	/* Locking notes : the attrib spinlock has lower precendence
> @@ -101,6 +107,7 @@ struct ias_object *irias_new_object( cha
>  	if (obj->attribs == NULL) {
>  		IRDA_WARNING("%s(), Unable to allocate attribs!\n",
>  			     __FUNCTION__);
> +		kfree(obj->name);
>  		kfree(obj);
>  		return NULL;
>  	}
> @@ -357,6 +364,15 @@ void irias_add_integer_attrib(struct ias
>  
>  	/* Insert value */
>  	attrib->value = irias_new_integer_value(value);
> +	if (!attrib->name || !attrib->value) {
> +		IRDA_WARNING("%s: Unable to allocate attribute!\n",
> +			     __FUNCTION__);
> +		if (attrib->value)
> +			irias_delete_value(attrib->value);
> +		kfree(attrib->name);
> +		kfree(attrib);
> +		return;
> +	}
>  
>  	irias_add_attrib(obj, attrib, owner);
>  }
> @@ -391,6 +407,15 @@ void irias_add_octseq_attrib(struct ias_
>  	attrib->name = strndup(name, IAS_MAX_ATTRIBNAME);
>  
>  	attrib->value = irias_new_octseq_value( octets, len);
> +	if (!attrib->name || !attrib->value) {
> +		IRDA_WARNING("%s: Unable to allocate attribute!\n",
> +			     __FUNCTION__);
> +		if (attrib->value)
> +			irias_delete_value(attrib->value);
> +		kfree(attrib->name);
> +		kfree(attrib);
> +		return;
> +	}
>  
>  	irias_add_attrib(obj, attrib, owner);
>  }
> @@ -424,6 +449,15 @@ void irias_add_string_attrib(struct ias_
>  	attrib->name = strndup(name, IAS_MAX_ATTRIBNAME);
>  
>  	attrib->value = irias_new_string_value(value);
> +	if (!attrib->name || !attrib->value) {
> +		IRDA_WARNING("%s: Unable to allocate attribute!\n",
> +			     __FUNCTION__);
> +		if (attrib->value)
> +			irias_delete_value(attrib->value);
> +		kfree(attrib->name);
> +		kfree(attrib);
> +		return;
> +	}
>  
>  	irias_add_attrib(obj, attrib, owner);
>  }
> @@ -473,6 +507,12 @@ struct ias_value *irias_new_string_value
>  	value->type = IAS_STRING;
>  	value->charset = CS_ASCII;
>  	value->t.string = strndup(string, IAS_MAX_STRING);
> +	if (!value->t.string) {
> +		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
> +		kfree(value);
> +		return NULL;
> +	}
> +
>  	value->len = strlen(value->t.string);
>  
>  	return value;
