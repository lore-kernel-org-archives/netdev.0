From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v12 net-next 03/11] bpf: add
 lookup/update/delete/iterate methods to BPF maps
Date: Tue, 16 Sep 2014 15:16:06 -0400 (EDT)
Message-ID: <20140916.151606.448751391205382097.davem@davemloft.net>
References: <1410808721-27493-1-git-send-email-ast@plumgrid.com>
	<1410808721-27493-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, torvalds@linux-foundation.org,
	luto@amacapital.net, dborkman@redhat.com,
	hannes@stressinduktion.org, chema@google.com, edumazet@google.com,
	a.p.zijlstra@chello.nl, pablo@netfilter.org, hpa@zytor.com,
	akpm@linux-foundation.org, keescook@chromium.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbaIPTQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 15:16:10 -0400
In-Reply-To: <1410808721-27493-4-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 15 Sep 2014 12:18:33 -0700

> @@ -83,6 +112,15 @@ union bpf_attr {
>  		__u32	value_size;	/* size of value in bytes */
>  		__u32	max_entries;	/* max number of entries in a map */
>  	};
> +
> +	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
> +		int map_fd;
> +		void __user *key;
> +		union {
> +			void __user *value;
> +			void __user *next_key;
> +		};
> +	};
>  };
>  
>  #endif /* _UAPI__LINUX_BPF_H__ */

Depending upon the processor ABI, this change can increase the
alignment requirements of union bpf_attr.  So the structure is not
compatible between patch #1 and patch #3 here.

Also, you haven't implemented any compat layer whatsoever for the
necessary translations.  This happens because you are using pointers
which are different sized between 32-bit and 64-bit ABIs.

I would suggest you use instead something like "aligned_u64" since
these are just arbitrary userland cookies and using "aligned_u64"
vs. "u64" will make it so that you don't have to deal with the 64-bit
type alignment differences between x86-32 and x86-64 while writing the
compat wrappers (if any).
