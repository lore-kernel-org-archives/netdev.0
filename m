From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 22:36:00 +0900 (JST)
Message-ID: <20050112.223600.09187852.yoshfuji@linux-ipv6.org>
References: <20050112125336.GH26856@postel.suug.ch>
	<20050112.220816.56650893.yoshfuji@linux-ipv6.org>
	<20050112132126.GI26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, buytenh@wantstofly.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050112132126.GI26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050112132126.GI26856@postel.suug.ch> (at Wed, 12 Jan 2005 14:21:26 +0100), Thomas Graf <tgraf@suug.ch> says:

> * YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20050112.220816.56650893.yoshfuji@linux-ipv6.org> 2005-01-12 22:08
> > How about adding multiple tunnels (with same ipip_bucket(t))
> > concurrently? :-)
> > 
> 
> * Lennert Buytenhek <20050112130940.GA12547@xi.wantstofly.org> 2005-01-12 14:09
> > What if you add two tunnels at the same time?  (Or is that perhaps
> > synchronised on a higher level?)
> 
> Not possible, protected via rtnl semaphore acquired in default
> handler of dev_ioctl.

Good.


David, I think we need to fix sit.c, anyway.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/sit.c 1.43 vs edited =====
--- 1.43/net/ipv6/sit.c	2004-10-04 07:03:07 +09:00
+++ edited/net/ipv6/sit.c	2005-01-12 22:29:32 +09:00
@@ -135,10 +135,10 @@
 {
 	struct ip_tunnel **tp = ipip6_bucket(t);
 
-	write_lock_bh(&ipip6_lock);
 	t->next = *tp;
-	write_unlock_bh(&ipip6_lock);
+	write_lock_bh(&ipip6_lock);
 	*tp = t;
+	write_unlock_bh(&ipip6_lock);
 }
 
 static struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int create)

--yoshfuji
