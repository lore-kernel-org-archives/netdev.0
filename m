From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Thu, 31 Mar 2011 20:02:25 +0200
Message-ID: <20110331180225.GA6677@midget.suse.cz>
References: <1300603423.1869.18.camel@dan>
 <1300639685.26693.286.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, ralf@linux-mips.org,
	davem@davemloft.net, netdev@vger.kernel.org, security@kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58256 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758792Ab1CaSC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 14:02:28 -0400
Content-Disposition: inline
In-Reply-To: <1300639685.26693.286.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 20, 2011 at 04:48:05PM +0000, Ben Hutchings wrote:
> @@ -365,49 +393,44 @@ static int rose_parse_ccitt(unsigned char *p, struct rose_facilities_struct *fac
>  	return n;
>  }
>  
> -int rose_parse_facilities(unsigned char *p,
> +int rose_parse_facilities(unsigned char *p, unsigned packet_len,
>  	struct rose_facilities_struct *facilities)
>  {
>  	int facilities_len, len;
>  
>  	facilities_len = *p++;
>  
> -	if (facilities_len == 0)
> +	if (facilities_len == 0 || (unsigned)facilities_len > packet_len)
>  		return 0;
>  
> -	while (facilities_len > 0) {
> -		if (*p == 0x00) {
> -			facilities_len--;
> -			p++;
> -
> -			switch (*p) {
> -			case FAC_NATIONAL:		/* National */
> -				len = rose_parse_national(p + 1, facilities, facilities_len - 1);
> -				if (len < 0)
> -					return 0;
> -				facilities_len -= len + 1;
> -				p += len + 1;
> -				break;
> -
> -			case FAC_CCITT:		/* CCITT */
> -				len = rose_parse_ccitt(p + 1, facilities, facilities_len - 1);
> -				if (len < 0)
> -					return 0;
> -				facilities_len -= len + 1;
> -				p += len + 1;
> -				break;
> -
> -			default:
> -				printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities family %02X\n", *p);
> -				facilities_len--;
> -				p++;
> -				break;
> -			}
> -		} else
> -			break;	/* Error in facilities format */
> +	while (facilities_len >= 3 && *p == 0x00) {
> +		facilities_len--;
> +		p++;
> +
> +		switch (*p) {
> +		case FAC_NATIONAL:		/* National */
> +			len = rose_parse_national(p + 1, facilities, facilities_len - 1);
> +			break;
> +
> +		case FAC_CCITT:		/* CCITT */
> +			len = rose_parse_ccitt(p + 1, facilities, facilities_len - 1);
> +			break;
> +
> +		default:
> +			printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities family %02X\n", *p);
> +			len = 1;
> +			break;
> +		}
> +
> +		if (len < 0)
> +			return 0;
> +		if (WARN_ON(len >= facilities_len))
> +			return 0;
> +		facilities_len -= len + 1;
> +		p += len + 1;
>  	}
>  
> -	return 1;
> +	return facilities_len == 0;
>  }


This last hunk does not look correct. In the default branch of
the switch, you set len = 1, which means 
	p += 2; facilities_len -= 2.

The original code does 
	facilities_len--; p++;
... and it looks correct. So, to get the old behaviour back:

diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
index f6c71ca..9777700 100644
--- a/net/rose/rose_subr.c
+++ b/net/rose/rose_subr.c
@@ -418,7 +418,7 @@ int rose_parse_facilities(unsigned char *p, unsigned packet_len,
 
 		default:
 			printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities family %02X\n", *p);
-			len = 1;
+			len = 0;
 			break;
 		}

However, I wonder how much sense it makes to continue parsing the
facilities if an unknown facility family appears. We don't know
the length of its data, so we will interpret each 16 bytes a new
facilities header, hopefully soon bailing out on *p != 0x00.

In case of a long packet where every other byte is zero, the loop
will spam the kernel log with the printk ... which could probably
be classified as a security problem on its own. So how about the
following instead? I have no idea if this breaks some rose
specification, though. 


Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
index f6c71ca..e687c7f 100644
--- a/net/rose/rose_subr.c
+++ b/net/rose/rose_subr.c
@@ -418,8 +418,7 @@ int rose_parse_facilities(unsigned char *p, unsigned packet_len,
 
 		default:
 			printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities family %02X\n", *p);
-			len = 1;
-			break;
+			return 0;
 		}
 
 		if (len < 0)


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

