From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [PATCH] ipvs -- format /proc/net/ip_vs_conn entries in dotted
 notation.
Date: Tue, 16 Sep 2003 01:17:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F664879.4090309@drugphish.ch>
References: <20030915144329.6dc442ad.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   Wensong Zhang <wensong@linux-vs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
In-Reply-To: <20030915144329.6dc442ad.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Easier for human's to read dotted notation IP addresses.

True, but ipvsadm will not be happy ;).

> diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
> --- a/net/ipv4/ipvs/ip_vs_conn.c	Mon Sep 15 14:31:28 2003
> +++ b/net/ipv4/ipvs/ip_vs_conn.c	Mon Sep 15 14:31:28 2003
> @@ -682,23 +682,33 @@
>  		ct_read_unlock(l - ip_vs_conn_tab);
>  }
>  
> +static inline void addr_format(char * tmp,__u32 addr, __u16 port)
> +{
> +	sprintf(tmp, "%u.%u.%u.%u:%u",
> +		NIPQUAD(addr), ntohs(port));
> +}
> +
> +
>  static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
>  {
>  
>  	if (v == SEQ_START_TOKEN)
> -		seq_puts(seq,
> -   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires\n");
> +		seq_printf(seq, "%-3s %-18s %-18s %-18s %-11s %-6s\n",
> +			   "Pro", "From", "To", "Destination", 
> +			   "State", "Expire");

Why did you change the wording? Hmm, on the other hand it might just 
look more consistent with similar existing code (thinking of netfilter) 
after all. Only we will need to fix the ipvsadm user space code if this 
patch goes in.

>  	else {
>  		const struct ip_vs_conn *cp = v;
> +		char from[20], to[20], dest[20];

Either one of us can't count, I get 21 bytes "worst-case" from 
addr_format(...).

> +
> +		addr_format(from, cp->caddr, ntohs(cp->cport));
> +		addr_format(to, cp->vaddr, ntohs(cp->vport));
> +		addr_format(dest, cp->daddr, ntohs(cp->dport));
>  
> -		seq_printf(seq,
> -			"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
> -				ip_vs_proto_name(cp->protocol),
> -				ntohl(cp->caddr), ntohs(cp->cport),
> -				ntohl(cp->vaddr), ntohs(cp->vport),
> -				ntohl(cp->daddr), ntohs(cp->dport),
> -				ip_vs_state_name(cp->protocol, cp->state),
> -				(cp->timer.expires-jiffies)/HZ);
> +		seq_printf(seq,	"%-3s %-18s %-18s %-18s %-11s %7lu\n",

This looks wrong, from, to and dest are 20 bytes in your patch.

> +			   ip_vs_proto_name(cp->protocol),
> +			   from, to, dest,
> +			   ip_vs_state_name(cp->protocol, cp->state),
> +			   (cp->timer.expires-jiffies)/HZ);
>  	}
>  	return 0;
>  }

Thanks for your work. It's truely appreciated. Take care,
Roberto Nibali, ratz
-- 
echo '[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq'|dc
