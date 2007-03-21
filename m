From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 13:25:17 +0100
Message-ID: <20070321122517.GT521@postel.suug.ch>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.885191779@lsx.localdomain> <4600B828.1050801@trash.net> <20070321114522.GR521@postel.suug.ch> <46011FBF.90409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47296 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752685AbXCUMY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 08:24:56 -0400
Content-Disposition: inline
In-Reply-To: <46011FBF.90409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-21 13:06
> Thomas Graf wrote:
> > * Patrick McHardy <kaber@trash.net> 2007-03-21 05:44
> > 
> >>This looks like it would break nfnetlink, which appears to be
> >>using 0 as smallest message type.
> > 
> > 
> > It shouldn't do that, the first 16 message types are reserved
> > for control messages.
> 
> 
> I'm afraid it does:
> 
> enum cntl_msg_types {
>         IPCTNL_MSG_CT_NEW,
>         IPCTNL_MSG_CT_GET,
>         IPCTNL_MSG_CT_DELETE,
>         IPCTNL_MSG_CT_GET_CTRZERO,
>         IPCTNL_MSG_MAX
> };
> 
> This is totally broken of course since it also uses netlink_ack(),
> netlink_dump() etc. :( Any smart ideas how to fix this without
> breaking compatibility?

Hmm... I think nfnetlink isn't even broken:

/* netfilter netlink message types are split in two pieces:
 * 8 bit subsystem, 8bit operation.
 */

#define NFNL_SUBSYS_ID(x)	((x & 0xff00) >> 8)
#define NFNL_MSG_TYPE(x)	(x & 0x00ff)

/* No enum here, otherwise __stringify() trick of
 * MODULE_ALIAS_NFNL_SUBSYS()
 * won't work anymore */
#define NFNL_SUBSYS_NONE 		0
#define NFNL_SUBSYS_CTNETLINK		1
#define NFNL_SUBSYS_CTNETLINK_EXP	2
#define NFNL_SUBSYS_QUEUE		3
#define NFNL_SUBSYS_ULOG		4
#define NFNL_SUBSYS_COUNT		5

A msg_type < 0x10 would just trigger a -EINVAL as no 0x0 subsystem
can ever be registered.
