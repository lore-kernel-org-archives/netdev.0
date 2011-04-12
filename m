From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: Fix meta match u32 with 0xffffffff
Date: Tue, 12 Apr 2011 08:19:07 -0700
Message-ID: <20110412081907.4f2e21fd@nehalam>
References: <20110411115234.74b5936b@nehalam>
	<1302595009.3664.8.camel@lsx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45663 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701Ab1DLPTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 11:19:10 -0400
In-Reply-To: <1302595009.3664.8.camel@lsx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2011 09:56:49 +0200
Thomas Graf <tgraf@redhat.com> wrote:

> On Mon, 2011-04-11 at 11:52 -0700, Stephen Hemminger wrote: 
> > The value 0xffffffff is a valid mask and bstrtoul() would return
> > ULONG_MAX which was the error value. Resolve the problem by separating
> > return value and error indication.
> >  
> > -unsigned long bstrtoul(const struct bstr *b)
> > +int bstrtoul(const struct bstr *b, unsigned long *lp)
> >  {
> >  	char *inv = NULL;
> > -	unsigned long l;
> >  	char buf[b->len+1];
> >  
> > +	if (b->len == 0)
> > +		return -EINVAL;
> > +
> >  	memcpy(buf, b->data, b->len);
> >  	buf[b->len] = '\0';
> >  
> > -	l = strtoul(buf, &inv, 0);
> > -	if (l == ULONG_MAX || inv == buf)
> > -		return ULONG_MAX;
> > +	*lp = strtoul(buf, &inv, 0);
> > +	if (inv == buf)
> > +		return -EINVAL;
> > +
> > +	if (*lp == ULONG_MAX || errno == ERANGE)
> > +		return -ERANGE;
> >  
> > -	return l;
> > +	return 0;
> >  }
> 
> This is definitely much better but we still can't parse ULONG_MAX
> as string representative. Checking glibc docs, the only way to do it is
> to ignore the return value for error checking and look errno.
> 

I think the error case is ret == ULONG_MAX && errno == ERANGE
If there is no error, then strtoul doesn't set errno.



-- 
