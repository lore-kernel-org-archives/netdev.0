From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Tue, 5 Sep 2017 10:11:12 +0800
Message-ID: <20170905021112.GA86057@cran64.bj.intel.com>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87mv6abte5.fsf-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
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

On Mon, Sep 04, 2017 at 07:22:26PM +0800, Hannes Frederic Sowa wrote:
> Hello,
> 
> "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> 
> > On Wed, Aug 30, 2017 at 05:53:27PM +0800, Hannes Frederic Sowa wrote:
> >> Hello,
> >> 
> >> Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> >> 
> >> [...]
> >> 
> >> > +struct ovs_key_nsh {
> >> > +	u8 flags;
> >> > +	u8 ttl;
> >> > +	u8 mdtype;
> >> > +	u8 np;
> >> > +	__be32 path_hdr;
> >> > +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> >> > +};
> >> > +
> >> >  struct sw_flow_key {
> >> >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
> >> >  	u8 tun_opts_len;
> >> > @@ -144,6 +154,7 @@ struct sw_flow_key {
> >> >  			};
> >> >  		} ipv6;
> >> >  	};
> >> > +	struct ovs_key_nsh nsh;         /* network service header */
> >> >  	struct {
> >> >  		/* Connection tracking fields not packed above. */
> >> >  		struct {
> >> 
> >> Does it makes sense to keep the context headers as part of the flow?
> >> What is the reasoning behind it? With mdtype 2 headers this might either
> >> not work very well or will increase sw_flow_key size causing slowdowns
> >> for all protocols.
> >
> > For userspace, miniflow can handle such issue, but kernel data path
> > didn't provide such mechanism, so I don't think we can think of a better
> > way to fix this.
> 
> I do think that both, kernel and dpdk dp, are fine if you don't match on
> context fields, which I think is the common case.
> 
> As soon as a few paths start to match on contexts at different offsets I
> am not sure if miniflow will actually help. I don't know enough about
> that. Set cover is a NP hard problem, so constructing plain simple flows
> will be an approximation somewhere anyway at some point.
> 
> If the context values are in some way discrete it might make sense, but
> for load balancing purposes your ingress router might fill out one
> context field with a flow hash of the inner flow to allow ECMP or
> loadbalancing. You might want to treat that separately. Otherwise the
> different paths might always need to context[3] & 0x3 (bits as number of
> possible next hops) and put that into the flow state. Because every hop
> and every path might have different numbers of nexthops etc., I don't
> think this is easy unifiable anymore.

Anyway, this is a common issue but not NSH-implemention-specific issue.
In my perspective, kernel data path won't have better perfromance than
userspace DPDK data path, maybe you're considering hardware offload, but
so far there isn't an infrastructure in OVS to offload NSH.

> 
> > We have to have context headers in flow for match and set, every hop in
> > service function chaining can put its metedata into context headers on
> > demand, MD type 2 is much more complicated than you can imagine, it is
> > impossible to use an uniform way to handle MD type 1 and MD type 2, our
> > way is to keep MD type 1 keys in struct ovs_key_nsh and to reuse struct
> > flow_tnl for MD type 2 metadata, in case of MD type 2, we can set
> > context headers to 0 in struct ovs_key_nsh.
> 
> Understood and agreed.
> 
> > I beleive every newly-added key will result in similiar issue you
> > concern, maybe it will be better to introduce miniflow in kernel data
> > path, but it isn't in scope of this patch series.
> 
> You will see the same problem with offloading flows e.g. to network
> cards very soon. Flow explosion here will cause your 100Gbit/s NIC
> suddenly to go to software slow path.

Do you mean the whole OVS data path offload? As I said, this is a common
issue, it isn't NSH-specific.

> 
> > It will be great if you can have a better proposal to fix your concern.
> 
> I do think that something alike miniflow might make sense, but I don't
> know enough about miniflow.
> 
> New ACTIONS, that are not only bound to NSH, seem appealing to me at the
> moment. E.g. have a subtable match in the kernel dp or allowing for some
> OXM % modulo -> select action or neighbor alike thing would probably
> cover a lot of cases in the beginning. The submatch would probably very
> much reassemble the miniflow in dpdk dp.

I'm not sure what new action you expect to bring here, I think group
action is just for this, as you said it isn't only bound to NSH, you can
start a new thread to discuss this. I don't think it is in scope of NSH.

> 
> Thanks,
> Hannes
