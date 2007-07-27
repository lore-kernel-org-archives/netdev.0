From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Fri, 27 Jul 2007 15:47:06 -0400
Message-ID: <46AA4BBA.5060905@myri.com>
References: <200707201741.45079.ossthema@de.ibm.com> <46A785C2.9090708@myri.com> <200707271418.49781.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933638AbXG0Tra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 15:47:30 -0400
In-Reply-To: <200707271418.49781.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:

 > On Wednesday 25 July 2007 19:17, Andrew Gallatin wrote:

 >> 3) Padded frames.
 >>
 >> I may be missing something, but I don't see where you
 >> either strip padding from frames or reject padded frames.
 >> (see the pskb_trim_rcsum() in net/ipv4/ip_input.c:ip_rcv()
 >>
 > I think I missed something :-) Will fix that.
 > In lro_tcp_ip_check we check for the "SKB aggregation interface"
 > the skb->len against ip->tot_len. This catches padded frames as
 > eth_type_trans(skb, dev) reduces the length of the SKB.
 > However, the possible VLAN header is not taken into account.
 > And for the "receive in pages" interface a wrong length is passed
 > as argument as well.
 >
 > I'd suggest to reject padded frames for aggregation as we do now
 > (when bugs are fixed) and thus keep the code simple.
 > I guess that padded frames don't occur too often in high load
 > situations. If we detect a real performance issue we can still
 > change that later.

The one case where performance may be at issue is in aggregating Acks
on connections w/o TCP timestamps where a frame size of 54 bytes is
padded out to 60.  I did some very quick measurements using netperf
-tTCP_SENDFILE on the same athlons mentioned earlier using our 1.3.1
driver.  I see a roughly 8% CPU increase (~17% -> ~25%) when I disable
LRO (and hence Ack aggregation) on the sender.  This works out to an
increase in service demand from ~0.3 to ~0.44 according to netperf.
With LRO enabled, our counters show we're aggregating acks at a
roughly 3:1 ratio.  This is probably an optimization that can be done
later, but it is helpful.

This reminds me.. what would you think about adding some sort of
counters, ideally per-interface, to expose how well LRO is working?
At the simplest level, you could add them to the lro mgr struct and
let drivers export them via ethtool.  I think a central approach might
be more appropriate.  At any rate, I'd prefer the final
version to at least have counters to indicate how many packets were
aggregated, how many packets were flushed, and how many times we
failed to aggregate something due to insufficient net_lro_desc
descriptors.

Thanks again for taking the lead on this,

Drew
