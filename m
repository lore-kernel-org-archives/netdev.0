From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 20:34:10 +0100
Message-ID: <20130106193410.GL16031@1wt.eu>
References: <1357484342.6919.61.camel@edumazet-glaptop> <20130106155123.GB16031@1wt.eu> <1357490393.6919.267.camel@edumazet-glaptop> <20130106164416.GF16031@1wt.eu> <1357492255.6919.336.camel@edumazet-glaptop> <20130106173543.GB22432@1wt.eu> <1357497541.6919.519.camel@edumazet-glaptop> <1357497809.6919.529.camel@edumazet-glaptop> <1357498276.6919.547.camel@edumazet-glaptop> <1357498815.6919.570.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357498815.6919.570.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 06, 2013 at 11:00:15AM -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 10:51 -0800, Eric Dumazet wrote:
> > > 
> > > (sd->len is usually 4096, which is expected, but sd->total_len value is
> > > huge in your case, so we always set the flag in fs/splice.c)
> > 
> > I am testing :
> > 
> >        if (sd->len < sd->total_len && pipe->nrbufs > 1)
> >                 more |= MSG_SENDPAGE_NOTLAST;
> > 
> 
> Yes, this should fix the problem :
> 
> If there is no following buffer in the pipe, we should not set NOTLAST.
> 
> diff --git a/fs/splice.c b/fs/splice.c
> index 8890604..6909d89 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -696,8 +696,10 @@ static int pipe_to_sendpage(struct pipe_inode_info *pipe,
>  		return -EINVAL;
>  
>  	more = (sd->flags & SPLICE_F_MORE) ? MSG_MORE : 0;
> -	if (sd->len < sd->total_len)
> +
> +	if (sd->len < sd->total_len && pipe->nrbufs > 1)
>  		more |= MSG_SENDPAGE_NOTLAST;
> +
>  	return file->f_op->sendpage(file, buf->page, buf->offset,
>  				    sd->len, &pos, more);
>  }
 
OK it works like a charm here now ! I can't break it anymore, so it
looks like you finally got it !

I noticed that the data rate was higher when the loopback's MTU
is exactly a multiple of 4096 (making the 64k choice optimal)
while I would have assumed that in order to efficiently splice
TCP segments, we'd need to have some space for IP/TCP headers
and n*4k for the payload.

I also got the transfer freezes again a few times when starting
tcpdump on the server, but this is not 100% reproducible I'm afraid.
So I'll bring this back when I manage to get some analysable pattern.

The spliced transfer through all the chain haproxy works fine again
at 10gig with your fix. The issue is closed for me. Feel free to add
my Tested-By if you want.

Thank you Eric :-)
Willy
