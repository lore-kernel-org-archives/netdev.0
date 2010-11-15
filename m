From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Reduce number of pointer dereferences in IPv6 netfilter
 LOG module function dump_packet()
Date: Mon, 15 Nov 2010 22:49:01 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011152246050.20408@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1011142241260.1253@swampdragon.chaosbits.net> <1289782215.2743.167.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-292843583-1289857617=:20408"
Cc: Netfilter Core Team <coreteam@netfilter.org>,
	Jan Rekorajski <baggins@pld.org.pl>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289782215.2743.167.camel@edumazet-laptop>
Content-ID: <alpine.LNX.2.00.1011152247130.20408@swampdragon.chaosbits.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-292843583-1289857617=:20408
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LNX.2.00.1011152247131.20408@swampdragon.chaosbits.net>

On Mon, 15 Nov 2010, Eric Dumazet wrote:

> Le dimanche 14 novembre 2010 à 22:47 +0100, Jesper Juhl a écrit :
> > By adding two pointer variables to 
> > net/ipv6/netfilter/ip6t_LOG.c::dump_packet() we can save 19 bytes of .text 
> > and many pointer dereferences.
> > 
> > before:
> >    text    data     bss     dec     hex filename
> >    6258     600    3088    9946    26da net/ipv6/netfilter/ip6t_LOG.o
> > 
> > after:
> >    text    data     bss     dec     hex filename
> >    6239     600    3088    9927    26c7 net/ipv6/netfilter/ip6t_LOG.o
> > 
> > 
> > Please Cc me on replies.
> > 
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  ip6t_LOG.c |   16 ++++++++++------
> >  1 file changed, 10 insertions(+), 6 deletions(-)
> > 
> > diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
> > index 09c8889..51d10a5 100644
> > --- a/net/ipv6/netfilter/ip6t_LOG.c
> > +++ b/net/ipv6/netfilter/ip6t_LOG.c
[...]
> 
> Same comment than previous patch, you add a NULL dereference.
> 
Hopefully this is beter (same as change done to the other (ipv4) patch).



Fewer pointer derefs and smaller .text size for
net/ipv4/netfilter/ipt_LOG.c::dump_packet()

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ip6t_LOG.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 09c8889..de15b14 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -46,6 +46,7 @@ static void dump_packet(struct sbuff *m,
 	unsigned int ptr;
 	unsigned int hdrlen = 0;
 	unsigned int logflags;
+	struct sock *sk;
 
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
@@ -359,12 +360,13 @@ static void dump_packet(struct sbuff *m,
 
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & IP6T_LOG_UID) && recurse && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
+		sk = skb->sk;
+		read_lock_bh(&sk->sk_callback_lock);
+		if (sk->sk_socket && sk->sk_socket->file)
 			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
+				sk->sk_socket->file->f_cred->fsuid,
+				sk->sk_socket->file->f_cred->fsgid);
+		read_unlock_bh(&sk->sk_callback_lock);
 	}
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
--8323328-292843583-1289857617=:20408--
