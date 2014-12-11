From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: OOPS: net/ipv6/datagram.c (line 260) ipv6_local_error
Date: Thu, 11 Dec 2014 12:37:54 +0100
Message-ID: <20141211113754.GN6390@secunet.com>
References: <5487CDE9.4070606@gtsys.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39743 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242AbaLKLiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 06:38:03 -0500
Content-Disposition: inline
In-Reply-To: <5487CDE9.4070606@gtsys.com.hk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2014 at 12:36:57PM +0800, Chris Ruehl wrote:
> Hi all,
> 
> We running a Dell server which crash frequently with (dell crash
> video snapshot) vanilla 3.14.25
> 
> 
> 
> The capture don't sadly don't show the full trace, so we lack on
> information.
> 1st line I can see in the crash video from the idrac :
> tcp_transmit_skb+0x461
> 
> The null pointer happen:
>  Type "apropos word" to search for commands related to "word"...
> Reading symbols from net/ipv6/datagram.o...done.
> (gdb) list *(ipv6_local_error+0x17)
> 0xae7 is in ipv6_local_error (net/ipv6/datagram.c:260).
> 255        struct ipv6_pinfo *np = inet6_sk(sk);
> 256        struct sock_exterr_skb *serr;
> 257        struct ipv6hdr *iph;
> 258        struct sk_buff *skb;
> 259
> 260        if (!np->recverr)
> 261            return;
> 262
> 263        skb = alloc_skb(sizeof(struct ipv6hdr), GFP_ATOMIC);
> 264        if (!skb)
> (gdb) quit
> 
> 
> We running a 6in4 with ipsec tunnel on the 6. I found a pull request from
> Steffen Klassert
> here:
> http://article.gmane.org/gmane.linux.network/281469
> 
> Which might be relevant to this problem.
> 
> For time being I add a
> 
>         if (np == NULL){
>                 LIMIT_NETDEBUG(KERN_DEBUG "ipv6_pinfo is NULL\n");
>                 return;
>         }
> 
> as work around to stop the server crashing

Looks like ipv6_local_error() got an ipv4 socket. You could
extend your workaround to something like the below. This
should give a full backtrace and the socket family.

 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index cc11396..cf3a5d8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -258,6 +258,13 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info)
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 
+	if (np == NULL) {
+		WARN_ON_ONCE(1);
+		if (net_ratelimit())
+			printk(KERN_DEBUG "ipv6_pinfo is NULL, sk family %d\n", sk->sk_family);
+		return;
+	}
+
 	if (!np->recverr)
 		return;
 
