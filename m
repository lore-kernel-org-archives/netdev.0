From: walter harms <wharms@bfs.de>
Subject: Re: [patch -resend] 9p: fix min_t() casting in p9pdu_vwritef()
Date: Wed, 27 Jun 2012 12:19:26 +0200
Message-ID: <4FEADE2E.90005@bfs.de>
References: <20120627090141.GF31212@elgon.mountain>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:40896 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799Ab2F0KT2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 06:19:28 -0400
In-Reply-To: <20120627090141.GF31212@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 27.06.2012 11:01, schrieb Dan Carpenter:
> I don't think we're actually likely to hit this limit but if we do
> then the comparison should be done as size_t.  The original code
> is equivalent to:
>         len = strlen(sptr) % USHRT_MAX;
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I was told this patch "has already made it upstream via the v9fs pull."
> but it must have been dropped accidentally.  Originally sent on Sat,
> Jan 15, 2011.
> 
> diff --git a/net/9p/protocol.c b/net/9p/protocol.c
> index 9ee48cb..3d33ecf 100644
> --- a/net/9p/protocol.c
> +++ b/net/9p/protocol.c
> @@ -368,7 +368,7 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
>  				const char *sptr = va_arg(ap, const char *);
>  				uint16_t len = 0;
>  				if (sptr)
> -					len = min_t(uint16_t, strlen(sptr),
> +					len = min_t(size_t, strlen(sptr),
>  								USHRT_MAX);
>  
>  				errcode = p9pdu_writef(pdu, proto_version,

this will result in
	uint16_t = size_t
i would expect compilers to complains since uint16 < size_t (most times). In this special case
it seems more easy  write it. also ushort seems ambitious since  uint16_t  need not to be ushort.
so my idea would look like this:

	len=strlen
	if (len>65535) len=65535;
	p9pdu_writef(...,(unint16_t)len);

just my 2 cents,
 wh	
	
