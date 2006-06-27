From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec [Updated #2]
Date: Tue, 27 Jun 2006 12:33:31 -0400
Message-ID: <OF25503D9D.7472F189-ON8525719A.005A800A-8525719A.005AF5A3@us.ibm.com>
References: <Pine.LNX.4.64.0606270954080.804@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, chrisw@osdl.org,
	Catherine Zhang <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	George Wilson <gcwilson@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, jmorris@redhat.com,
	latten@austin.ibm.com, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:40164 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1161160AbWF0Qdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 12:33:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5RGXZXe010307
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 12:33:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5RGXZEG211394
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 12:33:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5RGXYFE022671
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 12:33:35 -0400
In-Reply-To: <Pine.LNX.4.64.0606270954080.804@d.namei>
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more fixes:
 
> diff -purN -X dontdiff linux-2.6.o/net/unix/af_unix.c linux-2.6.
> w/net/unix/af_unix.c
> --- linux-2.6.o/net/unix/af_unix.c   2006-06-21 00:02:30.000000000 -0400
> +++ linux-2.6.w/net/unix/af_unix.c   2006-06-27 09:30:12.000000000 -0400
> @@ -128,6 +128,28 @@ static atomic_t unix_nr_socks = ATOMIC_I
> 
>  #define UNIX_ABSTRACT(sk)   (unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
> 
> +#ifdef CONFIG_SECURITY_NETWORK
> +static void unix_get_peersec_dgram(struct sk_buff *skb)
> +{

add int err;

> +   err = security_socket_getpeersec_dgram(skb, UNIXSECDATA(skb),
> +                      UNIXSECLEN(skb));
> +   if (err)
> +      *(UNIXSEC(skb)) = NULL;

change to *(UNIXSECDATA(skb)) = NULL;

> +}
> +
> +static inline void unix_set_secdata(struct scm_cookie *scm, struct 
> sk_buff *skb)
> +{
> +   scm->secdata = *UNIXSECDATA(skb);
> +   scm->seclen = UNIXSECLEN(skb);

change to scm->seclen = *UNIXSECLEN(skb);

> +}
> +#else
> +static void unix_get_peersec_dgram(struct sk_buff *skb)
> +{ }
> +
> +static inline void unix_set_secdata(struct scm_cookie *scm, struct 
> sk_buff *skb)
> +{ }
> +#endif /* CONFIG_SECURITY_NETWORKING */
> +
>  /*
>   *  SMP locking strategy:
>   *    hash table is protected with spinlock unix_table_lock
> @@ -1291,6 +1313,8 @@ static int unix_dgram_sendmsg(struct kio
>     if (siocb->scm->fp)
>        unix_attach_fds(siocb->scm, skb);
> 
> +   unix_get_peersec_dgram(skb);
> +
>     skb->h.raw = skb->data;
>     err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
>     if (err)
> @@ -1570,6 +1594,7 @@ static int unix_dgram_recvmsg(struct kio
>        memset(&tmp_scm, 0, sizeof(tmp_scm));
>     }
>     siocb->scm->creds = *UNIXCREDS(skb);
> +   unix_set_secdata(siocb->scm, skb);
> 
>     if (!(flags & MSG_PEEK))
>     {

