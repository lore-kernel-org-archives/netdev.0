From: Ben Greear <greearb@candelatech.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Sat, 29 Jun 2013 09:31:54 -0700
Message-ID: <51CF0BFA.4080308@candelatech.com>
References: <51CBAA48.3080802@oracle.com>    <1372311118.3301.214.camel@edumazet-glaptop>  <51CD0E67.4000008@oracle.com>    <1372402340.3301.229.camel@edumazet-glaptop>   <1372412262.3301.251.camel@edumazet-glaptop> <51CE1E19.3020108@oracle.com>  <1372490428.3301.300.camel@edumazet-glaptop>  <51CF0723.9020604@candelatech.com> <1372523168.3301.302.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Jin <joe.jin@oracle.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zheng.x.li@oracle.com" <zheng.x.li@oracle.com>,
	Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36416 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab3F2QcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 12:32:12 -0400
In-Reply-To: <1372523168.3301.302.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2013 09:26 AM, Eric Dumazet wrote:
> On Sat, 2013-06-29 at 09:11 -0700, Ben Greear wrote:
>
>> Do you know if your patch should go in 3.9?
>>
>
> Yes it should.

Ok, I'll add that to my tree.

>> Your test case sounds a bit like what gives us the rare crash in tcp_collapse
>> (we have lots of bouncing wifi interfaces running slow-speed TCP trafic).  But,
>> it takes days for us to hit the problem most of the time.
>
> Well, unfortunately that's a different problem :(

For what it's worth, I added this patch to my tree.  We haven't hit the problem
since, but perhaps on the over-the-weekend run we'll see it.


commit 0286716b36a0e5b82c385052a0971f44bc3c3442
Author: Ben Greear <greearb@candelatech.com>
Date:   Tue Jun 25 15:49:52 2013 -0700

     tcp:  Try to work around crash in tcp_collapse.

     And print out some info about why it crashed.

     Signed-off-by: Ben Greear <greearb@candelatech.com>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a2f267a..63f7704 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4810,7 +4810,15 @@ restart:
                         int offset = start - TCP_SKB_CB(skb)->seq;
                         int size = TCP_SKB_CB(skb)->end_seq - start;

-                       BUG_ON(offset < 0);
+                       if (WARN_ON(offset < 0)) {
+                               /* We see a crash here (when using BUG_ON) every few days under
+                                * some torture tests.  I'm not sure how to clean this up properly,
+                                * so just return and hope thinks keep muddling through. --Ben
+                                */
+                               printk("offset: %i  start: %i seq: %i size: %i copy: %i\n",
+                                      offset, start, TCP_SKB_CB(skb)->seq, size, copy);
+                               return;
+                       }
                         if (size > 0) {
                                 size = min(copy, size);
                                 if (skb_copy_bits(skb, offset, skb_put(nskb, size), size))



Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
