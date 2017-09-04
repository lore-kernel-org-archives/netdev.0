From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Mon, 4 Sep 2017 10:38:32 +0800
Message-ID: <20170904023831.GA68062@cran64.bj.intel.com>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wp5l7560.fsf-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
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

On Wed, Aug 30, 2017 at 05:53:27PM +0800, Hannes Frederic Sowa wrote:
> Hello,
> 
> Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> 
> [...]
> 
> > +struct ovs_key_nsh {
> > +	u8 flags;
> > +	u8 ttl;
> > +	u8 mdtype;
> > +	u8 np;
> > +	__be32 path_hdr;
> > +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> > +};
> > +
> >  struct sw_flow_key {
> >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
> >  	u8 tun_opts_len;
> > @@ -144,6 +154,7 @@ struct sw_flow_key {
> >  			};
> >  		} ipv6;
> >  	};
> > +	struct ovs_key_nsh nsh;         /* network service header */
> >  	struct {
> >  		/* Connection tracking fields not packed above. */
> >  		struct {
> 
> Does it makes sense to keep the context headers as part of the flow?
> What is the reasoning behind it? With mdtype 2 headers this might either
> not work very well or will increase sw_flow_key size causing slowdowns
> for all protocols.

For userspace, miniflow can handle such issue, but kernel data path
didn't provide such mechanism, so I don't think we can think of a better
way to fix this.

We have to have context headers in flow for match and set, every hop in
service function chaining can put its metedata into context headers on
demand, MD type 2 is much more complicated than you can imagine, it is
impossible to use an uniform way to handle MD type 1 and MD type 2, our
way is to keep MD type 1 keys in struct ovs_key_nsh and to reuse struct
flow_tnl for MD type 2 metadata, in case of MD type 2, we can set
context headers to 0 in struct ovs_key_nsh.

I beleive every newly-added key will result in similiar issue you
concern, maybe it will be better to introduce miniflow in kernel data
path, but it isn't in scope of this patch series.

It will be great if you can have a better proposal to fix your concern.

> 
> [...]
