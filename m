From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
Date: Thu, 15 Oct 2015 06:41:42 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC350F7AE54A@ORSMSX101.amr.corp.intel.com>
References: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
 <20151013085600.GA23077@pox.localdomain>
 <E4CD12F19ABA0C4D8729E087A761DC350F7AC0AA@ORSMSX101.amr.corp.intel.com>
 <20151014074436.GE3266@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919AbbJOGlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 02:41:44 -0400
In-Reply-To: <20151014074436.GE3266@pox.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Thomas Graf
>Sent: Wednesday, October 14, 2015 12:45 AM
>To: Arad, Ronen
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
>
>On 10/13/15 at 05:52pm, Arad, Ronen wrote:
>> [@Ronen] My reader as I described above is providing a larger message
>> which I'm trying to properly size. I'm aware that libnl shields
>> applications from the need to know and provide properly sized buffer by
>> peeking or/and re-allocating a buffer.
>> My issue is with iproute2 "ip link show" and "bridge vlan show" commands.
>
>>
>> >I'm just trying to understand which exact case you are solving here.
>> Allocation is always performed by alloc_size which could be
>> nlk->max_recvmsg_len (only when min_dump_alloc is sufficiently small) and
>> upon failure falling back to alloc_min_size.
>> The trimming of the skb space is common regardless of the allocation call.
>> I tried to submit the minimal patch to address the issue. If you think the
>> Re-organized code is better I can re-submit a V2.
>
>I was about to suggest the same code change after initial discussion ;-)
>
>So you are fixing the case where >2x messages fit the padded skb size.
[@Ronen] I'm not sure I understand this statement. I'm fixing the padding
of the skb such that reader could have reasonable buffer size based on the
largest netdev. It is just happened that the skb allocation was about
double the size. Probably because the allocation was some kind of power
of 2 and the requested size was slightly above the next lower power of 2.

On a separate patch titled 
[PATCH net-next v3] netlink: Rightsize IFLA_AF_SPEC size calculation
I'm reducing the over-estimation of the buffer size for "ip link"
requests. It turned out that VLAN information space was added to
unrelated dump requests since ext_filter_mask was not passed to
rtnl_link_get_af_size().
The "rightsizing" patch also reduces the buffer size of compressed VLANs
dump. Non-compressed VLANs dump will continue to require more than the
16KiB buffer size from somewhere around 1800 VLANs and above (based on
8 bytes per VLAN plus other attributes consuming about 1700 bytes).
Using the same logic the full range of 4094 VLANs uncompressed would take
Roughly 34500 bytes. It looks like a "safe" iproute2 statically sized
Buffer would have to be about 36000 bytes or so.

>This was not clear from the commit message. I would appreciate a note
>in the commit message and updated code comment to reflect this.
>
>The fix is definitely not incorrect and the penalty for readers which
>peek first is less than I thought since nlk->max_recvmsg_len is at
>least 16K in size. Since most peekers will double buffer sizes they
>will most likely end up growing nlk->max_recvmsg_len after the first
>read.
[@Ronen] nlk->max_recvmsg_len is actually capped at 16KiB.
/* Record the max length of recvmsg() calls for future allocations */
nlk->max_recvmsg_len = max(nlk->max_recvmsg_len, len);
nlk->max_recvmsg_len = min_t(size_t, nlk->max_recvmsg_len, 16384);
>
>However, if alloc_size is > 16K, we would have typically ended up with a
>giant skb which peeking users were able to take advantage of while
>with this fix this is no longer the case.
[@Ronen] As I noted above, peeking reader could only enjoy saving up to 
16KiB.
>
>However #2, I'll see if it makes sense to look at MSG_PEEK in recvmsg
>and change nlk->max_recvmsg_len accordingly so we take advantage of
>the full skb size on sockets which perform peeking. Given that both
>reader behaviours can be preserved, I'm good with your proposed v2.
[@Ronen] I'll submit by suggested v2.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
