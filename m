From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: Bonding with tun-devices
Date: Thu, 22 May 2014 15:24:36 +0200
Message-ID: <20140522132436.GD6295@redhat.com>
References: <537CB13A.3030100@markas-al-nour.org>
 <20140521155434.GC6295@redhat.com>
 <537D0E52.9030901@markas-al-nour.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Linus Gasser <list@markas-al-nour.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbaEVNZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 09:25:03 -0400
Content-Disposition: inline
In-Reply-To: <537D0E52.9030901@markas-al-nour.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 09:36:34PM +0100, Linus Gasser wrote:
>Le 21/05/14 16:54, Veaceslav Falico a =E9crit :
>>On Wed, May 21, 2014 at 02:59:22PM +0100, Linus Gasser wrote:
>>>Dear list,
>>>
>>>I'm trying to create a bonded interface using tun-devices created by=
 the
>>>
>>>ssh -NTCf -w 0:0
>>>
>>>command. The reason is that I'm behind a satellite connection with
>>>per-stream limited bandwidth...
>>>
>>>On some older kernels everything was fine, and I could do:
>>>
>>># ssh -NTCf -w 0:0 web
>>># ssh -NTCf -w 1:1 web
>>># modprobe bonding mode=3D0 miimon=3D100
>>># ifconfig bond0 172.16.0.1 netmask 255.255.255.0
>>># ifconfig bond0 hw ether 12:34:56:78:9a
>>># ifenslave bond0 tun0 tun1
>>
>>It should fail here, as tun (from the first approach*) doesn't have
>>ndo_set_mac_address, and bonding relies on that, *unless* fail_over_m=
ac is
>>set to 1.
>>
>>Could you try setting fail_over_mac =3D 1 on modprobe or via sysfs an=
d
>>retesting?
>>
>>* I've tried to quickly recreate your setup but hit a panic (already
>>submitted a fix).
>>
>>Also, enabling debug for bonding (via dynamic_debug or anything else)=
 and
>>attaching the output would help a lot.
>
>Hi,
>
>OK, I tried to add "fail_over_mac=3D1" to the modprobe-call, but both=20
>with "ifenslave" and "ip add" I get the same error. In the logs I=20
>found (with fail_over_mac):
>
>kernel: bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 20=
11)
>kernel: bonding: MII link monitoring set to 100 ms
>kernel: bonding: Warning: fail_over_mac only affects active-backup mod=
e.
>bonding: bond0: Warning: The first slave device specified does not=20
>support setting the MAC address.
>bonding: bond0: Warning: The first slave device specified does not=20
>support setting the MAC address.
>
>As far as I see, my kernel doesn't have dynamic_debug enabled. I'm in=20
>the midst of downloading it - hold on for a day or two ;) If you can=20
>tell me how I can debug otherwise, I'll be glad to do so.

No worries, I figured it out why it's misbehaving. Basically now bondin=
g
expects every slave to have support of setting the mac address (that's =
in
short), but tun device is a IP device, which doesn't support mac addres=
ses.

A workaround would be to use tap devices, as they're more "real" and
support mac address setting.

I'll, though, try to figure out how to make bonding work even on NOARP
devices if it doesn't need to fiddle with OSI level 2...

Hope that helps.

>
>Linus
>
>>
>>Thank you!
>>
>>>
>>>on one side and
>>>
>>># modprobe bonding mode=3D0 miimon=3D100
>>># ifconfig bond0 172.16.0.2 netmask 255.255.255.0
>>># ifconfig bond0 hw ether 12:35
>>># ifenslave -f bond0 tun0 tun1
>>># ping 172.16.0.1
>>>
>>>on the other side. On a newer kernel (>3.14) this doesn't work (at
>>>least not on linux-armv7), while on 3.13 it does work under
>>>linux-armv7. Now I've been told to use the iproute2-suite, as
>>>ifenslave is deprecated. But if I try to do
>>>
>>># ssh -NTCf -w 0:0 web
>>># ssh -NTCf -w 1:1 web
>>># ip link add name bond1 type bond
>>># ip link set dev tun0 master bond1
>>>
>>>it gives me an error
>>>
>>>RTNETLINK answers: Operation not supported
>>>
>>>Any idea what I'm doing wrong?
>>>
>>>Linus
>>>--
>>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>the body of a message to majordomo@vger.kernel.org
>>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
