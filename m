From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT][PATCH] convert 802/tr to seq_file
Date: Wed, 20 Aug 2003 01:20:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820012014.B23942@electric-eye.fr.zoreil.com>
References: <20030819141326.2a63bad0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Phillips <mikep@linuxtr.net>, linux-tr@linuxtr.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030819141326.2a63bad0.shemminger@osdl.org>; from shemminger@osdl.org on Tue, Aug 19, 2003 at 02:13:26PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> Convert the /proc interface to tokenring routing information
> to the new seq_file interface.
> 
> Builds and loads on 2.6.0-test3, but I don't have any real tokenring hardware
> to make entries show up in table.
> 
> diff -Nru a/net/802/tr.c b/net/802/tr.c
> --- a/net/802/tr.c	Tue Aug 19 14:07:56 2003
> +++ b/net/802/tr.c	Tue Aug 19 14:07:56 2003
[...]
> @@ -456,84 +457,108 @@
>   *	routing.
>   */
>   
> -#ifndef CONFIG_PROC_FS
> -static int rif_get_info(char *buffer,char **start, off_t offset, int length)  { return 0;}
> -#else
> -static int rif_get_info(char *buffer,char **start, off_t offset, int length) 
> -{
> -	int len=0;
> -	off_t begin=0;
> -	off_t pos=0;
> -	int size,i,j,rcf_len,segment,brdgnmb;
> -	unsigned long now=jiffies;
> +#ifdef CONFIG_PROC_FS
> +/* Magic token to indicate first entry (header line) */
> +#define RIF_PROC_START	((void *)1)
> +
> +static struct rif_cache_s *rif_get_idx(loff_t pos)
> +{
> +	int i;
> +	struct rif_cache_s *entry;
> +	loff_t off = 0;
> +
> +	for(i=0;i < RIF_TABLE_SIZE;i++) 
> +		for(entry=rif_table[i];entry;entry=entry->next) {
> +			if (off == pos)
> +				return entry;
> +			++off;
> +		}
> +

Add a few more spaces and braces (it's 1:00 AM here |o) )
	for (i = 0; i < RIF_TABLE_SIZE; i++) {
		for (entry = rif_table[i]; entry; entry = entry->next) {
			if (--pos < 0)
				return entry;
		}
	}
(killed "off" btw)

> +	return NULL;
> +}
> +
> +static void *rif_seq_start(struct seq_file *seq, loff_t *pos)
> +{
>  	unsigned long flags;
>  
> -	rif_cache entry;
> +	spin_lock_irqsave(&rif_lock, flags);
> +	seq->private = (void *) flags;
> +
> +	return *pos ? rif_get_idx(*pos - 1) : RIF_PROC_START;
> +}
> +
> +static void *rif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> +{
> +	return rif_get_idx(*pos++);
                           ^^^^^^
Won't this increment the pointer instead of the value it adresses ?

<jargon>
	void *v;

	v = rif_get_idx(*pos + 1);
	*pos += !!ERR_PTR(v);
	return v;
</jargon>

> +}
> +
> +static void rif_seq_stop(struct seq_file *seq, void *v)
> +{
> +	unsigned long flags = (unsigned long) seq->private;
> +	spin_lock_irqsave(&rif_lock, flags);
        ^^^^^^^^^^^^^^^^^

This should probably read:
  +	spin_unlock_irqrestore(&rif_lock, flags);

--
Ueimor
