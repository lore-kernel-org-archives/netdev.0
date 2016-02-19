From: =?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Subject: Re: [PATCH v4 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Fri, 19 Feb 2016 15:12:01 +0100
Message-ID: <56C722B1.5090504@gmail.com>
References: <1455630663-18400-1-git-send-email-bro.devel+kernel@gmail.com>
 <1455630663-18400-3-git-send-email-bro.devel+kernel@gmail.com>
 <1455808685.648.16.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37216 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947080AbcBSOME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 09:12:04 -0500
Received: by mail-wm0-f41.google.com with SMTP id g62so72816019wme.0
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 06:12:03 -0800 (PST)
In-Reply-To: <1455808685.648.16.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2016 04:18 PM, Eric Dumazet wrote:
>>  
>> -static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>> +void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>>  {
>>  	__copy_skb_header(new, old);
>>  
>> @@ -1061,6 +1061,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>>  	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
>>  	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
>>  }
>> +EXPORT_SYMBOL(copy_skb_header);
> 
> Why are you exporting this ? tcp is statically linked into vmlinux.

Ah, this is actually leftover from the earlier module based
implementation of RDB. Will remove.

>> +EXPORT_SYMBOL(skb_append_data);
> 
> Same remark here.

Will remove.

> And this is really a tcp helper, you should add a tcp_ prefix.

Certainly.

> About rdb_build_skb() : I do not see where you make sure
> @bytes_in_rdb_skb is not too big ?

The number of previous SKBs in the queue to copy data from is given
by rdb_can_bundle_test(), which tests if total payload does not
exceed the MSS. Only if there is room (within the MSS) will it test
the sysctl options to further restrict bundling:

+       /* We start at xmit_skb->prev, and go backwards. */
+       tcp_for_write_queue_reverse_from_safe(skb, tmp, sk) {
+               if ((total_payload + skb->len) > mss_now)
+                       break;
+
+               if (sysctl_tcp_rdb_max_bytes &&
+                   ((total_payload + skb->len) > sysctl_tcp_rdb_max_bytes))
+                       break;

I'll combine these two to (total_payload + skb->len) > max_payload

> tcp_rdb_max_bytes & tcp_rdb_max_packets seem to have no .extra2 upper
> limit, so a user could do something really stupid and attempt to crash
> the kernel.

Those sysctl additions are actually a bit buggy, specifically the
proc_handlers.

Is it not sufficient to ensure that 0 is the lowest possible value?
The max payload limit is really min(mss_now, sysctl_tcp_rdb_max_bytes),
so if sysctl_tcp_rdb_max_bytes or sysctl_tcp_rdb_max_packets are set too
large, bundling will simply be limited by the MSS.

> Presumably I would use SKB_MAX_HEAD(MAX_TCP_HEADER) so that we do not
> try high order page allocation.

Do you suggest something like this?:
bytes_in_rdb_skb = min_t(u32, bytes_in_rdb_skb, SKB_MAX_HEAD(MAX_TCP_HEADER));

Is this necessary when bytes_in_rdb_skb will always contain exactly
the required number of bytes for the payload of the (RDB) packet,
which will never be greater than mss_now?

Or is it aimed at scenarios where the page size is so small that
allocating to an MSS (of e.g. 1460) will require high order page
allocation?


Thanks for looking over the code!

Bendik
