From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 11:41:07 -0600
Message-ID: <001301c734de$8252b170$cc0a010a@tcssec.com>
References: <Pine.LNX.4.64.0701100913050.8582@d.namei>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Paul Moore" <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:35673 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964950AbXAJRlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 12:41:39 -0500
To: "'James Morris'" <jmorris@namei.org>,
	"Herbert Xu" <herbert.xu@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0701100913050.8582@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This patch causes security policy denials to be cached instead of
> > causing a relookup every time.

Only, on a security policy denial (-ESRCH from the LSM hook), a 0
is returned by the resolver to signify no applicable policy since
a negative result is akin to no policy. And I see the "no policy"
case is already cached.

I think what may have gotten us here is the comment:

                       if (err) {
                                /* Force security policy check on next
lookup */
                                *head = fle->next;
                                flow_entry_kill(cpu, fle);
                        } else {

But the error we would be looking at here would be a non-denial
related error (neither positive nor negative) that the security
server may have run into, in which case we would in fact want to
attempt a full-lookup again the next time.

<snip>
> > So if the security folks actually care about this, they'd need to
> > flush the flow cache whenever a relevant change is made to the
> > security database.

Sure. Will look into this.

> >
> > This patch also happens to fix a nasty bug where if an expiring
> > flow entry that's not at the head happens to trigger a security
> > denial, all entries before it are removed from the cache and
> > leaked.

I think just leaving the flow_entry as it is will take care of it.

IOW, no entry_killing nor messing with it's object/reference. This
should naturally cause us to invoke the resolver again the next time.

