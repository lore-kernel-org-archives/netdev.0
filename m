From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 19/19] netfilter: gre: fix resource leak when
 unregister gre proto
Date: Mon, 7 Jan 2013 04:27:11 +0100
Message-ID: <20130107032711.GA18953@1984>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1356662206-2260-20-git-send-email-gaofeng@cn.fujitsu.com>
 <20130105035048.GA20027@1984>
 <50EA2489.3070309@cn.fujitsu.com>
 <20130107021517.GA12215@1984>
 <20130107023808.GA14431@1984>
 <50EA3A1F.8020108@cn.fujitsu.com>
 <50EA3B68.1080001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33239 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab3AGD1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 22:27:18 -0500
Content-Disposition: inline
In-Reply-To: <50EA3B68.1080001@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 11:05:12AM +0800, Gao feng wrote:
> On 01/07/13 10:59, Gao feng wrote:
> > On 01/07/13 10:38, Pablo Neira Ayuso wrote:
> >> On Mon, Jan 07, 2013 at 03:15:17AM +0100, Pablo Neira Ayuso wrote:
> >>> Hi Gao,
> >>>
> >>> On Mon, Jan 07, 2013 at 09:27:37AM +0800, Gao feng wrote:
> >>>> Hi Pablo,
> >>>>
> >>>> On 01/05/13 11:50, Pablo Neira Ayuso wrote:
> >>>>> Hi Gao,
> >>>>>
> >>>>> On Fri, Dec 28, 2012 at 10:36:46AM +0800, Gao feng wrote:
> >>>>>> Currectly we unregister proto before all conntrack entries of
> >>>>>> this proto being destroyed. so in function destroy_conntrack
> >>>>>> we can't find proper l4proto to call l4proto->destroy.
> >>>>>> this will cause resource leak.
> >>>>>
> >>>>> Good catch.
> >>>>>
> >>>>> But better to remove the entries before unregistering the protocol
> >>>>> tracker, so l4proto->destroy is always called.
> >>>>>
> >>>>
> >>>> I think the reason we unregister proto before remove all entries
> >>>> is to avoid new entry for this protocol being created.
> >>>>
> >>>> If we remove all contrack entries before unregistration, there maybe
> >>>> some new entries being created between nf_ct_iterate_cleanup and
> >>>> nf_conntrack_l4proto_unregister_net.this will cause some terrible things.
> >>>
> >>> Leaks are less likely to happen, but may well still happen while
> >>> racing with protocol removal, agreed.
> >>>
> >>>> SO I think we should make proto unavailable first,remove all entries next,
> >>>> and remove proto from nf_ct_protos arrays finally.
> >>>
> >>> Your proposal adds a branch in the packet path to fix an issue that is
> >>> specific of the GRE protocol tracker. In the current code, this fixes
> >>> the memory leak while removing the nf_conntrack_proto_gre module,
> >>> which is a rare operation.
> >>>
> >>> We have to come with a less intrusive solution.
> >>
> >> Wait. The existing code is calling nf_ct_gre_keymap_flush in
> >> proto_gre_net_exit path, so those keymap objects are not leaked.
> > 
> > Agree, it looks like nf_ct_gre_keymap_flush is added to solve this
> > problem.
> > 
> > Please ignore this patch.
> 
> I mean ignore the codes of gre part.
> I still think nf_ct_iterate_cleanup doesn't make sure all entries being
> destroyed.

There is another round of nf_ct_iterate cleanup in
nf_conntrack_cleanup_net. So I don't see any possible leak so far. Let
me know if you find anything.

Thanks.
