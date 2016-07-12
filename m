From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 08:44:17 -0400
Message-ID: <20160712084417.4ca31962@gandalf.local.home>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
	<20160711120814.504c20cb@gandalf.local.home>
	<20160712083837.GE1884@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0238.hostedemail.com ([216.40.44.238]:59812 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751179AbcGLMo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 08:44:26 -0400
In-Reply-To: <20160712083837.GE1884@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2016 10:38:37 +0200
Jiri Pirko <jiri@resnulli.us> wrote:


> Hmm, I'm trying to make it work this was but it seems to be a bit more
> complicated. I did not find any code doing this (having the tracepoint
> compiled in or not) so I cannot copy&paste the solution.
> 
> The problem is that trace_devlink_hwmsg is included from
> include/trace/events/devlink.h when devlink is on and from
> include/net/devlink.h. Odd but ok.
> 
> I cannot include include/trace/events/devlink.h in include/net/devlink.h
> because include/net/devlink.h is included in include/trace/events/devlink.h
> 
> So I have to directly include include/trace/events/devlink.h from mlxsw
> driver (trace caller). But when devlink is not compiled in, trecepoint
> is not created and I'm getting errors.
> 
> I see no easy way our of this other than the wrapper function I was
> originally using. Seem simple and elegant.

No. You missed my solution.

Any user of trace_devlink_hwmsg() should directly include
trace/events/devlink.h. That's what all other trace users do. They
include the trace file header.

I said in that header do:


#if IS_ENABLED(CONFIG_NET_DEVLINK)

#undef TRACE_SYSTEM
#define TRACE_SYSTEM devlink

#if !defined(_TRACE_DEVLINK_H) || defined(TRACE_HEADER_MULTI_READ)
#define _TRACE_DEVLINK_H

#include <linux/device.h>
#include <net/devlink.h>
#include <linux/tracepoint.h>

[..]

#endif /* _TRACE_DEVLINK_H */

/* This part must be outside protection */
#include <trace/define_trace.h>

#else /* CONFIG_NET_DEVLINK */
static inline void trace_devlink_hwmsg(const struct devlink *devlink,
				       bool incoming, unsigned long type,
				       const u8 *buf, size_t len)
{
}
#endif


-- Steve
