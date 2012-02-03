From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Fri, 3 Feb 2012 16:56:53 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C9FBB0@EUSAACMS0702.eamcs.ericsson.se>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
 <1328304719.2480.5.camel@edumazet-laptop> <4F2C5429.3080406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:55032 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360Ab2BCV5H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:57:07 -0500
In-Reply-To: <4F2C5429.3080406@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have the same issue when using  SO_BINDTODEVICE to bind to specifc in=
terface,  RST is getting lost in ip_route_output_key. =20

-----Original Message-----
=46rom: Ben Greear [mailto:greearb@candelatech.com]=20
Sent: Friday, February 03, 2012 1:40 PM
To: Eric Dumazet
Cc: Shawn Lu; davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmai=
l.com
Subject: Re: [PATCH] tcp: RST: binding oif to iif for tcp v4

On 02/03/2012 01:31 PM, Eric Dumazet wrote:
> Le vendredi 03 f=E9vrier 2012 =E0 12:16 -0800, Shawn Lu a =E9crit :
>> Binding RST packet outgoing interface to incomming interface for tcp=
=20
>> v4. This has few benefits:
>> 1. tcp_v6_send_reset already did that.
>
> I dont think so. ipv6 makes no special provision for RST.
>
>> 2. This helps tcp connect with SO_BINDTODEVICE set. When connection=20
>> is lost, we still able to sending out RST using same interface.
>
> I dont understand this.

I have been using a similar patch for years now.  When using routing ru=
les that depend on binding to an interface, the RST isn't always bound =
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


It was originally written by Patrick McHardy, but I've hacked it a bit =
over the years to keep it compiling.  It seems to work fine.

Thanks,
Ben


--
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
