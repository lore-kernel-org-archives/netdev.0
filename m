From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling fib_lookup()
Date: Tue, 22 Mar 2016 13:45:17 -0700
Message-ID: <CAM_iQpV6srT84xa4y0WHrKG0mbO2xs=rnKKCx1XB9FtWusxCgw@mail.gmail.com>
References: <1458660679-7279-1-git-send-email-lrichard@redhat.com>
	<56F18EEE.4070000@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lance Richardson <lrichard@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:33828 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbcCVUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 16:45:18 -0400
Received: by mail-yw0-f181.google.com with SMTP id h129so270192710ywb.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 13:45:18 -0700 (PDT)
In-Reply-To: <56F18EEE.4070000@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 11:29 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 3/22/16 9:31 AM, Lance Richardson wrote:
>>
>> Field fl4.flowi4_flags is not initialized in fib_compute_spec_dst()
>> before calling fib_lookup(), which means fib_table_lookup() is
>> using non-deterministic data at this line:
>>
>>         if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {
>>
>> Fix by initializing fl4.flowi4_flags to zero.
>>
>> Signed-off-by: Lance Richardson <lrichard@redhat.com>
>> ---
>>   net/ipv4/fib_frontend.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
>> index 21add55..896844a 100644
>> --- a/net/ipv4/fib_frontend.c
>> +++ b/net/ipv4/fib_frontend.c
>> @@ -304,6 +304,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
>>                 fl4.flowi4_scope = scope;
>>                 fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark :
>> 0;
>>                 fl4.flowi4_tun_key.tun_id = 0;
>> +               fl4.flowi4_flags = 0;
>>                 if (!fib_lookup(net, &fl4, &res, 0))
>>                         return FIB_RES_PREFSRC(net, res);
>>         } else {
>>
>
> Fixes: 58189ca7b2741 ("net: Fix vti use case with oif in dst lookups")

Why does this patch fix this commit? Even before this commit, flowi4_flags
was already tested for other bit:


@@ -1426,7 +1426,7 @@ int fib_table_lookup(struct fib_table *tb, const
struct flowi4 *flp,
                            nh->nh_flags & RTNH_F_LINKDOWN &&
                            !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
                                continue;
-                       if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+                       if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {
                                if (flp->flowi4_oif &&
                                    flp->flowi4_oif != nh->nh_oif)
                                        continue;

For me, it looks the bug was introduce by commit 35ebf65e851c6d9731abc6362b1.
