From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Sat, 27 May 2006 12:45:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605271223390.12872@d.namei>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:54440 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964913AbWE0QpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 12:45:18 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060527134629.GA16306@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 27 May 2006, Evgeniy Polyakov wrote:

> > connector (the w1 driver) to use generic Netlink?
> 
> Process accounting, CIFS and OFS netfilter module use it too.

w1 is the only in-tree thing I can see using any of the exported connector 
symbols.  I can see that cifs has included a connector header but not how 
it's using the API.

> As long as quite a lot of out of the tree projects.

Out of tree code does not count.

> 
> > I suspect that some of the nfnetlink infrastructure can be used more 
> > generically, and that a simple API for the common case of kernel->user 
> > event notifications could be also be provided.
> >
> > Thoughts?
> 
> I would like to ask, how LSM labeling supposed to work with encapsulated
> netlink traffic. 

This is the problem I'm trying to solve in the general case.

Have a look at security/selinux/nlmsgtab.c, which includes lookups table 
for Netlink messages vs. permissions.

Currently this only covers plain netlink families, and should eventually 
work ok for encapsulated protocols as long as we know about them and can 
identify them (e.g. the genl->family field).

A further possibility is allowing netfilter protocols to register their 
own permission tables.

One of the problems is that different Netlink protocols bury their 
commands at different levels, so the SELinux code has to know how how deep 
to dig (and then do the digging) to determine exactly which command is 
being called.

e.g. TIPC only registers one genl_ops and embeds all commands inside 
TIPC_GENL_CMD, while unencapsulated netlink protocols use the nlmsg_type 
field of the actual netlink header.

It's inconsistent.

Actually, if people are going to use genl this way, perhaps we can get rid 
of dynamic genl_ops registration.  Alternatively, require that modules use 
a different genl_ops for each type of command (not possible now for TIPC 
as it's already in-tree).


> Will SELinux (for example) have some rules to allow w1 packets and block 
> other for the same socket type?

Yes, once userspace policy is updated to include support for the w1 
netlink socket, otherwise it will fall through to generic netlink perms.


> And what happens when the same socket start to send packets with
> different strucutre or some new protocol will be added? 
> Should it consult with SELinux so it updated it's security processing code?

This is where allowing protocols to register their own message perms would 
make things work automatically: add a new message type and then signify 
whether it's read, write or readpriv.


> Or LSM supposed to work only on top of socket numbers (which could be
> the best) and just control "raw" netlink messages?

It can work at that level, too, by falling back to generic netlink perms.


- James
-- 
James Morris
<jmorris@namei.org>
