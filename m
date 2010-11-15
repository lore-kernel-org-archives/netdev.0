From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Reduce number of pointer dereferences in IPv4 netfilter
 LOG module function dump_packet()
Date: Mon, 15 Nov 2010 22:48:10 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011152227310.20408@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1011142212310.1253@swampdragon.chaosbits.net> <1289782180.2743.166.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1965366321-1289857557=:20408"
Cc: Netfilter Core Team <coreteam@netfilter.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289782180.2743.166.camel@edumazet-laptop>
Content-ID: <alpine.LNX.2.00.1011152247010.20408@swampdragon.chaosbits.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1965366321-1289857557=:20408
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LNX.2.00.1011152247011.20408@swampdragon.chaosbits.net>

On Mon, 15 Nov 2010, Eric Dumazet wrote:

> Le dimanche 14 novembre 2010 à 22:35 +0100, Jesper Juhl a écrit :
> > By adding two pointer variables to 
> > net/ipv4/netfilter/ipt_LOG.c::dump_packet() we can save 16 bytes of .text 
> > and 9 pointer dereferences.
> > 
> > before this patch we did 20 pointer dereferences and had this object file 
> > size:
> >    text    data     bss     dec     hex filename
> >    6233     600    3080    9913    26b9 net/ipv4/netfilter/ipt_LOG.o
> > 
> > after this patch we do just 11 pointer dereferences and have this object 
> > file size:
> >    text    data     bss     dec     hex filename
> >    6217     600    3080    9897    26a9 net/ipv4/netfilter/ipt_LOG.o
> > 
> > 
> > Please Cc me on replies.
> > 
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  ipt_LOG.c |   16 ++++++++++------
> >  1 file changed, 10 insertions(+), 6 deletions(-)
> > 
> > diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
> > index 72ffc8f..02a92de 100644
> > --- a/net/ipv4/netfilter/ipt_LOG.c
> > +++ b/net/ipv4/netfilter/ipt_LOG.c
[...]
> > -	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
> > -		read_lock_bh(&skb->sk->sk_callback_lock);
> > -		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
> > +	sk = skb->sk;
> > +	sk_socket = sk->sk_socket;
> 
> Really ? sk can be NULL, so you add a NULL dereference.
> 
Arrgh, yes, you are right. How could I miss that "&& skb->sk" test? I even 
modified that bit without thinking about it (I guess that's the problem, 
not thinking about it and it being late and me having had too much 
coffee and then not testing enough)...
Sorry about that.

[...]
> > -				skb->sk->sk_socket->file->f_cred->fsuid,
> > -				skb->sk->sk_socket->file->f_cred->fsgid);
> > -		read_unlock_bh(&skb->sk->sk_callback_lock);
> > +				sk_socket->file->f_cred->fsuid,
> > +				sk_socket->file->f_cred->fsgid);
> > +		read_unlock_bh(&sk->sk_callback_lock);
> >  	}
> >  
> >  	/* Max length: 16 "MARK=0xFFFFFFFF " */
> > 
> > 
> > 
> 
> Most of these "dereferences" are compiler optimized.
> 
> You added a bug in your patch, and make ipt_LOG slower if rule is not
> asking for IPT_LOG_UID
> 
Yes, I see that now. Thank you for pointing it out.

How about the following instead? It still manages to save 16 bytes of 
.text and a number of pointer derefs and it doesn't deref potentially NULL 
pointers and it doesn't do any extra work if IPT_LOG_UID is not asked for.
And this time I didn't just compile test it but booted and ran a kernel 
with the patch as well.



Fewer pointer derefs and smaller .text size for 
net/ipv4/netfilter/ipt_LOG.c::dump_packet()

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ipt_LOG.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 72ffc8f..539dce3 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -39,6 +39,7 @@ static void dump_packet(struct sbuff *m,
 	struct iphdr _iph;
 	const struct iphdr *ih;
 	unsigned int logflags;
+	struct sock *sk;
 
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
@@ -336,12 +337,13 @@ static void dump_packet(struct sbuff *m,
 
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
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
--8323328-1965366321-1289857557=:20408--
