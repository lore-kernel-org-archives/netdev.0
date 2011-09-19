From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Mon, 19 Sep 2011 09:03:13 -0400
Message-ID: <20110919130313.GA27819@hmsreliant.think-freely.org>
References: <20110919121940.GA19942@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110919121940.GA19942-k/PPzeaMb74v2OKnPYDugg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2011 at 08:19:40AM -0400, Benjamin Poirier wrote:
> Hi,
> 
> I noticed what appears to be a discrepancy between the ip(7) man page
> and the kernel code with regards to the IP DF flag for UDP sockets.
> 
> The man page says that "The don't-fragment flag is set on all outgoing
> datagrams" and that the ip_no_pmtu_disc sysctl affects only SOCK_STREAM
> sockets. This is quickly disproved by doing:
> echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc
> firing up netcat and looking at a few outgoing udp packets in wireshark
> (they don't have the DF flag set).
> 
> 1) in the words of `man 7 ip`:
> IP_MTU_DISCOVER (since Linux 2.2)
>       Set or receive the Path MTU Discovery  setting  for  a  socket.
>       When  enabled, Linux will perform Path MTU Discovery as defined
>       in RFC 1191 on this socket.  The don't-fragment flag is set  on
>       all  outgoing datagrams.  The system-wide default is controlled
>       by the /proc/sys/net/ipv4/ip_no_pmtu_disc file for  SOCK_STREAM
>       sockets, and disabled on all others.
> 
> This is the text present in the latest version of the online manpages,
> http://webcache.googleusercontent.com/search?q=cache:http://www.kernel.org/doc/man-pages/reporting_bugs.html&ie=UTF-8
> 
> 2) in net/ipv4/af_inet.c:inet_create():
> 	if (ipv4_config.no_pmtu_disc)
> 		inet->pmtudisc = IP_PMTUDISC_DONT;
> 	else
> 		inet->pmtudisc = IP_PMTUDISC_WANT;
> 
> and pmtudisc is left alone from there on for UDP sockets.
> 
> What should be adjusted, the man page or the code?
> 
The man page is wrong I think

By my read, the code:
1) Affects UDP and TCP the same way (which makes sense to me)

2) Is doing exactly what you asked it to, since you set no_pmtu_disc, which
means the stack should be free to fragment a frame as it sees fit according to
the MTU metric of the route its traversing, hence the cleared DF bit in the
fraem.

RFC 1191 can apply equally well to udp, as tcp, and is evident in that you can
set the per-socket option IP_MTU_DISCOVER to any of the 4 acceptible values
offered (DONT/WANT/DO/PROBE), so theres no reason the sysctl governing the
default value at creation shouldn't apply as well.
Neil

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
