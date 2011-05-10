From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
 not	interacting well with multicast in 2.6.38-4
Date: Tue, 10 May 2011 15:11:00 -0700
Message-ID: <20110510151100.52a9f8fa@nehalam>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
	<1304995124.4065.157.camel@localhost>
	<20110510043833.GG6397@morgul.net>
	<1305031369.4065.259.camel@localhost>
	<20110510180540.GI6397@morgul.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>, 625914@bugs.debian.org,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Noah Meyerhans <noahm@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53485 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751381Ab1EJWMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 18:12:07 -0400
In-Reply-To: <20110510180540.GI6397@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011 11:05:40 -0700
Noah Meyerhans <noahm@debian.org> wrote:

> On Tue, May 10, 2011 at 01:42:49PM +0100, Ben Hutchings wrote:
> > > > This is pretty weird.  Debian version 2.6.38-3 has a few bridging
> > > > changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like they
> > > > would cause this.
> > > 
> > > I have apparently filed the bug against the wrong version of Debian's
> > > kernel.  2.6.38-3 is not affected, and works as expected.  The change
> > > was introduced in -4.  That may have been clear from the report itself,
> > > but the report was filed against -3.  I've fixed that in the BTS.
> > 
> > I gathered that, and then made the same mistake in writing the above!
> > The version with the regression, 2.6.38-4, includes the changes from
> > stable 2.6.38.3 and 2.6.38.4
> 
> With a little help from git bisect, I've tracked this regression down to
> the following commit to the stable-2.6.38.y tree:
> 
> commit 5f1c356a3fadc0c19922d660da723b79bcc9aad7
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Mar 18 05:27:28 2011 +0000
> 
>     bridge: Reset IPCB when entering IP stack on NF_FORWARD
>     
>     [ Upstream commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e ]
>     
>     Whenever we enter the IP stack proper from bridge netfilter we
>     need to ensure that the skb is in a form the IP stack expects
>     it to be in.
>     
>     The entry point on NF_FORWARD did not meet the requirements of
>     the IP stack, therefore leading to potential crashes/panics.
>     
>     This patch fixes the problem.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> The diff is
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 4b5b66d..49d50ea 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -741,6 +741,9 @@ static unsigned int br_nf_forward_ip(unsigned int
> hook, struct sk_buff *skb,
>                 nf_bridge->mask |= BRNF_PKT_TYPE;
>         }
>  
> +       if (br_parse_ip_options(skb))
> +               return NF_DROP;
> +
>         /* The physdev module checks on this */
>         nf_bridge->mask |= BRNF_BRIDGED;
>         nf_bridge->physoutdev = skb->dev;
> 
> If I revert this change, network connectivity functions as expected for
> the VMs on this host.
> 
> I don't know enough about this change or the problem it was supposed to
> solve to be able to guess about what's going wrong.
> 
> noah
> 

There were two more follow on commits in stable related to this.
I recommend merging 2.6.38.6 which includes these.


-- 
