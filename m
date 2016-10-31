From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix: escape all null bytes in abstract unix domain
 socket
Date: Mon, 31 Oct 2016 15:31:17 -0400 (EDT)
Message-ID: <20161031.153117.1954668010224339938.davem@davemloft.net>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
        <1477768820-1295-2-git-send-email-iboukris@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: iboukris@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477768820-1295-2-git-send-email-iboukris@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Isaac Boukris <iboukris@gmail.com>
Date: Sat, 29 Oct 2016 22:20:20 +0300

> Abstract unix domain socket may embed null characters,
> these should be translated to '@' when printed out to
> proc the same way the null prefix is currently being
> translated.
> 
> This helps for tools such as netstat, lsof and the proc
> based implementation in ss to show all the significant
> bytes of the name (instead of getting cut at the first
> null occurrence).
> 
> Signed-off-by: Isaac Boukris <iboukris@gmail.com>
 ...
> @@ -2805,14 +2805,19 @@ static int unix_seq_show(struct seq_file *seq, void *v)
>  
>  			i = 0;
>  			len = u->addr->len - sizeof(short);
> -			if (!UNIX_ABSTRACT(s))
> +			if (!UNIX_ABSTRACT(s)) {
>  				len--;
> -			else {
> +				for ( ; i < len; i++)
> +					seq_putc(seq,
> +						 u->addr->name->sun_path[i]);
> +			} else {
>  				seq_putc(seq, '@');
>  				i++;
> +				for ( ; i < len; i++)
> +					seq_putc(seq,
> +						 u->addr->name->sun_path[i] ?:
> +						 '@');
>  			}
> -			for ( ; i < len; i++)
> -				seq_putc(seq, u->addr->name->sun_path[i]);

I think this patch is simpler if you just do the "@" translation
unconditionally, if it'll never trigger for the !UNIX_ABSTRACT case
that is perfectly fine.
