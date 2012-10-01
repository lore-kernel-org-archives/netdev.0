From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 19:28:49 +0100
Message-ID: <5069E0E1.7030906@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>  <1347979239.26523.267.camel@edumazet-glaptop>  <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>  <50643DA1.7070306@googlemail.com>  <1348748042.5093.1168.camel@edumazet-glaptop>  <50649567.2010704@googlemail.com>  <1348779826.5093.1750.camel@edumazet-glaptop>  <1348780624.5093.1767.camel@edumazet-glaptop>  <50656C4A.8090302@googlemail.com>  <1348831592.5093.2251.camel@edumazet-glaptop>  <5068648C.7050005@googlemail.com>  <1349034330.12401.210.camel@edumazet-glaptop>  <506955F3.8050304@googlemail.com>  <1349082950.12401.669.camel@edumazet-glaptop>  <5069B300.9080308@googlemail.com>  <1349105498.12401.706.camel@edumazet-glaptop>  <5069C27A.3090706@googlemail.c
 om> <1349109436.12401.712.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33827 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab2JAS2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 14:28:50 -0400
Received: by eekb15 with SMTP id b15so2525738eek.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 11:28:49 -0700 (PDT)
In-Reply-To: <1349109436.12401.712.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/12 17:37, Eric Dumazet wrote:
> On Mon, 2012-10-01 at 17:19 +0100, Chris Clayton wrote:
>>
>> On 10/01/12 16:31, Eric Dumazet wrote:
>>> On Mon, 2012-10-01 at 16:13 +0100, Chris Clayton wrote:
>>>>
>>>> On 10/01/12 10:15, Eric Dumazet wrote:
>>>>> On Mon, 2012-10-01 at 09:36 +0100, Chris Clayton wrote:
>>>>>>
>>>>>
>>>>>>         0 ICMP messages received
>>>>>>         0 input ICMP message failed.
>>>>>>         ICMP input histogram:
>>>>>>         0 ICMP messages sent
>>>>>>         0 ICMP messages failed
>>>>>>         ICMP output histogram:
>>>>>
>>>>>>
>>>>>> After:
>>>>>>
>>>>>> $ netstat -s
>>>>>> Icmp:
>>>>>>         4 ICMP messages received
>>>>>>         4 input ICMP message failed.
>>>>>>         ICMP input histogram:
>>>>>>             echo replies: 4
>>>>>
>>>>> So icmp replies come back and are delivered to host instead of being
>>>>> forwarded.
>>>>>
>>>>> I wonder if MASQUERADE broke...
>>>>>
>>>>> Could you send
>>>>>
>>>>> iptables -t -nat -nvL
>>>>
>>>> $ iptables -t -nat -nvL
>>>> iptables v1.4.15: can't initialize iptables table `-nat': Table does not
>>>> exist (do you need to insmod?)
>>>> Perhaps iptables or your kernel needs to be upgraded.
>>>>
>>>>> conntrack -L   # while ping is running from guest
>>>>
>>>> $ conntrack -L
>>>> conntrack v1.2.2 (conntrack-tools): Operation failed: invalid parameters
>>>>
>>>
>>> Thats not expected, you described you used MASQUERADE target, so
>>> "iptables -t nat -nvL" should display something.
>>>
>>
>> To check this I've booted a 3.5.4 kernel. I get the same response to the
>> two commands. I also double checked that, with a 3.5.4 kernel, pinging
>> the router and browsing the internet from the client work and they do.
>>
>> Except for the packets and bytes columns, the command iptables -nvL
>> gives the following output under both 3.5.4 and 3.6.0 kernels:
>>
>> Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
>>    pkts bytes target     prot opt in     out     source destination
>>    3757 3240K ACCEPT     all  --  *      *       0.0.0.0/0 0.0.0.0/0
>>          state RELATED,ESTABLISHED
>>      14   840 ACCEPT     all  --  *      *       127.0.0.1 127.0.0.1
>>      41  4362 ACCEPT     all  --  *      *       192.168.0.0/24 0.0.0.0/0
>>      90 12780 ACCEPT     all  --  *      *       192.168.200.0/24 0.0.0.0/0
>>       0     0 ACCEPT     all  --  *      *       192.168.201.0/24 0.0.0.0/0
>>       0     0 DROP       all  --  *      *       0.0.0.0/0 0.0.0.0/0
>>
>> Chain FORWARD (policy ACCEPT 4470 packets, 3065K bytes)
>>    pkts bytes target     prot opt in     out     source destination
>>
>> Chain OUTPUT (policy ACCEPT 3243 packets, 349K bytes)
>>    pkts bytes target     prot opt in     out     source destination
>>      64  8344 ACCEPT     all  --  *      *       0.0.0.0/0 192.168.200.0/24
>>       0     0 ACCEPT     all  --  *      *       0.0.0.0/0 192.168.201.0/24
>
> I am lost, since n your first mail you said :
> -----------------------------------------------------------------------------
> # Load the connection-sharing for qemu/kvm guests
> echo 1 > /proc/sys/net/ipv4/ip_forward
> iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> ...
> # allow traffic to and from the qemu/kvm virtual networks
> NETS="200 201"
> for net in $NETS; do
>     iptables -A INPUT -s 192.168.$net.0/24 -j ACCEPT
>     iptables -A OUTPUT -d 192.168.$net.0/24 -j ACCEPT
> done
> ...
>
> The network-related modules that are loaded are:
>
> $ lsmod
> Module                  Size  Used by
> tun                    12412  0
> xt_state                 891  1
> iptable_filter           852  1
> ipt_MASQUERADE          1222  1
> iptable_nat             3087  1
> nf_nat                 10901  2 ipt_MASQUERADE,iptable_nat
> nf_conntrack_ipv4       4942  4 nf_nat,iptable_nat
> nf_defrag_ipv4           815  1 nf_conntrack_ipv4
> nf_conntrack           37644  5
> ipt_MASQUERADE,nf_nat,xt_state,iptable_nat,nf_conntrack_ipv4
> ...
> r8169                  47159  0
>
>
> -----------------------------------------------
>
> Now you say you dont have nat ?
>
> Something is wrong.
>

Here's the complete script that starts up my firewall. I can't recall 
having changed this at all for two or three years, other than when a 
replacement router changed the network from 192.168.1.x or I add (or 
remove) other networks to (from) the $NETS list for other KVM clients

$ cat /etc/rc.d/rc.firewall
#! /bin/sh

case "$1" in
     stop)
         echo 0 > /proc/sys/net/ipv4/ip_forward
         # clear out the current settings
         iptables -F
         iptables -X
         iptables -Z
         ;;
     start)
         # Load the connection-sharing for qemu/kvm guests
         echo 1 > /proc/sys/net/ipv4/ip_forward
         iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

         iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

         # Allow anything internal to this machine (i.e. localhost)
	# is this really necessary?
         iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT

         # Allow any traffic from nodes on home network
         iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT

         # and traffic to and from the qemu/kvm virtual networks
         NETS="200 201"
         for net in $NETS; do
             iptables -A INPUT -s 192.168.$net.0/24 -j ACCEPT
             iptables -A OUTPUT -d 192.168.$net.0/24 -j ACCEPT
          done

         # drop everything else
         # iptables -A INPUT -j LOG --log-level 4 --log-prefix "FIREWALL: "
         iptables -A INPUT -j DROP
         ;;
     restart|reload)
         $0 stop
         $0 start
         ;;
     status)
         iptables -L
         ;;
     *)
         echo "Usage: $0 {start|stop|restart|reload|status}"
         exit 1
         ;;
esac

>

eth0 is set up by calling /sbin/ifup from udev on the add event for eth0 
(wlan0 is disabled on the laptop, so that won't be getting in the way). 
Here's the script (the SSID is not really XXXXX:

$ cat /sbin/ifup
#!/bin/sh

PATH="/usr/bin:/usr/sbin:/sbin:/bin"
export PATH

SSID=XXXXX

#logger "$0 called with arguments $@"
if [ "$1" = "wlan0" ]; then

     # Bring the interface up before the iwconfig stuff below
     # assign ip address later else association with AP fails when using WPA
     ifconfig wlan0 up

     # Configure the wireless adapter
     iw wlan0 connect $SSID

     # start wpa_supplicant
     if [ -z `pgrep wpa_supplicant` ]; then
         wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant.conf 
-iwlan0 -Dwext -B -f/var/log/wpa_supplicant.log
     fi

     # wait until associated with the AP - can take a while with WPA
     secs=0
     until iw wlan0 link | grep -q "SSID: $SSID"; do
         let secs++
         if [ $secs -ge 20 ]; then
             logger -p user.err -t IFUP "Failed to associate with AP 
within 20 seconds"
             exit -1
         fi
         sleep 1
     done

     # set the regulatory domain (kernel >= 2.6.28)
     iw reg set GB

     ifconfig wlan0 192.168.0.140 netmask 255.255.255.0 up

     route add default gw 192.168.0.1 netmask 0.0.0.0 metric 1

     exit 0

fi

if [ "$1" = "eth0" ] ; then
     # load the module if necessary
     if ! grep -q eth0 /proc/net/dev; then
         modprobe r8169
     fi

     # wait up to 5 seconds for eth0 to appear
     secs=0
     until grep -q eth0 /proc/net/dev; do
         let secs++
         if [ $secs -ge 5 ]; then
             logger -p user.err -t IFUP "eth0 failed to appear within 5 
seconds"
             exit -1
         fi
         sleep 1
     done

     ifconfig eth0 192.168.0.40 netmask 255.255.255.0 up

     route add default gw 192.168.0.1 netmask 0.0.0.0 metric 1

     exit 0
fi

When the KVM client is running the routing on the host is:

$ route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use 
Iface
default         router.local.la 0.0.0.0         UG    1      0        0 eth0
Unix            *               255.0.0.0       U     0      0        0 lo
local.lan       *               255.255.255.0   U     0      0        0 eth0
192.168.200.0   *               255.255.255.0   U     0      0        0 tap0

Like I say, the set up has been like this for ages and has worked. It's 
only since I started using 3.6 kernels that I've had a problem. I don't 
recall anything from the nat table ever having been listed by iptables -L.

>
