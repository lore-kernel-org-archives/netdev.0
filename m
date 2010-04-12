From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Patch 1/3] sysctl: refactor integer handling proc code
Date: Mon, 12 Apr 2010 10:18:01 +0000 (UTC)
Message-ID: <20100413111814.GB4396@x200>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>
 <20100412100754.5302.99552.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 13 Apr 2010 14:18:15 +0300
Content-Disposition: inline
In-Reply-To: <20100412100754.5302.99552.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 12, 2010 at 06:04:04AM -0400, Amerigo Wang wrote:
> As we are about to add another integer handling proc function a little
> bit of cleanup is in order: add a few helper functions to improve code
> readability and decrease code duplication.
> 
> In the process a bug is also fixed: if the user specifies a number
> with more then 20 digits it will be interpreted as two integers
> (e.g. 10000...13 will be interpreted as 100.... and 13).

ULONG_MAX is not 22 digits always.

The fix is to not rely on simple_strtoul()

I guess it's time to finally remove it. :-(

Also, it's better to copy_from user stuff once.
Without looking at non-trivial users, one page should be enough.

> Behavior for EFAULT handling was changed as well. Previous to this
> patch, when an EFAULT error occurred in the middle of a write
> operation, although some of the elements were set, that was not
> acknowledged to the user (by shorting the write and returning the
> number of bytes accepted). EFAULT is now treated just like any other
> errors by acknowledging the amount of bytes accepted.

> +static int proc_skip_wspace(char __user **buf, size_t *size)
> +{
> +	char c;
> +
> +	while (*size) {
> +		if (get_user(c, *buf))
> +			return -EFAULT;
> +		if (!isspace(c))
> +			break;
> +		(*size)--;
> +		(*buf)++;
> +	}
> +
> +	return 0;
> +}

yeah, copy_from_user once, so we won't have this.

> +static bool isanyof(char c, const char *v, unsigned len)

A what?
this is memchr()

> +{
> +	int i;
> +
> +	if (!len)
> +		return false;
> +
> +	for (i = 0; i < len; i++)
> +		if (c == v[i])
> +			break;
> +	if (i == len)
> +		return false;
> +
> +	return true;
> +}
> +
> +#define TMPBUFLEN 22
> +/**
> + * proc_get_long - reads an ASCII formated integer from a user buffer
> + *
> + * @buf - user buffer
> + * @size - size of the user buffer
> + * @val - this is where the number will be stored
> + * @neg - set to %TRUE if number is negative
> + * @perm_tr - a vector which contains the allowed trailers
> + * @perm_tr_len - size of the perm_tr vector
> + * @tr - pointer to store the trailer character
> + *
> + * In case of success 0 is returned and buf and size are updated with
> + * the amount of bytes read. If tr is non NULL and a trailing
> + * character exist (size is non zero after returning from this
> + * function) tr is updated with the trailing character.
> + */
> +static int proc_get_long(char __user **buf, size_t *size,
> +			  unsigned long *val, bool *neg,
> +			  const char *perm_tr, unsigned perm_tr_len, char *tr)
> +{
> +	int len;
> +	char *p, tmp[TMPBUFLEN];
> +
> +	if (!*size)
> +		return -EINVAL;
> +
> +	len = *size;
> +	if (len > TMPBUFLEN-1)
> +		len = TMPBUFLEN-1;
> +
> +	if (copy_from_user(tmp, *buf, len))
> +		return -EFAULT;
> +
> +	tmp[len] = 0;
> +	p = tmp;
> +	if (*p == '-' && *size > 1) {
> +		*neg = 1;
> +		p++;
> +	} else
> +		*neg = 0;
> +	if (!isdigit(*p))
> +		return -EINVAL;
> +
> +	*val = simple_strtoul(p, &p, 0);
> +
> +	len = p - tmp;
> +
> +	/* We don't know if the next char is whitespace thus we may accept
> +	 * invalid integers (e.g. 1234...a) or two integers instead of one
> +	 * (e.g. 123...1). So lets not allow such large numbers. */
> +	if (len == TMPBUFLEN - 1)
> +		return -EINVAL;
> +
> +	if (len < *size && perm_tr_len && !isanyof(*p, perm_tr, perm_tr_len))
> +		return -EINVAL;
> +
> +	if (tr && (len < *size))
> +		*tr = *p;
> +
> +	*buf += len;
> +	*size -= len;
> +
> +	return 0;
> +}
