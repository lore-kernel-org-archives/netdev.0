From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] limit rt cache size
Date: Mon, 7 Aug 2006 20:48:42 +0400
Message-ID: <20060807164842.GA3412@ms2.inr.ac.ru>
References: <44D75EF8.1070901@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:4309 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932216AbWHGQtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 12:49:09 -0400
To: Kirill Korotaev <dev@sw.ru>
Content-Disposition: inline
In-Reply-To: <44D75EF8.1070901@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> During OpenVZ stress testing we found that UDP traffic with
> random src can generate too much excessive rt hash growing
> leading finally to OOM and kernel panics.
> 
> It was found that for 4GB i686 system (having 1048576 total pages and
>  225280 normal zone pages) kernel allocates the following route hash:
> syslog: IP route cache hash table entries: 262144 (order: 8, 1048576 bytes)
> => ip_rt_max_size = 4194304 entries, i.e.
> max rt size is 4194304 * 256b = 1Gb of RAM > normal_zone

Grrr... Indeed.


> Attached the patch which removes HASH_HIGHMEM flag from
> alloc_large_system_hash() call. However, I'm not sure whether
> it should be removed as well for TCP tcp_hashinfo.ehash and
> tcp_hashinfo.bhash (as those are probably limited by number of files?).

The patch looks OK. But I am not sure too.

To be honest, I do not understand the sense of HASH_HIGHMEM flag.
At the first sight, hash table eats low memory, objects hashed in this table
also eat low memory. Why is its size calculated from total memory?
But taking into account that this flag is used only by tcp.c and route.c,
both of which feed on low memory, I miss something important.

Let's ask people on netdev.


What's about routing cache size, it looks like it is another bug.
route.c should not force rt_max_size = 16*rt_hash_size.
I think it should consult available memory and to limit rt_max_size
to some reasonable value, even if hash size is too high.



> --- ./net/ipv4/route.c.xrt	2006-07-14 19:08:33.000000000 +0400
> +++ ./net/ipv4/route.c	2006-08-07 18:25:37.000000000 +0400
> @@ -3149,7 +3149,7 @@ int __init ip_rt_init(void)
>  					rhash_entries,
>  					(num_physpages >= 128 * 1024) ?
>  					15 : 17,
> -					HASH_HIGHMEM,
> +					0,
>  					&rt_hash_log,
>  					&rt_hash_mask,
>  					0);

