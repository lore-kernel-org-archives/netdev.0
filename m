From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Mon, 14 Aug 2017 09:51:17 +0200
Message-ID: <20170814095117.056fdf96@griffin>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
	<20170811102418.6b1be4f7@griffin>
	<20170811084722.GA19968@cran64.bj.intel.com>
	<20170811111055.482bd42b@griffin>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
	<20170811114449.745c49c5@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7273679A@ESESSMB107.ericsson.se>
	<20170811122256.2cec123e@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D72736EAE@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D72736EAE-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
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

On Sun, 13 Aug 2017 21:13:57 +0000, Jan Scheurich wrote:
> Jiri, I am not too familiar with conventions on the OVS netlink
> interface regarding the handling of variable length fields. What is
> the benefit of structuring the push_nsh action into
> 
> OVS_ACTION_ATTR_PUSH_NSH
> +-- OVS_ACTION_ATTR_NSH_BASE_HEADER
> +-- OVS_ACTION_ATTR_NSH_MD
> 
> instead of grouping the base header fields and the variable length MD
> into a single monolithic attribute OVS_ACTION_ATTR_PUSH_NSH? Is the
> main concern a potential future need to add additional parameters to
> the push_nsh datapath action? Are there examples for such structured
> actions other than OVS_ACTION_ATTR_CT where the need is obvious
> because it is very polymorphic?

This is about having the design clean. What would you do if you had two
variable length fields? Would you still put them in a single structure
and have a length field in the structure, too? That would be wrong, we
have length in the attribute header. I doubt you would do that. Which
indicates that putting variable length fields to an attribute with
anything other is wrong.

Also, look at how ugly the code would be. You'd have to subtract the
base header length from the attribute length to get the variable data
length. That's not nice at all.

Think about the netlink in the way that by default, every field should
have its own attribute. Structures are included only for performance
reasons where certain fields are always passed in a message and having
them in separate attributes would be impractical and waste of space.
Going out of your way to include the context data in the structure thus
doesn't make sense.

> BTW:  The name OVS_ACTION_ATTR_NSH_BASE_HEADER is misleading because
> in the NSH draft the term base header is used for the first 32-bit
> word, whereas here it includes also the 32-bit Service Path header.

An excellent comment. This means that it's very well possible that
future NSH versions may not include SP header or may have it of a
different size. Maybe we should consider putting it into a separate
attribute, too? Not sure it is needed, though, I don't think it's
likely to happen.

 Jiri
