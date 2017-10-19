From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v12] openvswitch: enable NSH support
Date: Thu, 19 Oct 2017 21:12:15 +0800
Message-ID: <20171019131215.GA84551@cran64.bj.intel.com>
References: <1508162009-30359-1-git-send-email-yi.y.yang@intel.com>
	<20171018231955.058ec5c8@griffin>
	<20171019114052.GA83037@cran64.bj.intel.com>
	<20171019144347.421351db@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171019144347.421351db@griffin>
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

On Thu, Oct 19, 2017 at 02:43:47PM +0200, Jiri Benc wrote:
> On Thu, 19 Oct 2017 19:40:53 +0800, Yang, Yi wrote:
> > Actually mdtype can't be set, only push_nsh can set mdtype, so set_nsh
> > won't have mdtype flow key, we can't get it from flow_key in set_nsh,
> > only ttl, flags and path_hdr can be set in set_nsh as you can see in code.
> > I understand your concern is calling skb_ensure_writable twice, so
> > changing the first one to pskb_may_pull is more appropriate for set_nsh.
> 
> Isn't set_nsh called only after the packet was already dissected (i.e.
> parse_nsh called)? The dissected fields should be available in flow_key.

flow_key in set_nsh is got from netlink message which is set by
commit_nsh in user space, here is code.

    mask.mdtype = 0;     /* Not writable. */
    mask.np = 0;         /* Not writable. */

    if (commit_nsh(&base_flow->nsh, use_masked, &key, &base, &mask,
            sizeof key, odp_actions)) {
        put_nsh_key(&base, base_flow, false);
        if (mask.mdtype != 0) { /* Mask was changed by commit(). */
            put_nsh_key(&mask, &wc->masks, true);
        }
    }

Here set is set with mask, so key value is masked by mask.mdtype

        /* OVS_KEY_ATTR_NSH keys */
        nsh_key_ofs = nl_msg_start_nested(odp_actions,
OVS_KEY_ATTR_NSH);

        /* put value and mask for OVS_NSH_KEY_ATTR_BASE */
        char *data = nl_msg_put_unspec_uninit(odp_actions,
                                              OVS_NSH_KEY_ATTR_BASE,
                                              2 * sizeof(nsh_base));
        const char *lkey = (char *)&nsh_base, *lmask = (char
*)&nsh_base_mask;
        size_t lkey_size = sizeof(nsh_base);

        while (lkey_size--) {
            *data++ = *lkey++ & *lmask++;
        }
        lmask = (char *)&nsh_base_mask;
        memcpy(data, lmask, sizeof(nsh_base_mask));

> 
>  Jiri
