From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] af_unix: speedup /proc/net/unix
Date: Sat, 09 Jun 2012 10:10:20 +0200
Message-ID: <1339229420.6001.146.camel@edumazet-glaptop>
References: <1339167801.6001.111.camel@edumazet-glaptop>
	 <4FD2E22F.9090503@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33956 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab2FIIKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 04:10:23 -0400
Received: by weyu7 with SMTP id u7so1033803wey.19
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 01:10:21 -0700 (PDT)
In-Reply-To: <4FD2E22F.9090503@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Sat, 2012-06-09 at 09:42 +0400, Michael Tokarev wrote:
> On 08.06.2012 19:03, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > /proc/net/unix has quadratic behavior, and can hold unix_table_lock for
> > a while if high number of unix sockets are alive. (90 ms for 200k
> > sockets...)
> 
> Two comments, nitpicking...
> 
> []
> >  struct unix_iter_state {
> >  	struct seq_net_private p;
> > -	int i;
> >  };
> 
> Can't seq_net_private be used directly?
> 

Absolutely

> >  
> >  static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> >  {
> > +	return unix_next_socket(seq, v, pos);
> >  }
> 
> Why unix_seq_next() is needed?  Can't unix_next_socket() be used directly instead?

Nope, you missed the "++*pos;"

static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
{
	++*pos;
	return unix_next_socket(seq, v, pos);
}

Thanks !

[PATCH net-next] af_unix: remove unix_iter_state

As pointed out by Michael Tokarev , struct unix_iter_state is no longer
needed.

Suggested-by: Michael Tokarev <mjt@tls.msk.ru>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 net/unix/af_unix.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index cf83f6b..79981d9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2255,10 +2255,6 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 #define get_offset(x) ((x) & ((1L << BUCKET_SPACE) - 1))
 #define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
 
-struct unix_iter_state {
-	struct seq_net_private p;
-};
-
 static struct sock *unix_from_bucket(struct seq_file *seq, loff_t *pos)
 {
 	unsigned long offset = get_offset(*pos);
@@ -2383,7 +2379,7 @@ static const struct seq_operations unix_seq_ops = {
 static int unix_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &unix_seq_ops,
-			    sizeof(struct unix_iter_state));
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations unix_seq_fops = {
