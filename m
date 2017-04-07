From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 7 Apr 2017 21:21:34 +0200
Message-ID: <20170407192134.GA23205@salvia>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407.115315.23470877439489670.davem@davemloft.net>
 <1491591552.5800.1.camel@sipsolutions.net>
 <20170407190601.GA22991@salvia>
 <1491592185.5800.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33042 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933216AbdDGTVo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:21:44 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F299C170D2B
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:21:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E237FDA86F
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:21:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B55EBDA865
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:21:37 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1491592185.5800.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 09:09:45PM +0200, Johannes Berg wrote:
> On Fri, 2017-04-07 at 21:06 +0200, Pablo Neira Ayuso wrote:
> > On Fri, Apr 07, 2017 at 08:59:12PM +0200, Johannes Berg wrote:
> > [...]
> > > Heh. I think I really want to solve - at least partially -
> > > nla_parse()
> > > to see that it can be done this way. It'd be nice to even transform
> > > all
> > > the callers (I generated half of these patches with spatch anyway)
> > > to
> > > have at least that.
> > 
> > We can just have a modified version of nla_parse that deals with
> > this.
> 
> Yes, but we need to figure out a good way to have the offset.
> 
> We also need to see if we want to *force* having the offset. In some
> sense that'd be useful, in another it might be very complicated to fill
> it in at all times, if for example errors come from lower layers like
> drivers.

For my usecases in netfilter, the attributes and an specific error
code should be enough to figure out what is wrong. Will not need
strings.

BTW, we may not have an offset, eg. EINVAL because of missing
attribute. Given we have different requirements, I would leave it to
each subsystem to decide what netlink error attributes are specified.

> (It's ultimately always going to be optional since we'll continue
> returning errors without *any* extended error information - likely
> indefinitely - but if we have a wrong attribute, should we always have
> an offset? Would be nice, but could be difficult in practice)
> 
> > We can probably use struct nla_policy to place the extended error
> > code or the string (as we discussed I don't need string errors, but
> > I'm fine if other people find it useful).
> 
> I don't think for the error strings really would be useful for
> nla_parse() or a policy - we can return something generic like
> "malformed attribute" there as a string, and hopefully point to the
> attribute/offset from there generically. I just really want to see how
> to actually do that.

I think the most flexible way is to pass the container error structure
to nla_parse() so it sets this for you. This would also save tons of
"malformed attribute" strings.
