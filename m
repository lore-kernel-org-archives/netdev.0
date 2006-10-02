From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 14:39:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610021429400.11840@d.namei>
References: <36282A1733C57546BE392885C0618592015CF4DE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Paul Moore <paul.moore@hp.com>,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:11232 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964852AbWJBSji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 14:39:38 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF4DE@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2006, Venkat Yekkirala wrote:

> This is indeed the "designed" and expected (for me) behavior.

This is a security hole.  SELinux denies all access by default, so the 
default behavior of this code is to allow all traffic to bypass IPsec.

You should not need to add a rule to 'allow' increased security.

> But I am
> beginning to see where this is perhaps NOT in line with the user
> expectation when the users have an IPSec policy rule that does NOT use
> labels.
> currently, EACH flow needing to use this rule MUST
> have SELinux policy "polmatch"ing the flow context (ftpd_t)
> to unlabeled_t (the implied in the absence of an explicit
> context on the IPSec policy rule) or the traffic would flow
> in clear text ("leaks" in user perception).

Plaintext leak is not a user perception, it's an absolute.

> What I propose we do is to do the polmatch check ONLY when
> there's an explicit label associated with the spd rule. Does
> this sound reasonable and correct in the larger SELinux context?

I think so.

> In cases where there's an explicit label on an spd rule like:
> 
> spdadd 192.168.4.79 192.168.4.78 any -ctx 1 1
> "system_u:object_r:labeled_ipsec_t:s2-s4"
> 	-P out ipsec
>         esp/transport//require;
> 
> spdadd 192.168.4.78 192.168.4.79 any -ctx 1 1
> "system_u:object_r:labeled_ipsec_t:s2-s4"
> 	-P in ipsec
>         esp/transport//require;
> 
> then the current behavior (prior to this proposed patch) would be the
> desired behavior, i.e., a polmatch denial in the SELinux module just
> means that the flow isn't expected to undergo IPSec xfrms. IOW, there's
> no need to propagate -EACCES all the way back up. We could still propagate
> errors other than -EACCES if we like.

This needs to be handled within SELinux as far as possible, and errors 
will generally need to be propagated back to the callers, as we don't know 
what other LSMs might do, and errors unrelated to access control can be 
returned.


- James
-- 
James Morris
<jmorris@namei.org>
