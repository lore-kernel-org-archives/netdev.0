From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Thu, 10 Feb 2005 21:53:20 GMT
Message-ID: <0523RGW12@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It does not seem to solve the problem:
. Linux 2.6.9 takes 15 seconds to copy 105 MB to the Mac OSX
. Linux 2.6.10 with the TCP patch still takes 325 seconds.

Stephen Hemminger wrote:
>
> Please try this patch, based on Alexey's suggestion:
> 
> > That's one quick and simple idea: set PSH on each tso segment.
> > Seems, it is always good. Hardware will preserve it only on the last skb and
> > everyone will be happy.
> 
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2005/02/09 11:00:57-08:00 shemminger@linux.site 
> #   Always set PUSH on TSO multi-segment frames
> #   to workaround bugs in MacOSX
> # 
> # net/ipv4/tcp_output.c
> #   2005/02/09 11:00:44-08:00 shemminger@linux.site +8 -0
> #   Always set PUSH on TSO multi-segment frames
> #   to workaround bugs in MacOSX
> # 
> diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> --- a/net/ipv4/tcp_output.c	2005-02-09 11:01:12 -08:00
> +++ b/net/ipv4/tcp_output.c	2005-02-09 11:01:12 -08:00
> @@ -754,6 +754,14 @@
>  					break;
>  			}
>  
> +			/* Force push to be on for any large TSO frames
> +			 * to workaround problems with busted implementations
> +			 * like MacOSX that hold off delivery of data until
> +			 * push.
> +			 */
> +			if (tcp_skb_pcount(skb) > 1)
> +			    TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
> +
>  			TCP_SKB_CB(skb)->when = tcp_time_stamp;
>  			if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
>  				break;
