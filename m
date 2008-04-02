From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 07:42:13 -0400
Message-ID: <1207136533.4451.132.camel@localhost>
References: <47EAAFEC.6000805@trash.net>	<20080331123311.64e4ca37@extreme>
	 <47F13E43.2040404@trash.net>
	 <20080331.130757.199769025.davem@davemloft.net>
	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>
	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>
	 <47F35933.5080305@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:32426 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596AbYDBLmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 07:42:17 -0400
Received: by an-out-0708.google.com with SMTP id d31so676609and.103
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 04:42:16 -0700 (PDT)
In-Reply-To: <47F35933.5080305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-04 at 12:00 +0200, Patrick McHardy wrote:

> No, in the case of events its supposed to be set to the pid of the
> socket that caused the event. Check out qdisc_notify() or rtmsg_ifa()
> for example.

nod - however, there is inconsistency;
for example if rtmsg_ifa() was in the code path of something invoked by
ioctl, the pid of the event will be 0. Alexey almost chewed my head off
when i tried to change that. His (valid) explanation was, if iirc:
a) that the pid belonged to the source - and 0 means "kernel". 
b) The pid could also be some negative number (even in qdisc_notify) if
you have multiple netlink sockets in one process (resolvable if you
getname())
c) what happens when processid goes to > 32-bit?

> nlmsg_seq is already used by userspace to match responses to requests,
> so that probably wouldn't work very well.

True, and thats what made me suggest earlier that if i had two sockets
in my app, one listening and the other sending (the way quagga does for
example), and that the app has a setting which says "all my netlink
messages to the kernel would have sequence 0x1234" - then the listening
socket could be told to set bpf to filter out any events with sequence
0x1234. This overcomes all of #a, #b and #c above but i admit it is
equally weak as using pids because it relies on the fact that only one
app is targeting something in the kernel with sequence 0x1234. You could
do it if you owned the box.
As one step further - route messages "proto" field on the other hand
overcomes that challenge of multiple applications ambiguity. of course
this has other challenges as well (ex: several apps claiming to be zebra
or if you intentionaly want to run multiple quaggas for VRs but wanted
to distinguish who added the route).

cheers,
jamal

