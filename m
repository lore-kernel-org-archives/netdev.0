From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
Date: Tue, 13 Oct 2015 17:52:29 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC350F7AC0AA@ORSMSX101.amr.corp.intel.com>
References: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
 <20151013085600.GA23077@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18706 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932515AbbJMRwl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 13:52:41 -0400
In-Reply-To: <20151013085600.GA23077@pox.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Thomas Graf [mailto:tgraf@suug.ch]
>Sent: Tuesday, October 13, 2015 1:56 AM
>To: Arad, Ronen
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
>
>On 10/12/15 at 06:15pm, Ronen Arad wrote:
>> The available room in the skb allocated in netlink_dump for iproute2
>> show requests (e.g. "ip link [show]", "bridge [-c] vlan show") should
>> be trimmed to the exact size requested in order to avoid MSG_TRUNC flag
>> set in netlink_recvmg.
>> This was handled properly for small skb allocated when no interface has
>> many VLANs configured. This patch applies the same logic to larger skbs
>> which are allocated using the calculated min_dump_alloc size.
>>
>> Signed-off-by: Ronen Arad <ronen.arad@intel.com>
>
>Wouldn't this imply a bug in which rtnl_calcit() does not account for
>some data that is later dumped?
[@Ronen] rtnl_calcit() is not bug-free. It is not, however, the direct
cause of the problem this patch intends to solve.
rtnl_calcit() overestimates the min_alloc_size. The space for VLAN_INFO for
the maximum number ov VLANs on any interface is always added to
min_alloc_size even when the dump request does not specify VLAN or
compressed VLANs. The overestimation is because if_nlmsg_size() does not
pass ext_filter_mask to  rtnl_link_get_af_size() or rtnl_link_get_size().
(ext_filter_mask is passed to rtnl_vfinfo_size() and rtnl_port_size())
 
>How else could the skb end up being
>larger than what alloc_size accounts for at this point unless we end
>up stuffing 2x smallish messages into the padded projection of the
>calculated maximum message size of that type.
[@Ronen] The skb size (i.e. the tailroom of a newly allocated skb) is
greater than the argument passed to netlink_skb_alloc(). I didn't fully
looked at the allocation mechanism (there could be multiple ways and
netlink skbs could be memory mapped)). My understanding is that this is
expected as indicated by the comment in the code.

Netlink dump by design attempts to pack as many smallish messages into the
same skb to minimize the number of parts of a multi-part dump response.
The min_alloc_size is intended to guarantee drivers/modules sufficient
space for the largest dump message of a single netdev. 

>Is that what you are
>seeing?

[@Ronen] My initial observation was that with many VLANs configured, the 
min_alloc_size is greater than the 16KiB buffer iproute2 uses for both
"ip link show" and "bridge [-c[ompressvlans]] vlan show" commands. This buf
is defined locally within iproute2's lib/libnetlink.c.
Each VLAN_INFO attribute takes 8 bytes. 4094 VLANs requires 32,752 bytes.
Compressed VLANs would need a lot less (at the extreme only 8 bytes for a
single range covering the entire 1-4094 or any other range).

I bumped iproute2 buffer size from 16KiB to 3*16KiB when I first noticed
"Message truncated" error from "ip" and "bridge" commands. I was surprised
when such a large buffer remained insufficient for a system with more
interfaces.

The root cause is that the skb is allocated with more space than requested
and the dump is allowed to use this extra space available. In my case I
observed skb allocated with total space of 65,216 bytes when 34,420
were requested.
 
>
>Regardless of that, alloc_size is likely larger than nlk->max_recvmsg_len
>anyway at this point so unless the reader suddenly provides a different
>message size or does peeking it will likely still be truncated.
>
[@Ronen] My reader as I described above is providing a larger message
which I'm trying to properly size. I'm aware that libnl shields
applications from the need to know and provide properly sized buffer by
peeking or/and re-allocating a buffer.
My issue is with iproute2 "ip link show" and "bridge vlan show" commands.
 
>I'm just trying to understand which exact case you are solving here.
[@Ronen] My patch applies the same logic that is used when allocation is
done by nlk->max_recvmsg_len to allocation that is done by min_alloc_size.
The code could be clearer like that:

	/* NLMSG_GOODSIZE is small to avoid high order allocations being
	 * required, but it makes sense to _attempt_ a 16K bytes allocation
	 * to reduce number of system calls on dump operations, if user
	 * ever provided a big enough buffer.
	 */
	cb = &nlk->cb;
	alloc_min_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);

	if (alloc_min_size < nlk->max_recvmsg_len) {
		alloc_size = nlk->max_recvmsg_len;
		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
					GFP_KERNEL |
					__GFP_NOWARN |
					__GFP_NORETRY);
	}
	if (!skb) {
		alloc_size = alloc_min_size;
		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
					GFP_KERNEL);
	}
	if (!skb)
		goto errout_skb;
	/* available room should be exact amount to avoid MSG_TRUNC */
      skb_reserve(skb, skb_tailroom(skb) - alloc_size);

Allocation is always performed by alloc_size which could be
nlk->max_recvmsg_len (only when min_dump_alloc is sufficiently small) and
upon failure falling back to alloc_min_size.
The trimming of the skb space is common regardless of the allocation call.
I tried to submit the minimal patch to address the issue. If you think the
Re-organized code is better I can re-submit a V2.


 
