From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 21:55:49 GMT
Message-ID: <0525M9211@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: shemminger@osdl.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        Nivedita Singhvi<niv@us.ibm.com>, Rick Jones <rick.jones2@hp.com>,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry, it still does not work, unless I made a mistake:
Linux 2.6.9 takes 15 seconds to copy 105 MB to Mac OSX
Linux 2.6.10 with the TCP patch below still takes 325 seconds to do the same.

You can pick the new tcpdump report, created through:
tcpdump -i eth1 ip host 10.107.96.230 -w /tmp/dump-2.6.10-tcp2
at http://fullpliant.org/pliant/browse/file/archive/dump-2.6.10-tcp2.gz

Here is the connection summary:

Dell PowerEdge 2600 (dual Xeon with hyper threading) running libsmbclient
on Linux 2.6.x, IP for eth1 (Intel pro 1000) is 10.107.96.7 (full
duplex, flow control is enabled)
     |
     |
gigabit switch
     |
     |
100 Mbps switch
     |
     |
Mac running Samba server on OSX,
IP is 10.107.96.230


David S. Miller wrote:
>
> Hubert, try this patch instead.
> 
> ===== net/ipv4/tcp_output.c 1.77 vs edited =====
> --- 1.77/net/ipv4/tcp_output.c	2005-01-18 12:23:36 -08:00
> +++ edited/net/ipv4/tcp_output.c	2005-02-10 16:42:42 -08:00
> @@ -408,6 +408,16 @@
>  		sk->sk_send_head = skb;
>  }
>  
> +static inline void tcp_tso_set_push(struct sk_buff *skb)
> +{
> +	/* Force push to be on for any TSO frames to workaround
> +	 * problems with busted implementations like Mac OS-X that
> +	 * hold off socket reveive wakeups until push is seen.
> +	 */
> +	if (tcp_skb_pcount(skb) > 1)
> +		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
> +}
> +
>  /* Send _single_ skb sitting at the send head. This function requires
>   * true push pending frames to setup probe timer etc.
>   */
> @@ -419,6 +429,7 @@
>  	if (tcp_snd_test(tp, skb, cur_mss, TCP_NAGLE_PUSH)) {
>  		/* Send it out now. */
>  		TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +		tcp_tso_set_push(skb);
>  		if (!tcp_transmit_skb(sk, skb_clone(skb, sk->sk_allocation))) {
>  			sk->sk_send_head = NULL;
>  			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
> @@ -755,6 +766,7 @@
>  			}
>  
>  			TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +			tcp_tso_set_push(skb);
>  			if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
>  				break;
>  
> @@ -1096,6 +1108,7 @@
>  	 * is still in somebody's hands, else make a clone.
>  	 */
>  	TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +	tcp_tso_set_push(skb);
>  
>  	err = tcp_transmit_skb(sk, (skb_cloned(skb) ?
>  				    pskb_copy(skb, GFP_ATOMIC):
> @@ -1668,6 +1681,7 @@
>  
>  			TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
>  			TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +			tcp_tso_set_push(skb);
>  			err = tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC));
>  			if (!err) {
>  				update_send_head(sk, tp, skb);
