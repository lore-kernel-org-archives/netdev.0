From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix unsigned int comparison with less than
 zero
Date: Sun, 13 Nov 2016 12:15:19 -0500 (EST)
Message-ID: <20161113.121519.399311594808700910.davem@davemloft.net>
References: <20161110155758.26996-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, pshelar@ovn.org, weiyongjun1@huawei.com,
        fw@strlen.de, tycho.andersen@canonical.com,
        xiyou.wangcong@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161110155758.26996-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 10 Nov 2016 15:57:58 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> family->id is unsigned, so the less than zero check for
> failure return from idr_alloc is never true and so the error exit
> is never handled.  Instead, assign err and check if this is less
> than zero since this is a signed integer.
> 
> Issue found with static analysis with CoverityScan, CID 1375916
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/netlink/genetlink.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index f0b65fe..2ea61ba 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -360,12 +360,10 @@ int genl_register_family(struct genl_family *family)
>  	} else
>  		family->attrbuf = NULL;
>  
> -	family->id = idr_alloc(&genl_fam_idr, family,
> +	family->id = err = idr_alloc(&genl_fam_idr, family,
>  			       start, end + 1, GFP_KERNEL);

First of all, if we make this change you must fixup the indentation of
the second l ine of this idr_alloc() call.  Arguments spanning
multiple lines of a call must be indented precisely to the column
following the openning parenthesis of the first line.

Next, the IDR helpers never give us values that fall within the
positive range of an integer that does not fall within the postive
range of an unsigned integer.

We are going to pass this value in later to release the ID, again
the interface will expect a signed rather than an unsigned int.

Therefore is makes sesne only to change the family->id type to
what it must be, which is a signed int.

I've commited the following to net-next:

====================
[PATCH] genetlink: Make family a signed integer.

The idr_alloc(), idr_remove(), et al. routines all expect IDs to be
signed integers.  Therefore make the genl_family member 'id' signed
too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/genetlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 3ec87ba..a34275b 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -48,7 +48,7 @@ struct genl_info;
  * @n_ops: number of operations supported by this family
  */
 struct genl_family {
-	unsigned int		id;		/* private */
+	int			id;		/* private */
 	unsigned int		hdrsize;
 	char			name[GENL_NAMSIZ];
 	unsigned int		version;
-- 
2.7.4
