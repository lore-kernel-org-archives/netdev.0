From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 11:46:45 +0200
Message-ID: <20170905114645.33bf0e32@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
	<20170904080005.GA70767@cran64.bj.intel.com>
	<20170904124216.6db68e8c@griffin>
	<20170904120907.GA75461@cran64.bj.intel.com>
	<20170904145744.4d8b7fd5@griffin>
	<20170905055144.GA88800@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170905055144.GA88800-re2EX8HDrk21gSHoDXDV2kEOCMrvLtNR@public.gmane.org>
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

On Tue, 5 Sep 2017 13:51:45 +0800, Yang, Yi wrote:
> But if we follow your way, how does nla_for_each_nested handle such
> pattern?
> 
> attribute1
> attribute1_mask
> attribute2
> attribute2_mask
> attribute3
> attribute3_mask

Uh? That will just work. Note that nla len contains the size of the
whole attribute, i.e. includes both fields.

> I don't think this can increase performance and readability.

Do you realize you're stating that not copying data around in hot path
can't increase performance? ;-)

> if we use one function to handle both attributes and masks, I can't
> see any substantial difference between two ways as far as the
> performance is concerned.

Except that what you did is so unexpected to netlink that you had to go
out of your way to parse it. Those two memcpys speak for themselves.

> If we consider OVS_KEY_ATTR_NSH as a big attribute, current way is
> precisely following current design pattern

Do you have an idea how nested netlink attributes work? It's very well
defined. What you're doing is breaking the definition. You can't do
that.

The (non-nested) attributes contain header followed by data. The data
is a single value or it is a struct. In ovs for masked actions,
attributes contain a struct of two fields (value and mask). The struct
access is open coded but it's still a struct.

Now, nested attributes are very well defined: it's a nla header
followed by a stream of attributes. There's no requirement on the order
of the attributes. Do you see how you're breaking this assumption? You
expect that each attribute is present exactly twice, once among first
half of attributes, once among second half of attributes. You don't
check that this weird assumption is adhered to. You don't even check
that the point where you split the data is between attributes! You may
very well be splitting an attribute in half and interpreting its data
as nla headers.

Consider your proposal NACKed from my side.

 Jiri
