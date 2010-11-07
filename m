From: Vasiliy Kulikov <segooon@gmail.com>
Subject: Re: [PATCH 2/3] net: packet: fix information leak to userland
Date: Sun, 7 Nov 2010 15:06:36 +0300
Message-ID: <20101107120636.GA7101@albatros>
References: <1288545028-16436-1-git-send-email-segooon@gmail.com>
 <4CCE84E2.9050801@bfs.de>
 <20101106143911.GA17428@albatros>
 <4CD68F7E.5050407@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42252 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294Ab0KGMGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 07:06:43 -0500
Content-Disposition: inline
In-Reply-To: <4CD68F7E.5050407@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 07, 2010 at 12:37 +0100, walter harms wrote:
> Am 06.11.2010 15:39, schrieb Vasiliy Kulikov:
> > On Mon, Nov 01, 2010 at 10:14 +0100, walter harms wrote:
> >> Vasiliy Kulikov schrieb:
> >>> @@ -1719,7 +1719,7 @@ static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
> >>>  	rcu_read_lock();
> >>>  	dev = dev_get_by_index_rcu(sock_net(sk), pkt_sk(sk)->ifindex);
> >>>  	if (dev)
> >>> -		strlcpy(uaddr->sa_data, dev->name, 15);
> >>> +		strncpy(uaddr->sa_data, dev->name, 14);
> >>>  	else
> >>>  		memset(uaddr->sa_data, 0, 14);
> >>
> >> if i understand the code correcly the max size for dev->name is IFNAMSIZ.
> > 
> > For dev->name - IFNAMSIZ, for uaddr->sa_data - 14.
> > 
> 
> 
> did not notice, since uaddr->sa_data should take dev->name this does no look very
> clever. How is the size of  sa_data defined ?

Magic size...

~/linux/include/linux/socket.h:

struct sockaddr {
	sa_family_t	sa_family;	/* address family, AF_xxx	*/
	char		sa_data[14];	/* 14 bytes of protocol address	*/
};


> Would it hurt when some uses IFNAMSIZ here ?

If copy _to_ sa_data string of maximum IFNAMSIZ bytes - yes.


In packet_getname_spkt() the output buffer is 128 bytes, so it doesn't
really overflows anything.  I don't think that *_getname() implementations
don't know this.

> Perhaps someone who know more about the network stack can figure out what is actualy done
> with uaddr->sa_data.

Yeah, also I wonder whether it is always NULL-terminated string or not.

> looks like a can of worms.
> 
> 
> In packet_bind_spkt() they will copy a char[15], obviously it is a real problem.

No, packet_bind_spkt() copies 14-byte string into array of 15 bytes.
The vice versa would be a bug.

> re,
>  wh
> 
> 
> >> You can simply that part:
> >>
> >> memset(uaddr->sa_data, 0, IFNAMSIZ);
> >> dev = dev_get_by_index_rcu(sock_net(sk), pkt_sk(sk)->ifindex);
> >> if (dev)
> >> 	strlcpy(uaddr->sa_data, dev->name, IFNAMSIZ);
> > 
> > This will overflow uaddr->sa_data.  Also I don't see any difficulty to
> > fill the array only once.
> > 
> >> you should send that as separate patch.
> >> re,
> >>  wh
> >>
> >>
> >>>  	rcu_read_unlock();
> >>> @@ -1742,6 +1742,7 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
> >>>  	sll->sll_family = AF_PACKET;
> >>>  	sll->sll_ifindex = po->ifindex;
> >>>  	sll->sll_protocol = po->num;
> >>> +	sll->sll_pkttype = 0;
> >>>  	rcu_read_lock();
> >>>  	dev = dev_get_by_index_rcu(sock_net(sk), po->ifindex);
> >>>  	if (dev) {
> > 
> > Thanks,
> > 

-- 
Vasiliy
