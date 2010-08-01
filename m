From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Sun, 01 Aug 2010 12:50:16 +0200
Message-ID: <4C555168.3090800@hartkopp.net>
References: <4C529EFB.4090601@hartkopp.net>
	<20100801.010337.68133932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100801.010337.68133932.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01.08.2010 10:03, David Miller wrote:
> From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Date: Fri, 30 Jul 2010 11:44:27 +0200
> 
>> Hello Eric, hello Patrick,
>>
>> Commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 (net: Introduce
>> skb_orphan_try()) allows an early orphan of the skb and takes care on
>> tx timestamping, which needs the sk-reference in the skb on driver level.
>> So does the can-raw socket, which has not been taken into account here.
>>
>> The patch below adds a 'prevent_sk_orphan' bit in the skb tx shared info,
>> which fixes the problem discovered by Matthias Fuchs here:
>>
>>       http://marc.info/?t=128030411900003&r=1&w=2
> 
> Your patch sets this new value, but I never see it getting tested anywhere.
> 
> How does this work?


The flags are tested all together in skb_orphan_try() ...

See at

http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5

+/*
+ * Try to orphan skb early, right before transmission by the device.
+ * We cannot orphan skb if tx timestamp is requested, since
+ * drivers need to call skb_tstamp_tx() to send the timestamp.
+ */
+static inline void skb_orphan_try(struct sk_buff *skb)
+{
+       if (!skb_tx(skb)->flags)
+               skb_orphan(skb);
+}

So my patch just added a new bit that's tested here but does not touch the
rest of the tx timestamp bits that are checked at this place.

Regards,
Oliver
