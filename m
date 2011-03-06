From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 6/8] bonding: move processing of recv
 handlers into handle_frame()
Date: Sun, 6 Mar 2011 14:34:13 +0100
Message-ID: <20110306133413.GB2795@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-7-git-send-email-jpirko@redhat.com>
 <4D7249BA.8030401@gmail.com>
 <20110305144314.GC8573@psychotron.redhat.com>
 <4D724DB4.9020207@gmail.com>
 <4D737D00.20406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458Ab1CFNew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 08:34:52 -0500
Content-Disposition: inline
In-Reply-To: <4D737D00.20406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 06, 2011 at 01:24:32PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 05/03/2011 15:50, Nicolas de Peslo=FCan a =E9crit :
>>Le 05/03/2011 15:43, Jiri Pirko a =E9crit :
>>>Sat, Mar 05, 2011 at 03:33:30PM CET, nicolas.2p.debian@gmail.com wro=
te:
>>>>Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
>>>>>Since now when bonding uses rx_handler, all traffic going into bon=
d
>>>>>device goes thru bond_handle_frame. So there's no need to go back =
into
>>>>>bonding code later via ptype handlers. This patch converts
>>>>>original ptype handlers into "bonding receive probes". These funct=
ions
>>>>>are called from bond_handle_frame and they are registered per-mode=
=2E
>>>>
>>>>Does this still support having the arp_ip_target on a vlan?
>>>>
>>>>(eth0 -> bond0 -> bond0.100, with arp_ip_target only reachable
>>>>through bond0.100).
>>>
>>>This case is still covered with vlan_on_bond_hook
>>>eth0->
>>>bond_handle_frame
>>>bond0->
>>>vlan_hwaccel_do_receive
>>>bond0.5->
>>>vlan_on_bond_hook -> reinject into bond0
>>>-> bond_handle_frame (here it is processed)
>>
>>Sound good to me.
>>
>>Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>
>After another review, I think it won't work.
>
>vlan_on_bond() will reinject into bond0, but bond_handle_frame() is
>registered as the rx_handler for the slaves (eth0 in the above
>setup), not as the rx_handler for the master (bond0 in the above
>setup). So, bond_handlee_frame() will never see the untagged ARP
>request/reply and bonding ARP monitoring will fail.

Damn, you are right. I mislooked.

>
>That being said, the current vlan_on_bond_hook() hack already suffer
>other troubles and for example won't support the following setup:
>
>eth0 -> bond0 -> br0 -> br0.100.

blah. Well correct me if my thinking is wrong but I cannot imagine
a scenario where there's not other way how to do arp monitoring than
over vlan.

So how about to just remove the vlan_on_bond_hook and forbid the
possibility. IMHO it should have never been introduced in the first
place.

>
>I think we need to fix this stacking issue in a more general way.

Well this issue is more or less out of the concept and breaks layering.
I cannot think of how to resolve this nicely atm.

>
>	Nicolas.
