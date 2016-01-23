From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on inactive
 slaves
Date: Sat, 23 Jan 2016 09:26:36 +0100
Message-ID: <20160123082636.GC2193@nanopsycho.orion>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <14563.1453496352@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33811 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbcAWI0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 03:26:39 -0500
Received: by mail-wm0-f67.google.com with SMTP id b14so1886684wmb.1
        for <netdev@vger.kernel.org>; Sat, 23 Jan 2016 00:26:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <14563.1453496352@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 22, 2016 at 09:59:12PM CET, jay.vosburgh@canonical.com wrote:
>Jarod Wilson <jarod@redhat.com> wrote:
>
>>The network core tries to keep track of dropped packets, but some packets
>>you wouldn't really call dropped, so much as intentionally ignored, under
>>certain circumstances. One such case is that of bonding and team device
>>slaves that are currently inactive. Their respective rx_handler functions
>>return RX_HANDLER_EXACT (the only places in the kernel that return that),
>>which ends up tracking into the network core's __netif_receive_skb_core()
>>function's drop path, with no pt_prev set. On a noisy network, this can
>>result in a very rapidly incrementing rx_dropped counter, not only on the
>>inactive slave(s), but also on the master device, such as the following:
>[...]
>>In this scenario, p5p1, p5p2 and p7p1 are all inactive slaves in an
>>active-backup bond0, and you can see that all three have high drop counts,
>>with the master bond0 showing a tally of all three.
>>
>>I know that this was previously discussed some here:
>>
>>    http://www.spinics.net/lists/netdev/msg226341.html
>>
>>It seems additional counters never came to fruition, but honestly, for
>>this particular case, I'm not even sure they're warranted, I'd be inclined
>>to say just silently drop these packets without incrementing a counter. At
>>least, that's probably what would make someone who has complained loudly
>>about this issue happy, as they have monitoring tools that are squaking
>>loudly at any increments to rx_dropped.

In this case, it is delivered with exact delivery according to per-dev
registered callback. We just have to avoid it gets to bond. So this case
is not "to drop", but rather "to block skb to don't get where it does
not belong".

>
>	I don't think the kernel should silently drop packets; there
>should be a counter somewhere.  If a packet is being thrown away
>deliberately, it should not just vanish into the screaming void of
>space.  Someday someone will try and track down where that packet is
>being dropped.
>
>	I've had that same conversation with customers who insist on
>accounting for every packet drop (from the "any drop is an error"
>mindset), so I understand the issue.
>
>	Thinking about the prior discussion, the rx_drop_inactive is
>still a good idea, but I'd actually today get good use from a
>"rx_drop_unforwardable" (or an equivalent but shorter name) counter that
>counts every time a packet is dropped due to is_skb_forwardable()
>returning false.  __dev_forward_skb does this (and hits rx_dropped), as
>does the bridge (and does not count it).
>
>	-J
>
>>CC: "David S. Miller" <davem@davemloft.net>
>>CC: Eric Dumazet <edumazet@google.com>
>>CC: Jiri Pirko <jiri@mellanox.com>
>>CC: Daniel Borkmann <daniel@iogearbox.net>
>>CC: Tom Herbert <tom@herbertland.com>
>>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>CC: Veaceslav Falico <vfalico@gmail.com>
>>CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>>CC: netdev@vger.kernel.org
>>Signed-off-by: Jarod Wilson <jarod@redhat.com>
>>---
>> net/core/dev.c | 3 +++
>> 1 file changed, 3 insertions(+)
>>
>>diff --git a/net/core/dev.c b/net/core/dev.c
>>index 8cba3d8..1354c7b 100644
>>--- a/net/core/dev.c
>>+++ b/net/core/dev.c
>>@@ -4153,8 +4153,11 @@ ncls:
>> 		else
>> 			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>> 	} else {
>>+		if (deliver_exact)
>>+			goto inactive; /* bond or team inactive slave */
>> drop:
>> 		atomic_long_inc(&skb->dev->rx_dropped);
>>+inactive:
>> 		kfree_skb(skb);
>> 		/* Jamal, now you will not able to escape explaining
>> 		 * me how you were going to use this. :-)
>>-- 
>>1.8.3.1
>>
>
>---
>	-Jay Vosburgh, jay.vosburgh@canonical.com
