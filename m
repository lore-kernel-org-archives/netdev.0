From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bug report] rhashtable: Add nested tables
Date: Sat, 25 Feb 2017 22:38:11 +0800
Message-ID: <20170225143811.GA28272@gondor.apana.org.au>
References: <20170216121703.GA26276@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Graf <tgraf@suug.ch>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38269 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751169AbdBYO6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2017 09:58:39 -0500
Content-Disposition: inline
In-Reply-To: <20170216121703.GA26276@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 03:17:03PM +0300, Dan Carpenter wrote:
> Hello Herbert Xu,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 40137906c5f5: "rhashtable: Add nested tables" from Feb 11, 
> 2017, leads to the following Smatch complaint:
> 
> lib/rhashtable.c:149 bucket_table_free()
> 	 warn: variable dereferenced before check 'tbl' (see line 146)
> 
> lib/rhashtable.c
>    145	{
>    146		if (tbl->nest)
>                     ^^^^^^^^^
> New unchecked dereference.
> 
>    147			nested_bucket_table_free(tbl);
>    148	
>    149		if (tbl)
>                     ^^^
> Old code checked for NULL.
> 
>    150			kvfree(tbl->locks);
>    151	

Thanks for catching this.  I checked all the callers and none
of them can provide a NULL pointer so let's just kill the check.

---8<---
Subject: rhashtable: Fix use before NULL check in bucket_table_free

Dan Carpenter reported a use before NULL check bug in the function
bucket_table_free.  In fact we don't need the NULL check at all as
no caller can provide a NULL argument.  So this patch fixes this by
simply removing it.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 172454e..fac1a78 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -146,9 +146,7 @@ static void bucket_table_free(const struct bucket_table *tbl)
 	if (tbl->nest)
 		nested_bucket_table_free(tbl);
 
-	if (tbl)
-		kvfree(tbl->locks);
-
+	kvfree(tbl->locks);
 	kvfree(tbl);
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
