From: Linus Gasser <list@markas-al-nour.org>
Subject: Re: Bonding with tun-devices
Date: Thu, 22 May 2014 15:50:05 +0100
Message-ID: <537E0E9D.8060405@markas-al-nour.org>
References: <537CB13A.3030100@markas-al-nour.org> <20140521155434.GC6295@redhat.com> <537D0E52.9030901@markas-al-nour.org> <20140522132436.GD6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from virt.linusetviviane.ch ([78.46.227.60]:47584 "EHLO
	mail.profeda.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaEVOtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 10:49:45 -0400
In-Reply-To: <20140522132436.GD6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/14 14:24, Veaceslav Falico a =E9crit :
> On Wed, May 21, 2014 at 09:36:34PM +0100, Linus Gasser wrote:
>> Le 21/05/14 16:54, Veaceslav Falico a =E9crit :
>>> On Wed, May 21, 2014 at 02:59:22PM +0100, Linus Gasser wrote:
>>>> Dear list,
>>>>
>>>> I'm trying to create a bonded interface using tun-devices created =
by
>>>> the
>>>>
>>>> ssh -NTCf -w 0:0
>>>>
>>>> command. The reason is that I'm behind a satellite connection with
>>>> per-stream limited bandwidth...
>>>>
>>>> On some older kernels everything was fine, and I could do:
>>>>
>>>> # ssh -NTCf -w 0:0 web
>>>> # ssh -NTCf -w 1:1 web
>>>> # modprobe bonding mode=3D0 miimon=3D100
>>>> # ifconfig bond0 172.16.0.1 netmask 255.255.255.0
>>>> # ifconfig bond0 hw ether 12:34:56:78:9a
>>>> # ifenslave bond0 tun0 tun1
>>>
>>> It should fail here, as tun (from the first approach*) doesn't have
>>> ndo_set_mac_address, and bonding relies on that, *unless*
>>> fail_over_mac is
>>> set to 1.
>>>
>>> Could you try setting fail_over_mac =3D 1 on modprobe or via sysfs =
and
>>> retesting?
>>>
>>> * I've tried to quickly recreate your setup but hit a panic (alread=
y
>>> submitted a fix).
>>>
>>> Also, enabling debug for bonding (via dynamic_debug or anything els=
e)
>>> and
>>> attaching the output would help a lot.
>>
>> Hi,
>>
>> OK, I tried to add "fail_over_mac=3D1" to the modprobe-call, but bot=
h
>> with "ifenslave" and "ip add" I get the same error. In the logs I
>> found (with fail_over_mac):
>>
>> kernel: bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
>> kernel: bonding: MII link monitoring set to 100 ms
>> kernel: bonding: Warning: fail_over_mac only affects active-backup m=
ode.
>> bonding: bond0: Warning: The first slave device specified does not
>> support setting the MAC address.
>> bonding: bond0: Warning: The first slave device specified does not
>> support setting the MAC address.
>>
>> As far as I see, my kernel doesn't have dynamic_debug enabled. I'm i=
n
>> the midst of downloading it - hold on for a day or two ;) If you can
>> tell me how I can debug otherwise, I'll be glad to do so.
>
> No worries, I figured it out why it's misbehaving. Basically now bond=
ing
> expects every slave to have support of setting the mac address (that'=
s in
> short), but tun device is a IP device, which doesn't support mac addr=
esses.
>
> A workaround would be to use tap devices, as they're more "real" and
> support mac address setting.

OK, what can I say - thank you for helping me not to have fiddled aroun=
d=20
with it more than needed ;) If you manage to support=20
non-mac-connections, this would be great, of course. Else I'll have to=20
try Openvpn which supports tap-devices.

Thanks for your efforts

>
> I'll, though, try to figure out how to make bonding work even on NOAR=
P
> devices if it doesn't need to fiddle with OSI level 2...
>
> Hope that helps.
>
>>
>> Linus
>>
>>>
>>> Thank you!
>>>
>>>>
>>>> on one side and
>>>>
>>>> # modprobe bonding mode=3D0 miimon=3D100
>>>> # ifconfig bond0 172.16.0.2 netmask 255.255.255.0
>>>> # ifconfig bond0 hw ether 12:35
>>>> # ifenslave -f bond0 tun0 tun1
>>>> # ping 172.16.0.1
>>>>
>>>> on the other side. On a newer kernel (>3.14) this doesn't work (at
>>>> least not on linux-armv7), while on 3.13 it does work under
>>>> linux-armv7. Now I've been told to use the iproute2-suite, as
>>>> ifenslave is deprecated. But if I try to do
>>>>
>>>> # ssh -NTCf -w 0:0 web
>>>> # ssh -NTCf -w 1:1 web
>>>> # ip link add name bond1 type bond
>>>> # ip link set dev tun0 master bond1
>>>>
>>>> it gives me an error
>>>>
>>>> RTNETLINK answers: Operation not supported
>>>>
>>>> Any idea what I'm doing wrong?
>>>>
>>>> Linus
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
