From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 08:59:08 +0200
Message-ID: <20170411065908.GB1492@salvia>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
 <20170408202434.12018-2-johannes@sipsolutions.net>
 <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
 <1491838218.28432.5.camel@sipsolutions.net>
 <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60376 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751619AbdDKG72 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 02:59:28 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9C853D25F8
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 08:59:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8D7F2DA875
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 08:59:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7633EDA80B
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 08:59:21 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 09:35:27AM -0600, David Ahern wrote:
> On 4/10/17 9:30 AM, Johannes Berg wrote:
> > On Mon, 2017-04-10 at 09:26 -0600, David Ahern wrote:
> >> On 4/8/17 2:24 PM, Johannes Berg wrote:
> >>> @@ -2300,14 +2332,35 @@ void netlink_ack(struct sk_buff *in_skb,
> >>> struct nlmsghdr *nlh, int err)
> >>>  			  NLMSG_ERROR, payload, 0);
> >>>  	errmsg = nlmsg_data(rep);
> >>>  	errmsg->error = err;
> >>> -	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh-
> >>>> nlmsg_len : sizeof(*nlh));
> >>> +	memcpy(&errmsg->msg, nlh,
> >>> +	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
> >>> +						 : sizeof(*nlh));
> >>> +
> >>
> >> generically this makes userspace parsing more problematic: the
> >> parsing layer may not know if the socket option has been set to
> >> precisely know the size of errmsg->msg and how much data needs to be
> >> skipped to get to the new attributes.
> > 
> > Yes, I know. I'd hope that userspace can remember that per socket - I
> > don't see a good other way to do this.
> > 
> > If we insert the TLVs in front of, or instead of (with a TLV containing
> > it), the request message then at least libnl's debugging will need to
> > be changed.
> > 
> > As it is, I can assume that libnl will not set the CAP setting, and
> > everything works fine even if I don't change libnl, which makes things
> > easier.
> > 
> > Do you have any better ideas?
> 
> NETLINK_F_CAP_ACK and NETLINK_F_EXT_ACK should be incompatible -- if one
> is set the other can not be set. CAP_ACK means abbreviate the response
> and EXT_ACK means give me more data.

CAP_ACK means: trim off the payload that the netlink error message
is embedding, just like ICMP error does.

What is exactly your concern? If the user explicitly requests this via
socket option for this socket, then we're expecting they do the right
handling for what they're asking for.
