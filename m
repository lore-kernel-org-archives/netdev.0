From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC 0/2] Interface for TCP Metrics
Date: Thu, 23 Aug 2012 08:22:35 -0700
Message-ID: <20120823082235.27c057f6@nehalam.linuxnetplumber.net>
References: <1345734105-28328-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60041 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932396Ab2HWPWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 11:22:54 -0400
In-Reply-To: <1345734105-28328-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 18:01:43 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> 	This patchset contains 2 patches, one for kernel
> and one for iproute2. We add DUMP/GET/DEL support for
> genl "tcp_metrics" and minimal support for filtering
> by address prefix and family in user space.
> 
> 	I tested show/del/flush, filtering by family, prefix,
> output for metrics such as rtt, rttvar, cwnd, ssthresh (after
> modifying route). I didn't tested output for fast open.
> 
> 	May be some corrections in output can be desired.
> 
> 	The kernel patch has some parts to check:
> 
> - in tcp_metrics_nl_cmd_del I'm trying to flush all addresses
> with single request, eg. when no family, address or other
> selectors are provided. I use some arbitrary counter sync_count
> to force memory to be freed in parts by using synchronize_rcu,
> note that we are under genl_mutex, so may be this is bad idea
> to delay other genl users? My idea was to avoid many commands
> on "flush all", may be we should trigger flush by using some
> other mechanism that is pernet? And I don't know how to test
> it properly without large cache.
> 
> - This function now uses rcu_dereference_protected, someone
> should check if these lockdep checks are correct. I enabled
> lockdep in config and don't see any warnings.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Some of netlink API comments:

1. My preference is to not make it so granular.
   I.e make things like RTT a structure with value and variance
   rather than lots of independent objects.

2. Make sure netlink API is symmetric. Get should report all
   values and Set should accept the same values (but ignore
   if value can not be modified).

3. Try and make ip command output invertable, as in what you
   print is close to what ip command arguments are.

4. What about monitoring changes?
