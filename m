From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH 2/2] ppp: implement rtnetlink device handling
Date: Mon, 25 Jan 2016 16:28:30 +0100
Message-ID: <20160125152830.GW18510@alphalink.fr>
References: <cover.1450900138.git.g.nault@alphalink.fr>
 <c5f53cba74321e0b9fc5e03fd5c55bdc8c1bc4bf.1450900138.git.g.nault@alphalink.fr>
 <56A6026E.4020709@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: walter harms <wharms@bfs.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56A6026E.4020709@bfs.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 12:09:34PM +0100, walter harms wrote:
> 
> 
> Am 23.12.2015 21:04, schrieb Guillaume Nault:
> > @@ -1012,7 +1017,24 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
> >  	int indx;
> >  	int err;
> >  
> > -	file = conf->file;
> > +	if (conf->fd >= 0) {
> > +		file = fget(conf->fd);
> > +		if (file) {
> > +			if (file->f_op != &ppp_device_fops) {
> > +				fput(file);
> > +				return -EBADF;
> > +			}
> > +
> > +			/* Don't hold reference on file: ppp_release() is
> > +			 * responsible for safely freeing the associated
> > +			 * resources upon release. So file won't go away
> > +			 * from under us.
> > +			 */
> > +			fput(file);
> > +		}
> > +	} else {
> > +		file = conf->file;
> > +	}
> >  	if (!file)
> >  		return -EBADF;
> 
> 
> I would write that a bid different to reduce indent
> und improve readability
> 
> (note: totaly untested just reviewing)
> 
> if (conf->fd < 0) {
> 	file = conf->file;
> 	if (!file)
>   		return -EBADF;
> }
> else
> {
> file = fget(conf->fd);
> if (!file)
>   	return -EBADF;
> 
Early return on fget() failure looks indeed simpler.

> fput(file);
> if (file->f_op != &ppp_device_fops) {		
> 		return -EBADF;
> 	}
> 
But this is wrong: we can't act on file after fput(). So we have to
place fput() after the test.

Thanks for your review.
