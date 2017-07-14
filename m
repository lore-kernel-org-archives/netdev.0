From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH net-next v1 2/3] gtp: Support creating flow-based gtp
 net_device
Date: Fri, 14 Jul 2017 10:12:36 +0200
Message-ID: <20170714081236.zxxdnjzihp3sexxa@nataraja>
References: <20170713004455.3946570-1-ouyangj@fb.com>
 <20170713004455.3946570-3-ouyangj@fb.com>
 <20170713073540.q4tqqawhxwzqrzsv@nataraja>
 <FFC0D5B5-37F4-4DD0-B294-FE3074EA9017@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "osmocom-net-gprs@lists.osmocom.org"
        <osmocom-net-gprs@lists.osmocom.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "pshelar@nicira.com" <pshelar@nicira.com>,
        "wieger.ijntema.tno@gmail.com" <wieger.ijntema.tno@gmail.com>,
        "yi.y.yang@intel.com" <yi.y.yang@intel.com>,
        "joe@ovn.org" <joe@ovn.org>,
        Amar Padmanabhan <amarpadmanabhan@fb.com>
To: Jiannan Ouyang <ouyangj@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:48793 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdGNIPM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 04:15:12 -0400
Content-Disposition: inline
In-Reply-To: <FFC0D5B5-37F4-4DD0-B294-FE3074EA9017@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiannan,

On Fri, Jul 14, 2017 at 01:01:34AM +0000, Jiannan Ouyang wrote:
> > you're unconditionally binding to both GTP0 and GTP1 UDP ports.  This is
> > done selectively based on netlink attributes in the existing "normal"
> > non-OVS kernel code, i.e. the control is left to the user.
> > 
> > Is this function is only called/used in the context of OVS?  If so,
> > since you explicitly implement only GTPv1, why bind to GTPv0 port?
> > 
> 
> I had doubts on how this flow-based GTPv1 code path should fit in, which is why
> the GTPv0 and the GTPv1 code pieces are mixed in my changes. 

Well, I know nothing about flow-based paths and OVS, so if you are the
one proposing related changes to me as the maintainer, you need to make
sure that your changes are consistend and useful within your use
case/scenario while making sure that the existing features don't break.

If you refactor generic code (used by "classic" GTP tunneling + your new
flow based tunneling), and that old code worked with GTPv0 and GTPv1,
then your modifications must make sure that they continue to support
GTPv0 and v1 in the "classic tunnel" use case.

If your new code for flow-based tunneling simply only implements v0, it
is fine to me - but then those restrictions must be in the flow-based
part only, and things must be consistent.  I.e. in this case, for the
flow-based tunnel approach you must not bind the v0 port, if you don't
handle related packets.

> Should I explicitly claim that the flow-based change is for GTPv1
> only?

That's definitely important, too - but is not the point I raised (see
above).

> > > +	setup_udp_tunnel_sock(net, sock1u, &tunnel_cfg);
> > 
> > even here, you're only setting up the v1 and not v0.
> 
> same reason as above.

yes, but if I read your code correctly, this is generic/shared code that
will break the existing GTPv0 support in the "classic tunnel" case!

> > > +	/* Assume largest header, ie. GTPv0. */
> > > +	dev->needed_headroom	= LL_MAX_HEADER +
> > > +		sizeof(struct iphdr) +
> > > +		sizeof(struct udphdr) +
> > > +		sizeof(struct gtp0_header);
> > 
> > ... and here you're using headroom for a GTPv0 header, despite (I think)
> > only supporting GTPv1 from this configuration?
> 
> Yes, only GTPv1 is supported.

well, then I suggest you don't generate headroom for a v0 header (which
is larger) in a v1-only code path :)

> > > +	err = gtp_hashtable_new(gtp, GTP_PDP_HASHSIZE); // JO: when to free??
> > 
> > I think that question about when to free needs to be resolved before any
> > merge.  Did you check that it persists even after the device is
> > closed/removed?
> 
> I didn't investigate it. What do you mean by persist?

"persist" means "remains allocated after the release of the network
device".  Whatever you allocate during device creation you must
de-allocate on device release.  I cannot tell you when exactly (as I'm
not familiar with OVS or flow-based tunneling, as indicateD).  However,
I know for sure we cannot introduce code that looks like it introduces
memory leaks to the kernel :)

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
