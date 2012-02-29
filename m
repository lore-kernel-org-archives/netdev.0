From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: ingress filter not matching on bonded interface
Date: Tue, 28 Feb 2012 22:32:07 -0500
Message-ID: <1330486327.4671.78.camel@denise.theartistscloset.com>
References: <1330451524.4671.71.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:52525 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755192Ab2B2DcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 22:32:17 -0500
In-Reply-To: <1330451524.4671.71.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-28 at 12:52 -0500, John A. Sullivan III wrote:
> Hello, all.  We are delighted to finally have a functioning adaptive
> traffic shaping system for 95th percentile billing except for one very
> serious issue.  For some reason, our ingress filter to redirect to an
> IFB interface is not working on a bonded interface.  It does appear to
> work on a non-bonded interface.
> 
> Here are the stats on the test system:
> root@testswitch01:/usr/local/sbin# tc -s filter show dev eth1 parent ffff:
> filter protocol ip pref 1 u32
> filter protocol ip pref 1 u32 fh 800: ht divisor 1
> filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 terminal flowid ???  (rule hit 1960 success 1960)
>   match 00000000/00000000 at 0 (success 1960 )
>         action order 1: mirred (Egress Redirect to device ifb0) stolen
>         index 17 ref 1 bind 1 installed 2318 sec
>         Action statistics:
>         Sent 609472 bytes 1960 pkt (dropped 0, overlimits 0 requeues 0)
>         rate 0bit 0pps backlog 0b 0p requeues 0
> 
> Note the rule hit / rule match.
> 
> Here are the stats from production running the same scripts:
> [root@fw ~]# tc -s filter show dev bond3 parent ffff:
> filter protocol ip pref 1 u32
> filter protocol ip pref 1 u32 fh 800: ht divisor 1
> filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0  (rule hit 61596 success 0)
>   match 00000000/00000000 at 0 (success 61596 )
>         action order 1: mirred (Egress Redirect to device ifb0) stolen
>         index 2 ref 1 bind 1 installed 2185 sec used 2185 sec
>         Action statistics:
>         Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>         rate 0bit 0pps backlog 0b 0p requeues 0
> 
> Note zero success on the rule and we are not seeing traffic in the
> associated classes.
> What do we need to do to do ingress shaping on a bonded interface? We
> tried placing the filter on the physical interfaces but then the rules
> were not hit at all.
> 
> Here is the pertinent portion of the script:
> # Redirect traffic into the IFB interfaces
> # Egress
> 	c=1
> 	for IF in ${DIFS} ${MIFS} ${VIFS}
> 	do
> 		${TC} filter replace dev ${IF} parent ${c}:0 protocol ip prio 1 u32 match u8 0 0 flowid ${c}:1 action mirred egress redirect dev ${EIFB}
> # Ingress
> 		${TC} qdisc replace dev ${IF} ingress
> 		${TC} filter replace dev ${IF} parent ffff: protocol ip prio 1 u32 match u8 0 0 action mirred egress redirect dev ${IIFB}
> 		((c++))
> 	done
> 
> I'm honestly not sure if the issue is the bonded interface but that is
> the one difference which leaps out to me.  I suppose it could be our
> kernel or iproute versions.  This firewall is running kernel 2.6.30.5 on
> CentOS 5.7 and iproute-2.6.18-11.el5.  Any known issues?  Thanks - John
> 
<snip>
The problem appears to be not specifying a flowid.  We did not need to
do so for the ingress filter under Debian Squeeze but it appears we do
under CentOS 5.7.  Making the rule:
${TC} filter replace dev ${IF} parent ffff: protocol ip prio 1 u32 match u8 0 0 flowid ${c}:0 action mirred egress redirect dev ${IIFB}
worked.

Our final, hopefully, problem is trying to use multiple linked filters.
I'll post that under a separate thread - John
