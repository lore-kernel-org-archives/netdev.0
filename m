From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Wed, 7 Jan 2015 11:01:18 +0000
Message-ID: <20150107110118.GO21820@casper.infradead.org>
References: <CAADnVQ+EO34qYbK+sji-Da3CMkn+-V-9Uvdar_WgxRQ4_+JFXA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC2740@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33209 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbbAGLBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 06:01:21 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC2740@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 10:03am, David Laight wrote:
> From: Alexei Starovoitov
> > On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > > +struct vxlan_gbp {
> > > +#ifdef __LITTLE_ENDIAN_BITFIELD
> > > +       __u8    reserved_flags1:3,
> > ...
> > > +       __be16 policy_id;
> > > +} __packed;
> > 
> > are you sure that compiler will be smart enough
> > to do single short load when you pack
> > u8 + struct vxlan_gbp inside struct vxlanhdr ?
> > I suspect compiler will use two byte loads
> > with shifts and ors every time to access policy_id.
> > Even it works ok, I think this struct layout is ugly.
> > imo would be much easier to read if you replace
> > the whole vxlanhdr with vxlanhdr_gbp
> > or split vxlanhdr into two 32-bit structs.
> > then __packed hacks won't be needed.

If I read objdump output correctly, gcc seems fine with it:

        /* For backwards compatibility, only allow reserved fields to be
         * used by VXLAN extensions if explicitly requested.
         */
        if (vs->exts) {
                if (!vxh->vni_present)
    2640:       41 0f b6 55 08          movzbl 0x8(%r13),%edx
    2645:       f6 c2 08                test   $0x8,%dl
    2648:       74 c2                   je     260c <vxlan_udp_encap_recv+0x9c>
    [...]
                        md.gbp = ntohs(vxh->gbp.policy_id);
    2652:       41 0f b7 55 0a          movzwl 0xa(%r13),%edx

Let me know what I have to do/provide to validate this properly.

> Also, if you are writing the values then you need to write
> all the members of the bitfield in order to get a single write.
> 
> Basically you are much better off using explicit masks.

I went back and forth on this and chose to use individual bit fields
and map them to a static bit definition which is exported via Netlink.
That way the user space Netlink interface remains stable should the
wire protocol ever change. Yes, this implies some branching which could
be avoided right now as long as user and wire protocol are identical. I
did not observe any performance differences in benchmarks though.
