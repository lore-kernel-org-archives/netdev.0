From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH] net: Cache align dst refcnt
Date: Tue, 17 Dec 2013 10:47:11 -0800
Message-ID: <1387306031.19078.286.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312171013050.5720@tomh.mtv.corp.google.com>
	 <1387304951.19078.282.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f169.google.com ([209.85.161.169]:44844 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332Ab3LQSrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 13:47:18 -0500
Received: by mail-gg0-f169.google.com with SMTP id f4so280172ggn.28
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 10:47:17 -0800 (PST)
In-Reply-To: <1387304951.19078.282.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 10:29 -0800, Eric Dumazet wrote:
> On Tue, 2013-12-17 at 10:15 -0800, Tom Herbert wrote:
> > ipv4_dst_check is coming up very high in perf top for TCP_RR tests and
> > it really is not doing much interesting. Looks like we have false
> > sharing with dst->refcnt. This patch cache aligns refcnt. There were
> > already some comments in the code that refcnt needs to be cache aligned.
> > 
> > Signed-off-by: Tom Herbert <therbert@google.com>
> > ---
> >  include/net/dst.h | 11 +++--------
> >  1 file changed, 3 insertions(+), 8 deletions(-)

BTW, this dst refcount dirtying is because of netperf using blocking
reads, enabling prequeuing (assuming /proc/sys/net/ipv4/tcp_low_latency
is 0)

And the rx dst is shared by all cpus, if you use concurrent netperfs all
coming from one particular source.

This could be solved (if we really care about this case on real
workloads) by making nh_rth_input a per cpu var, as we did for
nh_pcpu_rth_output
