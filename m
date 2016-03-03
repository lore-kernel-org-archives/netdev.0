From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl
 adjustments
Date: Thu, 3 Mar 2016 15:32:29 +0100
Message-ID: <20160303143229.GC18624@orbyte.nwl.cc>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
 <499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
 <20160302095414.45a928df@xeon-e3>
 <56D84863.5090203@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53115 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbcCCOcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 09:32:31 -0500
Content-Disposition: inline
In-Reply-To: <56D84863.5090203@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Mar 03, 2016 at 09:21:23AM -0500, Jamal Hadi Salim wrote:
> On 16-03-02 12:54 PM, Stephen Hemminger wrote:
> > On Wed, 2 Mar 2016 11:20:31 +0000
> > Phil Sutter <phil@nwl.cc> wrote:
> >
> >> +		res = parse_cmd(&argc, &argv, 1, TU32,0x0f,sel,tkey);
> >>   		goto done;
> > Please add whitespace after ,
> >
> 
> There are a few whitespace issues in that code that would be nice to fix
> given the cleanup opportunity.

In v2, I added a separate patch which makes that file conform to
checkpatch.pl (used the --fix-inplace option and tweaked the output a
bit). So that should be fine already.

> The patches look good to me. Phil, maybe get rid of that comment at the
> top which was worrying about endianness. I think you fixed it.

I'm not so sure. The kernel explicitly takes care to get the bit
ordering right:

| struct iphdr
|   {
| #if __BYTE_ORDER == __LITTLE_ENDIAN
|     unsigned int ihl:4;
|     unsigned int version:4;
| #elif __BYTE_ORDER == __BIG_ENDIAN
|     unsigned int version:4;
|     unsigned int ihl:4;
| #else
| # error "Please fix <bits/endian.h>"
| #endif

act_pedit though just mangles the whole byte as-is, and if that was
correct, we would not have to go that extra mile in struct iphdr, or do
we?

> Your tests in patch 0 are nice and could go in tests/ directory.
> I can send you some of the basic tests i run via the kernel; they look
> something of the form:
> 
> #
> #RFC
> #dst MAC starts at -14
> #src MAC at -8
> #ethertype at -2
> #
> #
> tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
> match ip src 192.168.1.10/32 flowid 1:2 \
> action pedit munge offset -14 u16 set 0x0000 \
> munge offset -12 u32 set 0x00010100 \
> munge offset -8 u32 set 0x0aaf0100 \
> munge offset -4 u32 set 0x0008ec06 pipe \
> action mirred egress redirect dev eth1
> #
> #
> 
> These would of course require more of a larger setup to vet
> and running tcpdump to check the correct bytes are being
> modified.

Since I am lazy, I wanted to have as much automation as possible while
testing. Therefore I just assumed that act_pedit does the right thing
all the time, and iproute just has to feed it correct values. Given the
scope of this patch, this is also completely sufficient. Of course, the
tests/ directory would benefit more from a full test. But since
automation then becomes tricky, I'm not sure it makes much sense to
deliberately write code for that.

Thanks for the review,

Phil
