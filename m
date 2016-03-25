From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Thu, 24 Mar 2016 22:06:25 -0700
Message-ID: <CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com>
	<CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
	<56F4810A.9060904@candelatech.com>
	<56F49036.8050902@candelatech.com>
	<56F490B2.3090603@candelatech.com>
	<CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
	<56F4BFF1.8010806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34661 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbcCYFG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 01:06:26 -0400
Received: by mail-yw0-f173.google.com with SMTP id h129so85799867ywb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 22:06:26 -0700 (PDT)
In-Reply-To: <56F4BFF1.8010806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 9:34 PM, Ben Greear <greearb@candelatech.com> wrote:
>
>
> On 03/24/2016 06:44 PM, Vijay Pandurangan wrote:
>>
>> Oops, I think my last email didn't go through due to an inadvertent
>> html attachment from my phone mail client.
>>
>> Can you send us a copy of a packet you're sending and/or confirm that
>> the IP and UDP4 checksums are set correctly in the packet?
>>
>> If those are set right, I think we need to read through the networking
>> code again to see why this is broken...
>
>
> Wireshark decodes the packet as having no checksum errors.
>
> I think the contents of the packet is correct, but the 'ip_summed'
> field is set incorrectly to 'NONE' when transmitting on a raw packet
> socket.

Yeah, these bugs are all due to the different interpretations of
ip_summed on TX path and RX path. I think the following patch
should work, if the comments don't mislead me. Could you give
it a try?

For the long term, we need to unify the meaning of ip_summed
on TX path and RX path, or at least translate it in skb_scrub_packet().

Thanks.

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8d22de7..726457e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -377,7 +377,7 @@ static int raw_send_hdrinc(struct sock *sk, struct
flowi4 *fl4,
        iph = ip_hdr(skb);
        skb_put(skb, length);

-       skb->ip_summed = CHECKSUM_NONE;
+       skb->ip_summed = CHECKSUM_UNNECESSARY;

        sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4319e65..e6b3e31 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -646,7 +646,7 @@ static int rawv6_send_hdrinc(struct sock *sk,
struct msghdr *msg, int length,
        skb_reset_network_header(skb);
        iph = ipv6_hdr(skb);

-       skb->ip_summed = CHECKSUM_NONE;
+       skb->ip_summed = CHECKSUM_UNNECESSARY;

        skb->transport_header = skb->network_header;
        err = memcpy_from_msg(iph, msg, length);
