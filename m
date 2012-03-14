From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] enhance usability of /proc/sys/net/ipv4/ip_local_reserved_ports (v3)
Date: Wed, 14 Mar 2012 15:34:45 -0700
Message-ID: <m14ntqbym2.fsf@fess.ebiederm.org>
References: <4F5BE563.9050506@gmx.de> <4F5FAF28.5030205@gmx.de>
	<4F611835.4080904@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47994 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932403Ab2CNWbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 18:31:25 -0400
In-Reply-To: <4F611835.4080904@gmx.de> (Helge Deller's message of "Wed, 14 Mar
	2012 23:14:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Helge Deller <deller@gmx.de> writes:

> When writing to the ip_local_reserved_ports proc file it will currently clear
> all previously reserved ports and update the current list with the one given 
> in the input.
>
> This behaviour makes it's usage quite hard, for example:
> a) The generic proc filesystem limitation of only handle up to PAGE_SIZE-1
>    characters at maximum may not be sufficient to provide all your wished-to-
>    be-reserved ports at once.

Fundamentally this need to be fixed first or else you will not be able
to display the bitmap through sysctl.

> b) There is no easy way to disable specific given ports, you always need to
>    give the full port list at once. This makes shell scripting hard, since
>    you need to parse everything yourself.

> c) There is no easy way to just add specific ports or port ranges. Again,
>    this would be useful for shell scripts.

Arguably b and c call for user space tools for better tools for dealing
with text ranges not a magic parser in /proc.  We already have tools
like seq, dshbak, and pdsh.  What is the difficulty of writing a little
shell utility instead of modifying /proc?

> The following patch solves this problem by simply extending the parser
> in proc_do_large_bitmap() to accept the keywords "add" and "release" in front
> of given ports or port ranges and to either add or drop the given ports
> from the already existing list.
>
> Here is an example:
> $ echo "1000-2000,5000" > /proc/sys/net/ipv4/ip_local_reserved_ports
> $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
> 1000-2000,5000   (works as before, current port list is replaced by new one)
>
> $ echo "add 3000-4000" > /proc/sys/net/ipv4/ip_local_reserved_ports
> $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
> 1000-2000,3000-4000,5000   (new ports added)
>
> $ echo "release 1500-3500" > /proc/sys/net/ipv4/ip_local_reserved_ports
> $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
> 1000-1499,3501-4000,5000   (given ports were dropped from the list)
>
> My main motivation for this patch is because of a huge commercial application
> which by default may use lots of ports. The full port list which I would have
> needed to echo to the /proc/sys/net/ipv4/ip_local_reserved_ports file was
> around 30K, and in this case all ports were already combined to regions where
> possible. With this patch it's now easy to split up the port ranges into
> single pieces and to implement everything in simple bootup shell scripts.
> Furthermore adding new or removing unneeded ports dynamically at runtime is
> now easily possible.

You are breaking concept that the bitmap is a single value in /proc/sys
which I don't like at all.

And ultimately this is a lot of code to avoid fixing a 4K limit of
sysctl reads and writes.  If I understand this correctly after this
patch is applied you can not read the result you write in with your
commercial application.  That just seems wrong.

Can you please attack the fundamental issue first?

Eric

> Signed-off-by: Helge Deller <deller@gmx.de>
> CC: Octavian Purdila <octavian.purdila@intel.com>
> CC: netdev@vger.kernel.org
> CC: David Miller <davem@davemloft.net>
> CC: Cong Wang <amwang@redhat.com>
> CC: "Eric W. Biederman" <ebiederm@xmission.com>
>
>  Documentation/networking/ip-sysctl.txt |   10 +++++-
>  kernel/sysctl.c                        |   51 ++++++++++++++++++++++++++++-----
>  2 files changed, 53 insertions(+), 8 deletions(-)
>
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index ad3e80e..fc52546 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -624,7 +624,15 @@ ip_local_reserved_ports - list of comma separated ranges
>  	list of ranges (e.g. "1,2-4,10-10" for ports 1, 2, 3, 4 and
>  	10). Writing to the file will clear all previously reserved
>  	ports and update the current list with the one given in the
> -	input.
> +	input unless one of the keywords "add" or "release" is used
> +	in front of the ports in which case the given ports are added
> +	to or released from the currently existing port list.
> +	Example:
> +	$ echo "1000-2000" > /proc/sys/net/ipv4/ip_local_reserved_ports
> +	$ echo "add 3000-4000,5000" > /proc/sys/net/ipv4/ip_local_reserved_ports
> +	$ echo "release 1500-3500" > /proc/sys/net/ipv4/ip_local_reserved_ports
> +	$ cat /proc/sys/net/ipv4/ip_local_reserved_ports
> +	1000-1499,3501-4000,5000
>  
>  	Note that ip_local_port_range and ip_local_reserved_ports
>  	settings are independent and both are considered by the kernel
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index f487f25..f9b1930 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2805,6 +2805,8 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
>   * We use a range comma separated format (e.g. 1,3-4,10-10) so that
>   * large bitmaps may be represented in a compact manner. Writing into
>   * the file will clear the bitmap then update it with the given input.
> + * If "add" or "release" is written in front of numbers or number ranges,
> + * the given bits will be added to or released from the existing bitmap.
>   *
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
>  		if (!tmp_bitmap) {
>  			free_page(page);
>  			return -ENOMEM;
> @@ -2852,6 +2857,29 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>  			unsigned long val_a, val_b;
>  			bool neg;
>  
> +			left -= proc_skip_spaces(&kbuf);
> +			if (!left)
> +				continue;
> +
> +			if (first || add_or_release) {
> +				if (!strnicmp(kbuf, "add ", 4)) {
> +					xrelease = 0;
> +					add_or_release = 1;
> +					kbuf += 4;
> +					left -= 4;
> +				} else
> +				if (!strnicmp(kbuf, "release ", 8)) {
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
> +
>  			err = proc_get_long(&kbuf, &left, &val_a, &neg, tr_a,
>  					     sizeof(tr_a), &c);
>  			if (err)
> @@ -2885,12 +2913,20 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
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
>  		}
>  		free_page(page);
> +
> +		/* Do not allow adding and releasing same bits in one step. */
> +		if (!err && add_or_release &&
> +		    bitmap_intersects(tmp_bitmap, release_bitmap, bitmap_len))
> +			err = -EINVAL;
>  	} else {
>  		unsigned long bit_a, bit_b = 0;
>  
> @@ -2926,9 +2962,10 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
>  
>  	if (!err) {
>  		if (write) {
> -			if (*ppos)
> +			if (*ppos || add_or_release) {
>  				bitmap_or(bitmap, bitmap, tmp_bitmap, bitmap_len);
> -			else
> +				bitmap_andnot(bitmap, bitmap, release_bitmap, bitmap_len);
> +			} else
>  				memcpy(bitmap, tmp_bitmap,
>  					BITS_TO_LONGS(bitmap_len) * sizeof(unsigned long));
>  		}
