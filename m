From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Mon, 19 Dec 2011 11:53:28 -0500
Message-ID: <1324313608.4187.19.camel@denise.theartistscloset.com>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:63788 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab1LSQxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 11:53:32 -0500
In-Reply-To: <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-12-18 at 11:55 -0800, Stephen Hemminger wrote:
> On Sun, 18 Dec 2011 00:12:12 -0500
> "John A. Sullivan III" <jsullivan@opensourcedevel.com> wrote:
> 
> > Since netem appears to be classless, we realized we would need to
> > replace the SFQ on each leaf with netem which we really didn't want to
> > do - not only to not lose SFQ but because we didn't want to maintain the
> > netem parameters on each leaf.  So, we activated our ifb1 interface,
> > placed netem on it and redirected all the egress traffic to ifb1.  Taht
> > worked fine.
> 
> Current versions of netem can take one class.
<snip>
Thanks but how would that work? For example, I assume we could not send
netem processed packets to SFQ because SFQ is classless.  We tried
anyway and got:

root@testswitch01:~# tc class add dev ifb0 parent 1201: classid 1202 sfq
perturb 60
Error: Qdisc "sfq" is classless.
root@testswitch01:~# tc qdisc add dev ifb0 parent 1201: handle 1202 sfq
perturb 60
RTNETLINK answers: Operation not supported

1201 is a netem qdisc at the end of hfsc.

Not being quite sure what you meant, we thought we experiment before
asking so we tried to attach an hfsc class to the netem qdisc.  We
didn't think it would work and it didn't:

root@testswitch01:~# tc qdisc add dev eth3 root handle 7 netem delay
25ms 5ms distribution normal loss 0.1% 30%
root@testswitch01:~# tc class add dev eth3 parent 7: classid 7:1 hfsc sc
rate 1490kbit ul rate 1490kbit
RTNETLINK answers: Invalid argument

So we tried adding the hfsc qdisc first:
root@testswitch01:~# tc qdisc add dev eth3 parent 7: handle 7:1 hfsc
default 70
RTNETLINK answers: File exists

Then, just for kicks, we tried adding an SFQ qdisc in case the problem
with the previous attempts was that the netem qdisc was not at the top
level:

root@testswitch01:~# tc qdisc add dev eth3 parent 7: handle 7:1 sfq
perturb 60
RTNETLINK answers: File exists

So I'm still not sure how we can do anything other than stick netem on
the end of one of our branches or at root.  Thanks - John
