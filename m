From: Jan Engelhardt <jengelh@medozas.de>
Subject: genetlink misinterprets NEW as GET
Date: Tue, 4 Jan 2011 03:14:05 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:49496 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803Ab1ADCOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 21:14:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey there,


I can't really say whether it's genetlink or netlink to blame,
but I noticed that a request with

	nlmsg_flags = NLM_F_CREATE | NLM_F_EXCL

to a genl-registered component can return -EOPNOTSUPP because it does 
not have a dumpit function defined in struct genl_ops. Make sense?
Not at first sight at least.
include/linux/netlink.h has this nice anecdote:

	/* Modifiers to GET request */
	#define NLM_F_ROOT      0x100
	#define NLM_F_MATCH     0x200
	#define NLM_F_ATOMIC    0x400
	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
	
	/* Modifiers to NEW request */
	#define NLM_F_REPLACE   0x100
	#define NLM_F_EXCL      0x200
	#define NLM_F_CREATE    0x400
	#define NLM_F_APPEND    0x800

Except there is nothing that declares a particular Netlink message
as "GET" or "NEW". Subsequently, genetlink chokes:

	if (nlh->nlmsg_flags & NLM_F_DUMP)
		if (ops->dumpit == NULL)
			return -EOPNOTSUPP;

Because NLM_F_CREATE | NLM_F_EXCL == NLM_F_DUMP.
That, of course, is absolutely bogus.

[N.B.: I am also wondering whether
	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
may have been desired, because NLM_F_DUMP is composed of two bits.]
