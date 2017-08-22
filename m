From: Ben Pfaff <blp-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Tue, 22 Aug 2017 10:35:13 -0700
Message-ID: <20170822173513.GM6175@ovn.org>
References: <20170821061109.GA72656@cran64.bj.intel.com>
	<20170821101925.3f9b36a1@griffin>
	<20170821083900.GA74649@cran64.bj.intel.com>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
	<20170821113514.6f0ec15e@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
	<20170821115106.70fa1e1d@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A5C7@ESESSMB107.ericsson.se>
	<20170821135019.5c65b888@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7274C9FB@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274C9FB-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
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

On Tue, Aug 22, 2017 at 08:32:49AM +0000, Jan Scheurich wrote:
> > > Or why else does OVS user space code take so great pain to model
> > > possible misalignment and provide/use safe access functions?
> > 
> > I don't know how the ovs user space deals with packet allocation. In
> > the kernel, the network header is aligned in a way that it allows
> > efficient 32bit access.
> 
> It seems that OVS has not had the same approach as Linux. There is no
> config parameter covering the alignment characteristics of the machine
> architecture. For packets buffers received from outside sources
> (e.g. DPDK interfaces) they make no assumptions on alignment and play
> safe. For packets allocated inside OVS, the Ethernet packet is
> typically stored so that the L3 header is 32-bit aligned, so that the
> misalignment precautions would be unnecessary. But I didn't check all
> code paths.

We solved the alignment problem in OVS userspace a different way, by
defining our versions of the network protocol headers so that they only
need 16-bit alignment.  In turn, we did that by defining a
ovs_16aligned_be32 type as a pair of be16s and ovs_16aligned_be64 as
four be16s, and using helper functions for reads and writes.  This made
it harder to screw up alignment in a subtle way and only find out long
after release when someone tested a corner case on a RISC architecture.
It probably has a performance cost on those RISC architectures, for the
cases where the access really is aligned, but it's more obviously
correct and I highly value that for OVS userspace.

As far as I can tell it's not actually possible, in the general case, to
add padding such that all parts of a packet are aligned.  VXLAN is the
case that comes to mind.  With VXLAN, as far as I can tell, the 14-byte
inner Ethernet header mean that you can align either the outer IPv4
header or the inner IPv4 header, but not both.  That means that no
matter how careful OVS is about aligning packets, it would still have to
deal with unaligned accesses in some cases.

I see that the VXLAN issue has come up in Linux before:
https://www.ietf.org/mail-archive/web/nvo3/current/msg05743.html
