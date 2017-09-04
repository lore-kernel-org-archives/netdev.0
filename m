From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 12:57:15 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84@ESESSMB107.ericsson.se>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
        <20170831124516.0c5db686@griffin>
        <20170904080005.GA70767@cran64.bj.intel.com>
 <20170904124216.6db68e8c@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>
To: Jiri Benc <jbenc@redhat.com>, "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:62033 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753602AbdIDM6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 08:58:18 -0400
In-Reply-To: <20170904124216.6db68e8c@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 4 Sep 2017 16:00:05 +0800, Yang, Yi wrote:
> > I think we have had similiar discussion about this, the issue is we have
> > no way to handle both MD type 1 and MD type 2 by using a common flow key struct.
> >
> > So we have to do so, there is miniflow to handle such issue in
> > userspace, but kernel data path didn't provide such mechanism. I think
> > every newly-added key will result in the same space-wasting issue for
> > kernel data path, isn't it?
> 
> Yes. And it would be surprising if it didn't have an effect on
> performance.
> 
> I don't care that much as this is a result of openvswitch module design
> decisions but it still would be good to reach a consensus before
> implementing uAPI that might not be needed in the end.

Matching on NSH MD1 context headers is definitely required. So these must
be part of the flow.

> 
> > OVS_ATTR_KEY_NSH is the first case to use nested attributes for set
> > action, so no reference code for this, set action has two use cases, one
> > has mask but the other hasn't, so it will be easier an nested attribute is
> > handled as a whole, in user space, nsh_key_from_nlattr is used in
> > several places.
> 
> I very much disagree. What you're doing is very poor design as can be
> seen from the code where you have to do weird gymnastics to implement
> that. Compare that to a much simple case where each attribute carries
> its own value and mask.

I have no principle objections against splitting NSH base header and MD1 context
headers into independent key attributes on the uAPI if that simplifies the code.
But we need to full picture here:

So is what you are suggesting the following?

For matching:
OVS_KEY_ATTR_NSH_BASE_HEADER		mandatory
OVS_KEY_ATTR_NSH_MD1_CONTEXT		optional, in case MDTYPE == MD1

For setting:
OVS_ACTION_ATTR_SET_MASKED
-    OVS_KEY_ATTR_NSH_BASE_HEADER		when setting any base header fields
OVS_ACTION_ATTR_SET_MASKED
-    OVS_KEY_ATTR_NSH_MD1_CONTEXT	when setting any MD1 context data fields

For push_nsh:
OVS_ACTION_ATTR_PUSH_NSH
-    OVS_KEY_ATTR_NSH_BASE_HEADER		mandatory
-    OVS_NSH_ATTR_CONTEXT_HEADERS		optional (opaque metadata octet stream) 

So push_nsh would still require nested attributes. Is that what we want (see below).

> > How can we do so? I see batch process code in user space implementation,
> > but kernel data path didn't such infrastructure,
> 
> You're right that there's no infrastructure. I somewhat agree that it
> might be out of scope of this patch and it can be optimized later.
> That's why I also included other suggestions to speed this up until we
> implement better parsing: namely, verify correctness once (at the time
> it is set from user space) and just expect things to be correct in the
> fast path.
> 
> > how can we know next push_nsh uses the same nsh header as previous
> > one?
> 
> We store the prepopulated header together with the action.

I agree.

In our original modelling of OVS_ACTION_ATTR_PUSH_NSH in OVS 2.8 we 
introduced a monolithic push_nsh action struct including the NSH base header
and variable length opaque context headers. That avoids any logic in the 
kernel datapath to translate a nested action attribute into an internal format
with pre-populated header. The user space does that work.

Should we consider to stick to that simple and efficient approach? As far 
As I can see it will be generic for the foreseeable future.

> > > These checks should be done only once when the action is configured, not for
> > > each packet.
> >
> > I don't know how to implement a batch processing in kernel data path, it
> > seems there isn't such code for reference.
> 
> The checks should be done somewhere in __ovs_nla_copy_action. Which
> seems to be done even in your patch by nsh_key_put_from_nlattr
> (I didn't get that far during the review last week. The names of
> those nsh_(key|hdr)_*_nlattr are so similar that it's impossible to
> tell what they do without looking at the call sites - something you
> should also consider to improve). That makes it even more wrong: you
> appear to check everything twice, first on configuration and then for
> every packet.

Agree. Validation should only happen at action configuration time.

BR, Jan
