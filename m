From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Wed, 09 Aug 2006 10:34:38 -0700
Message-ID: <1155144878.3049.8.camel@w-sridhar2.beaverton.ibm.com>
References: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
	 <20060807.205910.68157131.davem@davemloft.net>
	 <1155057591.26188.5.camel@w-sridhar2.beaverton.ibm.com>
	 <20060808.170941.71164303.davem@davemloft.net>
	 <1155093402.5731.35.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:65409 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751222AbWHIRjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 13:39:52 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k79HdpGB015841
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 13:39:51 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k79HdpQb281116
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 13:39:51 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k79HdpBx006881
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 13:39:51 -0400
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1155093402.5731.35.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 23:16 -0400, Trond Myklebust wrote:
> On Tue, 2006-08-08 at 17:09 -0700, David Miller wrote:
> 
> > Trond, I think the highmem check in xs_sendpages() is completely
> > bogus, do you mind if we remove it? :-)
> > 
> > The socket layer will properly check the device to make sure it
> > can handle highmem pages, and if not it will copy the data into
> > a low-mem page as-needed.
> 
> If the special case is no longer useful, then I for one am quite happy
> to get rid of it.

OK. Here is a patch that does it.

[SUNRPC]: Remove the unnecessary check for highmem in xs_sendpages()
and call kernel_sendpage() directly.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -174,7 +174,6 @@ static inline int xs_sendpages(struct so
 	struct page **ppage = xdr->pages;
 	unsigned int len, pglen = xdr->page_len;
 	int err, ret = 0;
-	ssize_t (*sendpage)(struct socket *, struct page *, int, size_t, int);
 
 	if (unlikely(!sock))
 		return -ENOTCONN;
@@ -207,7 +206,6 @@ static inline int xs_sendpages(struct so
 		base &= ~PAGE_CACHE_MASK;
 	}
 
-	sendpage = kernel_sendpage;
 	do {
 		int flags = XS_SENDMSG_FLAGS;
 
@@ -220,10 +218,7 @@ static inline int xs_sendpages(struct so
 		if (pglen != len || xdr->tail[0].iov_len != 0)
 			flags |= MSG_MORE;
 
-		/* Hmm... We might be dealing with highmem pages */
-		if (PageHighMem(*ppage))
-			sendpage = sock_no_sendpage;
-		err = sendpage(sock, *ppage, base, len, flags);
+		err = kernel_sendpage(sock, *ppage, base, len, flags);
 		if (ret == 0)
 			ret = err;
 		else if (err > 0)



