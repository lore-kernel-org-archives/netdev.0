From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 14:57:34 +0200
Message-ID: <20160712125734.GF6844@nanopsycho.orion>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
 <20160711120814.504c20cb@gandalf.local.home>
 <20160712083837.GE1884@nanopsycho.orion>
 <20160712084417.4ca31962@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34064 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbcGLM5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 08:57:37 -0400
Received: by mail-wm0-f68.google.com with SMTP id w75so1954861wmd.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 05:57:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160712084417.4ca31962@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 12, 2016 at 02:44:17PM CEST, rostedt@goodmis.org wrote:
>On Tue, 12 Jul 2016 10:38:37 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>
>> Hmm, I'm trying to make it work this was but it seems to be a bit more
>> complicated. I did not find any code doing this (having the tracepoint
>> compiled in or not) so I cannot copy&paste the solution.
>> 
>> The problem is that trace_devlink_hwmsg is included from
>> include/trace/events/devlink.h when devlink is on and from
>> include/net/devlink.h. Odd but ok.
>> 
>> I cannot include include/trace/events/devlink.h in include/net/devlink.h
>> because include/net/devlink.h is included in include/trace/events/devlink.h
>> 
>> So I have to directly include include/trace/events/devlink.h from mlxsw
>> driver (trace caller). But when devlink is not compiled in, trecepoint
>> is not created and I'm getting errors.
>> 
>> I see no easy way our of this other than the wrapper function I was
>> originally using. Seem simple and elegant.
>
>No. You missed my solution.
>
>Any user of trace_devlink_hwmsg() should directly include
>trace/events/devlink.h. That's what all other trace users do. They
>include the trace file header.
>
>I said in that header do:
>
>
>#if IS_ENABLED(CONFIG_NET_DEVLINK)
>
>#undef TRACE_SYSTEM
>#define TRACE_SYSTEM devlink
>
>#if !defined(_TRACE_DEVLINK_H) || defined(TRACE_HEADER_MULTI_READ)
>#define _TRACE_DEVLINK_H
>
>#include <linux/device.h>
>#include <net/devlink.h>
>#include <linux/tracepoint.h>
>
>[..]
>
>#endif /* _TRACE_DEVLINK_H */
>
>/* This part must be outside protection */
>#include <trace/define_trace.h>
>
>#else /* CONFIG_NET_DEVLINK */
>static inline void trace_devlink_hwmsg(const struct devlink *devlink,
>				       bool incoming, unsigned long type,
>				       const u8 *buf, size_t len)
>{
>}
>#endif


Okay. That looks good. Thanks!


>
>
>-- Steve
