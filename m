From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: 11 Sep 2004 15:59:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094932793.2344.82.camel@jzny.localdomain>
References: <20040910195003.GA13912@bougret.hpl.hp.com>
	 <20040910200644.GJ20088@postel.suug.ch>
	 <20040910201302.GA16556@bougret.hpl.hp.com>
	 <20040910202235.GK20088@postel.suug.ch>
	 <20040910203203.GA17078@bougret.hpl.hp.com>
	 <20040910204348.GL20088@postel.suug.ch>
	 <1094857082.1041.19.camel@jzny.localdomain>
	 <20040910231726.GP20088@postel.suug.ch>
	 <1094868070.1042.77.camel@jzny.localdomain>
	 <20040911134409.GA21181@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040911134409.GA21181@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-09-11 at 09:44, Thomas Graf wrote:
> * jamal <1094868070.1042.77.camel@jzny.localdomain> 2004-09-10 22:01
> > On Fri, 2004-09-10 at 19:17, Thomas Graf wrote:

> Possibly, I change everything the user requests me to do.
> 
> > Valid to receive the two updates i would think in that case.
> 
> That's not the problem, the problem is that you may receive
> more updates than requested changes. Let's assume you're changing
> the MTU using IFLA_MTU and it succeeds. dev_set_mtu will send
> out the first update, at the end the do_setlink will send
> out another update.

Ok, this doesnt sound right. 

> Changing MTU and ifname would result in 3 updates:
> 
>  1) RTM_NEWLINK with updated mtu (old name)
>
>  2) RTM_NEWLINK with mtu and name updated
>  3) same again as 2)
> 
> I personally have no problem with the current behaviour but maybe
> we should clean this up a bit.
> 
> Suggestion:
>  Send out a notify for every change we make. This can result
>  in 7 updates being sent out. It would allow the application
>  to see how far the kernel was successful quite easly or
>  do a revision control and switch back to older configurations.
> 

Not necessary to send all those updates. 
do_setlink was doing the right thing before your patch. It was
announcing the change of addresses (broadcast, etc). You introduced new
features which while related to link level have nothing to do with
address changes. So my suggestion is making your code the exception.
i.e something along the lines of:

addrchg = 1;

if (mtu/weight/name related)
	addrchng = 0;
if (!err & addrchang)
	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);

Also note, the semantics of netlink are all-or-nothing transaction. i.e
if one of the things requested for fails then you undo the rest. We can
probably loosely say that unles the ATOMIC flag is set you dont need to
undo that .. something to think about (summary is you probably dont want
to send progress update to user space unless the transaction is
successful; you however want to report progress of where failure happens
- as we are discussing at the moment in the error code thread).

cheers,
jamal
