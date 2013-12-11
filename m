From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH -next 3/3] netfilter: Use seq_overflow
Date: Wed, 11 Dec 2013 08:17:17 +0000
Message-ID: <20131211081717.GU10323@ZenIV.linux.org.uk>
References: <cover.1386738050.git.joe@perches.com>
 <81323bd2acdabcd7ab7d62e05032e6529b8dfbf0.1386738050.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36838 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058Ab3LKIRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 03:17:54 -0500
Content-Disposition: inline
In-Reply-To: <81323bd2acdabcd7ab7d62e05032e6529b8dfbf0.1386738050.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 09:12:44PM -0800, Joe Perches wrote:
> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> @@ -59,8 +59,10 @@ static bool ipv4_invert_tuple(struct nf_conntrack_tuple *tuple,
>  static int ipv4_print_tuple(struct seq_file *s,
>  			    const struct nf_conntrack_tuple *tuple)
>  {
> -	return seq_printf(s, "src=%pI4 dst=%pI4 ",
> -			  &tuple->src.u3.ip, &tuple->dst.u3.ip);
> +	seq_printf(s, "src=%pI4 dst=%pI4 ",
> +		   &tuple->src.u3.ip, &tuple->dst.u3.ip);
> +
> +	return seq_overflow(s);
>  }

I'm not at all sure we want ->print_tuple() to return anything;
if we *really* want to check overflow and skip some expensive
output, we can bloody well do that in callers of print_tuple().

> @@ -104,10 +104,10 @@ static int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
>  	if (ret)
>  		return 0;
>  
> -	ret = seq_printf(s, "secctx=%s ", secctx);
> +	seq_printf(s, "secctx=%s ", secctx);
>  
>  	security_release_secctx(secctx, len);
> -	return ret;
> +	return seq_overflow(s);
>  }

Definitely broken.

>  static inline int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
> @@ -141,10 +141,11 @@ static int ct_seq_show(struct seq_file *s, void *v)
>  	NF_CT_ASSERT(l4proto);
>  
>  	ret = -ENOSPC;
> -	if (seq_printf(s, "%-8s %u %ld ",
> -		      l4proto->name, nf_ct_protonum(ct),
> -		      timer_pending(&ct->timeout)
> -		      ? (long)(ct->timeout.expires - jiffies)/HZ : 0) != 0)
> +	seq_printf(s, "%-8s %u %ld ",
> +		   l4proto->name, nf_ct_protonum(ct),
> +		   timer_pending(&ct->timeout)
> +		   ? (long)(ct->timeout.expires - jiffies)/HZ : 0);
> +	if (seq_overflow(s))
>  		goto release;
>  
>  	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
> @@ -154,35 +155,44 @@ static int ct_seq_show(struct seq_file *s, void *v)
>  			l3proto, l4proto))
>  		goto release;
>  
> -	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
> +	seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL);
> +	if (seq_overflow(s))
>  		goto release;
>  
> -	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
> -		if (seq_printf(s, "[UNREPLIED] "))
> +	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status))) {
> +		seq_printf(s, "[UNREPLIED] ");
> +		if (seq_overflow(s))
>  			goto release;
> +	}
>  
>  	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
>  			l3proto, l4proto))
>  		goto release;
>  
> -	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
> +	seq_print_acct(s, ct, IP_CT_DIR_REPLY);
> +	if (seq_overflow(s))
>  		goto release;
>  
> -	if (test_bit(IPS_ASSURED_BIT, &ct->status))
> -		if (seq_printf(s, "[ASSURED] "))
> +	if (test_bit(IPS_ASSURED_BIT, &ct->status)) {
> +		seq_printf(s, "[ASSURED] ");
> +		if (seq_overflow(s))
>  			goto release;
> +	}
>  
>  #ifdef CONFIG_NF_CONNTRACK_MARK
> -	if (seq_printf(s, "mark=%u ", ct->mark))
> +	seq_printf(s, "mark=%u ", ct->mark);
> +	if (seq_overflow(s))
>  		goto release;
>  #endif
>  
>  	if (ct_show_secctx(s, ct))
>  		goto release;
>  
> -	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
> +	seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use));
> +	if (seq_overflow(s))
>  		goto release;
>  	ret = 0;
> +
>  release:
>  	nf_ct_put(ct);
>  	return ret;

All this "goto release on overflow" business here is pointless, AFAICS.
In any case, returning non-zero in those cases is a bug.

> @@ -297,7 +307,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
>  		    __nf_ct_l3proto_find(exp->tuple.src.l3num),
>  		    __nf_ct_l4proto_find(exp->tuple.src.l3num,
>  					 exp->tuple.dst.protonum));
> -	return seq_putc(s, '\n');
> +	seq_putc(s, '\n');
> +
> +	return seq_overflow(s);
>  }

Broken.

The rest is no better, AFAICS.  Joe, you are doing it from the wrong end;
the right approach would be something like "make ->print_tuple() return
void", etc.  As it is, you are just providing a lousy pattern to anybody
reading that.  The last thing we want is people blindly copying these
bugs just because they'd seen a "proper" way of producing that kind of
broken behaviour.  Monkey see, monkey do and all such...
