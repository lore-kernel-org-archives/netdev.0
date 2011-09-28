From: Flavio Leitner <fbl@redhat.com>
Subject: Re: ICMP redirect issue
Date: Wed, 28 Sep 2011 17:19:52 -0300
Message-ID: <20110928171952.0c0d2d05@asterix.rh>
References: <20110927162120.30394030@asterix.rh>
	<20110928.140632.726302773135946390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221Ab1I1UT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 16:19:56 -0400
In-Reply-To: <20110928.140632.726302773135946390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2011 14:06:32 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fbl@redhat.com>
> Date: Tue, 27 Sep 2011 16:21:20 -0300
> 
> > The issue is about the gateway being a LVS, so the servers behind
> > use the IP alias address as the default gateway.  However, when the
> > gateway sends an ICMP redirect, it comes from the primary IP
> > address which is ignored on older kernels because of the old_gw
> > check:
> > 
> > -                               if (rth->rt_dst != daddr ||
> > -                                   rth->rt_src != saddr ||
> > -                                   rth->dst.error ||
> > -                                   rth->rt_gateway != old_gw ||
> > -                                   rth->dst.dev != dev)
> > -                                       break;
> > 
> > 
> > Well, the consequence is that the issue doesn't happen in newer
> > kernels because it happily accepts the ICMP redirect.
> > 
> > The admin can still control using shared_media and secure_redirects
> > if the host should accept only the ICMP redirects for gateways
> > listed in default gateway list or not.
> 
> Unfortunately, shared_media is on by default which means the default
> secure_redirects setting of '1' is ignored.
> 
> This means that redirects can be spoofed in the default configuration,
> but with the above check they would not be spoofable.

I fail to see what that check is preventing because if someone manages
to inject a redirect packet into the network, then likely the old_gw can
be tweaked to be the network gateway.

> I suspect that, because of this, we'll need to add the check back.  Or
> do something similar.
> 
> We can't "fix" this by turning shared_media off by default because
> that changes behavior on input route processing wrt. how we decide
> whether to emit a redirect or not.

What about something like below? It will change a bit the
secure_redirects documentation.

shared_media  secure_redirect  behavior:
      0             0          all pass.
      0             1          only from gateways and for gateways.
      1             0          all pass.
      1             1          default, old behavior, only from
                               gateways.

If you agree with the approach, I'll run tests here and post
the patch with a proper changelog, documentation and signed-off.

thanks,
fbl

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 075212e..fa00fcd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1332,6 +1332,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
+	if (IN_DEV_SEC_REDIRECTS(in_dev) && ip_fib_check_default(old_gw, dev))
+		goto reject_redirect;
+
 	peer = inet_getpeer_v4(daddr, 1);
 	if (peer) {
 		peer->redirect_learned.a4 = new_gw;
