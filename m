From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Doing specific RTM_GETLINK or RTM_GETADDR
Date: Thu, 27 Jun 2013 00:23:30 +0100
Message-ID: <20130626232330.GD1394@casper.infradead.org>
References: <1967300F-6CEE-4D0F-8889-0CBC32DD3CD8@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: libnl@lists.infradead.org, netdev@vger.kernel.org
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50338 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102Ab3FZXXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 19:23:32 -0400
Content-Disposition: inline
In-Reply-To: <1967300F-6CEE-4D0F-8889-0CBC32DD3CD8@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCed netdev as this is ultimatively a kernel issue

On 06/24/13 at 01:42pm, Philip Prindeville wrote:
> I couldn't find documentation that said specifically if one can do a NLM_F_REQUEST | NLM_F_MATCH on a specific ifindex for an RTM_GETLINK or RTM_GETADDR.
> 
> I'm running Fedora (3.9.4) but also some older versions including uClinux and 2.6.39 (embedded) where this needs to work as well.
> 
> Even the following trivial query:
> 
> 	msg = (struct nlmsghdr *) buf;
> 	memset(msg, 0, sizeof(*msg));
> 
> 	msg->nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
> 	msg->nlmsg_type = RTM_GETLINK;
> 	msg->nlmsg_flags = NLM_F_REQUEST | NLM_F_MATCH;
> 	msg->nlmsg_pid = 0;
> 	msg->nlmsg_seq = iter->seq++;
> 
> 	NLMSG_DUMP(msg, "send2");
> 
> 	info = (struct ifinfomsg *) NLMSG_DATA(msg);
> 	memset(info, 0, sizeof(*info));
> 
> 	info->ifi_family = AF_NETLINK;
> 	info->ifi_index = iter->ifindex;
> 
> 
> results in ALL of the interfaces being reported back (ditto for RTM_GETADDR). So if the NLM_F_MATCH flag doesn't control that, I don't understand what does.
> 
> Also, I was looking for documentation about (1) what version IFLA_AF_SPEC was introduced, and (2) how to parse it but I couldn't find that either.
> 
> If this isn't the correct place to ask, please let me know. 

This is a bug that dates back as long as Netlink exists. What
would be expected:

NLM_F_MATCH: Return single match
NLM_F_DUMP: Dump complete tree

The following still makes sense:
NLM_F_DUMP = (NLM_F_ROOT | NLM_F_MATCH)

The problem is this:
net/core/rtnetlink.c:   if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP)

So if either NLM_F_MATCH or NLM_F_DUMP is set we dump the complete
tree. I have classified this as bug when I saw it but there is not
much we can do. A lot of applications expect it to behave like that.
Changing it now might break a lot.

Workaround is to leave otu NLM_F_MATCH alltogether, that will
result in a single match.
