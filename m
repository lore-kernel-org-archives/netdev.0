From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 12:42:16 +0200
Message-ID: <20170904124216.6db68e8c@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
	<20170904080005.GA70767@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170904080005.GA70767-re2EX8HDrk21gSHoDXDV2kEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 4 Sep 2017 16:00:05 +0800, Yang, Yi wrote:
> I think we have had similiar discussion about this, the issue is we have
> no way to handle both MD type 1 and MD type 2 by using a common flow key struct.
> 
> So we have to do so, there is miniflow to handle such issue in
> userspace, but kernel data path didn't provide such mechanism. I think
> every newly-added key will result in the same space-wasting issue for
> kernel data path, isn't it?

Yes. And it would be surprising if it didn't have an effect on
performance.

I don't care that much as this is a result of openvswitch module design
decisions but it still would be good to reach a consensus before
implementing uAPI that might not be needed in the end.

> OVS_ATTR_KEY_NSH is the first case to use nested attributes for set
> action, so no reference code for this, set action has two use cases, one
> has mask but the other hasn't, so it will be easier an nested attribute is
> handled as a whole, in user space, nsh_key_from_nlattr is used in
> several places.

I very much disagree. What you're doing is very poor design as can be
seen from the code where you have to do weird gymnastics to implement
that. Compare that to a much simple case where each attribute carries
its own value and mask.

> If we change it per your proposal, there will be a lot
> of rework,

That's not an argument. We care about doing things right, we don't do
things hastily and with as little effort as possible.

> we have to provide two functions to handle this, one is for
> the case with mask, the other is for the case without mask.

I don't see that. The function is called from a single place only.

> How can we do so? I see batch process code in user space implementation,
> but kernel data path didn't such infrastructure,

You're right that there's no infrastructure. I somewhat agree that it
might be out of scope of this patch and it can be optimized later.
That's why I also included other suggestions to speed this up until we
implement better parsing: namely, verify correctness once (at the time
it is set from user space) and just expect things to be correct in the
fast path.

> how can we know next push_nsh uses the same nsh header as previous
> one?

We store the prepopulated header together with the action.

> > Shouldn't we reject the packet, then? Pretending that something was parsed
> > correctly while in fact it was not, does not look correct.
> 
> For MD type 2, we don't implement metadata parsing, but it can still
> work. I'm not sure what you mean here, how do we reject a packet here?

Okay, we can match on mdtype and thus can find out about this type of
packets. No problem, then.

> > These checks should be done only once when the action is configured, not for
> > each packet.
> 
> I don't know how to implement a batch processing in kernel data path, it
> seems there isn't such code for reference.

The checks should be done somewhere in __ovs_nla_copy_action. Which
seems to be done even in your patch by nsh_key_put_from_nlattr
(I didn't get that far during the review last week. The names of
those nsh_(key|hdr)_*_nlattr are so similar that it's impossible to
tell what they do without looking at the call sites - something you
should also consider to improve). That makes it even more wrong: you
appear to check everything twice, first on configuration and then for
every packet.

 Jiri
