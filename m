From: Patrick McHardy <kaber@trash.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Thu, 17 May 2007 18:52:29 +0200
Message-ID: <464C884D.4010100@trash.net>
References: <Line.LNX.4.64.0705141430120.8521@d.namei> <4648AE85.6020608@trash.net> <4648B656.6030800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080500000404090109080108"
Cc: netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	Curtis Doty <Curtis@GreenKey.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33708 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850AbXEQQxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 12:53:10 -0400
In-Reply-To: <4648B656.6030800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080500000404090109080108
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
>>>BUG: unable to handle kernel NULL pointer dereference at virtual address
>>>000000a8
>>>[...]
>>>EIP is at inet_select_addr+0x4/0x9f
>>>Call Trace:
>>>[<f8b97046>] reject+0x0/0x4ae [ipt_REJECT]
>>>[<c05fd0b6>] icmp_send+0x14d/0x39b
>>
>>
>>A REJECT target in the output chain will trigger this in combination
>>with icmp_errors_use_inbound_ifaddr because skb->dev is still NULL
>>at this point and its passed to inet_select_addr.
>>
>>I'll look into this.
> 
> 
> 
> saddr = iph->daddr;
> if (!(rt->rt_flags & RTCF_LOCAL)) {
>         if (sysctl_icmp_errors_use_inbound_ifaddr)
> 
> 
>                 saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
>         else
>                 saddr = 0;
> }
> 
> Fixing the crash is easy, the right thing to do when skb->dev
> is not set is to let routing choose the address because the
> packet was locally generated and icmp_errors_use_inbound_ifaddr
> shouldn't apply (the crash can also happen with IPsec tunnels
> by the way).
> 
> This leaves the question what to do in the path after ip_output,
> when skb->dev points to the output device. We don't know the
> input device anymore, so there doesn't seem to be a way to make
> it do what the sysctl promises.


The last problem seems to be unfixable, so this patch fixes the crash
and adds a comment about the brokeness of this option.


--------------080500000404090109080108
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV4]: icmp: fix crash with sysctl_icmp_errors_use_inbound_ifaddr

When icmp_send is called on the local output path before the
packet hits ip_output, skb->dev is not set, causing a crash
when sysctl_icmp_errors_use_inbound_ifaddr is set. This can
happen with the netfilter REJECT target or IPsec tunnels.

Let routing decide the ICMP source address in that case, since the
packet is locally generated there is no inbound interface and
the sysctl should not apply.

The option actually seems to be unfixable broken, on the path
after ip_output() skb->dev points to the outgoing device and
we don't know the incoming device anymore, so its going to do
the absolute wrong thing and pick the address of the outgoing
interface. Add a comment about this.

Reported by Curtis Doty <Curtis@GreenKey.net>.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 637fc540b0ad22bf7971929e906e704236af06cd
tree 0c32138983e1bd7cc9ac96e7c62085e9b74b6217
parent 52ade9b3b97fd3bea42842a056fe0786c28d0555
author Patrick McHardy <kaber@trash.net> Thu, 17 May 2007 18:50:13 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 17 May 2007 18:50:13 +0200

 net/ipv4/icmp.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index d38cbba..e238b17 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -514,7 +514,10 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 	saddr = iph->daddr;
 	if (!(rt->rt_flags & RTCF_LOCAL)) {
-		if (sysctl_icmp_errors_use_inbound_ifaddr)
+		/* This is broken, skb_in->dev points to the outgoing device
+		 * after the packet passes through ip_output().
+		 */
+		if (skb_in->dev && sysctl_icmp_errors_use_inbound_ifaddr)
 			saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
 		else
 			saddr = 0;

--------------080500000404090109080108--
