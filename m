From: James Chapman <jchapman@katalix.com>
Subject: Re: unmanaged L2TPv3 ethernet pseudowire Cisco <=> Linux
Date: Tue, 26 Mar 2013 16:26:07 +0000
Message-ID: <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Tomas Agartz <tlund@nxs.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36399 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965531Ab3CZQgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 12:36:19 -0400
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	(Authenticated sender: james)
	by bert.katalix.com (Postfix) with ESMTPSA id 8BD994CBAB
	for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 16:26:08 +0000 (UTC)
Received: by mail-wi0-f179.google.com with SMTP id hn17so1125873wib.0
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 09:26:08 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 11:05 AM, Tomas Agartz <tlund@nxs.se> wrote:
> I am trying to set up an unmanaged L2TPv3 ethernet pseudowire from a Cisco
> 7200 (running IOS 15.2M) and a Linux box with kernel 3.2 (Debian Wheezy).
>
> Using Wireshark I can see L2TPv3 packets arriving from the Cisco router, but
> they are not parsed correctly by the kernel and only a few (mangled) frames
> are showing up on the l2tpeth0 interface.
>
> The actualy tunnel packets that arrive from the cisco router looks like
> this: [IPv4][L2TPv3][payload]. The L2TPv3 header is only 4 bytes, the bytes
> 00 00 00 c8 (just the session id, 200) and the payload is an ethernet frame
> recived by the Cisco on the interface where the tunnel is configured. A
> quick glance at the RFC seem to indicate that this is correct.
>
> I am assuming that the kernel is trying to parse more data then just the 4
> bytes, for example expecting a cookie and/or sequence numbers. It is also
> possible it is expecting a L2 sublayer header after the L2TPv3 header. I had
> to tune wireshark and set cookie size to "0", L2-Specific sublayer to "none"
> and tell it to decode the packet contents as "ethernet". With these
> settings, it is showing me exactly what I am expecting.

The issue is that Linux and Cisco use a different default for the
L2SpecificSublayer header setting and neither implementation provides
a config option to change its setting. :-( The Linux default is to use
the Default L2SpecificSublayer as defined in the RFC. Unfortunately
the Cisco default is to use no L2SpecificSublayer.

The kernel already has an API to allow the L2SpecificSublayer setting
to be configured. The missing piece is an iproute2 l2tp config option
to configure it. I'll work on an iproute2 patch now to allow this
setting to be configured.

> To configure the tunnel in the linux end, I have done this:
>
> ip l2tp add tunnel remote 172.16.0.1 local 192.168.0.1 tunnel_id 200
> peer_tunnel_id 200 encap ip
> ip l2tp add session tunnel_id 200 session_id 200 peer_session_id 200
>
> The cisco has the following config:
> !
> interface GigabitEthernet0/0
>  no ip address
>  xconnect 192.168.0.1 200 encapsulation l2tpv3 manual pw-class tlund
>   l2tp id 200 200
> !
> pseudowire-class tlund
>  encapsulation l2tpv3
>  interworking ethernet
>  protocol none
>  ip local interface Loopback0
> !
>
> I can not understand how Linux could possibly auto-detect the cookie size
> and know what kind L2 sublayer header to expect, meaning it needs to be
> configured. Is there some other tool outside of iproute2 that can be used to
> configure these aspect of the L2TPv3 tunnel in the Linux side?

For unmanaged tunnels, these parameters must be manually configured
consistently at each side. Both Cisco and Linux default to use no
cookies and both already have config parameters to set cookie
parameters, if needed. However, for L2SpecificSublayer this isn't the
case. We need to add a config option on the Linux side to force the
same setting as Cisco is using.

For managed tunnels, the L2TP control protocol (implemented by a
userspace daemon on Linux) would take care of negotiating these
settings with the peer and configuring the kernel appropriately.

>
> Best regards,
> Tomas

James
