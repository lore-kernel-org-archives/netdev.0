From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Fri, 03 Feb 2012 13:39:53 -0800
Message-ID: <4F2C5429.3080406@candelatech.com>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com> <1328304719.2480.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Lu <shawn.lu@ericsson.com>, davem@davemloft.net,
	netdev@vger.kernel.org, xiaoclu@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33918 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756048Ab2BCVkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:40:00 -0500
In-Reply-To: <1328304719.2480.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2012 01:31 PM, Eric Dumazet wrote:
> Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 12:16 -0800, Shawn Lu a =C3=A9=
crit :
>> Binding RST packet outgoing interface to incomming interface
>> for tcp v4. This has few benefits:
>> 1. tcp_v6_send_reset already did that.
>
> I dont think so. ipv6 makes no special provision for RST.
>
>> 2. This helps tcp connect with SO_BINDTODEVICE set. When connection
>> is lost, we still able to sending out RST using same interface.
>
> I dont understand this.

I have been using a similar patch for years now.  When using routing
rules that depend on binding to an interface, the RST isn't always boun=
d
properly without this fix.

My code looks like this:

@@ -650,6 +650,7 @@ static void tcp_v4_send_reset(struct sock *sk, stru=
ct sk_buff *skb)
  				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
  	arg.csumoffset =3D offsetof(struct tcphdr, check) / 2;
  	arg.flags =3D (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCC=
HECK : 0;
+	arg.bound_dev_if =3D skb_rtable(skb)->rt_iif;

  	net =3D dev_net(skb_dst(skb)->dev);
  	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,


It was originally written by Patrick McHardy, but I've hacked it
a bit over the years to keep it compiling.  It seems to work fine.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
