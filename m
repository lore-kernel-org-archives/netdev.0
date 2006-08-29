From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] Fix verify_iovec() to not allow overflow of iov_len
	values
Date: Tue, 29 Aug 2006 14:05:07 -0700
Message-ID: <1156885507.3147.12.camel@w-sridhar2.beaverton.ibm.com>
References: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
	 <20060829182039.GW10348@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:44450 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965330AbWH2VFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 17:05:14 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TL5EBS028124
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 17:05:14 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TL59Bm290656
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 17:05:14 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TL58As012180
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 17:05:09 -0400
To: Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <20060829182039.GW10348@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-29 at 11:20 -0700, Chris Wright wrote:
> * Sridhar Samudrala (sri@us.ibm.com) wrote:
> > -int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
> > +ssize_t verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
> >  {
> >  	int size, err, ct;
> > +	ssize_t tot_len = 0;
> >  	
> >  	if (m->msg_namelen) {
> >  		if (mode == VERIFY_READ) {
> > @@ -61,17 +62,22 @@ int verify_iovec(struct msghdr *m, struc
> >  	err = 0;
> >  
> >  	for (ct = 0; ct < m->msg_iovlen; ct++) {
> > -		err += iov[ct].iov_len;
> > +		ssize_t len;
> > +
> >  		/*
> > -		 * Goal is not to verify user data, but to prevent returning
> > -		 * negative value, which is interpreted as errno.
> > -		 * Overflow is still possible, but it is harmless.
> > +		 * Goal is not to verify user data, but to prevent the cases 
> > +		 * where an iov_len value or the sum of all iov_len values
> > +		 * overflows ssize_t.
> >  		 */
> > -		if (err < 0)
> > -			return -EMSGSIZE;
> > +		len = (ssize_t)iov[ct].iov_len;
> > +		if (len < 0)
> > +			return -EINVAL;
> > +		tot_len += len;
> > +		if (tot_len < 0)
> 
> I specifically used size_t here, because signed integer overflow is not
> defined in C.

Is this a problem even if we are adding only positive integers?
I tried some tests and i didn't see any problem.
For ex: adding 2 max positive integers 0x7fffffff gave a result of -2
which passes the test for overflow.
    0x7fffffff + 0x7ffffff = -2 
    0x7fffffff + 1 = -2147483648

Thanks
Sridhar

> 
> thanks,
> -chris
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

