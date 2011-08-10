From: Michael Guntsche <mguntsche@gmail.com>
Subject: Re: BUG: Bisected Gianfar in bridge not forwarding packets (was:
 3.0-rc1 Bridge not forwarding unicast packages)
Date: Wed, 10 Aug 2011 12:30:16 +0200
Message-ID: <CAMvAeqM-oH1UzxEp9PgO6ZP-AKtqosuMg5za25_X8DpPJMDX2w@mail.gmail.com>
References: <CAMvAeqOA0=FnjB2oPPCEYpkXdKrmqOs+MwAqszV5sTGys_a3mQ@mail.gmail.com>
	<20110810090014.GB1909@minipsycho.brq.redhat.com>
	<CAMvAeqO2bLaPwmdW+c+7hz-ec=-tF6Z0EFBv=FA7+rU_QZ_wDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, sebastian.belden@googlemail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMvAeqO2bLaPwmdW+c+7hz-ec=-tF6Z0EFBv=FA7+rU_QZ_wDA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 10, 2011 at 11:59 AM, Michael Guntsche <mguntsche@gmail.com=
> wrote:
<snip>
>>>Offload parameters for lan_wire:
>>>rx-checksumming: off
>>>tx-checksumming: off
>>>scatter-gather: off
>>>tcp-segmentation-offload: off
>>>udp-fragmentation-offload: off
>>>generic-segmentation-offload: off
>>>generic-receive-offload: on
>>>large-receive-offload: off
>>>rx-vlan-offload: off
>>>tx-vlan-offload: off
>>>ntuple-filters: off
>>>receive-hashing: off
>>>
>>>The Bridge device on the other hand....
>>>
>>>Offload parameters for lan:
>>>rx-checksumming: on
>>>tx-checksumming: on
>>>scatter-gather: off
>>>tcp-segmentation-offload: off
>>>udp-fragmentation-offload: off
>>>generic-segmentation-offload: off
>>>generic-receive-offload: on
>>>large-receive-offload: off
>>>rx-vlan-offload: off
>>>tx-vlan-offload: on
>> =A0^^^^^^^^^^^^^^^^^^^ is this gfar?
> No the "Lan" nic is the bridge itself. The gfar in question is lan_wi=
re.
>
> /Michael
>

Ok I would have saved hours of bisecting if I had just used the -e
switch with tcpdump from the beginning.
Jiri first of all the patch makes the connection work again. I can
ping the client on the wlan from the server and vice-versa. Taking a
look at the tcpdump (WITH -e) makes it obvious why it fails with the
non patched version...

This is a capture from the gfar lan port on the bridge with no patch ap=
plied
12:13:24.011492 00:13:d4:4f:a2:dc (oui Unknown) > b4:07:f9:70:b7:c1
(oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 19, p 0,
ethertype IPv4, gibson.comsick.at > 192.168.42.55: ICMP echo request,
id 23567, seq 74, length 64

As you can see we get a VLAN package????

With the patched version:
12:16:33.756966 00:13:d4:4f:a2:dc (oui Unknown) > b4:07:f9:70:b7:c1
(oui Unknown), ethertype IPv4 (0x0800), length 98: gibson.comsick.at >
192.168.42.55: ICMP echo request, id 23669, seq 2, length 64
12:16:33.843289 b4:07:f9:70:b7:c1 (oui Unknown) > 00:13:d4:4f:a2:dc
(oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.42.55 >
gibson.comsick.at: ICMP echo reply, id 23669, seq 2, length 64

No VLAN and I get my replies.
All that is left to do now is to find out why the current driver
thinks that it is on a VLAN when it isn't.

Any ideas Jiri?

Kind regards,
Michael
