From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Sat, 29 Jul 2006 17:03:33 -0400
Message-ID: <200607291703.34579.paul.moore@hp.com>
References: <36282A1733C57546BE392885C0618592013E80BD@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:6033 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S932247AbWG2VDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 17:03:42 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <36282A1733C57546BE392885C0618592013E80BD@chaos.tcs.tcs-sec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 29 July 2006 12:34 pm, Venkat Yekkirala wrote:
> > > This is only true wart I see in the patch set from my
> > > perspective.
> > >
> > > You have security_post_accept_hook(), which gets the parent and
> > > the child socket which is all the information you need, and it
> > > seems to be invoked at the correct location.
> > >
> > > So can you please hook into this location using the security
> > > level hook we already have?  Just check sock->sk->sk_family is
> > > PF_INET at the top of that hook if you only want to handle
> > > ipv4 sockets, or something like that.
> > >
> > > Could this work?
> > >
> > > When preparing and argument stating why this won't work, please
> > > suggest a nicer name for this af_inet.c hook or some way to make
> > > it more generic and palatable to us.
> >
> > The only reason for having this new hook in inet_accept() is to catch
> > all the in-kernel "daemons" who do not go through the LSM hooked
> > accept() code path.  I debated putting this hook into the patchset and
> > in the end figured it was at least worth a shot.
>
> If I understand the patch correctly, the openreq inherits cipso from
> the incoming syn and the syn-ack is then sent with this option. I further
> see that the child sock inherits options from the openreq already.
>
> Could you then please elaborate on the need for explicitly copying options
> from parent to child?

The NetLabel patch allows administrators to assign specific a CIPSO 
DOI/configuration to each LSM "domain".  Blindly using the CIPSO tag that the 
remote host sends could violate the administrator's NetLabel configuration.  

The current patch reads the CIPSO tag off the child socket, translating the 
tag according to the CIPSO DOI configuration to arrive at the correct/desired 
LSM  security attributes.  These LSM security attributes and the "domain" are 
then used to set the NetLabel on the socket.  In the case where everyone is 
well behaved this should have no effect on the socket IP options and the 
packets sent across the wire.  However, in the case of a not-nice remote host 
the outgoing CIPSO tag may change to match the administrators desired 
settings.

It is important to note that the next patchset will be based against David's 
net-2.6.19 git tree which has the additional LSM hooks in the accept code 
path - which I plan to use - so expect the implementation to change as a 
result.  Like I said earlier, these new LSM hooks are probably the proper way 
to do it, but I wanted to stick with the hooks that were present at the time 
I started working on NetLabel to minimize the impact on the kernel.

-- 
paul moore
linux security @ hp
