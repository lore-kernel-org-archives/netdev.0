From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec [Updated #2]
Date: Tue, 27 Jun 2006 09:14:29 -0400
Message-ID: <1151414069.20419.37.camel@moss-spartans.epoch.ncsc.mil>
References: <20060627052255.GA1311@jiayuguan.watson.ibm.com>
	 <Pine.LNX.4.64.0606270311210.30073@d.namei>
	 <Pine.LNX.4.64.0606270315130.30073@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Catherine Zhang <cxzhang@watson.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, jmorris@redhat.com,
	chrisw@osdl.org, Herbert Xu <herbert@gondor.apana.org.au>,
	tjaeger@cse.psu.edu, Andrew Morton <akpm@osdl.org>,
	latten@austin.ibm.com, sergeh@us.ibm.com, gcwilson@us.ibm.com,
	czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie.ncsc.mil ([144.51.88.131]:9431 "EHLO jazzdrum.ncsc.mil")
	by vger.kernel.org with ESMTP id S932257AbWF0NNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 09:13:21 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606270315130.30073@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 03:16 -0400, James Morris wrote:
> On Tue, 27 Jun 2006, James Morris wrote:
> 
> > I'll address that in a patch to follow.  Could you please test these 
> > updated patches?  Thanks.
> > 
> 
> 
> Below is a relative patch which only compiles this stuff into the core 
> networking code when appropriate kernel config is selected.
> 
> Please review.
> 
> 
> ---
> 
> diff -purN -X dontdiff linux-2.6.p/include/net/scm.h linux-2.6.w/include/net/scm.h
> --- linux-2.6.p/include/net/scm.h	2006-06-27 02:26:02.000000000 -0400
> +++ linux-2.6.w/include/net/scm.h	2006-06-27 03:03:30.000000000 -0400
> @@ -19,7 +19,9 @@ struct scm_cookie
>  {
>  	struct ucred		creds;		/* Skb credentials	*/
>  	struct scm_fp_list	*fp;		/* Passed files		*/
> +#ifdef CONFIG_SECURITY_NETWORK	
>  	char			*secdata;	/* Security context	*/

What about saving the u32 seclen with the secdata, and using it later
rather than recomputing strlen(secdata)?  That also avoids encoding an
assumption in the af_unix code about the content of the data (i.e.
NUL-terminated string), leaving that to the security module.

> +#endif	
>  	unsigned long		seq;		/* Connection seqno	*/
>  };
>  
> @@ -49,6 +51,17 @@ static __inline__ int scm_send(struct so
>  	return __scm_send(sock, msg, scm);
>  }
>  
> +#ifdef CONFIG_SECURITY_NETWORK
> +static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
> +{
> +	if (test_bit(SOCK_PASSSEC, &sock->flags) && scm->secdata != NULL)
> +		put_cmsg(msg, SOL_SOCKET, SCM_SECURITY, strlen(scm->secdata)+1, scm->secdata);
> +}

It would be cleaner if we had a scm->seclen to use above.

> +#ifdef CONFIG_SECURITY_NETWORKING
> +static void unix_get_peersec_dgram(struct sk_buff *skb)
> +{
> +	int tmp = 0;
> +	
> +	err = security_socket_getpeersec_dgram(skb, UNIXSEC(skb), &tmp);

tmp should actually be u32 not int (also wrong in the original patch),
and it seems odd to throw it away rather than saving it and using it for
the put_cmsg.

-- 
Stephen Smalley
National Security Agency

