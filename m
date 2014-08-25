From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH net-next 3/3] packet: make use of deferred TX queue
 flushing
Date: Mon, 25 Aug 2014 17:16:34 +0200
Message-ID: <20140825171634.180b5a07@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-4-git-send-email-dborkman@redhat.com>
	<20140825155402.2f2a03d7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Daniel Borkmann <dborkman@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932637AbaHYPQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 11:16:38 -0400
In-Reply-To: <20140825155402.2f2a03d7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2014 15:54:02 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Sun, 24 Aug 2014 15:42:18 +0200
> Daniel Borkmann <dborkman@redhat.com> wrote:
> 
> > This adds a first use-case of deferred tail pointer flushing
> > for AF_PACKET's TX_RING in QDISC_BYPASS mode.
> 
> Testing with trafgen.  I've updated patch 1/3 to NOT call mmiowb(),
> during this testing, see why in my other post.
> 
> trafgen cmdline:
>  trafgen --cpp  --dev eth5 --conf udp_example01.trafgen -V --cpus 1
>  * Only use 1 CPU
>  * default is mmap
>  * default is QDISC_BYPASS mode
> 
> BASELINE(no-patches): trafgen QDISC_BYPASS and mmap:
>  - tx:1562539 pps
> 
> With PACKET_FLUSH_THRESH=8, and QDISC_BYPASS and mmap:
>  - tx:1683746 pps
> 
> Improvement:
>  + 121207 pps
>  - 46 ns (1/1562539*10^9)-(1/1683746*10^9)
> 
> This is a significant improvement! :-)

I'm unfortunately seeing a regression, if I'm NOT bypassing the qdisc
layer, and still use mmap.  Trafgen have an option --qdisc-path for
this. (I believe most other solutions, don't set the QDISC_BYPASS
socket option)

trafgen command:
 # trafgen --cpp --dev eth5 --conf udp_example01.trafgen -V  --qdisc-path --cpus 1
 * still use mmap
 * choose normal qdisc code path via --qdisc-path

BASELINE(no-patches): trafgen using --qdisc-path and mmap:
 - tx:1371307 pps

(Patched): trafgen using --qdisc-path and mmap
 - tx:1345999 pps

Regression:
 * 25308 pps slower than before
 * 13.71 nanosec slower (1/1371307*10^9)-(1/1345999*10^9)

How can we explain this?!?

As can be deducted from the baseline numbers, the cost of the qdisc
path is fairly high, with 89.24 ns ((1/1562539*10^9)-(1/1371307*10^9)).
(This is a bit higher than I expected based on my data from:
http://people.netfilter.org/hawk/presentations/nfws2014/dp-accel-qdisc-lockless.pdf
where I measured it to be 60ns).

(Does this makes sense?):  Above results say we can save 46ns by
delaying tailptr updates.  But the qdisc path itself will add 89ns of
delay between packet, which is then too large to take advantage of the
tailptr win.  (not sure this explains the issue... feel free to come up
with a better explanation)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
