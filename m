From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [PATCH] Convert ipvs to use seq_file.
Date: Tue, 16 Sep 2003 00:56:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F66439E.60909@drugphish.ch>
References: <20030915143957.041689d8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   wensong@linux-vs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
In-Reply-To: <20030915143957.041689d8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stephen,

Wow, thanks for doing this!

> Convert IPVS (for 2.6.0-test5) to use seq_file for the /proc interface.
> Got rid of gratuitous 64 column trailing blank padding.

Looks good, but in the end it's of course Wensong's call.

> P.s: how come there is no MAINTAINER listed for IPVS?

You mean something along the lines of:

--- MAINTAINERS 2003-09-08 23:43:22.000000000 +0200
+++ MAINTAINERS.lvs     2003-09-16 00:24:17.000000000 +0200
@@ -1340,6 +1340,14 @@
  L:     netdev@oss.sgi.com
  S:     Maintained

+NETWORKING [IPVS]
+P:     Wensong Zhang
+M:     wensong@linux-vs.org
+M:     lvs-users@linuxvirtualserver.org
+W:     http://www.linux-vs.org/
+L:     lvs-users@linuxvirtualserver.org
+S:     Maintained
+
  NFS CLIENT
  P:     Trond Myklebust
  M:     trond.myklebust@fys.uio.no

> @@ -615,61 +614,116 @@ ip_vs_conn_new(int proto, __u32 caddr, _
>  /*
>   *	/proc/net/ip_vs_conn entries
>   */
> -static int
> -ip_vs_conn_getinfo(char *buffer, char **start, off_t offset, int length)
> -{
> -	off_t pos=0;
> -	int idx, len=0;
> -	char temp[70];
> -	struct ip_vs_conn *cp;
> -	struct list_head *l, *e;
> +#ifdef CONFIG_PROC_FS
>  
> -	pos = 128;
> -	if (pos > offset) {
> -		len += sprintf(buffer+len, "%-127s\n",
> -			       "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires");
> -	}
> +#define SEQ_START_TOKEN	((void *)1)
>  
> +static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
> +{
> +	struct list_head *e;
> +	int idx;
> +	loff_t off = 0;
> +	
>  	for(idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
> -		/*
> -		 *	Lock is actually only need in next loop
> -		 *	we are called from uspace: must stop bh.
> -		 */
>  		ct_read_lock_bh(idx);
> +		list_for_each(e, &ip_vs_conn_tab[idx]) {
> +			if (off == pos) {
> +				seq->private = &ip_vs_conn_tab[idx];
> +				return list_entry(e, struct ip_vs_conn, c_list);
> +			}
> +			++off;
> +		}	
> +		ct_read_unlock_bh(idx);
> +	}
>  
> -		l = &ip_vs_conn_tab[idx];
> -		for (e=l->next; e!=l; e=e->next) {
> -			cp = list_entry(e, struct ip_vs_conn, c_list);
> -			pos += 128;
> -			if (pos <= offset)
> -				continue;
> -			sprintf(temp,
> -				"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu",
> +	return NULL;
> +}
> +
> +static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
> +{
> +	seq->private = NULL;
> +	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;

Nitpicking: s/:S/: S/

> -static int
> -ip_vs_stats_get_info(char *buf, char **start, off_t offset, int length)
> +#ifdef CONFIG_PROC_FS
> +static int ip_vs_stats_show(struct seq_file *seq, void *v)
>  {
> -	int len=0;
> -	off_t pos=0;
> -	char temp[64];
> -
> -	pos += 320;
> -	if (pos > offset) {
> -		len += sprintf(buf+len, "%-63s\n%-63s\n",
> -/*                              01234567 01234567 01234567 0123456701234567 0123456701234567 */
> -			       "   Total Incoming Outgoing         Incoming         Outgoing",
> -			       "   Conns  Packets  Packets            Bytes            Bytes");
> -
> -		spin_lock_bh(&ip_vs_stats.lock);
> -		sprintf(temp, "%8X %8X %8X %8X%08X %8X%08X",
> -			ip_vs_stats.conns,
> -			ip_vs_stats.inpkts,
> -			ip_vs_stats.outpkts,
> -			(__u32)(ip_vs_stats.inbytes>>32),
> -			(__u32)ip_vs_stats.inbytes,
> -			(__u32)(ip_vs_stats.outbytes>>32),
> -			(__u32)ip_vs_stats.outbytes);
> -		len += sprintf(buf+len, "%-62s\n\n", temp);
> -
> -		len += sprintf(buf+len, "%-63s\n",
> -/*                              01234567 01234567 01234567 0123456701234567 0123456701234567 */
> -			       " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s");
> -		sprintf(temp, "%8X %8X %8X %16X %16X",
> +
> +/*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
> +	seq_puts(seq,
> +		 "   Total Incoming Outgoing         Incoming         Outgoing\n");
> +	seq_printf(seq, 	   
> +		   "   Conns  Packets  Packets            Bytes            Bytes\n");
> +
> +	spin_lock_bh(&ip_vs_stats.lock);
> +	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.conns,
> +		   ip_vs_stats.inpkts, ip_vs_stats.outpkts,
> +		   ip_vs_stats.inbytes, ip_vs_stats.outbytes);

%16LX is maybe better than %8X%08X, I agree ;)

Now we have to wait for Wensong's approval. It certainly looks good to 
me. I have no idea what his plans are currently as the CVS version is 
not synched with the current bk version of 2.6.x. Also we still seem to 
have non-resolved issues with the skb linearisation patches.

Best regards,
Roberto Nibali, ratz
-- 
echo '[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq'|dc
