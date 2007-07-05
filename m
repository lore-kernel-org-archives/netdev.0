From: jamal <hadi@cyberus.ca>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Thu, 05 Jul 2007 09:53:30 -0400
Message-ID: <1183643610.5163.76.camel@localhost>
References: <1183492286.4021.21.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:37638 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113AbXGENxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 09:53:34 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2343854wxd
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2007 06:53:33 -0700 (PDT)
In-Reply-To: <1183492286.4021.21.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This email captures the essence of the thread, so let me start here. 
I dont know if i read well enough all the details, but i think i have a
good grasp of the discusion.

To just pick on mentioned issues on the thread which i picked up:
- i think it is fairly usable by netlink to be used as an IPC. The fact
you can do mcast is a huge advantage. i.e i should be able to send to
kernel/user and a mcast group to which a "netlink sniffer" is connected
for debugging etc.
The DoS issue is applicable IMO to any IPC. i.e
if i have access to sending to you, i can send you many messages and
fill up your unix socket rcvq etc.
- On reliability: This is something you will have to deal with yourself
in your application.
For example you could have netlink ACKs sent back to you by all
receivers to the mcast grp (just like the kernel does when you unicast
and ask for acknowledgement).
- In addition to the netlink sock open/close that Patrick mentioned, you
can listen to generic netlink events on the accounting/task netlink and
find out when processes are created/destroyed if that is useful. I
couldnt tell why you needed to know this...

On Tue, 2007-03-07 at 21:51 +0200, Johannes Berg wrote:
> Hey,
> 
> Looking through the code that uses NL_NONROOT_SEND I just realised that
> it's impossible to send multicast messages from userspace to multicast
> groups with IDs higher than 31. That's not really good given that
> everywhere else we handle multicast groups up to 2^32-1 :/

Yes, this is TheWayItHasBeen(tm).
Patrick had a patch a while back to allow for subscribing to higher
groups because bind() has a similar issue in that it allows you only to
subscribe to the first 32. So it is logical to fix connect, and sendmsg
in a similar fashion.

> Unfortunately, I haven't found any good way to fix this; in fact the
> only way to fix it backward-compatibly I could come up with so far is to
> extend struct sockaddr_nl by "__u32 nl_group;" and use that in
> netlink_sendmsg instead of nl_groups when msg_namelen is large enough
> and I'm not even sure that checking msg_namelen is enough, apps could
> give you a length much longer than the actual structure... Maybe
> additionally require that nl_groups is set to ~0 or something. 

We had long chats when Patricks patch went in on this specific issue. I
cant remember the outcome - i remember vaguely that something was going
to break if you muck with sockaddr_nl

> The same
> should be done for netlink_connect() then.

Fixing connect IMO would be a good first start because if you do
connect() to the right group(s) before sendsmg() you could send
to the correct group.

> It would of course be possible to add a new sockopt
> NETLINK_{SET,GET}_DST_GROUP, 

This maybe your best first starting option IMO. It will be in similar
spirit to Patricks bind() fix.

> but that prevents you from sending messages
> to multiple high groups with sendmsg(), 

Iirc, i dont think we can do that anymore. But we can introduce a new
scheme to allow for this. For example, could you not use CMSG to specify
an explicit list of groups on sendmsg? IIRC, Patrick used CMSG to report
on rcv which group a msg was received on. 

cheers,
jamal

