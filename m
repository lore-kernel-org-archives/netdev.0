From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2] ip: add support for more MPLS labels
Date: Tue, 16 May 2017 10:32:27 +0200
Message-ID: <20170516083224.GC15081@vergenet.net>
References: <20170514012702.1083-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33995 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdEPIcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 04:32:32 -0400
Received: by mail-qk0-f179.google.com with SMTP id k74so121158289qke.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 01:32:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170514012702.1083-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 13, 2017 at 07:27:02PM -0600, David Ahern wrote:
> Kernel now supports up to 30 labels but not defined as part of the uapi.
> iproute2 handles up to 8 labels but in a non-consistent way. Update ip
> to handle more labels, but in a more programmatic way.
> 
> For the MPLS address family, the data field in inet_prefix is used for
> labels.  Increase that field to 64 u32's -- 64 as nothing more than a
> convenient power of 2 number.
> 
> Update mpls_pton to take the length of the address field, convert that
> length to number of labels and add better error handling to the parsing
> of the user supplied string.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>  include/utils.h |  7 ++-----
>  lib/mpls_pton.c | 11 +++++++----
>  lib/utils.c     |  7 +++++--
>  3 files changed, 14 insertions(+), 11 deletions(-)
> 
> diff --git a/include/utils.h b/include/utils.h
> index 8c12e1e2a60c..bfbc9e6dff55 100644
> --- a/include/utils.h
> +++ b/include/utils.h
> @@ -61,7 +61,7 @@ typedef struct
>  	__s16 bitlen;
>  	/* These next two fields match rtvia */
>  	__u16 family;
> -	__u32 data[8];
> +	__u32 data[64];
>  } inet_prefix;
>  
>  #define PREFIXLEN_SPECIFIED 1
> @@ -88,9 +88,6 @@ struct ipx_addr {
>  # define AF_MPLS 28
>  #endif
>  
> -/* Maximum number of labels the mpls helpers support */
> -#define MPLS_MAX_LABELS 8
> -
>  __u32 get_addr32(const char *name);
>  int get_addr_1(inet_prefix *dst, const char *arg, int family);
>  int get_prefix_1(inet_prefix *dst, char *arg, int family);
> @@ -155,7 +152,7 @@ const char *ipx_ntop(int af, const void *addr, char *str, size_t len);
>  int ipx_pton(int af, const char *src, void *addr);
>  
>  const char *mpls_ntop(int af, const void *addr, char *str, size_t len);
> -int mpls_pton(int af, const char *src, void *addr);
> +int mpls_pton(int af, const char *src, void *addr, size_t alen);
>  
>  extern int __iproute2_hz_internal;
>  int __get_hz(void);
> diff --git a/lib/mpls_pton.c b/lib/mpls_pton.c
> index bd448cfcf14a..6d2e6a69436a 100644
> --- a/lib/mpls_pton.c
> +++ b/lib/mpls_pton.c
> @@ -7,12 +7,13 @@
>  #include "utils.h"
>  
>  
> -static int mpls_pton1(const char *name, struct mpls_label *addr)
> +static int mpls_pton1(const char *name, struct mpls_label *addr,
> +		      unsigned int maxlabels)
>  {
>  	char *endp;
>  	unsigned count;
>  
> -	for (count = 0; count < MPLS_MAX_LABELS; count++) {
> +	for (count = 0; count < maxlabels; count++) {
>  		unsigned long label;
>  
>  		label = strtoul(name, &endp, 0);
> @@ -37,17 +38,19 @@ static int mpls_pton1(const char *name, struct mpls_label *addr)
>  		addr += 1;
>  	}
>  	/* The address was too long */
> +	fprintf(stderr, "Error: too many labels.\n");
>  	return 0;
>  }
>  
> -int mpls_pton(int af, const char *src, void *addr)
> +int mpls_pton(int af, const char *src, void *addr, size_t alen)
>  {
> +	unsigned int maxlabels = alen / sizeof(struct mpls_label);

Could ARRAY_SIZE be used?

Also, I know its only calculated twice, but might it be nicer to
provide a function or macro to do so? It seems like an ugly thing
to open code.

Cosmetic points above notwithstanding:

Reviewed-by: Simon Horman <simon.horman@netronome.com>

>  	int err;
>  
>  	switch(af) {
>  	case AF_MPLS:
>  		errno = 0;
> -		err = mpls_pton1(src, (struct mpls_label *)addr);
> +		err = mpls_pton1(src, (struct mpls_label *)addr, maxlabels);
>  		break;
>  	default:
>  		errno = EAFNOSUPPORT;
> diff --git a/lib/utils.c b/lib/utils.c
> index 6d5642f4f1f3..e77bd302530b 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -518,15 +518,18 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
>  	}
>  
>  	if (family == AF_MPLS) {
> +		unsigned int maxlabels;
>  		int i;
>  
>  		addr->family = AF_MPLS;
> -		if (mpls_pton(AF_MPLS, name, addr->data) <= 0)
> +		if (mpls_pton(AF_MPLS, name, addr->data,
> +			      sizeof(addr->data)) <= 0)
>  			return -1;
>  		addr->bytelen = 4;
>  		addr->bitlen = 20;
>  		/* How many bytes do I need? */
> -		for (i = 0; i < 8; i++) {
> +		maxlabels = sizeof(addr->data) / sizeof(struct mpls_label);
> +		for (i = 0; i < maxlabels; i++) {
>  			if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
>  				addr->bytelen = (i + 1)*4;
>  				break;
> -- 
> 2.11.0 (Apple Git-81)
> 
