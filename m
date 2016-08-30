From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Tue, 30 Aug 2016 15:31:55 +0200
Message-ID: <20160830153155.702868f5@redhat.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
        <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
        <20160829103047.3968a4d8@redhat.com>
        <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
        <20160829153905.50066865@redhat.com>
        <20160829175509.7ed19b89@redhat.com>
        <09886285-aeae-625d-9d0e-bec1c1944efe@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, brouer@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751873AbcH3NcC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 09:32:02 -0400
In-Reply-To: <09886285-aeae-625d-9d0e-bec1c1944efe@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2016 08:13:15 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 16-08-29 11:55 AM, Jesper Dangaard Brouer wrote:
> > tc filter add dev mlx5p2 parent ffff: prio 4 protocol ip u32 match ip protocol 17 0xff match udp dst 9 0xffff flowid 1:1 action  
> 
> Syntax is a little more convoluted  than that ;->. Try:
> 
> sudo tc filter add dev eth0 parent ffff: prio 4 protocol ip u32 \
> match ip protocol 17 0xff \
> match ip dport 1900 0xffff \
> flowid 1:1 \
> action drop

I think I figured out why, match "udp dst" does not work.  It seems to
depend on "nexthdr+0" which is an implicit variable, that for unknown
reasons are not set in my original rule (above).

Before you suggestion I managed to match the udp port by manually
defining the offset, assuming an IP-header is 20 bytes (no-options),
like:

tc filter add dev $device parent ffff: prio 4 protocol ip \
	u32 \
	match ip protocol 17 0xff \
	match udp dst $udp_port 0xffff at 21\
	flowid 1:1 \
	action drop

You solution with "ip dport" also works, but man[1] tc-u32(8) also have
a warning about "ip dport" size assumptions...

Updated my script to use "u32 match ip port":
 https://github.com/netoptimizer/network-testing/commit/6449f6beb4d2

> Note, this will be more cycles than drop all.

Yes, that is the point ;-) XDP also does header parsing...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] http://man7.org/linux/man-pages/man8/tc-u32.8.html#SELECTORS
