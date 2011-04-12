From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [RFC] iproute2: Fix meta match u32 with 0xffffffff
Date: Tue, 12 Apr 2011 09:56:49 +0200
Message-ID: <1302595009.3664.8.camel@lsx>
References: <20110411115234.74b5936b@nehalam>
Reply-To: tgraf@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab1DLH4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 03:56:51 -0400
In-Reply-To: <20110411115234.74b5936b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-11 at 11:52 -0700, Stephen Hemminger wrote: 
> The value 0xffffffff is a valid mask and bstrtoul() would return
> ULONG_MAX which was the error value. Resolve the problem by separating
> return value and error indication.
>  
> -unsigned long bstrtoul(const struct bstr *b)
> +int bstrtoul(const struct bstr *b, unsigned long *lp)
>  {
>  	char *inv = NULL;
> -	unsigned long l;
>  	char buf[b->len+1];
>  
> +	if (b->len == 0)
> +		return -EINVAL;
> +
>  	memcpy(buf, b->data, b->len);
>  	buf[b->len] = '\0';
>  
> -	l = strtoul(buf, &inv, 0);
> -	if (l == ULONG_MAX || inv == buf)
> -		return ULONG_MAX;
> +	*lp = strtoul(buf, &inv, 0);
> +	if (inv == buf)
> +		return -EINVAL;
> +
> +	if (*lp == ULONG_MAX || errno == ERANGE)
> +		return -ERANGE;
>  
> -	return l;
> +	return 0;
>  }

This is definitely much better but we still can't parse ULONG_MAX
as string representative. Checking glibc docs, the only way to do it is
to ignore the return value for error checking and look errno.

So I guess we should do something like this:

errno = 0;
*lp = strtoul(buf, &inv, 0);
if (*inv != '\0')
return -EINVAL;
else if (errno)
return errno;

return 0;

