From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Sending big Netlink messages to userspace
Date: Wed, 25 Jun 2008 12:44:01 +0200
Message-ID: <20080625104401.GJ20815@postel.suug.ch>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com> <4861282C.4000208@trash.net> <f4845fc0806241118u397a17e3qbe09f5d04a7e5035@mail.gmail.com> <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com> <4861282C.4000208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vince Busam <vbusam@google.com>
To: Patrick McHardy <kaber@trash.net>, Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46129 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726AbYFYKnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 06:43:40 -0400
Content-Disposition: inline
In-Reply-To: <f4845fc0806241118u397a17e3qbe09f5d04a7e5035@mail.gmail.com> <4861282C.4000208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Julius Volz <juliusv@google.com> 2008-06-24 20:18
> libnl hides this from the user, but from reading the code it looks
> like it now has correct a provision for increasing receive buffer size
> automatically on seeing MSG_TRUNC. However, it doesn't seem to help in
> my case...

libnl initializes the buffer size to the size of a page. The value
can be overwritten by calling nl_set_buffer_size(socket, rx, tx)

* Patrick McHardy <kaber@trash.net> 2008-06-24 19:00
> > It depends on what kind of attributes you're sending. In case
> > of top-level attributes you should only dump objects until
> > you reach NLMSG_GOODSIZE and continue during the next dump
> > callback invocation. Sending arbitary amounts of nested
> > data is more tricky, or might even be impossible currently.
> 
> Then I probably have a problem because the list items I'm sending are
> nested and the whole list itself is contained in a nested attribute:
> 
> IPVS_ENTRY_ATTR_SERVICE_LIST
>   IPVS_ENTRY_ATTR_SERVICE
>     [service attributes]
>     ...
>   IPVS_ENTRY_ATTR_SERVICE
>     [service attributes]
>     ...
>   ...
> 
> Each list entry has a limited size, however, so if I get rid of the
> top-level wrapper (SERVICE_LIST), I could try to see if there is
> enough space left in the skb for another whole nested service entry
> and continue in the next callback invocation if space runs out.
> 
> Actually, nla_nest_cancel() seems to be what I'm looking for: start
> dumping service entries into the skb, call nla_nest_cancel() on a put
> failure and begin with the canceled element on the next invocation.
> That should work, right?

Yes, that's how it's intended to work. You can fill until one of the
nla_put variantes aborts and starting trimming off what you've added
already using the nla_nest_cancel() methods until you reach a point
where you can safely cut your stream of attributes. So far we typically
made sure that this barrier is on netlink message level but is no
requirement. You may split a list into several messages you just
have to make sure that you call nla_nest_end() and nlmsg_end() properly
before you send the message.

