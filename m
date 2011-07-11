From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 15:41:35 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:22671 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906Ab1GKUlh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 16:41:37 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please provide more configuration information like:
>  - NIC type
>  - iptables and bridge and address configuration

The NICs are 3Com 3C905B's.  The iptables config is complex - I'll paste
in the relevant pieces.  Note that it all works as expected when I put
the br0 device into promiscuous mode.  I included all the layer 2 MAC
address info in the original email.  

> Do you have reverse path filtering enabled/disabled?

rp_filter doesn't seem to effect the behavior one way or the other.
I've tried with rp_filter set to both 0 and 1 on eth0, eth1, and br0
with no change in behavior.  

Here are the relevant parts of my rc.firewall script:

.
.
.
echo "Setting up aliases for public IP addresses"

/sbin/ifconfig ${BR_IFACE}:0 $PUBLIC_GRE_IP netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
#/sbin/ifconfig ${BR_IFACE}:1 $PUBLIC_EMAIL_IP netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
# EMAIL and GRE share the same IP Address
/sbin/ifconfig ${BR_IFACE}:2 ${PUBLIC_FTP_IP[0]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
/sbin/ifconfig ${BR_IFACE}:3 ${PUBLIC_FTP_IP[1]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
/sbin/ifconfig ${BR_IFACE}:4 ${PUBLIC_FTP_IP[2]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
/sbin/ifconfig ${BR_IFACE}:5 ${PUBLIC_FTP_IP[3]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
#/sbin/ifconfig ${BR_IFACE}:6 ${PUBLIC_VTC_IP[0]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
#/sbin/ifconfig ${BR_IFACE}:7 ${PUBLIC_VTC_IP[1]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
# The VTC devices are now bridged.  They have their own IP Addresses.
#/sbin/ifconfig ${BR_IFACE}:8 ${PUBLIC_WEB_IP[0]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
#/sbin/ifconfig ${BR_IFACE}:9 ${PUBLIC_WEB_IP[1]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
#/sbin/ifconfig ${BR_IFACE}:10 ${PUBLIC_WEB_IP[2]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
#/sbin/ifconfig ${BR_IFACE}:11 ${PUBLIC_WEB_IP[3]} netmask $INET_NETMASK
broadcast $INET_BCAST_ADDRESS
# Web and FTP sites have the same addresses.

echo "ARPinging the world so everyone knows our MAC Addresses"
/sbin/arping -A $INET_IP -c 1 -I $BR_IFACE
/sbin/arping -A $PUBLIC_GRE_IP -c 1 -I $BR_IFACE
for ADR in "${PUBLIC_FTP_IP[@]}"; do
    /sbin/arping -A $ADR -c 1 -I $BR_IFACE
done
for ADR in "${PUBLIC_WWW_IP[@]}"; do
    /sbin/arping -A $ADR -c 1 -I $BR_IFACE
done

/sbin/arping -A $TRUSTED1_IP -c 1 -I $BR_IFACE

/sbin/arping -A $DMZ_IP -c 1 -I $DMZ_IFACE
.
.
.
echo "	MASQUERADING requests to the internally hosted server apps"
echo "	(Email - SMTP, POP3, IMAP, OWA)"
$IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 25 -d $PRIVATE_EMAIL_IP -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 110 -d $PRIVATE_EMAIL_IP -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 143 -d $PRIVATE_EMAIL_IP -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 80 -d $PRIVATE_EMAIL_IP -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 443 -d $PRIVATE_EMAIL_IP -j MASQUERADE

echo "	(Internally hosted ftp sites)"
for ADR in "${PUBLIC_FTP_IP[@]}"; do
    $IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 21 -d $ADR -j MASQUERADE
done

echo "	(Internally hosted web sites)"
for ADR in "${PUBLIC_WWW_IP[@]}"; do
    $IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 80 -d $ADR -j MASQUERADE
    $IPTABLES -t nat -A POSTROUTING -s $TRUSTED1_IP_RANGE -o $BR_IFACE \
	-p TCP --dport 443 -d $ADR -j MASQUERADE
done
.
.
.
echo "	FTP sites (port 21 inbound)"
for ADR in "${PRIVATE_FTP_IP[@]}"; do
    $IPTABLES -A FORWARD -p TCP --dport 21 -s 0/0 -d $ADR -j allowed 
done

echo "	Web (HTTP) sites (port 80 inbound)"
for ADR in "${PRIVATE_WWW_IP[@]}"; do
    $IPTABLES -A FORWARD -p TCP --dport 80 -s 0/0 -d $ADR -j allowed 
done
.
.
.

echo "	FTP sites (TCP port 21)"
for ((i = 0 ; i < ${#PUBLIC_FTP_IP[@]} ; i++ ))
do
    $IPTABLES -t nat -A PREROUTING -d ${PUBLIC_FTP_IP[i]} \
	-p tcp --dport 21 -j DNAT --to ${PRIVATE_FTP_IP[i]}
	# -m mark --mark 1 (from the Internet) removed so we
	# DNAT for internal users also.
done

echo "	Web (HTTP) sites (TCP port 80)"
for ((i = 0 ; i < ${#PUBLIC_WWW_IP[@]} ; i++ ))
do
    $IPTABLES -t nat -A PREROUTING -d ${PUBLIC_WWW_IP[i]} \
	-p tcp --dport 80 -j DNAT --to ${PRIVATE_WWW_IP[i]}
	# -m mark --mark 1 (from the Internet) removed so we
	# DNAT for internal users also.
done

echo "  Email - SMTP, POP3, IMAP, OWA; provision for internal users"
$IPTABLES -t nat -A PREROUTING -d $PUBLIC_EMAIL_IP \
		-p tcp --dport 25 -j DNAT --to $PRIVATE_EMAIL_IP
$IPTABLES -t nat -A PREROUTING -d $PUBLIC_EMAIL_IP \
		-p tcp --dport 110 -j DNAT --to $PRIVATE_EMAIL_IP
$IPTABLES -t nat -A PREROUTING -d $PUBLIC_EMAIL_IP \
		-p tcp --dport 143 -j DNAT --to $PRIVATE_EMAIL_IP
$IPTABLES -t nat -A PREROUTING -d $PUBLIC_EMAIL_IP \
		-p tcp --dport 80 -j DNAT --to $PRIVATE_EMAIL_IP
$IPTABLES -t nat -A PREROUTING -d $PUBLIC_EMAIL_IP \
		-p tcp --dport 443 -j DNAT --to $PRIVATE_EMAIL_IP


As a benchmark test, from an internal host, I'll do telnet {public IP}
80.  And then listen in another window on the firewall with tcpdump.
Once we came across the promiscuous mode theory, we tried tcpdump with
-e and -p.  -e shows layer 2 stuff and -p does not put the device into
promiscuous mode.  Here is what we found:

For my testing, from a CMD window on the server hosting the website, I
do:

telnet aa.bb.115.151 80 (aa.bb obfuscated first 2 IP Address octets),
and then watch with tcpdump on the firewall.  

Also on the firewall, I did this:
echo "0" > /proc/sys/net/ipv4/conf/eth0/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/eth1/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/br0/rp_filter

So that turned of any possible rp_filtering.  

And then on the firewall:
/usr/sbin/tcpdump -p -e -i br0 host aa.bb.115.151 -nn -vv

while the telnet was running in another window.

Nothing - no output, no matter what value I use for any of the rp_filter
files.  Nothing from my telnet session to port 80 hits bridge br0 on the
firewall.  

But here's the curious part - looking at physical interface eth1, I see
these packets when I do the same telnet test:

[root@ehac-fw2011 ~]# /usr/sbin/tcpdump -p -e -i eth1 host aa.bb.115.151
-nn -vv
tcpdump: WARNING: eth1: no IPv4 address assigned
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size
65535 bytes
14:51:33.412280 00:0f:20:f7:06:18 > 00:03:47:3a:59:79, ethertype IPv4
(0x0800), length 62: (tos 0x0, ttl 128, id 18631, offset 0, flags [DF],
proto TCP (6), length 48)
    192.168.10.2.54092 > aa.bb.115.151.80: Flags [S], cksum 0xddb2
(correct), seq 4146878900, win 65535, options [mss 1460,nop,nop,sackOK],
length 0
14:51:39.427928 00:0f:20:f7:06:18 > 00:03:47:3a:59:79, ethertype IPv4
(0x0800), length 62: (tos 0x0, ttl 128, id 18733, offset 0, flags [DF],
proto TCP (6), length 48)
    192.168.10.2.54092 > aa.bb.115.151.80: Flags [S], cksum 0xddb2
(correct), seq 4146878900, win 65535, options [mss 1460,nop,nop,sackOK],
length 0 ^C
2 packets captured
2 packets received by filter
0 packets dropped by kernel
[root@ehac-fw2011 ~]#


So for some reason, the bridging stuff is apparently not passing from
eth1 to br0.  The single, one and only change to make this work is:

ip link set br0 promisc on

When I do above, then the internal packets to external IP Addresses flow
out to the firewall and back in as expected.  

Did bridging used to put the bridge device into promiscuous mode by
default and now it doesn't?  Just trying to figure out what's different.


thanks

- Greg Scott
