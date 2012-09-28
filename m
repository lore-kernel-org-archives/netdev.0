From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Fri, 28 Sep 2012 10:22:18 +0100
Message-ID: <50656C4A.8090302@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>  <1347979239.26523.267.camel@edumazet-glaptop>  <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>  <50643DA1.7070306@googlemail.com>  <1348748042.5093.1168.camel@edumazet-glaptop>  <50649567.2010704@googlemail.com>  <1348779826.5093.1750.camel@edumazet-glaptop> <1348780624.5093.1767.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57073 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab2I1JWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 05:22:19 -0400
Received: by bkcjk13 with SMTP id jk13so3060809bkc.19
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 02:22:18 -0700 (PDT)
In-Reply-To: <1348780624.5093.1767.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/27/12 22:17, Eric Dumazet wrote:
> On Thu, 2012-09-27 at 23:03 +0200, Eric Dumazet wrote:
>> On Thu, 2012-09-27 at 19:05 +0100, Chris Clayton wrote:
>>> On 09/27/12 13:14, Eric Dumazet wrote:
>>>> On Thu, 2012-09-27 at 12:50 +0100, Chris Clayton wrote:
>>>>> Just for information - I've pulled Linus' tree this morning and the
>>>>> problem is still present. Also, Gunther Piaz has reported, via the
>>>>> bugzilla entry, that he too has hit this regression.
>>>>
>>>> I tried to reproduce the bug, and my kvm guests have no problem.
>>>>
>>>> I guess you need to precisely describe how you setup your network, so
>>>> that I can reproduce the problem and eventually fix it.
>>>>
>>>
>>> You've seen the bits from my firewall setup script that relate to this
>>> issue. I start the WinXP client with another script:
>>>
>>> #!/bin/sh
>>> if [ -e $HOME/kvm/var/run/kvm-winxp.pid ]; then
>>>       echo "winxp is already running ..." > /dev/stderr
>>>       exit 1
>>> fi
>>>
>>> # make sure the kvm modules are loaded
>>> if test -z "$(grep '\<kvm\>' /proc/misc)"; then
>>>       sudo modprobe kvm-intel
>>>       while test -z "$(grep '\<kvm\>' /proc/misc)"; do
>>>           true
>>>       done
>>> fi
>>>
>>> # make sure tun module is loaded
>>> if test ! -e /dev/net/tun; then
>>>       sudo modprobe tun
>>> fi
>>>
>>> # figure out the cpu to use
>>> QVER=$(qemu-kvm --version | cut -d' ' -f 4 | sed 's/,/./')
>>> # assumes major version is 1
>>> MINORVER=$(echo $QVER | cut -d'.' -f 2)
>>> if [ $MINORVER -ge 1 ]; then
>>>       CPU="host"
>>> else
>>>       CPU="qemu64"
>>> fi
>>>
>>> # set up the network interface
>>> TAPDEV=$(sudo tunctl -b -u $(whoami))
>>> sudo ifconfig $TAPDEV 192.168.200.254 netmask 255.255.255.0 broadcast
>>> 192.168.200.255
>>>
>>> # start Windows XP
>>> qemu-kvm -drive file=$HOME/kvm/winxp.qcow2,index=0,cache=none,if=virtio
>>> -cpu $CPU -smp cores=1,threads=2 -soundhw es1370 \
>>>       -m 768 -net nic,model=virtio,macaddr=$(getmacaddr) -net
>>> tap,ifname=$TAPDEV -startdate $(date +%Y-%m-%dT%H:%M:%S) \
>>>       -name kxplaptop -pidfile $HOME/kvm/var/run/kvm-winxp.pid $*
>>>
>>> # stop the network interface
>>> sudo ifconfig $TAPDEV down
>>> sudo tunctl -d $TAPDEV &>/dev/null
>>>
>>> # tidy up
>>> rm -f $HOME/kvm/var/run/kvm-winxp.pid
>>>
>>>
>>> The call to getmacaddr just returns the next in a sequence of mac
>>> addresses. qemu-kvm is a symlink to /usr/bin/qemu-system-i386. I first
>>> found the problem whilst running qemu-kvm version 1.1.1 although I've
>>> since updated to 1.2.0.
>>>
>>> By the way, I doubt it will make a difference, but, although my laptop
>>> has a 64bit CPU, I am running a 32 bit kernel and, obviously, user space.
>>>
>>> Let me know if you need anything else.
>>
>> It works for me.
>>
>> Hmm, maybe your guest is using DHCP and DHCP fails ?

No, the WinXP guest is configured with a fixed IP address 
(192.168.200.1). Subnet mask is 255.255.255.0, and default gateway is 
192.168.200.254. DNS is 192.168.0.1.

>
> Yes it seems the problem. On the host I tried :
>
> # ip ro get 8.8.8.8 from 192.168.200.1 iif tap1
> 8.8.8.8 from 192.168.200.1 via 172.30.42.1 dev eth0
>      cache  iif *
>
> So if the guest tries to send a frame to 8.8.8.8 we are going to forward
> the packet to eth0
>
> But if the guest tries to send to 255.255.255.255, we try to deliver the
> packet to the host itself, instead of broadcasting to eth0
>
> # ip ro get 255.255.255.255 from 192.168.200.1 iif tap1
> broadcast 255.255.255.255 from 192.168.200.1 dev lo
>      cache <local,brd>  iif *
>
>
> David, maybe you'll have an idea ?
>
> Thanks
>
>
