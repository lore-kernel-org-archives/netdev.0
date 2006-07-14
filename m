From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 08/10] MLSXFRM: Add security context to acquire messag
	es using PF_KEY
Date: Thu, 13 Jul 2006 20:05:09 -0400
Message-ID: <36282A1733C57546BE392885C06185920138E224@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	tjaeger@cse.psu.edu, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:41148 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161144AbWGNAHO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 20:07:14 -0400
To: James Morris <jmorris@namei.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This seems problematic in that it's not a general solution 
> and depends 
> > always on hooking in at all of the right places in every protocol.  
> > Adding a bunch of hooks to protocol-specific code is what 
> got us in trouble 
> > with the initial LSM submission.
> >
> > What about using secmark and connection tracking for this, instead?
> 
> 
> I did get a reply from Venkat but can't find it in the 
> archives, so it may 
> have been off-list?
> 
> IIRC, the outgoing netfilter hook is in the wrong location.
> 
> Venkat, please clarify.

(added item 3 below since last time; rest slightly modified)

1. By the time we are in secmark (outbound), the xfrm(s) will already
   been chosen and the ip packet labeled (NetLabel).

2. Secmark can't be used for the multi-level process case since data at
   different levels can be written onto the same socket by a
trusted/privileged
   process.

3. As for secmark and connection tracking, we would indeed end up using
   this label (the one assigned by secmark on the inbound) when I do the
   sid-reconciliation patch (which I am planning to work on next); the
   hooks in the protocol-specific code, proposed in this patch will end up
   doing the job of carrying over the secmark label from the incoming packet
   onto the response (in cases such as timewait acks and such where we don't
   have any other source of a label for the outbound packet).

Secmark serves primarily as a flow control point in our new design (both
inbound
and outbound) and secondarily as a labeling mechanism for the inbound
packets in
the absence of an explicit label coming in with the packet.

As for the "right places" in the protocol code, there's only one
"standard and intuitive" place, which is where a flow is defined.
We are just asking that they "label" the flow, that too, only if
they desire to use multi-labeled communication using that protocol.
Hopefully the secid.txt doc will aid in this.

Typically, I suspect the developers will just ignore the sid (which
should be OK; it should then be just a matter of having the right policy
for the single-labeled communication). It would then fall to one of us
to label the flows as and when we desire to use those protos for
multi-labeled communication. I have sought help from Joy Latten and others
at IBM in testing to verify that this assertion is true in relation to
the above protos.
