From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Tue, 27 Mar 2007 15:24:29 +0200
Message-ID: <200703271524.30326.netdev@axxeo.de>
References: <20070323003116.GC2712@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkm@devicescape.com>
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:57996 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845AbXC0NZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:25:28 -0400
In-Reply-To: <20070323003116.GC2712@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Jean Tourrilhes schrieb:
> diff -u -p linux/include/net/iw_handler.j1.h linux/include/net/iw_handler.h
> --- linux/include/net/iw_handler.j1.h	2007-03-16 17:36:22.000000000 -0700
> +++ linux/include/net/iw_handler.h	2007-03-21 11:01:09.000000000 -0700
> @@ -500,7 +504,11 @@ iwe_stream_add_event(char *	stream,		/* 
>  	/* Check if it's possible */
>  	if(likely((stream + event_len) < ends)) {
>  		iwe->len = event_len;
> -		memcpy(stream, (char *) iwe, event_len);
> +		/* Beware of alignement issues on 64 bits */
> +		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);

useless cast (void* and char* are already compatible).
You just need to cast to "char *", if you like to add an byte offset.
If not, just don't cast.

> +		memcpy(stream + IW_EV_LCP_LEN,
> +		       ((char *) iwe) + IW_EV_LCP_LEN,
> +		       event_len - IW_EV_LCP_LEN);
>  		stream += event_len;

Can this be a helper like "stream = copy_to_stream(stream, iwe, len);" ?
Or do the offsets in stream and iwe vary too much for this?

>  	}
>  	return stream;
> @@ -521,10 +529,10 @@ iwe_stream_add_point(char *	stream,		/* 
>  	/* Check if it's possible */
>  	if(likely((stream + event_len) < ends)) {
>  		iwe->len = event_len;
> -		memcpy(stream, (char *) iwe, IW_EV_LCP_LEN);
> +		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);

useless cast.

>  		memcpy(stream + IW_EV_LCP_LEN,
>  		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
> -		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
> +		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
>  		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
>  		stream += event_len;
>  	}
> @@ -574,7 +582,11 @@ iwe_stream_check_add_event(char *	stream
>  	/* Check if it's possible, set error if not */
>  	if(likely((stream + event_len) < ends)) {
>  		iwe->len = event_len;
> -		memcpy(stream, (char *) iwe, event_len);
> +		/* Beware of alignement issues on 64 bits */
> +		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);

useless cast.

> +		memcpy(stream + IW_EV_LCP_LEN,
> +		       ((char *) iwe) + IW_EV_LCP_LEN,
> +		       event_len - IW_EV_LCP_LEN);
>  		stream += event_len;
>  	} else
>  		*perr = -E2BIG;
> @@ -598,10 +610,10 @@ iwe_stream_check_add_point(char *	stream
>  	/* Check if it's possible */
>  	if(likely((stream + event_len) < ends)) {
>  		iwe->len = event_len;
> -		memcpy(stream, (char *) iwe, IW_EV_LCP_LEN);
> +		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);

useless cast.

>  		memcpy(stream + IW_EV_LCP_LEN,
>  		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
> -		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
> +		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
>  		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
>  		stream += event_len;
>  	} else


Regards

Ingo Oeser
