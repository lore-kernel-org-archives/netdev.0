From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RFC: Latency reducing TCP modifications for thin-stream interactive
 applications
Date: Fri, 28 Nov 2008 14:25:11 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811281252430.23100@wrl-59.cs.helsinki.fi>
References: <492EA31D.8000704@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users@vger.kernel.org, mdavem@davemloft.net,
	jgarzik@pobox.com, kohari@novell.com, peterz@infradead.org,
	jzemlin@linux-foundation.org, mrexx@linux-foundation.org,
	tytso@mit.edu, mingo@elte.hu, kristrev@simula.no, griff@simula.no,
	paalh@ifi.uio.no, Netdev <netdev@vger.kernel.org>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50441 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbYK1MZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 07:25:25 -0500
In-Reply-To: <492EA31D.8000704@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux-net is users list, use netdev instead on matters relating 
development...

On Thu, 27 Nov 2008, Andreas Petlund wrote:

> A wide range of Internet-based services that use reliable transport 
> protocols display what we call thin-stream properties. This means 
> that the application sends data with such a low rate that the 
> retransmission mechanisms of the transport protocol are not fully 
> effective. In time-dependent scenarios (like online games, control 
> systems or some sensor networks) where the user experience depends 
> on the data delivery latency, packet loss can be devastating for 
> the service quality. Extreme latencies are caused by TCP's 
> dependency on the arrival of new data from the application to trigger 
> retransmissions effectively through fast retransmit instead of 
> waiting for long timeouts. After analyzing a large number of 
> time-dependent interactive applications, we have seen that they 
> often produce thin streams (as described above) and also stay with 
> this traffic pattern throughout its entire lifespan. The 
> combination of time-dependency and the fact that the streams 
> provoke high latencies when using TCP is unfortunate.
> 
> In order to reduce application-layer latency when packets are lost, 
> we have implemented modifications to the TCP retransmission 
> mechanisms in the Linux kernel. We have also implemented a 
> bundling mechanisms that introduces redundancy in order to 
> preempt the experience of packet loss. In short, if the kernel 
> detects a thin stream, we trade a small amount of bandwidth for 
> latency reduction and apply:
> 
> Removal of exponential backoff: To prevent an exponential increase 
> in retransmission delay for a repeatedly lost packet, we remove 
> the exponential factor.
> 
> FASTER Fast Retransmit: Instead of waiting for 3 duplicate 
> acknowledgments before sending a fast retransmission, we retransmit 
> after receiving only one.
> 
> Redundant Data Bundling: We copy (bundle) data from the 
> unacknowledged packets in the send buffer into the next packet if
>  space is available.
> 
> These enhancements are applied only if the stream is detected as
> thin. 
> This is accomplished by defining thresholds for packet size and 
> packets in flight. Also, we consider the redundancy introduced 
> by our mechanisms acceptable because the streams are so thin 
> that normal congestion mechanisms do not come into effect.
> 
> We have implemented these changes in the Linux kernel (2.6.23.8), 
> and have tested the modifications on a wide range of different 
> thin-stream applications (Skype, BZFlag, SSH, ...) under varying 
> network conditions. Our results show that applications which use 
> TCP for interactive time-dependent traffic will experience a 
> reduction in both maximum and average latency, giving the users 
> quicker feedback to their interactions.
> 
> Availability of this kind of mechanisms will help provide 
> customizability for interactive network services. The quickly 
> growing market for Linux gaming may benefit from lowered latency. 
> As an example, most of the large MMORPG's today use TCP (like World 
> of Warcraft and Age of Conan) and several multimedia applications 
> (like Skype) use TCP fallback if UDP is blocked.
> 
> The modifications are all TCP standard compliant and transparent
> to the receiver. As such, a game server could implement the 
> modifications and get a one-way latency benefit without touching 
> any of the clients.
> 
> In the following papers, we discuss the benefits and tradeoffs of 
> the decribed mechanisms:
> "The Fun of using TCP for an MMORPG": 
> http://simula.no/research/networks/publications/Griwodz.2006.1
> "TCP Enhancements For Interactive Thin-Stream Applications": 
> http://simula.no/research/networks/publications/Simula.ND.83
> "Improving application layer latency for reliable thin-stream game
> traffic": http://simula.no/research/networks/publications/Simula.ND.185
> "TCP mechanisms for improving the user experience for time-dependent 
> thin-stream applications": 
> http://simula.no/research/networks/publications/Simula.ND.159
> Our presentation from the 2008 Linux-Kongress can be found here: 
> http://data.guug.de/slides/lk2008/lk-2008-Andreas-Petlund.pdf
> 
> We have included a patch for the 2.6.23.8 kernel which implements the 
> modifications. The patch is not properly segmented and formatted, but 
> attached as a reference. We are currently working on an updated patch 
> set which we hopefully will be able to post in a couple of weeks.

Please make sure that it's based on net-next tree next time since there 
are lots of changes already in the areas you're touching.

> This will also give us time to integrate any ideas that may arise from 
> the discussions here.
> 
> We are happy for all feedback regarding this:
> Is something like this viable to introduce into the kernel?

No idea in general. But it has to be (nearly) minimal and clean if such 
thing is ever to be considered. The one below is definately not even close
minimal in many areas...

> Is the scheme for thin-stream detection mechanism acceptable.

Does reduncancy happen in the initial slow start as well (depends on 
write pattern)? Why it is so in case the stream is to become thick 
right after initial rtts?

> Any viewpoints on the architecture and design? 

I'll go through the patch below (some things are mostly "educational"
since I also propose dropping the current way of use here and there).
Some overall comments below everything.

> diff -Nur linux-2.6.23.8.vanilla/include/linux/sysctl.h linux-2.6.23.8-tcp-thin/include/linux/sysctl.h
> --- linux-2.6.23.8.vanilla/include/linux/sysctl.h	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/include/linux/sysctl.h	2008-07-03 11:47:21.000000000 +0200
> @@ -355,6 +355,11 @@
>  	NET_IPV4_ROUTE=18,
>  	NET_IPV4_FIB_HASH=19,
>  	NET_IPV4_NETFILTER=20,
> +	
> +	NET_IPV4_TCP_FORCE_THIN_RDB=29,         /* Added @ Simula */
> +	NET_IPV4_TCP_FORCE_THIN_RM_EXPB=30,     /* Added @ Simula */
> +	NET_IPV4_TCP_FORCE_THIN_DUPACK=31,      /* Added @ Simula */
> +	NET_IPV4_TCP_RDB_MAX_BUNDLE_BYTES=32,   /* Added @ Simula */

I don't think you could reuse empty ranges. In any case all new sysctls 
to be added must use CTL_UNNUMBERED. These number are deprecated and 
should not be added anymore. And you add too many sysctl anyway 
considering the change (e.g., max & rdb are redundant if proper mapping 
of values is used).

>  	NET_IPV4_TCP_TIMESTAMPS=33,
>  	NET_IPV4_TCP_WINDOW_SCALING=34,
> diff -Nur linux-2.6.23.8.vanilla/include/linux/tcp.h linux-2.6.23.8-tcp-thin/include/linux/tcp.h
> --- linux-2.6.23.8.vanilla/include/linux/tcp.h	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/include/linux/tcp.h	2008-07-02 15:17:38.000000000 +0200
> @@ -97,6 +97,10 @@
>  #define TCP_CONGESTION		13	/* Congestion control algorithm */
>  #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
>  
> +#define TCP_THIN_RDB            15      /* Added @ Simula - Enable redundant data bundling  */
> +#define TCP_THIN_RM_EXPB        16      /* Added @ Simula - Remove exponential backoff  */
> +#define TCP_THIN_DUPACK         17      /* Added @ Simula - Reduce number of dupAcks needed */
> +
>  #define TCPI_OPT_TIMESTAMPS	1
>  #define TCPI_OPT_SACK		2
>  #define TCPI_OPT_WSCALE		4
> @@ -296,6 +300,10 @@
>  	u8	nonagle;	/* Disable Nagle algorithm?             */
>  	u8	keepalive_probes; /* num of allowed keep alive probes	*/
>  
> +	u8      thin_rdb;       /* Enable RDB                           */
> +	u8      thin_rm_expb;   /* Remove exp. backoff                  */
> +	u8      thin_dupack;    /* Remove dupack                        */
> +

Only one bit used per field?

>  /* RTT measurement */
>  	u32	srtt;		/* smoothed round trip time << 3	*/
>  	u32	mdev;		/* medium deviation			*/
> diff -Nur linux-2.6.23.8.vanilla/include/net/sock.h linux-2.6.23.8-tcp-thin/include/net/sock.h
> --- linux-2.6.23.8.vanilla/include/net/sock.h	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/include/net/sock.h	2008-07-02 17:07:10.000000000 +0200
> @@ -462,7 +462,10 @@
>  
>  static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
>  {
> -	skb_truesize_check(skb);
> +	/* Modified @ Simula 
> +	   skb_truesize_check creates unnecessary 
> +	   noise when combined with RDB */
> +	//skb_truesize_check(skb);

Please fix the bugs you added instead of hacking around them. You'll have 
to do proper accounting.

>  	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
>  	sk->sk_wmem_queued   -= skb->truesize;
>  	sk->sk_forward_alloc += skb->truesize;
> diff -Nur linux-2.6.23.8.vanilla/include/net/tcp.h linux-2.6.23.8-tcp-thin/include/net/tcp.h
> --- linux-2.6.23.8.vanilla/include/net/tcp.h	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/include/net/tcp.h	2008-07-03 11:48:54.000000000 +0200
> @@ -188,9 +188,19 @@
>  #define TCP_NAGLE_CORK		2	/* Socket is corked	    */
>  #define TCP_NAGLE_PUSH		4	/* Cork is overridden for already queued data */
>  
> +/* Added @ Simula - Thin stream support */
> +#define TCP_FORCE_THIN_RDB            0 /* Thin streams: exp. backoff   default off */
> +#define TCP_FORCE_THIN_RM_EXPB        0 /* Thin streams: dynamic dupack default off */
> +#define TCP_FORCE_THIN_DUPACK         0 /* Thin streams: smaller minRTO default off */
> +#define TCP_RDB_MAX_BUNDLE_BYTES      0 /* Thin streams: Limit maximum bundled bytes */

Please drop these and just assign directly.

> +
>  extern struct inet_timewait_death_row tcp_death_row;
>  
>  /* sysctl variables for tcp */
> +extern int sysctl_tcp_force_thin_rdb;         /* Added @ Simula */
> +extern int sysctl_tcp_force_thin_rm_expb;     /* Added @ Simula */
> +extern int sysctl_tcp_force_thin_dupack;      /* Added @ Simula */
> +extern int sysctl_tcp_rdb_max_bundle_bytes;   /* Added @ Simula */
>  extern int sysctl_tcp_timestamps;
>  extern int sysctl_tcp_window_scaling;
>  extern int sysctl_tcp_sack;
> @@ -723,6 +733,16 @@
>  	return (tp->packets_out - tp->left_out + tp->retrans_out);
>  }
>  
> +/* Added @ Simula

Please remove the from the patch.

> + *
> + * To determine whether a stream is thin or not
> + * return 1 if thin, 0 othervice 

I don't find this comment too useful. The function name is obvious enough.

> + */
> +static inline unsigned int tcp_stream_is_thin(const struct tcp_sock *tp)
> +{
> +	return (tp->packets_out < 4 ? 1 : 0);

return tp->packets < 4; is enough??

> +}
> +
>  /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
>   * The exception is rate halving phase, when cwnd is decreasing towards
>   * ssthresh.
> diff -Nur linux-2.6.23.8.vanilla/net/ipv4/sysctl_net_ipv4.c linux-2.6.23.8-tcp-thin/net/ipv4/sysctl_net_ipv4.c
> --- linux-2.6.23.8.vanilla/net/ipv4/sysctl_net_ipv4.c	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/net/ipv4/sysctl_net_ipv4.c	2008-07-03 11:49:59.000000000 +0200
> @@ -187,6 +187,38 @@
>  }
>  
>  ctl_table ipv4_table[] = {
> +	{       /* Added @ Simula for thin streams */
> +                .ctl_name       = NET_IPV4_TCP_FORCE_THIN_RDB,

CTL_UNNUMBERED as mentioned above.

> +                .procname       = "tcp_force_thin_rdb",
> +                .data           = &sysctl_tcp_force_thin_rdb,
> +                .maxlen         = sizeof(int),
> +                .mode           = 0644,
> +                .proc_handler   = &proc_dointvec
> +        },
> +	{       /* Added @ Simula for thin streams */
> +                .ctl_name       = NET_IPV4_TCP_FORCE_THIN_RM_EXPB,
> +                .procname       = "tcp_force_thin_rm_expb",
> +                .data           = &sysctl_tcp_force_thin_rm_expb,
> +                .maxlen         = sizeof(int),
> +                .mode           = 0644,
> +                .proc_handler   = &proc_dointvec
> +        },
> +	{       /* Added @ Simula for thin streams */
> +                .ctl_name       = NET_IPV4_TCP_FORCE_THIN_DUPACK,
> +                .procname       = "tcp_force_thin_dupack",
> +                .data           = &sysctl_tcp_force_thin_dupack,
> +                .maxlen         = sizeof(int),
> +                .mode           = 0644,
> +                .proc_handler   = &proc_dointvec
> +        },
> +	{       /* Added @ Simula for thin streams */
> +                .ctl_name       = NET_IPV4_TCP_RDB_MAX_BUNDLE_BYTES,
> +                .procname       = "tcp_rdb_max_bundle_bytes",
> +                .data           = &sysctl_tcp_rdb_max_bundle_bytes,
> +                .maxlen         = sizeof(int),
> +                .mode           = 0644,
> +                .proc_handler   = &proc_dointvec
> +        },
>  	{
>  		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
>  		.procname	= "tcp_timestamps",
> diff -Nur linux-2.6.23.8.vanilla/net/ipv4/tcp.c linux-2.6.23.8-tcp-thin/net/ipv4/tcp.c
> --- linux-2.6.23.8.vanilla/net/ipv4/tcp.c	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/net/ipv4/tcp.c	2008-07-03 11:51:55.000000000 +0200
> @@ -270,6 +270,10 @@
>  
>  int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
>  
> +/* Added @ Simula */
> +int sysctl_tcp_force_thin_rdb __read_mostly = TCP_FORCE_THIN_RDB;
> +int sysctl_tcp_rdb_max_bundle_bytes __read_mostly = TCP_RDB_MAX_BUNDLE_BYTES;

No need for these defines, just assign directly.

> +
>  DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics) __read_mostly;
>  
>  atomic_t tcp_orphan_count = ATOMIC_INIT(0);
> @@ -658,6 +662,167 @@
>  	return tmp;
>  }
>  
> +/* Added at Simula to support RDB */
> +static int tcp_trans_merge_prev(struct sock *sk, struct sk_buff *skb, int mss_now)

why int?

...In general this function should be split, having a separate skb 
(non-TCP) function(s) and tcp-side would be ideal.

It's misnamed as well, it won't merge but duplicates?

Also, this approach is extremely intrusive and adding non-linear seqno 
things into write queue will require _you_ to do _full audit_ over every 
single place to verify that seqno leaps backwards won't break anything 
(and you'll still probably miss some cases). I wonder if you realize 
how easily this kind of change manifests itself as a silent data 
corruption on stream level and have taken appropriate actions to validate 
that not a single one of scenario leads to data coming as different out as 
was sent in (every single byte, it's not enough to declare that 
application worked which could well happen with corrupted data too). TCP 
is very coreish and such bugs will definately hit people hard.

> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	
> +	/* Make sure that this isn't referenced by somebody else */
> +	
> +	if(!skb_cloned(skb)){

I'd inverse the condition and return to reduce indentation level of the 
rest.

> +		struct sk_buff *prev_skb = skb->prev;
> +		int skb_size = skb->len;
> +		int old_headlen = 0;
> +		int ua_data = 0;
> +		int uad_head = 0;
> +		int uad_frags = 0;
> +		int ua_nr_frags = 0;
> +		int ua_frags_diff = 0;
> +		
> +		/* Since this technique currently does not support SACK, I
> +		 * return -1 if the previous has been SACK'd. */
> +		if(TCP_SKB_CB(prev_skb)->sacked & TCPCB_SACKED_ACKED){
> +			return -1;
> +		}

Drop block braces if the block's content in all fits on a single line 
(except in constructs where else would become braces unbalanced).

> +		
> +		/* Current skb is out of window. */
> +		if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una+tp->snd_wnd)){

...tcp_wnd_end(tp).

> +			return -1;
> +		}
> +		
> +		/*TODO: Optimize this part with regards to how the 
> +		  variables are initialized */
> +		
> +		/*Calculates the ammount of unacked data that is available*/
> +		ua_data = (TCP_SKB_CB(prev_skb)->end_seq - tp->snd_una > 
> +			   prev_skb->len ? prev_skb->len : 
> +			   TCP_SKB_CB(prev_skb)->end_seq - tp->snd_una);

min(...) ?. But see the comment below...

> +		ua_frags_diff = ua_data - prev_skb->data_len;
> +		uad_frags = (ua_frags_diff > 0 ? prev_skb->data_len : ua_data);
> +		uad_head = (ua_frags_diff > 0 ? ua_data - uad_frags : 0);
> +
> +		if(ua_data <= 0)
> +			return -1;

Can this ever happen except with syn/fin?

> +		
> +		if(uad_frags > 0){
> +			int i = 0;
> +			int bytes_frags = 0;
> +			
> +			if(uad_frags == prev_skb->data_len){
> +				ua_nr_frags = skb_shinfo(prev_skb)->nr_frags;
> +			} else{
> +				for(i=skb_shinfo(prev_skb)->nr_frags - 1; i>=0; i--){
> +					if(skb_shinfo(prev_skb)->frags[i].size 
> +					   + bytes_frags == uad_frags){
> +						ua_nr_frags += 1;
> +						break;
> +					} 	  
> +					ua_nr_frags += 1;
> +					bytes_frags += skb_shinfo(prev_skb)->frags[i].size;
> +				}
> +			}
> +		}
> +		
> +		/*
> +		 * Do the diffrenet checks on size and content, and return if
> +		 * something will not work.
> +		 *
> +		 * TODO: Support copying some bytes
> +		 *
> +		 * 1. Larger than MSS.
> +		 * 2. Enough room for the stuff stored in the linear area
> +		 * 3. Enoug room for the pages
> +		 * 4. If both skbs have some data stored in the linear area, and prev_skb
> +		 * also has some stored in the paged area, they cannot be merged easily.
> +		 * 5. If prev_skb is linear, then this one has to be it as well.
> +		 */
> +		if ((sysctl_tcp_rdb_max_bundle_bytes == 0 && ((skb_size + ua_data) > mss_now))
> +		    || (sysctl_tcp_rdb_max_bundle_bytes > 0 && ((skb_size + ua_data) >
> +								sysctl_tcp_rdb_max_bundle_bytes))){

max_size = sysctl_... ? : mss_now;
if (skb_size + ua_data > max_size)

?

> +			return -1;
> +		}
> +		
> +		/* We need to know tailroom, even if it is nonlinear */
> +		if(uad_head > (skb->end - skb->tail)){

skb_tailroom()

> +			return -1;
> +		}
> +		
> +		if(skb_is_nonlinear(skb) && (uad_frags > 0)){
> +			if((ua_nr_frags +
> +			    skb_shinfo(skb)->nr_frags) > MAX_SKB_FRAGS){
> +				return -1;
> +			}
> +			
> +			if(skb_headlen(skb) > 0){
> +				return -1;
> +			}
> +		}
> +		
> +		if((uad_frags > 0) && skb_headlen(skb) > 0){
> +			return -1;
> +		}
> +		
> +		/* To avoid duplicate copies (and copies
> +		   where parts have been acked) */
> +		if(TCP_SKB_CB(skb)->seq <= (TCP_SKB_CB(prev_skb)->end_seq - ua_data)){

So ua_data must be prev_skb->len or this fails? Why ua_data needs such 
complex setup above?

> +			return -1;
> +		}
> +		
> +		/*SYN's are holy*/
> +		if(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN || TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN){

flags & (...SYN|...FIN)  ??

> +			return -1;
> +		}
> +		
> +		/* Copy linear data */
> +		if(uad_head > 0){
> +			
> +			/* Add required space to the header. Can't use put due to linearity */
> +			old_headlen = skb_headlen(skb);
> +			skb->tail += uad_head;
> +			skb->len += uad_head;
> +			
> +			if(skb_headlen(skb) > 0){
> +				memmove(skb->data + uad_head, skb->data, old_headlen);
> +			}
> +			
> +			skb_copy_to_linear_data(skb, prev_skb->data + (skb_headlen(prev_skb) - uad_head), uad_head);
> +		}
> +		
> +		/*Copy paged data*/
> +		if(uad_frags > 0){
> +			int i = 0;
> +			/*Must move data backwards in the array.*/
> +			if(skb_is_nonlinear(skb)){
> +				memmove(skb_shinfo(skb)->frags + ua_nr_frags,
> +					skb_shinfo(skb)->frags,
> +					skb_shinfo(skb)->nr_frags*sizeof(skb_frag_t));
> +			}
> +			
> +			/*Copy info and update pages*/
> +			memcpy(skb_shinfo(skb)->frags,
> +			       skb_shinfo(prev_skb)->frags + (skb_shinfo(prev_skb)->nr_frags - ua_nr_frags),
> +			       ua_nr_frags*sizeof(skb_frag_t));
> +			
> +			for(i=0; i<ua_nr_frags;i++){
> +				get_page(skb_shinfo(skb)->frags[i].page);
> +			}
> +			
> +			skb_shinfo(skb)->nr_frags += ua_nr_frags;
> +			skb->data_len += uad_frags;
> +			skb->len += uad_frags;
> +		}
> +		
> +		TCP_SKB_CB(skb)->seq = TCP_SKB_CB(prev_skb)->end_seq - ua_data;
> +		
> +		if(skb->ip_summed == CHECKSUM_PARTIAL)
> +			skb->csum = CHECKSUM_PARTIAL;
> +		else
> +			skb->csum = skb_checksum(skb, 0, skb->len, 0);
> +	}
> +	
> +	return 1;
> +}

This function was far too complex to understand and very hard to validate 
as is, and I'm not that sure it will be needed anyway (see notes below).

> +
>  int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
>  		size_t size)
>  {
> @@ -825,6 +990,16 @@
>  
>  			from += copy;
>  			copied += copy;
> +			
> +			/* Added at Simula to support RDB */
> +			if(((tp->thin_rdb || sysctl_tcp_force_thin_rdb)) && skb->len < mss_now){
> +				if(skb->prev != (struct sk_buff*) &(sk)->sk_write_queue
> +				   && !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)
> +				   && !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)){

Why SYN/FIN are checked by both the caller and in tcp_trans_merge_prev

> +					tcp_trans_merge_prev(sk, skb, mss_now);
> +				}
> +			} /* End - Simula */
> +			
>  			if ((seglen -= copy) == 0 && iovlen == 0)
>  				goto out;
>  
> @@ -1870,7 +2045,25 @@
>  			tcp_push_pending_frames(sk);
>  		}
>  		break;
> -
> +		
> +        /* Added @ Simula. Support for thin streams */
> +	case TCP_THIN_RDB:
> +		if(val)
> +			tp->thin_rdb = 1;
> +		break;
> +		
> +        /* Added @ Simula. Support for thin streams */
> +	case TCP_THIN_RM_EXPB:
> +		if(val)
> +			tp->thin_rm_expb = 1;
> +		break;
> +		
> +        /* Added @ Simula. Support for thin streams */
> +	case TCP_THIN_DUPACK:
> +		if(val)
> +			tp->thin_dupack = 1;
> +		break;
> +	

These are probably for some experimentations? Should probably be dropped 
altogether.
	
>  	case TCP_KEEPIDLE:
>  		if (val < 1 || val > MAX_TCP_KEEPIDLE)
>  			err = -EINVAL;
> diff -Nur linux-2.6.23.8.vanilla/net/ipv4/tcp_input.c linux-2.6.23.8-tcp-thin/net/ipv4/tcp_input.c
> --- linux-2.6.23.8.vanilla/net/ipv4/tcp_input.c	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/net/ipv4/tcp_input.c	2008-07-03 11:57:08.000000000 +0200
> @@ -89,6 +89,9 @@
>  int sysctl_tcp_frto_response __read_mostly;
>  int sysctl_tcp_nometrics_save __read_mostly;
>  
> +/* Added @ Simula */
> +int sysctl_tcp_force_thin_dupack __read_mostly = TCP_FORCE_THIN_DUPACK;
> +
>  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>  int sysctl_tcp_abc __read_mostly;
>  
> @@ -1709,6 +1712,12 @@
>  		 */
>  		return 1;
>  	}
> +	
> +	/*Added at Simula to modify fast retransmit */
> +	if ((tp->thin_dupack || sysctl_tcp_force_thin_dupack) &&
> +	    tcp_fackets_out(tp) > 1 && tcp_stream_is_thin(tp)){

Nowadays tcp_dupack_heurestics(tp)

> +	  return 1;
> +	}
>  
>  	return 0;
>  }
> @@ -2442,30 +2451,127 @@
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	const struct inet_connection_sock *icsk = inet_csk(sk);
> -	struct sk_buff *skb;
> +	struct sk_buff *skb = tcp_write_queue_head(sk);
> +	struct sk_buff *next_skb;

If you need next_skb, you might want to iterate with _safe variant below 
unless there's a good reason to not use it (e.g., in the latest sack code 
it wasn't safe enough).

> +
>  	__u32 now = tcp_time_stamp;
>  	int acked = 0;
>  	int prior_packets = tp->packets_out;
> +	
> +	/*Added at Simula for RDB support*/
> +	__u8 done = 0;
> +	int remove = 0;
> +	int remove_head = 0;
> +	int remove_frags = 0;
> +	int no_frags;
> +	int data_frags;
> +	int i;
> +		
>  	__s32 seq_rtt = -1;
>  	ktime_t last_ackt = net_invalid_timestamp();
> -
> -	while ((skb = tcp_write_queue_head(sk)) &&
> -	       skb != tcp_send_head(sk)) {
> +	
> +	while (skb != NULL 
> +	       && ((!(tp->thin_rdb || sysctl_tcp_force_thin_rdb) 
> +		    && skb != tcp_send_head(sk) 
> +		    && skb != (struct sk_buff *)&sk->sk_write_queue) 
> +		   || ((tp->thin_rdb || sysctl_tcp_force_thin_rdb) 
> +		       && skb != (struct sk_buff *)&sk->sk_write_queue))){

Too complex while condition for most of the mortals to understand, rather 
use while(1) (or preferrably the _safe walk variant) and if (...) break;s

In addition, there has been large rewrite since 2.6.23 days in 
tcp_clean_rtx_queue...

>  		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
>  		__u8 sacked = scb->sacked;
> -
> +		
> +		if(skb == NULL){
> +			break;

??? You already checked for that, no? Unless of course that while 
condition defeated your too and you needed this to avoid imminent 
crashing... :-) The real fix is to simplify while condition.

> +		}
> +		
> +		if(skb == tcp_send_head(sk)){

ditto?

> +			break;
> +		}
> +		
> +		if(skb == (struct sk_buff *)&sk->sk_write_queue){

????

> +			break;
> +		}
> +		
>  		/* If our packet is before the ack sequence we can
>  		 * discard it as it's confirmed to have arrived at
>  		 * the other end.
>  		 */
>  		if (after(scb->end_seq, tp->snd_una)) {
> -			if (tcp_skb_pcount(skb) > 1 &&
> -			    after(tp->snd_una, scb->seq))
> -				acked |= tcp_tso_acked(sk, skb,
> -						       now, &seq_rtt);
> -			break;
> +			if (tcp_skb_pcount(skb) > 1 && after(tp->snd_una, scb->seq))
> +				acked |= tcp_tso_acked(sk, skb, now, &seq_rtt);

Not changing unrelated formats in the same patch would be nice (you 
probably knew that, just mentioning), it makes review a lot harder.

> +			
> +			done = 1;
> +			
> +			/* Added at Simula for RDB support*/
> +			if ((tp->thin_rdb || sysctl_tcp_force_thin_rdb) && after(tp->snd_una, scb->seq)) {
> +				if (!skb_cloned(skb) && !(scb->flags & TCPCB_FLAG_SYN)){

Does this thing of youes depend on skb being not cloned?

> +					remove = tp->snd_una - scb->seq;
> +					remove_head = (remove > skb_headlen(skb) ? 
> +						       skb_headlen(skb) : remove);
> +					remove_frags = (remove > skb_headlen(skb) ? 
> +							remove - remove_head : 0);
> +					
> +					/* Has linear data */
> +					if(skb_headlen(skb) > 0 && remove_head > 0){
> +						memmove(skb->data,
> +							skb->data + remove_head,
> +							skb_headlen(skb) - remove_head);
> +						
> +						skb->tail -= remove_head;
> +					}
> +					
> +					if(skb_is_nonlinear(skb) && remove_frags > 0){
> +						no_frags = 0;
> +						data_frags = 0;
> +						
> +						/*Remove unecessary pages*/
> +						for(i=0; i<skb_shinfo(skb)->nr_frags; i++){
> +							if(data_frags + skb_shinfo(skb)->frags[i].size 
> +							   == remove_frags){
> +								put_page(skb_shinfo(skb)->frags[i].page);
> +								no_frags += 1;
> +								break;
> +							}
> +							put_page(skb_shinfo(skb)->frags[i].page);
> +							no_frags += 1;
> +							data_frags += skb_shinfo(skb)->frags[i].size;
> +						}
> +						
> +						if(skb_shinfo(skb)->nr_frags > no_frags)
> +							memmove(skb_shinfo(skb)->frags,
> +								skb_shinfo(skb)->frags + no_frags,
> +								(skb_shinfo(skb)->nr_frags 
> +								 - no_frags)*sizeof(skb_frag_t));
> +						
> +						skb->data_len -= remove_frags;
> +						skb_shinfo(skb)->nr_frags -= no_frags;
> +						
> +					}
> +					
> +					scb->seq += remove;
> +					skb->len -= remove;
> +					
> +					if(skb->ip_summed == CHECKSUM_PARTIAL)
> +						skb->csum = CHECKSUM_PARTIAL;
> +					else
> +						skb->csum = skb_checksum(skb, 0, skb->len, 0);
> +					
> +				}

Open coded tcp_trim_head?

> +				
> +				/*Only move forward if data could be removed from this packet*/
> +				done = 2;
> +				
> +			}
> +			
> +			if(done == 1 || tcp_skb_is_last(sk,skb)){
> +				break;
> +			} else if(done == 2){
> +				skb = skb->next;
> +				done = 1;
> +				continue;
> +			}
> +			
>  		}
> -
> +		

Please make sure that no this kind of space changes will be present in the 
patch you're going do send.

>  		/* Initial outgoing SYN's get put onto the write_queue
>  		 * just like anything else we transmit.  It is not
>  		 * true data, and if we misinform our callers that
> @@ -2479,14 +2585,14 @@
>  			acked |= FLAG_SYN_ACKED;
>  			tp->retrans_stamp = 0;
>  		}
> -
> +		
>  		/* MTU probing checks */
>  		if (icsk->icsk_mtup.probe_size) {
>  			if (!after(tp->mtu_probe.probe_seq_end, TCP_SKB_CB(skb)->end_seq)) {
>  				tcp_mtup_probe_success(sk, skb);
>  			}
>  		}
> -
> +		
>  		if (sacked) {
>  			if (sacked & TCPCB_RETRANS) {
>  				if (sacked & TCPCB_SACKED_RETRANS)
> @@ -2510,24 +2616,32 @@
>  			seq_rtt = now - scb->when;
>  			last_ackt = skb->tstamp;
>  		}
> +		
> +		if ((tp->thin_rdb || sysctl_tcp_force_thin_rdb) && skb == tcp_send_head(sk)) {
> +			tcp_advance_send_head(sk, skb);
> +		}
> +		

I kind of missed the point of this change, can you please justify it if 
it's still needed? I think it must either be bug in your code causing this 
to happen or unnecessary.

>  		tcp_dec_pcount_approx(&tp->fackets_out, skb);
>  		tcp_packets_out_dec(tp, skb);
> +		next_skb = skb->next;
>  		tcp_unlink_write_queue(skb, sk);
>  		sk_stream_free_skb(sk, skb);
>  		clear_all_retrans_hints(tp);
> +		/* Added at Simula to support RDB */
> +		skb = next_skb;

Use _safe wq walking variant if you need this.

>  	}
> -
> +	
>  	if (acked&FLAG_ACKED) {
>  		u32 pkts_acked = prior_packets - tp->packets_out;
>  		const struct tcp_congestion_ops *ca_ops
>  			= inet_csk(sk)->icsk_ca_ops;
> -
> +		
>  		tcp_ack_update_rtt(sk, acked, seq_rtt);
>  		tcp_ack_packets_out(sk);
> -
> +		
>  		if (ca_ops->pkts_acked) {
>  			s32 rtt_us = -1;
> -
> +			
>  			/* Is the ACK triggering packet unambiguous? */
>  			if (!(acked & FLAG_RETRANS_DATA_ACKED)) {
>  				/* High resolution needed and available? */
> diff -Nur linux-2.6.23.8.vanilla/net/ipv4/tcp_output.c linux-2.6.23.8-tcp-thin/net/ipv4/tcp_output.c
> --- linux-2.6.23.8.vanilla/net/ipv4/tcp_output.c	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/net/ipv4/tcp_output.c	2008-07-03 11:55:45.000000000 +0200
> @@ -1653,7 +1653,7 @@
>  
>  		BUG_ON(tcp_skb_pcount(skb) != 1 ||
>  		       tcp_skb_pcount(next_skb) != 1);
> -
> +		
>  		/* changing transmit queue under us so clear hints */
>  		clear_all_retrans_hints(tp);
>  
> @@ -1702,6 +1702,166 @@
>  	}
>  }
>  
> +/* Added at Simula. Variation of the regular collapse,
> +   adapted to support RDB  */
> +static void tcp_retrans_merge_redundant(struct sock *sk,
> +					struct sk_buff *skb,
> +					int mss_now)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	struct sk_buff *next_skb = skb->next;
> +	int skb_size = skb->len;
> +	int new_data = 0;
> +	int new_data_head = 0;
> +	int new_data_frags = 0;
> +	int new_frags = 0;> +	int old_headlen = 0;
> +	
> +	int i;
> +	int data_frags = 0;
> +	
> +	/* Loop through as many packets as possible
> +	 * (will create a lot of redundant data, but WHATEVER).
> +	 * The only packet this MIGHT be critical for is
> +	 * if this packet is the last in the retrans-queue.
> +	 *
> +	 * Make sure that the first skb isnt already in
> +	 * use by somebody else. */
> +	
> +	if (!skb_cloned(skb)) {

Relying on skb's not being cloned will make your change to work in a 
minority of the cases on many hardwares that have tx reclaims happening 
late enough. I recently got some numbers about clones after rtt and can 
claim this to happen for sure!

> +		/* Iterate through the retransmit queue */
> +		for (; (next_skb != (sk)->sk_send_head) && 
> +			     (next_skb != (struct sk_buff *) &(sk)->sk_write_queue); 
> +		     next_skb = next_skb->next) {

_safe(...) walk.

> +			
> +			/* Reset variables */
> +			new_frags = 0;
> +			data_frags = 0;
> +			new_data = TCP_SKB_CB(next_skb)->end_seq - TCP_SKB_CB(skb)->end_seq;
> +			
> +			/* New data will be stored at skb->start_add + some_offset, 
> +			   in other words the last N bytes */
> +			new_data_frags = (new_data > next_skb->data_len ? 
> +					  next_skb->data_len : new_data);

min()...?

> +			new_data_head = (new_data > next_skb->data_len ? 
> +					 new_data - skb->data_len : 0);

max(new_data - skb->data_len, 0);

> +			
> +			/*
> +			 * 1. Contains the same data
> +			 * 2. Size
> +			 * 3. Sack
> +			 * 4. Window
> +			 * 5. Cannot merge with a later packet that has linear data
> +			 * 6. The new number of frags will exceed the limit
> +			 * 7. Enough tailroom
> +			 */
> +			
> +			if(new_data <= 0){
> +				return;
> +			}
> +			
> +			if ((sysctl_tcp_rdb_max_bundle_bytes == 0 && ((skb_size + new_data) > mss_now))
> +			    || (sysctl_tcp_rdb_max_bundle_bytes > 0 && ((skb_size + new_data) >
> +									sysctl_tcp_rdb_max_bundle_bytes))){
> +				return;
> +			}
> +			
> +			if(TCP_SKB_CB(next_skb)->flags & TCPCB_FLAG_FIN){
> +				return;
> +			}
> +			
> +			if((TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) ||
> +			   (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)){
> +				return;
> +			}
> +			
> +			if(after(TCP_SKB_CB(skb)->end_seq + new_data, tp->snd_una + tp->snd_wnd)){

tcp_wnd_end(tp)

> +				return;
> +			}
> +			
> +			if(skb_shinfo(skb)->frag_list || skb_shinfo(skb)->frag_list){

If it wasn't cloned, why you do this check?

> +				return;
> +			}
> +			
> +			/* Calculate number of new fragments. Any new data will be 
> +			   stored in the back. */
> +			if(skb_is_nonlinear(next_skb)){
> +				i = (skb_shinfo(next_skb)->nr_frags == 0 ? 
> +				     0 : skb_shinfo(next_skb)->nr_frags - 1);
> +				for( ; i>=0;i--){
> +					if(data_frags + skb_shinfo(next_skb)->frags[i].size == 
> +					   new_data_frags){
> +						new_frags += 1;
> +						break;
> +					}
> +					
> +					data_frags += skb_shinfo(next_skb)->frags[i].size;
> +					new_frags += 1;
> +				}
> +			}
> +			
> +			/* If dealing with a fragmented skb, only merge 
> +			   with an skb that ONLY contain frags */
> +			if(skb_is_nonlinear(skb)){
> +				
> +				/*Due to the way packets are processed, no later data*/
> +				if(skb_headlen(next_skb) && new_data_head > 0){
> +					return;
> +				}
> +				
> +				if(skb_is_nonlinear(next_skb) && (new_data_frags > 0) && 
> +				   ((skb_shinfo(skb)->nr_frags + new_frags) > MAX_SKB_FRAGS)){
> +					return;
> +				}
> +				
> +			} else {
> +				if(skb_headlen(next_skb) && (new_data_head > (skb->end - skb->tail))){
> +					return;
> +				}
> +			}
> +			
> +			/*Copy linear data. This will only occur if both are linear, 
> +			  or only A is linear*/
> +			if(skb_headlen(next_skb) && (new_data_head > 0)){
> +				old_headlen = skb_headlen(skb);
> +				skb->tail += new_data_head;
> +				skb->len += new_data_head;
> +				
> +				/* The new data starts in the linear area, 
> +				   and the correct offset will then be given by 
> +				   removing new_data ammount of bytes from length. */
> +				skb_copy_to_linear_data_offset(skb, old_headlen, next_skb->tail - 
> +							       new_data_head, new_data_head);
> +			}
> +			
> +			if(skb_is_nonlinear(next_skb) && (new_data_frags > 0)){
> +				memcpy(skb_shinfo(skb)->frags + skb_shinfo(skb)->nr_frags, 
> +				       skb_shinfo(next_skb)->frags + 
> +				       (skb_shinfo(next_skb)->nr_frags - new_frags), 
> +				       new_frags*sizeof(skb_frag_t));
> +				
> +				for(i=skb_shinfo(skb)->nr_frags; 
> +				    i < skb_shinfo(skb)->nr_frags + new_frags; i++)
> +					get_page(skb_shinfo(skb)->frags[i].page);
> +				
> +				skb_shinfo(skb)->nr_frags += new_frags;
> +				skb->data_len += new_data_frags;
> +				skb->len += new_data_frags;
> +			}
> +			
> +			TCP_SKB_CB(skb)->end_seq += new_data;
> +						
> +			if(skb->ip_summed == CHECKSUM_PARTIAL)
> +				skb->csum = CHECKSUM_PARTIAL;
> +			else
> +				skb->csum = skb_checksum(skb, 0, skb->len, 0);
> +			
> +			skb_size = skb->len;
> +		}
> +		
> +	}
> +}

I suppose this function was effectively:

{
	tcp_write_queue_walk_safe(...) {
		...checks...
		if (tcp_trim_head(...))
			break;
		tcp_collapse_retrans(...);
	}
}

It's sort of counter-intuitive that first you use redundancy but now in 
here when the path _has shown problems_ you now remove the redundancy if
I understand you correctly? The logic is...?

> +
>  /* Do a simple retransmit without using the backoff mechanisms in
>   * tcp_timer. This is used for path mtu discovery.
>   * The socket is already locked here.
> @@ -1756,6 +1916,8 @@
>  /* This retransmits one SKB.  Policy decisions and retransmit queue
>   * state updates are done by the caller.  Returns non-zero if an
>   * error occurred which prevented the send.
> + * Modified at Simula to support thin stream optimizations
> + * TODO: Update to use new helpers (like tcp_write_queue_next())
>   */
>  int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
>  {
> @@ -1802,10 +1964,21 @@
>  	    (skb->len < (cur_mss >> 1)) &&
>  	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
>  	    (!tcp_skb_is_last(sk, skb)) &&
> -	    (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
> -	    (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
> -	    (sysctl_tcp_retrans_collapse != 0))
> +	    (skb_shinfo(skb)->nr_frags == 0
> +	     && skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0)
> +	    && (tcp_skb_pcount(skb) == 1
> +		&& tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1)
> +	    && (sysctl_tcp_retrans_collapse != 0)
> +	    && !((tp->thin_rdb || sysctl_tcp_force_thin_rdb))) {
>  		tcp_retrans_try_collapse(sk, skb, cur_mss);
> +       	} else if ((tp->thin_rdb || sysctl_tcp_force_thin_rdb)) {
> +		if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
> +		    !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
> +		    (skb->next != tcp_send_head(sk)) &&
> +		    (skb->next != (struct sk_buff *) &sk->sk_write_queue)) {
> +			tcp_retrans_merge_redundant(sk, skb, cur_mss);
> +		}
> +	}

This function is recoded in net-next. And some rather simple changes are 
still expected to that area to handle paged data once I get to that.

>  
>  	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
>  		return -EHOSTUNREACH; /* Routing failure or similar. */
> diff -Nur linux-2.6.23.8.vanilla/net/ipv4/tcp_timer.c linux-2.6.23.8-tcp-thin/net/ipv4/tcp_timer.c
> --- linux-2.6.23.8.vanilla/net/ipv4/tcp_timer.c	2007-11-16 19:14:27.000000000 +0100
> +++ linux-2.6.23.8-tcp-thin/net/ipv4/tcp_timer.c	2008-07-02 15:17:38.000000000 +0200
> @@ -32,6 +32,9 @@
>  int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
>  int sysctl_tcp_orphan_retries __read_mostly;
>  
> +/* Added @ Simula */
> +int sysctl_tcp_force_thin_rm_expb __read_mostly = TCP_FORCE_THIN_RM_EXPB;
> +
>  static void tcp_write_timer(unsigned long);
>  static void tcp_delack_timer(unsigned long);
>  static void tcp_keepalive_timer (unsigned long data);
> @@ -368,13 +371,26 @@
>  	 */
>  	icsk->icsk_backoff++;
>  	icsk->icsk_retransmits++;
> -
> +	
>  out_reset_timer:
> -	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> +	/* Added @ Simula removal of exponential backoff for thin streams */
> +	if ((tp->thin_rm_expb || sysctl_tcp_force_thin_rm_expb) && tcp_stream_is_thin(tp)) {
> +		/* Since 'icsk_backoff' is used to reset timer, set to 0
> +		 * Recalculate 'icsk_rto' as this might be increased if stream oscillates
> +		 * between thin and thick, thus the old value might already be too high
> +		 * compared to the value set by 'tcp_set_rto' in tcp_input.c which resets
> +		 * the rto without backoff. */
> +		icsk->icsk_backoff = 0;
> +		icsk->icsk_rto = min(((tp->srtt >> 3) + tp->rttvar), TCP_RTO_MAX);

tcp_set_rto(sk);
tcp_bound_rto(sk);

Though combine + nuking tcp_bound_rto would definately make sense 
considering the callsites do both.

> +	} else {
> +		/* Use normal backoff */
> +		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> +	}
> +	/* End Simula*/
>  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
>  	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
>  		__sk_dst_reset(sk);
> -
> +	
>  out:;
>  }

It seems very intrusive solution in general. I doubt you succeed in 
pulling it off as is without breaking something. To me it seems rather 
fragile approach to make write queue seqno backleaps you're proposing. It 
also leads to troubles in the truesize as you have noticed. Why not just 
building those redundancy containing segments at the write time in case 
the stream is thin, then all other parts would not have to bother about 
dealing these things? Number of sysctls should be minimized, if they're
to be added at all. Skb work functions should be separated from tcp layer 
things.

If you depend on non-changing sysctl value to select right branch, you're 
asking for trouble as the userspave is allowed to change it during the 
flow as well and even during the ack processing.


-- 
 i.
