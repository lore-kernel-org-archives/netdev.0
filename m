From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] enhance usability of
 /proc/sys/net/ipv4/ip_local_reserved_ports (v2)
Date: Wed, 14 Mar 2012 15:43:53 +0800
Message-ID: <1331711033.17983.19.camel@cr0>
References: <4F5BE563.9050506@gmx.de> <4F5FAF28.5030205@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758539Ab2CNHoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:44:07 -0400
In-Reply-To: <4F5FAF28.5030205@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-13 at 21:33 +0100, Helge Deller wrote:
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index f487f25..1f60398 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2805,6 +2805,8 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
>   * We use a range comma separated format (e.g. 1,3-4,10-10) so that
>   * large bitmaps may be represented in a compact manner. Writing into
>   * the file will clear the bitmap then update it with the given input.
> + * If "add" or "release" is written in front of numbers or number ranges,
> + * the given bits will be added to or released from the existing bitmap.
>   *

What if I only write "add" or "release" ("add ", "release " too) into
this file? Make sure you have tested this corner case.

>   * Returns 0 on success.
>   */
> @@ -2813,11 +2815,13 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>  {
>  	int err = 0;
>  	bool first = 1;
> +	bool add_or_release = 0, xrelease = 0;
>  	size_t left = *lenp;
>  	unsigned long bitmap_len = table->maxlen;
>  	unsigned long *bitmap = (unsigned long *) table->data;
> -	unsigned long *tmp_bitmap = NULL;
> -	char tr_a[] = { '-', ',', '\n' }, tr_b[] = { ',', '\n', 0 }, c;
> +	unsigned long *tmp_bitmap = NULL, *release_bitmap = NULL;
> +	char tr_a[] = { '-', ',', ' ', '\n' },
> +	     tr_b[] = { ',', ' ', '\n', 0 }, c;
>  
>  	if (!bitmap_len || !left || (*ppos && !write)) {
>  		*lenp = 0;
> @@ -2841,8 +2845,9 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>                  }
>  		kbuf[left] = 0;
>  
> -		tmp_bitmap = kzalloc(BITS_TO_LONGS(bitmap_len) * sizeof(unsigned long),
> -				     GFP_KERNEL);
> +		tmp_bitmap = kzalloc(2 * BITS_TO_LONGS(bitmap_len) *
> +					sizeof(unsigned long), GFP_KERNEL);
> +		release_bitmap = &tmp_bitmap[BITS_TO_LONGS(bitmap_len)];

So you double the size, and give the second half to 'release_bitmap',
this will waste spaces when release_bitmap is short, right? *I think* we
can check if we want to release any bitmaps first, and then only
allocate one of tmp_bitmap and release_bitmap.

>  		if (!tmp_bitmap) {
>  			free_page(page);
>  			return -ENOMEM;
> @@ -2850,7 +2855,32 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>  		proc_skip_char(&kbuf, &left, '\n');
>  		while (!err && left) {
>  			unsigned long val_a, val_b;
> -			bool neg;
> +			bool neg, found;
> +
> +			left -= proc_skip_spaces(&kbuf);
> +			if (!left)
> +				continue;
> +
> +			if (first || add_or_release) {
> +				found = (0 == strnicmp(kbuf, "add ", 4));
> +				if (found) {

I think we don't need an extra variable 'found' here.

> +					xrelease = 0;
> +					add_or_release = 1;
> +					kbuf += 4;
> +					left -= 4;
> +				}
> +				found = (0 == strnicmp(kbuf, "release ", 8));
> +				if (found) {
> +					xrelease = 1;
> +					add_or_release = 1;
> +					kbuf += 8;
> +					left -= 8;
> +				}
> +
> +				left -= proc_skip_spaces(&kbuf);
> +				if (!left)
> +					continue;
> +			}
>  
>  			err = proc_get_long(&kbuf, &left, &val_a, &neg, tr_a,
>  					     sizeof(tr_a), &c);
> @@ -2885,7 +2915,10 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>  			}
>  
>  			while (val_a <= val_b)
> -				set_bit(val_a++, tmp_bitmap);
> +				if (xrelease)
> +					set_bit(val_a++, release_bitmap);
> +				else
> +					set_bit(val_a++, tmp_bitmap);
>  
>  			first = 0;
>  			proc_skip_char(&kbuf, &left, '\n');
> @@ -2926,9 +2959,10 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>  
>  	if (!err) {
>  		if (write) {
> -			if (*ppos)
> +			if (*ppos || add_or_release) {
>  				bitmap_or(bitmap, bitmap, tmp_bitmap, bitmap_len);
> -			else
> +				bitmap_andnot(bitmap, bitmap, release_bitmap, bitmap_len);
> +			} else


Thanks.
