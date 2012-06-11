From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Mon, 11 Jun 2012 13:16:59 +0200
Message-ID: <20120611111659.GK27795@secunet.com>
References: <20120611.022911.885347106959530782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60724 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311Ab2FKLRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 07:17:03 -0400
Content-Disposition: inline
In-Reply-To: <20120611.022911.885347106959530782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 11, 2012 at 02:29:11AM -0700, David Miller wrote:
> 
> -unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
> -				 unsigned short new_mtu,
> -				 struct net_device *dev)
> -{
> -	unsigned short old_mtu = ntohs(iph->tot_len);
> -	unsigned short est_mtu = 0;
> -	struct inet_peer *peer;
> -
> -	peer = inet_getpeer_v4(net->ipv4.peers, iph->daddr, 1);
> -	if (peer) {
> -		unsigned short mtu = new_mtu;
> -
> -		if (new_mtu < 68 || new_mtu >= old_mtu) {
> -			/* BSD 4.2 derived systems incorrectly adjust
> -			 * tot_len by the IP header length, and report
> -			 * a zero MTU in the ICMP message.
> -			 */
> -			if (mtu == 0 &&
> -			    old_mtu >= 68 + (iph->ihl << 2))
> -				old_mtu -= iph->ihl << 2;
> -			mtu = guess_mtu(old_mtu);
> -		}
> -
> -		if (mtu < ip_rt_min_pmtu)
> -			mtu = ip_rt_min_pmtu;
> -		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
> -			unsigned long pmtu_expires;
> -
> -			pmtu_expires = jiffies + ip_rt_mtu_expires;
> -			if (!pmtu_expires)
> -				pmtu_expires = 1UL;
> -
> -			est_mtu = mtu;
> -			peer->pmtu_learned = mtu;
> -			peer->pmtu_expires = pmtu_expires;
> -			atomic_inc(&__rt_peer_genid);
> -		}
> -
> -		inet_putpeer(peer);
> -	}
> -	return est_mtu ? : new_mtu;
> -}
> -

It seems that we don't cache the learned pmtu informations
in some cases with ip_rt_frag_needed() removed. 

At least when doing a simple ping test on a network that has
a router with mtu 1300 along the path, the following happens:

bash-3.00# ping -c 4 -s 1400 192.168.40.2                                       
PING 192.168.40.2 (192.168.40.2) 1400(1428) bytes of data.                      
>From 10.2.2.2 icmp_seq=1 Frag needed and DF set (mtu = 1300)                    
>From 10.2.2.2 icmp_seq=2 Frag needed and DF set (mtu = 1300)                    
>From 10.2.2.2 icmp_seq=3 Frag needed and DF set (mtu = 1300)                    
>From 10.2.2.2 icmp_seq=4 Frag needed and DF set (mtu = 1300)                    
                                                                                
--- 192.168.40.2 ping statistics ---                                            
4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3005ms     

We should learn the pmtu information with the first packet,
all further packets should get fragmented according to
the learned informations. Unfortunately we don't cache
these informations: 
                                                        
bash-3.00# ip r g 192.168.40.2                                                  
192.168.40.2 via 192.168.20.1 dev eth0  src 192.168.20.2                        
    cache
