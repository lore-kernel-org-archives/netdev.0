From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/6] openvswitch: Rename GENEVE_TUN_OPTS() to
 TUN_METADATA_OPTS()
Date: Wed, 7 Jan 2015 22:55:07 +0000
Message-ID: <20150107225507.GB21149@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <10cbd42aca443d862b8b62017b5a4356326e026f.1420594925.git.tgraf@suug.ch>
 <CAEP_g=-X_S1qmMQt3VjOUT9+qUEnxeJxUSf-B90Yktns72zWaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37963 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908AbbAGWzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:55:08 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-X_S1qmMQt3VjOUT9+qUEnxeJxUSf-B90Yktns72zWaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 02:46pm, Jesse Gross wrote:
> On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > A subsequent patch will introduce VXLAN options. Rename the existing
> > GENEVE_TUN_OPTS() to reflect its extended purpose of carrying generic
> > tunnel metadata options.
> >
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> This is generally a good idea (even outside of the larger context of
> this patch series) although a couple comments below:
> 
> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> > index d1eecf7..c60ae3f 100644
> > --- a/net/openvswitch/flow_netlink.c
> > +++ b/net/openvswitch/flow_netlink.c
> > @@ -387,20 +387,20 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
> >         return __parse_flow_nlattrs(attr, a, attrsp, log, false);
> >  }
> >
> > -static int genev_tun_opt_from_nlattr(const struct nlattr *a,
> > -                                    struct sw_flow_match *match, bool is_mask,
> > -                                    bool log)
> > +static int tun_md_opt_from_nlattr(const struct nlattr *a,
> > +                                 struct sw_flow_match *match, bool is_mask,
> > +                                 bool log)
> 
> I think this is a somewhat overzealous conversion. This function is
> verifying OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS and as such has some
> elements of Geneve protocol knowledge baked in (such as the check that
> the options are a multiple of 4 bytes). It's also nice for the log
> messages to indicate which netlink key is causing the problem and not
> be too generic.

OK. I was planning on always padding vxlan_opts to 4 bytes as well but
I agree with you. It seems clearer to have distinct functions for each
and they can share code where it makes sense.

> > @@ -1148,10 +1145,10 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
> >                 goto nla_put_failure;
> >
> >         if ((swkey->tun_key.ipv4_dst || is_mask)) {
> > -               const struct geneve_opt *opts = NULL;
> > +               const void *opts = NULL;
> >
> >                 if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
> > -                       opts = GENEVE_OPTS(output, swkey->tun_opts_len);
> > +                       opts = TUN_METADATA_OPTS(output, swkey->tun_opts_len);
> >
> >                 if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
> >                                        swkey->tun_opts_len))
> 
> I think it's probably better to factor this block of code out into a
> new function as you have done in the next patch (and include it with
> this one). It makes it clearer that it is Geneve-specific.

OK, will do.
