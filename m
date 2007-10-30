From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH 1/2] Convert /proc/net/ipv6_route to seq_file interface
Date: Tue, 30 Oct 2007 14:46:07 +0100
Message-ID: <4727359F.1070300@bull.net>
References: <20071030131147.GA6210@localhost.sw.ru> <47273318.9040408@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:54417 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbXJ3NqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 09:46:22 -0400
In-Reply-To: <47273318.9040408@bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cosmetic comment:

I forgot to say there are a few indentation "errors" when
I apply your patch. See below.


Benjamin Thery wrote:
> Alexey Dobriyan wrote:
>> One proc_net_create() user less.
> 
> Funny, I was working on a similar patch.
> 
> See comment below.
> 
> 
>> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
>> ---
>>
>>  net/ipv6/route.c |   70 +++++++++++++++++++------------------------------------
>>  1 file changed, 25 insertions(+), 45 deletions(-)
>>
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -2288,71 +2288,49 @@ struct rt6_proc_arg
>>  
>>  static int rt6_info_route(struct rt6_info *rt, void *p_arg)
>>  {
>> -	struct rt6_proc_arg *arg = (struct rt6_proc_arg *) p_arg;
>> +	struct seq_file *m = p_arg;
>>  
>> -	if (arg->skip < arg->offset / RT6_INFO_LEN) {
>> -		arg->skip++;
>> -		return 0;
>> -	}
>> -
>> -	if (arg->len >= arg->length)
>> -		return 0;
>> -
>> -	arg->len += sprintf(arg->buffer + arg->len,
>> -			    NIP6_SEQFMT " %02x ",
>> -			    NIP6(rt->rt6i_dst.addr),
>> +	seq_printf(m, NIP6_SEQFMT " %02x ", NIP6(rt->rt6i_dst.addr),
>>  			    rt->rt6i_dst.plen);
>>  
>>  #ifdef CONFIG_IPV6_SUBTREES
>> -	arg->len += sprintf(arg->buffer + arg->len,
>> -			    NIP6_SEQFMT " %02x ",
>> -			    NIP6(rt->rt6i_src.addr),
>> +	seq_printf(m, NIP6_SEQFMT " %02x ", NIP6(rt->rt6i_src.addr),
>>  			    rt->rt6i_src.plen);

Indent is wrong for the above line.

>>  #else
>> -	arg->len += sprintf(arg->buffer + arg->len,
>> -			    "00000000000000000000000000000000 00 ");
>> +	seq_puts(m, "00000000000000000000000000000000 00 ");
>>  #endif
>>  
>>  	if (rt->rt6i_nexthop) {
>> -		arg->len += sprintf(arg->buffer + arg->len,
>> -				    NIP6_SEQFMT,
>> +		seq_printf(m, NIP6_SEQFMT,
>>  				    NIP6(*((struct in6_addr *)rt->rt6i_nexthop->primary_key)));

Idem.

>>  	} else {
>> -		arg->len += sprintf(arg->buffer + arg->len,
>> -				    "00000000000000000000000000000000");
>> +		seq_puts(m, "00000000000000000000000000000000");
>>  	}
>> -	arg->len += sprintf(arg->buffer + arg->len,
>> -			    " %08x %08x %08x %08x %8s\n",
>> +	seq_printf(m, " %08x %08x %08x %08x %8s\n",
>>  			    rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
>>  			    rt->u.dst.__use, rt->rt6i_flags,
>>  			    rt->rt6i_dev ? rt->rt6i_dev->name : "");

Indent of the 3 above lines.

>>  	return 0;
>>  }
>>  
>> -static int rt6_proc_info(char *buffer, char **start, off_t offset, int length)
>> +static int ipv6_route_show(struct seq_file *m, void *v)
>>  {
>> -	struct rt6_proc_arg arg = {
>> -		.buffer = buffer,
>> -		.offset = offset,
>> -		.length = length,
>> -	};
>> -
>> -	fib6_clean_all(rt6_info_route, 0, &arg);
>> -
>> -	*start = buffer;
>> -	if (offset)
>> -		*start += offset % RT6_INFO_LEN;
>> -
>> -	arg.len -= offset % RT6_INFO_LEN;
>> -
>> -	if (arg.len > length)
>> -		arg.len = length;
>> -	if (arg.len < 0)
>> -		arg.len = 0;
>> +	fib6_clean_all(rt6_info_route, 0, m);
>> +	return 0;
>> +}
>>  
>> -	return arg.len;
>> +static int ipv6_route_open(struct inode *inode, struct file *file)
>> +{
>> +	return single_open(file, ipv6_route_show, NULL);
>>  }
>>  
>> +static const struct file_operations ipv6_route_proc_fops = {
>> +	.open		= ipv6_route_open,
>> +	.read		= seq_read,
>> +	.llseek		= seq_lseek,
>> +	.release	= single_release,
>> +};
>> +
>>  static int rt6_stats_seq_show(struct seq_file *seq, void *v)
>>  {
>>  	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
>> @@ -2499,9 +2477,11 @@ void __init ip6_route_init(void)
>>  
>>  	fib6_init();
>>  #ifdef 	CONFIG_PROC_FS
>> -	p = proc_net_create(&init_net, "ipv6_route", 0, rt6_proc_info);
>> -	if (p)
> 
>> +	p = create_proc_entry("ipv6_route", 0, init_net.proc_net);
>> +	if (p) {
>>  		p->owner = THIS_MODULE;
>> +		p->proc_fops = &ipv6_route_proc_fops;
>> +	}
> 
> You should use proc_net_fops_create() instead of the above code. 
> It does the same thing.
> 
> Otherwise the patch looks fine to me.
> Tested on i386.
> 
> Benjamin
> 
>>  	proc_net_fops_create(&init_net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
>>  #endif
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

   http://www.bull.com
