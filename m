From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Flows! Offload them.
Date: Sun, 1 Mar 2015 09:05:47 -0500
Message-ID: <20150301140547.GB31578@neilslaptop.think-freely.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <20150226133326.GC23050@casper.infradead.org>
 <54EF3A78.9020507@intel.com>
 <20150226201635.GA366@hmsreliant.think-freely.org>
 <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
 <20150227012239.GB8847@neilslaptop.think-freely.org>
 <20150227084141.GA17240@casper.infradead.org>
 <E4CD12F19ABA0C4D8729E087A761DC35067DC283@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	"joestringer@nicira.com" <joestringer@nicira.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"shrijeet@gmail.com" <shrijeet@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43121 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbbCAOHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 09:07:01 -0500
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067DC283@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 01, 2015 at 09:36:43AM +0000, Arad, Ronen wrote:
> 
> 
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> >Behalf Of Thomas Graf
> >Sent: Friday, February 27, 2015 12:42 AM
> >To: Neil Horman
> >Cc: Simon Horman; Fastabend, John R; Jiri Pirko; netdev@vger.kernel.org;
> >davem@davemloft.net; andy@greyhouse.net; dborkman@redhat.com;
> >ogerlitz@mellanox.com; jesse@nicira.com; jpettit@nicira.com;
> >joestringer@nicira.com; jhs@mojatatu.com; sfeldma@gmail.com;
> >f.fainelli@gmail.com; roopa@cumulusnetworks.com; linville@tuxdriver.com;
> >shrijeet@gmail.com; gospo@cumulusnetworks.com; bcrl@kvack.org
> >Subject: Re: Flows! Offload them.
> >
> >Blind random offload of some packets is better than nothing but knowing
> >and having control over which packets are offloaded is essential. You
> >typically don't want to randomly give one flow priority over another ;-)
> >Some software CPUs might not be able to handle the load. I know what
> >you mean though and as long as we allow to disable and overwrite this
> >behaviour we are good.
> >
> 
> Random offloading of flows does not preserve policy in general.
> For example let's consider two flows A.B.C.0/24 and A.B.C.D with the more
> specific rule has higher priority.
> If only the first rule is offloaded to HW, packets matched by the second
> rule will not be processed as expected by the user.
> Deciding which flow could be offloaded is an optimization decision that
> is better handled outside of the kernel. 
>   
Regarding the description of offload:
Random is I think a improper term here.  There is nothing random about flow
offload.  There is only the reality of needing to select which rules to offload,
as it is inevitable that hardware dataplane capacity won't/can't match that of
software limits.  All we can do is select which of those flows are offloaded.
When dealing with offload in the context of an existing sofware function, the
constraints of selecting which rules those are become fairly clear.  For example
with routing:
1) More specific rules get offloaded first
2) on overflow, you replace a rule that conforms to a pre-packaged policy (ex.
LRU), and iff it doesn't violate (1)
Theres nothing random about that.  The selection policy can make replacement as
deterministic as you like (though if you're more interested in just offloading
functionality, determinism of rules is less important, than just optimizing the
performance of the offloaded function within the above constraints).

Regarding offload selection:
I disagree.  you're correct when the key match is a multiple word tuple that has
no real context with in the kernel, but for the case you describe (l3
forwarding), the policy can be made fairly clearly.  All you need to do is
offload the more specific rule first.  Thats it.  If that doesn't give you the
offload performance you're looking for because theres not space for both rules
in the hw dataplane, too bad, thats the limitation of doing a kernel-function
mirroring to the hardware.  Hopefully that will get better as hardware dataplane
capacity improves.  Until then, thats what Johns Flow API is for.  It should
live in parallel with such a functional offload, so that if those limitations
are unacceptable to you, you can go off the reservation, and customize the
hardware behavior.

Neil

> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
