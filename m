From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Tue, 01 Mar 2011 00:35:12 +0000
Message-ID: <1298939712.2569.43.camel@bwh-desktop>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
	 <20110211011838.23554.3735.stgit@gitlad.jf.intel.com>
	 <1298302841.2608.35.camel@bwh-desktop>  <4D642222.6050202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8727 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab1CAAfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 19:35:15 -0500
In-Reply-To: <4D642222.6050202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-22 at 12:52 -0800, Alexander Duyck wrote:
[...]
> >> @@ -408,6 +425,14 @@ static int msglvl_changed;
> >>   static u32 msglvl_wanted = 0;
> >>   static u32 msglvl_mask = 0;
> >>
> >> +static int rx_rings_get = 0;
> >> +static int rx_class_rule_get = -1;
> >> +static int rx_class_rule_getall = 0;
> >> +static int rx_class_rule_del = -1;
> >> +static int rx_class_rule_added = 0;
> >> +static struct ethtool_rx_flow_spec rx_rule_fs;
> >> +static u8 rxclass_loc_valid = 0;
> >> +
> >>   static enum {
> >>        ONLINE=0,
> >>        OFFLINE,
> > [...]
> >> @@ -945,6 +974,23 @@ static void parse_cmdline(int argc, char **argp)
> >>                                                rxflow_str_to_type(argp[i]);
> >>                                        if (!rx_fhash_get)
> >>                                                show_usage(1);
> >> +                             } else if (!strcmp(argp[i], "rx-rings")) {
> >> +                                     i += 1;
> >> +                                     rx_rings_get = 1;
> >
> > I'm not convinced of the value of a separate rx-rings option/keyword.
> > However it's probably worth displaying the number of rings/queues when
> > showing other flow hashing and steering/filtering information (the -x
> > option does this).
> 
> My thought was that it would be useful for determining the number of 
> rings prior to adding a rule.  Especially if we have any kind of scripts 
> running on top of ethtool so that we can avoid rules that will fail due 
> to ring values being greater than the actual number of rings.  I might 
> try looking into adding it to the display options for the filters.

I think it would also be appropriate to add this to the output of the
-g/--show-ring option.

[...]
> >>                                } else
> >>                                        show_usage(1);
> >>                                break;
> >
> > I don't think the same options (-n, -N) should be used both for flow
> > hashing and n-tuple flow steering/filtering.  This command-line
> > interface and the structure used in the ethtool API just seem to reflect
> > the implementation in the niu driver.
> >
> > (In fact I would much prefer it if the -u and -U options could be used
> > for both the rxnfc and rxntuple interfaces.  But I haven't thought about
> > how the differences in functionality would be exposed to or hidden from
> > the user.)
> 
> I was kind of thinking about merging the two interfaces too, but I was 
> looking at it more from the perspective of moving away from ntuple more 
> towards this newer interface.  My main motivation being that the filter 
> display option is so badly broken for ntuple that it would be easier to 
> make ntuple a subset of the flow classifier instead of the other way around.
> 
> What would you think of using the "flow-type" keyword to indicate legacy 
> ntuple support, and then adding something like "class-rule-add", and 
> "class-rule-del" to add support for the network flow classifier calls?

I really don't want to introduce different syntax for functionality that
is common between the two command sets.  The user should not have to
know that driver A implements interface I and driver B implements
interface J, except that since version 2.6.y driver A implements
interface J too.

Surely it is possible to try one interface, then the other, when the
requested filter can be implemented either way?

[...]
> >> +     for (i = 2; i<  opt_cnt;) {
> >> +             if (!strcmp(optstr[i], "tos")) {
> >> +                     tos = (u_int8_t)strtoul(optstr[i+1], (char **)NULL,
> >> +                                              0);
> >> +                     tm = 0xff;
> >> +                     fsp->h_u.tcp_ip4_spec.tos = tos;
> >> +
> >> +                     i += 2;
> >> +                     if (opt_cnt>  (i+1)) {
> >> +                             if (!strcmp(optstr[i], "m")) {
> >> +                                     tm = (u_int8_t)strtoul(optstr[i+1],
> >> +                                                            (char **)NULL,
> >> +                                                            16);
> >> +                                     i += 2;
> >> +                             }
> >> +                     }
> >> +                     fsp->m_u.tcp_ip4_spec.tos = tm;
> >> +             } else if (!strcmp(optstr[i], "sip")) {
> > [...]
> >
> > These keyword names must be made consistent with those used for the -U
> > (--config-ntuple) option.
> >
> 
> I will update the names to be consistent with the ntuple options, 
> however I would prefer to keep the option of short-cutting the mask via 
> the "m" value.  It will not be hard to make it support both since the 
> pattern would be to test for either "m" or "%s-mask".
[...]

Agreed, that would be a useful shortcut.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

