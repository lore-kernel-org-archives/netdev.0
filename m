From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] Fix verify_iovec() to not allow overflow of iov_len values
Date: Tue, 29 Aug 2006 11:20:39 -0700
Message-ID: <20060829182039.GW10348@sequoia.sous-sol.org>
References: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chrisw@sous-sol.org, akpm@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:4225 "EHLO
	sous-sol.org") by vger.kernel.org with ESMTP id S1751133AbWH2SRt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 14:17:49 -0400
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Sridhar Samudrala (sri@us.ibm.com) wrote:
> -int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
> +ssize_t verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
>  {
>  	int size, err, ct;
> +	ssize_t tot_len = 0;
>  	
>  	if (m->msg_namelen) {
>  		if (mode == VERIFY_READ) {
> @@ -61,17 +62,22 @@ int verify_iovec(struct msghdr *m, struc
>  	err = 0;
>  
>  	for (ct = 0; ct < m->msg_iovlen; ct++) {
> -		err += iov[ct].iov_len;
> +		ssize_t len;
> +
>  		/*
> -		 * Goal is not to verify user data, but to prevent returning
> -		 * negative value, which is interpreted as errno.
> -		 * Overflow is still possible, but it is harmless.
> +		 * Goal is not to verify user data, but to prevent the cases 
> +		 * where an iov_len value or the sum of all iov_len values
> +		 * overflows ssize_t.
>  		 */
> -		if (err < 0)
> -			return -EMSGSIZE;
> +		len = (ssize_t)iov[ct].iov_len;
> +		if (len < 0)
> +			return -EINVAL;
> +		tot_len += len;
> +		if (tot_len < 0)

I specifically used size_t here, because signed integer overflow is not
defined in C.

thanks,
-chris
