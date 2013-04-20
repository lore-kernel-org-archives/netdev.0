From: David Miller <davem@davemloft.net>
Subject: Re: net: fix incorrect credentials passing
Date: Fri, 19 Apr 2013 21:58:56 -0400 (EDT)
Message-ID: <20130419.215856.1499421731544629706.davem@davemloft.net>
References: <alpine.LFD.2.03.1304191826080.2455@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serge@hallyn.com, ebiederm@xmission.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965470Ab3DTB67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 21:58:59 -0400
In-Reply-To: <alpine.LFD.2.03.1304191826080.2455@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 19 Apr 2013 18:32:32 -0700 (PDT)

> Commit 257b5358b32f ("scm: Capture the full credentials of the scm 
> sender") changed the credentials passing code to pass in the effective 
> uid/gid instead of the real uid/gid.

Yep, that's exactly what happened, via a very twisty and winding road.

The helper cred_to_ucred(), which was created by commit
3f551f9436c05a3b5eccdd6e94733df5bb98d2a5 ("sock: Introduce
cred_to_ucred") seemed to be aimed at providing the semantics expected
by SO_PEERCRED, which does in fact want to use the effective UIDs and
GIDs.

The SO_PEERCRED side of this can be seen more clearly in commit
109f6e39fa07c48f580125f531f46cb7c245b528 ("af_unix: Allow SO_PEERCRED
to work across namespaces.")

The error begins when we try to use that helper in the SCM credentials
code.

Initially, cred_to_ucred() is what was used by scm_set_cred().  Then
it got changed in dbe9a4173ea53b72b2c35d19f676a85b69f1c9fe ("scm:
Don't use struct ucred in NETLINK_CB and struct scm_cookie.") which
continues the error by propagating the effective UID/GID usage from
cred_to_ucred() into explicit accesses inside of scm_set_cred().

So, as stated, the error originates from trying to use this common
helper for both SO_PEERCERD and the SCM stuff, the latter of which
does not want to use effective UIDs and GIDs.

> This just undoes that (presumably unintentional) part of the commit.

Indeed, I'd say this was an oversight in semantic differences when
creating the cred_to_ucred() helper.

Eric B. please review and ACK this.

Thanks!
