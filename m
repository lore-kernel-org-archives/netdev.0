From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 13:21:43 +0100
Message-ID: <46012357.2030701@trash.net>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.885191779@lsx.localdomain> <4600B828.1050801@trash.net> <20070321114522.GR521@postel.suug.ch> <46011FBF.90409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41472 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbXCUMVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 08:21:54 -0400
In-Reply-To: <46011FBF.90409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Thomas Graf wrote:
> 
>>* Patrick McHardy <kaber@trash.net> 2007-03-21 05:44
>>
>>
>>>This looks like it would break nfnetlink, which appears to be
>>>using 0 as smallest message type.
>>
>>
>>It shouldn't do that, the first 16 message types are reserved
>>for control messages.
> 
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


Seems like we're lucky, nfnetlink encodes the "subsystem ID"
in the upper 8 bits of the message type and uses 1 as the
smallest ID:

/* netfilter netlink message types are split in two pieces:
 * 8 bit subsystem, 8bit operation.
 */

#define NFNL_SUBSYS_ID(x)       ((x & 0xff00) >> 8)
#define NFNL_MSG_TYPE(x)        (x & 0x00ff)

#define NFNL_SUBSYS_NONE                0
#define NFNL_SUBSYS_CTNETLINK           1
#define NFNL_SUBSYS_CTNETLINK_EXP       2
#define NFNL_SUBSYS_QUEUE               3
#define NFNL_SUBSYS_ULOG                4
#define NFNL_SUBSYS_COUNT               5



So this should work fine.

