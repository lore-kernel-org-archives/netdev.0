From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: genetlink misinterprets NEW as GET
Date: Thu, 06 Jan 2011 14:48:31 +0100
Message-ID: <4D25C82F.4010306@netfilter.org>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/11 03:14, Jan Engelhardt wrote:
> Hey there,
> 
> 
> I can't really say whether it's genetlink or netlink to blame,
> but I noticed that a request with
> 
> 	nlmsg_flags = NLM_F_CREATE | NLM_F_EXCL
> 
> to a genl-registered component can return -EOPNOTSUPP because it does 
> not have a dumpit function defined in struct genl_ops. Make sense?
> Not at first sight at least.
> include/linux/netlink.h has this nice anecdote:
> 
> 	/* Modifiers to GET request */
> 	#define NLM_F_ROOT      0x100
> 	#define NLM_F_MATCH     0x200
> 	#define NLM_F_ATOMIC    0x400
> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
> 	
> 	/* Modifiers to NEW request */
> 	#define NLM_F_REPLACE   0x100
> 	#define NLM_F_EXCL      0x200
> 	#define NLM_F_CREATE    0x400
> 	#define NLM_F_APPEND    0x800
> 
> Except there is nothing that declares a particular Netlink message
> as "GET" or "NEW". Subsequently, genetlink chokes:
> 
> 	if (nlh->nlmsg_flags & NLM_F_DUMP)
> 		if (ops->dumpit == NULL)
> 			return -EOPNOTSUPP;
> 
> Because NLM_F_CREATE | NLM_F_EXCL == NLM_F_DUMP.
> That, of course, is absolutely bogus.

Hm, NLM_F_CREATE | NLM_F_EXCL is not equal to NLM_F_DUMP.

You must be hitting -EOPNOTSUPP elsewhere.

> [N.B.: I am also wondering whether
> 	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
> may have been desired, because NLM_F_DUMP is composed of two bits.]

Someone may include NLM_F_ATOMIC to a dump operation, in that case the
checking that you propose is not valid.
