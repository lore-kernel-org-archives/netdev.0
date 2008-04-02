From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 14:12:43 -0400
Message-ID: <1207159963.4463.126.camel@localhost>
References: <1207000143.4424.167.camel@localhost>
	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>
	 <47F35933.5080305@trash.net> <20080402112103.GB20815@postel.suug.ch>
	 <1207137667.4451.143.camel@localhost> <47F37762.2030705@trash.net>
	 <1207139106.4451.155.camel@localhost> <47F38002.70005@trash.net>
	 <1207141852.4451.181.camel@localhost>
	 <20080402142834.GE20815@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:4973 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbYDBSMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 14:12:52 -0400
Received: by an-out-0708.google.com with SMTP id d31so712941and.103
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 11:12:51 -0700 (PDT)
In-Reply-To: <20080402142834.GE20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-04 at 16:28 +0200, Thomas Graf wrote:

> I think this is over the top. The netlink port already provides good
> means to retrieve information about the originator of a netlink message.

netlink is easier on the events. 
What needs resolving imo is the ioctl or /proc, sysfs etc. 
For both cases one needs to worry about the how such fields are set.

> An additional genl interface which would resolve a netlink port to a
> a process id / process name would be very helpful though.

An out of band genl could be used for the name serving. I think it may
make it easier if such name serving was centralized as opposed to per
subsystem - but the object setting would be per subsystem.

> If you want to keep track of netlink processes which have already closed
> the socket then a userspace daemon which subscribes to all groups and
> keeps a log of netlink port plus eventually message sequence numbers
> would be a better solution IMHO. The daemon could be used to log netlink
> events in general and even have triggers to invoke commands upon certain
> events.

Keeping track of all events will pose a scaling issue imo.
But it's not so much keeping track of apps which have closed their
sockets as it is to reduce the cost of recovery. 
The names are not supposed to change over re-incarnations and there
arent that many of them. There may be multiple instances of the same
name (multiple quaggas for example) - but thats a separate discussion.
If you look at routing and defined names, i think there about 14 defined
todate in the kernel and hardly a handful are used by any router at a
time. For this reason I suggest storing the names in the kernel.

> However, I'm positive to the idea of storing the netlink port on a per
> object basis. It would be nice to know which application is responsible
> for the creation of certain qdiscs without having to listen to events.

indeed. A useful list for the field is:
1) aesthetics - example: ive always toasted to the output of ip route ls
because i can see nicely who added the route
2) debugging - example: i can debug easier routing daemons by seeing who
added the route
3) filtering - example: Stephen trying to get quagga to scale better by
filtering unnecessary events. But i should also be able to do a GET to a
subsystem with whodunnit=ZEBRA and get only those etc.

There are other peripheral benefits like the cleanup/recovery/graceful
restart comment i made earlier.

> We could define the netlink port as follows to cover both netlink and
> non netlink applications:
> 
>   port identifier (10 bits) + process id (22 bits)
> 
> A special value for the port identifier is defined (e.g. all zeros) which
> specifies that the netlink port is really a ioctl based application. This
> way we can encode the process id for both netlink and ioctl, distinguish
> between them and support 1023 netlink sockets per application.


If all you are going to tell me is that "this was caused by ioctl", then
thats insufficient. If all you are going to tell me is "this was caused
by an ioctl from a process id 12345" then thats also not good enough
because the process maybe transient(example ifconfig setting of an IP
address). What i need to know eventually is "this was caused by
ifconfig". That information may be reached by just giving me what you
call a "port" above and i do a name resilution which tells me
"ifconfig". nlmsgpid is just too ambigous to be the "port".

my 1.9cents.

cheers,
jamal

