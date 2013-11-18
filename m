From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] Revert "af-packet: Use existing netdev reference
 for bound sockets"
Date: Tue, 19 Nov 2013 00:39:29 +0100
Message-ID: <528AA531.3000305@redhat.com>
References: <1384760425-37658-1-git-send-email-noureddine@aristanetworks.com> <5289D745.5020200@redhat.com> <20131118.130310.1183708218770881544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: noureddine@aristanetworks.com, willemb@google.com, phil@nwl.cc,
	edumazet@google.com, netdev@vger.kernel.org,
	greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064Ab3KRXkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 18:40:05 -0500
In-Reply-To: <20131118.130310.1183708218770881544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2013 07:03 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Mon, 18 Nov 2013 10:00:53 +0100
>
>> On 11/18/2013 08:40 AM, Salam Noureddine wrote:
>>> This reverts commit 827d978037d7d0bf0860481948c6d26ead10042f
>>> ("af-packet: Use existing netdev reference for bound sockets")
>>>
>>> The patch introduced a race condition between packet_snd and
>>> packet_notifier when a net_device is being unregistered. In the case
>>> of
>>> a bound socket, packet_notifier can drop the last reference to the
>>> net_device and packet_snd might end up sending a packet over a freed
>>> net_device.
>>
>> So there's no other workaround possible like e.g. setting a flag in
>> struct packet_sock so that in case our netdevice goes down, we just
>> set the flag and if set, we return with -ENXIO in send path?
>> Reverting this would decrease performance for everyone as we would
>> then do the lookup every time we send a packet again.
>
> Agreed, we should try first to find a reasonable fix instead of just
> doing a knee-jerk revert of this change.

Salam, could you give the below a try on your side ?

I tried reproducing this with trafgen, but couldn't so far, meaning
everything worked (before/after). Having that said, it could also be
that I'm currently just having a really crappy nic (asix) at hand.

Let me know, thanks !

 From 26caa771c0c7d53b28afafc76f1b91ab36a34e73 Mon Sep 17 00:00:00 2001
From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 18 Nov 2013 23:31:11 +0100
Subject: [PATCH] packet: don't send packets after we unregistered proto hook

Salam reported a use after free bug in PF_PACKET that occurs when
we're sending out frames on a socket bound device and suddenly the
netdevice is being unregistered.

Salam says:

   Commit 827d9780 introduced a race condition between packet_snd
   and packet_notifier when a net_device is being unregistered. In
   the case of a bound socket, packet_notifier can drop the last
   reference to the net_device and packet_snd might end up sending
   a packet over a freed net_device.

To avoid reverting 827d9780, we could make use of po->running member
that gets reset when we're calling __unregister_prot_hook() in
packet_notifier() when we receive NETDEV_DOWN notification. In
that case we receive NETDEV_DOWN before NETDEV_UNREGISTER where
prot_hook.dev is set to NULL, so that we could make sure to
leave send path early with -ENETDOWN, which corresponds also
to our notification.

Fixes: 827d978037d7 ("af-packet: Use existing netdev reference for bound sockets.")
Reported-by: Salam Noureddine <noureddine@aristanetworks.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
  net/packet/af_packet.c | 4 ++--
  1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2e8286b..e3f64f2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2094,7 +2094,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
  	reserve = dev->hard_header_len;

  	err = -ENETDOWN;
-	if (unlikely(!(dev->flags & IFF_UP)))
+	if (unlikely(!(dev->flags & IFF_UP) || !po->running))
  		goto out_put;

  	size_max = po->tx_ring.frame_size
@@ -2250,7 +2250,7 @@ static int packet_snd(struct socket *sock,
  		reserve = dev->hard_header_len;

  	err = -ENETDOWN;
-	if (!(dev->flags & IFF_UP))
+	if (unlikely(!(dev->flags & IFF_UP) || !po->running))
  		goto out_unlock;

  	if (po->has_vnet_hdr) {
-- 
1.8.3.1
