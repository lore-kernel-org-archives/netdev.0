From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH iptables 3/3] libxt_hashlimit: iptables-restore does not
 work as expected with xt_hashlimit
Date: Fri, 8 Jul 2016 13:54:09 +0200
Message-ID: <20160708115409.GA17275@salvia>
References: <20160602001759.GF1644@akamai.com>
 <20160623102511.GA10493@salvia>
 <576D7AD2.6050107@akamai.com>
 <20160625093924.GC1289@salvia>
 <577C14D2.3020005@akamai.com>
 <577D859F.2000003@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56054 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbcGHLyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 07:54:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C0A9517DB80
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 13:54:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B058F9EBA5
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 13:54:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DFBD29EBA5
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 13:54:13 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <577D859F.2000003@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 06:26:39PM -0400, Vishwanath Pai wrote:
> On 07/05/2016 04:13 PM, Vishwanath Pai wrote:
> > On 06/25/2016 05:39 AM, Pablo Neira Ayuso wrote:
> >> I see, but I'm not convinced about this /proc rename feature.
> >>
> >> I think the main point of this, as well as other entries in bugzilla
> >> related to this, is ability to update an existing hashlimit state.
> >>
> >> So, I'm not proposing to rename --enhanced-procfs to something else,
> >> I think that a different approach consisting on adding a new option
> >> like --hashlimit-update that will update the internal state of an
> >> existing hashlimit object is just fine for your usecase, right?
> >>
> >>>> Other than that, we are doing exactly what you said, but creating a new
> >>>> entry in the hashtable instead of updating it. The previous entry will
> >>>> automatically be removed when the old rule is flushed/deleted.> >> What I'm missing is why we need this /proc rename at all.
> >> What I'm missing is why we need this /proc rename at all.
> > 
> > The reason we need the procfs rename feature is because it is broken at
> > the moment. Let us assume someone adds two rules with the same name
> > (intentionally or otherwise). We cannot prevent them from doing this or
> > error out when someone does this because all of this is done in
> > hashlimit_mt_check which is called for every iptables rule change, even
> > an entirely different rule. I'll demonstrate two scenarios here. I have
> > put debug printk statements which prints everytime hashlimit_mt_check is
> > called.
> > 
> > 1) Add two rules with the same name but in different chains
> > 
> > $ iptables -A chain1 -m hashlimit --hashlimit-above 200/sec \
> >   --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP
> > 
> > $ dmesg -c
> > [  103.965578] hashlimit_mt_check for rule hashlimit1
> > 
> > 
> > $ iptables -A chain2 -m hashlimit --hashlimit-above 300/sec \
> >    --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP
> > 
> > $ dmesg -c
> > [  114.613758] hashlimit_mt_check for rule hashlimit1
> > [  114.621360] hashlimit_mt_check for rule hashlimit1
> > [  114.627411] hashlimit_mt_destroy on hashlimit1

We have to keep the existing behaviour. Yes, it's broken or ambiguos
but there may be people outthere relying on this.

What I think we can do to resolve this scenario that you describe
abobe is to provide a new option:

        --hashlimit-exclusive

this turns on a flag in the configuration that results in a bail out
if any of these two happens:

1) there is an existing hashlimit with that name already.
2) someone tries to add a hashlimit with a clashing name with no
   --hashlimit-exclusive.

So the --hashlimit-exclusive just makes sure the user gets a unique
name and silly things don't happen.

If not specified, we rely on the existing (broken) behaviour.

> > 2) Replace an iptables rule with iptables-restore
> > 
> > $ iptables -A chain1 -m hashlimit --hashlimit-above 200/sec \
> >   --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP
> > 
> > $ iptables-save > /tmp/hashlimit
> > 
> > $ vi /tmp/hashlimit (edit 200/s to 300/s)
> > 
> > $ iptables-restore < /tmp/hashlimit
> > 
> > $ dmesg -c
> > [ 1585.411093] hashlimit_mt_check for rule hashlimit1
> > [ 1585.418948] hashlimit_mt_destroy on hashlimit1

For this case, you rename your enhance-proc option to:

        --hashlimit-update

as I proposed, and remove the /proc entry rename logic.

> > In case 1 there exists two rules with the same name but we cannot have
> > procfs files for both of the rules since they have to exist in the same
> > directory. In case 2 there will be only one rule but there is a small
> > window where two rules with same name exist. We cannot differentiate
> > this from case 1. In both the cases we get the call for
> > hashlimit_mt_check for the new rule before the old rule is deleted.
> > 
> > Without the rename feature I do not know how to correctly handle the
> > scenario where two rules with different parameters but the same name exist.

With the explicit new options, we can indeed know where to go. If no
options are specified, we just keep behaving in the same (broken) way
that we provide now.

This is the way hashlimit has been working since day one

Does this sound good to you?

Thanks for not giving up on sorting out this problem.
