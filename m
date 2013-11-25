From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] pipe_to_sendpage: Ensure that MSG_MORE is set if we set MSG_SENDPAGE_NOTLAST
Date: Mon, 25 Nov 2013 08:42:16 +0100
Message-ID: <47783210.a9ocpbYofP@sandpuppy>
References: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com> <1385336527-27304-1-git-send-email-richard@nod.at> <1385342706.10637.125.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	viro@zeniv.linux.org.uk, shawnlandden@gmail.com,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1385342706.10637.125.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 24. November 2013, 17:25:06 schrieb Eric Dumazet:
> On Mon, 2013-11-25 at 00:42 +0100, Richard Weinberger wrote:
> > Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
> > added an internal flag MSG_SENDPAGE_NOTLAST.
> > We have to ensure that MSG_MORE is also set if we set
> > MSG_SENDPAGE_NOTLAST.
> > Otherwise users that check against MSG_MORE will not see it.
> > 
> > This fixes sendfile() on AF_ALG.
> > 
> > Cc: Tom Herbert <therbert@google.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: <stable@vger.kernel.org> # 3.4.x
> > Reported-and-tested-by: Shawn Landden <shawnlandden@gmail.com>
> > Signed-off-by: Richard Weinberger <richard@nod.at>
> > ---
> > 
> >  fs/splice.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/splice.c b/fs/splice.c
> > index 3b7ee65..b93f1b8 100644
> > --- a/fs/splice.c
> > +++ b/fs/splice.c
> > @@ -701,7 +701,7 @@ static int pipe_to_sendpage(struct pipe_inode_info
> > *pipe,> 
> >  	more = (sd->flags & SPLICE_F_MORE) ? MSG_MORE : 0;
> >  	
> >  	if (sd->len < sd->total_len && pipe->nrbufs > 1)
> > 
> > -		more |= MSG_SENDPAGE_NOTLAST;
> > +		more |= MSG_SENDPAGE_NOTLAST | MSG_MORE;
> > 
> >  	return file->f_op->sendpage(file, buf->page, buf->offset,
> >  	
> >  				    sd->len, &pos, more);
> 
> I do not think this patch is right. It looks like a revert of a useful
> patch for TCP zero copy. Given the time it took to discover this
> regression, I bet tcp zero copy has more users than AF_ALG, by 5 or 6
> order of magnitude ;)

Yeah, but AF_ALG broke. That's why I did the patch.

> Here we want to make the difference between the two flags, not merge
> them.
> 
> If AF_ALG do not care of the difference, try instead :
> 
> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
> index ef5356cd280a..850246206b12 100644
> --- a/crypto/algif_hash.c
> +++ b/crypto/algif_hash.c
> @@ -114,6 +114,9 @@ static ssize_t hash_sendpage(struct socket *sock, struct
> page *page, struct hash_ctx *ctx = ask->private;
>  	int err;
> 
> +	if (flags & MSG_SENDPAGE_NOTLAST)
> +		flags |= MSG_MORE;
> +

In the commit message of your patch you wrote "For all sendpage() providers, 
its a transparent change.". Why does AF_ALG need special handling?
If users have to care about MSG_SENDPAGE_NOTLAST it is no longer really an 
internal flag.

Thanks,
//richard
