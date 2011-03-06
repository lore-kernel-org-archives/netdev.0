From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 6/8] bonding: move processing of recv handlers
 into handle_frame()
Date: Sun, 06 Mar 2011 13:24:32 +0100
Message-ID: <4D737D00.20406@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36852 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286Ab1CFMYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 07:24:39 -0500
Received: by wwb22 with SMTP id 22so4224254wwb.1
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 04:24:38 -0800 (PST)
In-Reply-To: <4D724DB4.9020207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 15:50, Nicolas de Peslo=FCan a =E9crit :
> Le 05/03/2011 15:43, Jiri Pirko a =E9crit :
>> Sat, Mar 05, 2011 at 03:33:30PM CET, nicolas.2p.debian@gmail.com wro=
te:
>>> Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
>>>> Since now when bonding uses rx_handler, all traffic going into bon=
d
>>>> device goes thru bond_handle_frame. So there's no need to go back =
into
>>>> bonding code later via ptype handlers. This patch converts
>>>> original ptype handlers into "bonding receive probes". These funct=
ions
>>>> are called from bond_handle_frame and they are registered per-mode=
=2E
>>>
>>> Does this still support having the arp_ip_target on a vlan?
>>>
>>> (eth0 -> bond0 -> bond0.100, with arp_ip_target only reachable
>>> through bond0.100).
>>
>> This case is still covered with vlan_on_bond_hook
>> eth0->
>> bond_handle_frame
>> bond0->
>> vlan_hwaccel_do_receive
>> bond0.5->
>> vlan_on_bond_hook -> reinject into bond0
>> -> bond_handle_frame (here it is processed)
>
> Sound good to me.
>
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

After another review, I think it won't work.

vlan_on_bond() will reinject into bond0, but bond_handle_frame() is reg=
istered as the rx_handler for=20
the slaves (eth0 in the above setup), not as the rx_handler for the mas=
ter (bond0 in the above=20
setup). So, bond_handlee_frame() will never see the untagged ARP reques=
t/reply and bonding ARP=20
monitoring will fail.

That being said, the current vlan_on_bond_hook() hack already suffer ot=
her troubles and for example=20
won't support the following setup:

eth0 -> bond0 -> br0 -> br0.100.

I think we need to fix this stacking issue in a more general way.

	Nicolas.
