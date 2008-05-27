From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] devinet: sysctl setup off by one
Date: Tue, 27 May 2008 11:39:00 -0700
Message-ID: <20080527113900.3039baa1@speedy>
References: <20080523153559.156a1fb5@speedy>
	<483A6929.6060905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48295 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756598AbYE0SjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 14:39:01 -0400
In-Reply-To: <483A6929.6060905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2008 11:39:21 +0400
Pavel Emelyanov <xemul@openvz.org> wrote:

> Stephen Hemminger wrote:
> > It look like the code to setup /proc/sys/net/ipv4/conf/XXX has an off by one bug
> > that causes the last entry (arp_accept) not to be adjusted properly.  This causes
> > changes to the value to occur in the default namespace not the clone? Don't use
> > network namespaces myself, but this looks like a bug.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/net/ipv4/devinet.c	2008-05-23 15:23:19.000000000 -0700
> > +++ b/net/ipv4/devinet.c	2008-05-23 15:29:17.000000000 -0700
> > @@ -1466,7 +1466,7 @@ static int __devinet_sysctl_register(str
> >  	if (!t)
> >  		goto out;
> >  
> > -	for (i = 0; i < ARRAY_SIZE(t->devinet_vars) - 1; i++) {
> > +	for (i = 0; i < ARRAY_SIZE(t->devinet_vars); i++) {
> >  		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
> >  		t->devinet_vars[i].extra1 = p;
> >  		t->devinet_vars[i].extra2 = net;
> > 
> 
> This off-by-one is required, since the very last element of this array
> is used as a sentinel, that shows sysctl engine when to stop processing 
> the table.
> 
> Look, the sizeof(t->devinet_vars) is __NET_IPV4_CONF_MAX == 22, thus
> entries 0, 1, ... 20 are tables and the 21-st is this sentinel, so the
> initialization of this last entry, whose index is (this_sizeof() - 1),
> is not required.
> 
> Thanks,
> Pavel

okay, so that means there is one extra entry in the vars than needed? which
is harmless.
