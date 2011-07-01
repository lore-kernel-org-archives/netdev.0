From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Disable router anycast address for /127 prefixes
Date: Fri, 01 Jul 2011 20:26:09 +0200
Message-ID: <87y60hsvr2.fsf@nemi.mork.no>
References: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net>
	<1309519330-16649-1-git-send-email-bjorn@mork.no>
	<4E0DDDA5.20401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:58905 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118Ab1GAS02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 14:26:28 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QciQ6-00034T-QM
	for netdev@vger.kernel.org; Fri, 01 Jul 2011 20:26:26 +0200
Received: from nemi.mork.no ([148.122.252.4])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 20:26:26 +0200
Received: from bjorn by nemi.mork.no with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 20:26:26 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> writes:
> On 07/01/2011 07:22 AM, Bj=C3=B8rn Mork wrote:
>> RFC 6164 requires that routers MUST disable Subnet-Router anycast
>> for the prefix when /127 prefixes are used.
>>=20
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>> ---
>
>> @@ -1479,6 +1481,8 @@ static void addrconf_join_anycast(struct inet6=
_ifaddr *ifp)
>>  static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>>  {
>>  	struct in6_addr addr;
>> +	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
>> +		return;
>>  	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
>>  	if (ipv6_addr_any(&addr))
>>  		return;
>
> I'm not sure you'd need this part as there shouldn't be a /127 in the=
 list to remove.

I don't understand exactly what you mean here.... =20

The addrconf_{join,leave}_anycast() functions are definitely called
regardless of prefix length, including both 127 and 128.  The latter is
not a problem because it is handled by ipv6_addr_prefix().  But /127
prefixes are not handled according to RFC 6164.

Just to be sure I didn't miss something, I added a simple printk to the
beginning of addrconf_{join,leave}_anycast():

	printk(KERN_INFO "%s(): ifp->prefix_len=3D%d\n", __FUNCTION__, ifp->pr=
efix_len);


and got this as expected after doing=20
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

[   73.710174] addrconf_join_anycast(): ifp->prefix_len=3D128
[   73.712879] addrconf_join_anycast(): ifp->prefix_len=3D64
[   73.716799] addrconf_join_anycast(): ifp->prefix_len=3D64
[   73.719798] addrconf_join_anycast(): ifp->prefix_len=3D64

Notice the /128 prefix, which is the loopback address.

Adding a new interface, and setting a /127 on it:

ifconfig dummy0 up
[  134.434901] addrconf_join_anycast(): ifp->prefix_len=3D64

ip addr add 2001:db8:f00::3/127 dev dummy0
[  198.292972] addrconf_join_anycast(): ifp->prefix_len=3D127

And verifying that it actually answers the anycast address (which is th=
e
problem since that is supposed to be the other end of the point-to-poin=
t
link):

frtest1:~# ping6 2001:db8:f00::2
PING 2001:db8:f00::2(2001:db8:f00::2) 56 data bytes
64 bytes from 2001:db8:f00::3: icmp_seq=3D1 ttl=3D64 time=3D0.035 ms
64 bytes from 2001:db8:f00::3: icmp_seq=3D2 ttl=3D64 time=3D0.049 ms
64 bytes from 2001:db8:f00::3: icmp_seq=3D3 ttl=3D64 time=3D0.039 ms
^C
--- 2001:db8:f00::2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1998ms
rtt min/avg/max/mdev =3D 0.035/0.041/0.049/0.005 ms


Disabling forwarding again:

echo 0 > /proc/sys/net/ipv6/conf/all/forwarding
[  247.281543] addrconf_leave_anycast(): ifp->prefix_len=3D128
[  247.284220] addrconf_leave_anycast(): ifp->prefix_len=3D64
[  247.287959] addrconf_leave_anycast(): ifp->prefix_len=3D64
[  247.290178] addrconf_leave_anycast(): ifp->prefix_len=3D64
[  247.293390] addrconf_leave_anycast(): ifp->prefix_len=3D127
[  247.295476] addrconf_leave_anycast(): ifp->prefix_len=3D64



With the patch, we still get anycast addresses for the shorter prefix
lengths, but not for /127 prefixes:


frtest1:~# echo 1 > /proc/sys/net/ipv6/conf/all/forwarding=20
frtest1:~# ifconfig dummy0 up
frtest1:~#=20
frtest1:~# ip addr add 2001:db8:f00::3/127 dev dummy0
frtest1:~# ip -6 addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436=20
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 fe80::5054:ff:feff:100/64 scope link=20
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:4620:9:29a:5054:ff:feff:106/64 scope global dynamic=20
       valid_lft 86356sec preferred_lft 14356sec
    inet6 fe80::5054:ff:feff:106/64 scope link=20
       valid_lft forever preferred_lft forever
4: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500=20
    inet6 2001:db8:f00::3/127 scope global=20
       valid_lft forever preferred_lft forever
    inet6 fe80::d8b4:bcff:fe81:172/64 scope link=20
       valid_lft forever preferred_lft forever
frtest1:~# ping6 2001:4620:9:29a::
PING 2001:4620:9:29a::(2001:4620:9:29a::) 56 data bytes
64 bytes from 2001:4620:9:29a:5054:ff:feff:106: icmp_seq=3D1 ttl=3D64 t=
ime=3D0.032 ms
64 bytes from 2001:4620:9:29a:5054:ff:feff:106: icmp_seq=3D2 ttl=3D64 t=
ime=3D0.040 ms
^C
--- 2001:4620:9:29a:: ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev =3D 0.032/0.036/0.040/0.004 ms
frtest1:~# ping6 2001:db8:f00::2
PING 2001:db8:f00::2(2001:db8:f00::2) 56 data bytes
^C
--- 2001:db8:f00::2 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1008ms




Bj=C3=B8rn

