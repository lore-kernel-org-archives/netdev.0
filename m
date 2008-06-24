From: "Julius Volz" <juliusv@google.com>
Subject: Re: Sending big Netlink messages to userspace
Date: Tue, 24 Jun 2008 20:18:12 +0200
Message-ID: <f4845fc0806241118u397a17e3qbe09f5d04a7e5035@mail.gmail.com>
References: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
	 <4861282C.4000208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vince Busam" <vbusam@google.com>,
	"Thomas Graf" <tgraf@suug.ch>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:34633 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbYFXSS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 14:18:29 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m5OIIDoi005743
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 19:18:14 +0100
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by zps77.corp.google.com with ESMTP id m5OIIC0J009449
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 11:18:12 -0700
Received: by wf-out-1314.google.com with SMTP id 25so2719316wfc.28
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 11:18:12 -0700 (PDT)
In-Reply-To: <4861282C.4000208@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008, Patrick McHardy wrote:
> Thats done automatically through netlink_dump_start().
> You send one skb per dump callback invocation. The final
> call returns a zero sized skb to indicate the end of the
> dump.

Thanks for the pointer, that seems like what I was looking for!

> You probably need to increase the receive buffer size in libnl.

libnl hides this from the user, but from reading the code it looks
like it now has correct a provision for increasing receive buffer size
automatically on seeing MSG_TRUNC. However, it doesn't seem to help in
my case...

> It depends on what kind of attributes you're sending. In case
> of top-level attributes you should only dump objects until
> you reach NLMSG_GOODSIZE and continue during the next dump
> callback invocation. Sending arbitary amounts of nested
> data is more tricky, or might even be impossible currently.

Then I probably have a problem because the list items I'm sending are
nested and the whole list itself is contained in a nested attribute:

IPVS_ENTRY_ATTR_SERVICE_LIST
  IPVS_ENTRY_ATTR_SERVICE
    [service attributes]
    ...
  IPVS_ENTRY_ATTR_SERVICE
    [service attributes]
    ...
  ...

Each list entry has a limited size, however, so if I get rid of the
top-level wrapper (SERVICE_LIST), I could try to see if there is
enough space left in the skb for another whole nested service entry
and continue in the next callback invocation if space runs out.

Actually, nla_nest_cancel() seems to be what I'm looking for: start
dumping service entries into the skb, call nla_nest_cancel() on a put
failure and begin with the canceled element on the next invocation.
That should work, right?

Julius

-- 
Google Switzerland GmbH
