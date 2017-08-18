From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net v2] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Fri, 18 Aug 2017 19:42:48 +0200
Message-ID: <1503078168.3344.54.camel@redhat.com>
References: <20170818021157.20070-1-matthew@mjdsystems.ca>
         <1503065118.3344.18.camel@redhat.com> <1789862.HUSStbeWG9@ring00>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Macieira, Thiago" <thiago.macieira@intel.com>,
        willemdebruijn.kernel@gmail.com
To: Matthew Dawson <matthew@mjdsystems.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49536 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdHRRmv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 13:42:51 -0400
In-Reply-To: <1789862.HUSStbeWG9@ring00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-18 at 12:39 -0400, Matthew Dawson wrote:
> On Friday, August 18, 2017 10:05:18 AM EDT Paolo Abeni wrote:
> > On Thu, 2017-08-17 at 22:11 -0400, Matthew Dawson wrote:
> > > diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> > > index 7b52a380d710..be8982b4f8c0 100644
> > > --- a/net/unix/af_unix.c
> > > +++ b/net/unix/af_unix.c
> > > @@ -2304,10 +2304,7 @@ static int unix_stream_read_generic(struct
> > > unix_stream_read_state *state,> 
> > >  	 */
> > >  	
> > >  	mutex_lock(&u->iolock);
> > > 
> > > -	if (flags & MSG_PEEK)
> > > -		skip = sk_peek_offset(sk, flags);
> > > -	else
> > > -		skip = 0;
> > > +	skip = max(sk_peek_offset(sk, flags), 0);
> > > 
> > >  	do {
> > >  	
> > >  		int chunk;
> > 
> > later we have:
> > 
> > 	chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
> > 
> > without any call to __skb_try_recv_from_queue(), so we will get
> > bad/unexpected values from the above assignment when 'skip' is
> > negative.
> 
> The assignment to skip should ensure it is never less then zero, thanks to the 
> max(sk...(), 0).  Thus that shouldn't be an issue?

Right, I missed the max() call. Thanks for pointing it out. 
I'm fine with the above.

> > 
> > Overall I still think that adding/using an explicit MSG_PEEK_OFF bit
> > would produce a simpler code, but is just a personal preference.
> 
> I don't mind either way, that just seemed to be the preference I saw from the 
> discussion around the patch.  I think either way will work, so whatever the 
> list prefers I'm happy with.

I'm ok either way. Probably it's worth continue this way.

Paolo
