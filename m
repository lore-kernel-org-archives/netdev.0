From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: Re: [RFC][PATCH][XFRM][0/5] extension for XFRM databases
Date: Fri, 02 Feb 2007 20:25:59 +0900
Message-ID: <20070202132129.E2EA.SHINTA@sfc.wide.ad.jp>
References: <20070201114339.E2BD.SHINTA@sfc.wide.ad.jp> <1170336273.3915.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:34546 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbXBBL0G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 06:26:06 -0500
In-Reply-To: <1170336273.3915.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, 01 Feb 2007 08:24:33 -0500
jamal <hadi@cyberus.ca> wrote:

> Hello,
> I think i may have understood your approach before but i am a little
> lost right now, so bear with me.

No problem.

> 
> Could we not achieve your goals by using (on XFRM at least)
> XFRM_MSG_UPDPOLICY  and XFRM_MSG_UPDSA ?

At the beginning, we consider whether the existing messages
(XFRM_MSG_UPDPOLICY and XFRM_MSG_UPDSA) can do the job.  But after
careful analysis, we reached to the conclusion that we need
something else.  Let me expand:

In the design phase, we sorted out the requirements as below:

(1) Overhead of userland <-> kernel interaction message exchange
    should be kept minimum.
(2) There should not be too much requirement for user application
    to leverage the feature (dynamic update of endpoint).  More
    specifically, we don't want to expect the user application to
    have detailed information of IPsec security association
    (i.e. SPI).
(3) There should not be negative impact on the existing software
    which is based on PF_KEYv2 (RFC2367).

Firstly, if we use the existing messages for updating SPD and SAD,
we simply need 2 pairs of request/response exchange between the
userland and kernel for updating a single endpoint.  This is not
ideal from the perspective of (1).

Secondly, we need to be careful about updating the endpoint address
because it may invoke unexpected signaling (ACQUIRE) to the user
application.  Imagine you update SPD and SAD sequentially while there
is an outbound flow going on.  The kernel may end up with triggering
the userland application by unexpected ACQUIRE message due to the
absence of SAD entry.  In order to avoid this problem, we need a sort
of atomic update of SPD and SAD entries.  XFRM_MSG_MIGRATE is designed
and implemented in a way that unexpected ACQUIRE would never occur.

Thirdly, we also need to pay attention to the PF_KEYv2 spec.
XFRM_MSG_UPDSA is derived from SADB_UPDATE message in PF_KEYv2.
According to the spec, the semantics of SADB_UPDATE is to add a new
security association with the information provided by previous
SADB_GETSPI message.  We think it's not a good idea to overload
the semantics of SADB_UPDATE message because it may confuse legacy
software from the perspective of (3).  Moreover, caller of
SADB_UPDATE should specify SPI, source address, and destination
address, which is a bit problematic from the perspective of (2).

>From the above reasons, we decided to extend XFRM/PF_KEYv2 for
dynamic update of the endpoint.  Please note that the mechanism is
useful not only for Mobile IPv6 but also for Mobile VPN scenario.

Does this make sense?


Regards,
Shinta

> 
> cheers, 
> jamal
> 
> On Thu, 2007-01-02 at 13:09 +0900, Shinta Sugimoto wrote:
> > Hello,
> > 
> > Let me issue a request for comments for the patch set developed by
> > the USAGI project.  The patch set aims to extend the XFRM framework
> > so that endpoint addresses in the XFRM databases, namely Could XFRM policy
> > and XFRM state can be dynamically updated according to a request from
> > user application.  This feature is required for Mobile IPv6 to follow
> > the security requirements specified in RFC3776.  More specifically,
> > the Mobile Node and Home Agent need to update the endpoint addresses
> > of the IPsec tunnel when the Mobile Node changes its attachment point
> > (Care-of Address) to the Internet.  The kernel also notifies userland
> > application via both Netlink and PF_KEY sockets so that user application
> > (e.g. IKE Daemon) could be informed of the updates appropriately.
> > More detailed information of motivation/rationale for this feature
> > can be found in the internet draft[1].
> > 
> > The patch set consists of following patches:
> > 
> > [1/5] [XFRM]: Extension to the XFRM framework for dynamic update of endpoint address(es)
> > [2/5] [XFRM]: User interface for handling XFRM_MSG_MIGRATE
> > [3/5] [XFRM]: CONFIG_XFRM_MIGRATE option
> > [4/5] [PFKEYV2]: Extension to the PF_KEYv2 framework for dynamic update of endpoint address(es)
> > [5/5] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option
> > 
> > Any comments/suggestions are appreciated.
> > Thank you very much.
> > 
> > [1]: http://www.ietf.org/internet-drafts/draft-sugimoto-mip6-pfkey-migrate-03.txt
> > 
> > 
> > Regards,
> > Shinta
> > 
> > 
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html



