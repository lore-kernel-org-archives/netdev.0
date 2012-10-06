From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Filter matching problems
Date: Sat, 06 Oct 2012 12:30:25 -0400
Message-ID: <1349541025.18710.143.camel@denise.theartistscloset.com>
References: <1349459175.18710.112.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:51915 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712Ab2JFQa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2012 12:30:28 -0400
In-Reply-To: <1349459175.18710.112.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-05 at 13:46 -0400, John A. Sullivan III wrote:
> Hello, all.  Can anyone tell me why this filter does not match anything
> when I think it should match everything:
> 
> tc filter replace dev bond3 parent ffff: protocol ip prio 1 u32 match u8
> 0 0 action mirred egress redirect dev ifb0
> 
> I get:
> tc -s filter show dev bond3 parent ffff:
> filter protocol ip pref 1 u32
> filter protocol ip pref 1 u32 fh 800: ht divisor 1
> filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0
> (rule hit 1216169263 success 0)
>   match 00000000/00000000 at 0 (success 1216169263 )
>         action order 1: mirred (Egress Redirect to device ifb0) stolen
>         index 2 ref 1 bind 1 installed 11362879 sec used 11362879 sec
>         Action statistics:
>         Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>         rate 0bit 0pps backlog 0b 0p requeues 0
> 
> which I think is telling me I'm not getting any matches.  Here are more
> details.
> 
> 
> We are redirecting ingress into ifb0 and redirecting egress into ifb1
> (because several interfaces, e.g., OpenVPN tun devices) need the exact
> same traffic shaping.  We realize that we cannot place the ingress
> filter at ffff: and the egress filter at root as those appear to be
> treated as one and the same, i.e., the first match of those two filters
> will be used and the other will thus never see any packets.
> 
> To get around that problem, we inserted a priomap on the interface and
> apply the egress redirect filter on it's child like this:
> 
> tc qdisc replace dev bond3 root handle 1: prio bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> tc filter replace dev bond3 parent 1:0 protocol ip prio 1 u32 match u8 0 0 flowid 1:1 action mirred egress redirect dev ifb1
> tc qdisc replace dev bond3 ingress
> tc filter replace dev bond3 parent ffff: protocol ip prio 1 u32 match u8 0 0 action mirred egress redirect dev ifb0
> 
> So what have I mangled? Thanks - John
> 
<snip>
I believe I've solved it.  We were not specifying a flowid.  Debian
Squeeze in our test lab did not object but the production system in this
case is CentOS 5.7.  I am guessing the older tc did not like the missing
flowid.  We added flowid :1 and all started working.  I am a little
confused though.  What meaning does the flowid have on an ingress qdisc
and what is class 0:1? Thanks - John
