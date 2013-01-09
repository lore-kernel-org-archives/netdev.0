From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci
 field value
Date: Tue, 08 Jan 2013 22:27:30 -0800
Message-ID: <1357712850.27446.28.camel@edumazet-glaptop>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
	 <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Pearce <pearce@cs.berkeley.edu>, netdev@vger.kernel.org,
	dborkman <dborkman@redhat.com>, edumazet <edumazet@google.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60177 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756730Ab3AIG1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 01:27:33 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb11so824669pad.10
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 22:27:33 -0800 (PST)
In-Reply-To: <CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 22:06 -0800, Ani Sinha wrote:

> The proposed patch tries to fix the issue that arose after the
> following commit :
> 
> commit b40863c667c16b7a73d4f034a8eab67029b5b15a
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Sep 18 20:44:49 2012 +0000
> 
>     net: more accurate network taps in transmit path
> 
> 
> I do not believe 3.6.11 kernel has this change. 3.6.11 should not need
> the patch.

Thats irrelevant. This only shows that user land was depending on a
prior undocumented behavior.

It seems a libpcap issue to me. Kernel side provides all needed bits.

When I want "tcpdump src port 2030", filter is :

(000) ldh      [12]
(001) jeq      #0x86dd          jt 2	jf 8
(002) ldb      [20]
(003) jeq      #0x84            jt 6	jf 4
(004) jeq      #0x6             jt 6	jf 5
(005) jeq      #0x11            jt 6	jf 19
(006) ldh      [54]
(007) jeq      #0x7ee           jt 18	jf 19
(008) jeq      #0x800           jt 9	jf 19
(009) ldb      [23]
(010) jeq      #0x84            jt 13	jf 11
(011) jeq      #0x6             jt 13	jf 12
(012) jeq      #0x11            jt 13	jf 19
(013) ldh      [20]
(014) jset     #0x1fff          jt 19	jf 15
(015) ldxb     4*([14]&0xf)
(016) ldh      [x + 14]
(017) jeq      #0x7ee           jt 18	jf 19
(018) ret      #96
(019) ret      #0

See how it handles both IPv4 and IPv6, and various protocols
automatically ?

If I only wanted "udp and src port 2030" it would give :

(000) ldh      [12]
(001) jeq      #0x86dd          jt 2	jf 6
(002) ldb      [20]
(003) jeq      #0x11            jt 4	jf 15
(004) ldh      [54]
(005) jeq      #0x7ee           jt 14	jf 15
(006) jeq      #0x800           jt 7	jf 15
(007) ldb      [23]
(008) jeq      #0x11            jt 9	jf 15
(009) ldh      [20]
(010) jset     #0x1fff          jt 15	jf 11
(011) ldxb     4*([14]&0xf)
(012) ldh      [x + 14]
(013) jeq      #0x7ee           jt 14	jf 15
(014) ret      #96
(015) ret      #0



So when I want "tcpdump vlan 100" it generates :

(000) ldh      [12]
(001) jeq      #0x8100          jt 2	jf 6
(002) ldh      [14]
(003) and      #0xfff
(004) jeq      #0x64            jt 5	jf 6
(005) ret      #96
(006) ret      #0

What's wrong instructing libpcap to extend the filter to be able to 
get the correct result, vlan id being in skb->vlan_id (vlan accel on),
or in the packet itself (vlan accel off)

This way, you could chose if you want to get only accelerated vlan,
or non accelerated vlan, or both. And you need no kernel hacking.
