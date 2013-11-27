From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Wed, 27 Nov 2013 12:51:20 +0100
Message-ID: <20131127115120.GC20630@order.stressinduktion.org>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com> <20131002212720.GA30492@elgon.mountain> <20131127113218.GB1612@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org,
	=?utf-8?B?SsO8cmk=?= Aedla <juri.aedla@gmail.com>,
	stable@kernel.org
To: Eric Wong <normalperson@yhbt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41849 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498Ab3K0LvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 06:51:21 -0500
Content-Disposition: inline
In-Reply-To: <20131127113218.GB1612@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 27, 2013 at 11:32:18AM +0000, Eric Wong wrote:
> Dan Carpenter <dan.carpenter@oracle.com> wrote:
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -1964,6 +1964,16 @@ struct used_address {
> >  	unsigned int name_len;
> >  };
> >  
> > +static int copy_msghdr_from_user(struct msghdr *kmsg,
> > +				 struct msghdr __user *umsg)
> > +{
> > +	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
> > +		return -EFAULT;
> > +	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
> > +		return -EINVAL;
> > +	return 0;
> 
> Crap, this seems to break Ruby trunk :x
> https://bugs.ruby-lang.org/issues/9124
> 
> I'm inclined to think Ruby is wrong to use a gigantic buffer, but this
> may also break some other existing userspace code.  I'm not sure what
> the best option since breaking userspace (even buggy userspace?) is not
> taken lightly.
> 
> Is there a different way to fix this in the kernel?
> 
> Note: this doesn't affect a stable release of Ruby, yet.

We have to clamp msg_namelen to max sizeof(struct sockaddr_storage).
The sendmsg handler will check msg_namelen again and error out correctly if
the size of msg_name is too short.

Greetings,

  Hannes
