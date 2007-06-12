From: David Miller <davem@davemloft.net>
Subject: Re: TCP_MD5 and Intel e1000
Date: Tue, 12 Jun 2007 14:39:11 -0700 (PDT)
Message-ID: <20070612.143911.124443145.davem@davemloft.net>
References: <20070522105738.f03cb83b.dada1@cosmosbay.com>
	<20070522.183647.75785266.yoshfuji@linux-ipv6.org>
	<20070522.031432.08079709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, webmaster@poweraudio.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755273AbXFLVjT@vger.kernel.org>
In-Reply-To: <20070522.031432.08079709.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 22 May 2007 03:14:32 -0700 (PDT)

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Tue, 22 May 2007 18:36:47 +0900 (JST)
> 
> > In article <20070522105738.f03cb83b.dada1@cosmosbay.com> (at Tue, 22 May 2007 10:57:38 +0200), Eric Dumazet <dada1@cosmosbay.com> says:
> > 
> > > > I have tried to set up quagga with tcp-md5 support from kernel. All seems ok
> > > > with a intel e100 NIC, but as i testetd with a intel e1000 NIC the tcp
> > > > packets have an invalid md5 digest.
> > > > If i run tcpdump on the mashine the packets are generated, it shows on the
> > > > outgoing interface invalid md5 digests.
> > > > Are there known issues about tcp-md5 and e1000 NICs?
> > :
> > > You could try "ethtool -K tx off", and/or other ethtool -K settings
> > 
> > Disabling offloading should help; currently tcp-md5 stack
> > blindly copy md5-signature from the first segment
> > which is not appropriate for rest of segments.
> 
> It is clear we should disable TSO for sockets making use of TCP-MD5.

I'm going to fix this as follows:

commit 3d7dbeac58d0669c37e35a3b91bb41c0146395ce
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Jun 12 14:36:42 2007 -0700

    [TCP]: Disable TSO if MD5SIG is enabled.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 97e294e..354721d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -878,6 +878,7 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
 				kfree(newkey);
 				return -ENOMEM;
 			}
+			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
 		if (tcp_alloc_md5sig_pool() == NULL) {
 			kfree(newkey);
@@ -1007,7 +1008,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 			return -EINVAL;
 
 		tp->md5sig_info = p;
-
+		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4f06a51..193d9d6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -590,6 +590,7 @@ static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
 				kfree(newkey);
 				return -ENOMEM;
 			}
+			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
 		tcp_alloc_md5sig_pool();
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
@@ -724,6 +725,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 			return -ENOMEM;
 
 		tp->md5sig_info = p;
+		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
