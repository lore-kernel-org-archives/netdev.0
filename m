From: "Bernhard M. Wiedemann" <vger201406bmw@lsmod.de>
Subject: vhost+vlan CHECKSUM_PARTIAL bug
Date: Sat, 28 Jun 2014 12:14:09 +0200
Message-ID: <53AE9571.5040203@lsmod.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from golf.zq1.de ([144.76.96.7]:40229 "EHLO golf.zq1.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923AbaF1KUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jun 2014 06:20:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

I tracked down and built a reproducer for a rather hidden but ugly
bug, that we hit by accident.
It occurs, when using vhost/tap and VLAN for sending TCP into a KVM VM
which then decides to forward it (using DNAT+SNAT in my reproducer) on
an interface that can not carry on the CHECKSUM_PARTIAL optimization
bit, so it has to calculate the TCP checksum,
but happens to write it 4 bytes early into the outgoing packet.
And 4 bytes is the offset added by the VLAN header.

I built me a vanilla 3.16.0-rc2+ for testing with an added patch
that you can find in
http://www.zq1.de/~bernhard/temp/bnc884706/
along with pcaps before and after being screwed
by the CHECKSUM_PARTIAL logic


here is the reproducer:


# be in a directory with 500MB free disk space
wget -nc http://www.zq1.de/~bernhard/temp/sp3-mini.qcow2
# VM login is root:linux
# iptables rules are in /usr/local/sbin/
echo '#!/bin/sh
t=$1;
vconfig add $t 300
ifconfig $t up
ifconfig $t.300 192.168.77.1/24
' >myifup77
chmod a+x myifup77
echo '#!/bin/sh
t=$1;
ifconfig $t 192.168.76.1/24
' >myifup76
chmod a+x myifup76

# as root:
qemu-kvm -drive file=sp3-mini.qcow2,if=virtio -net
nic,model=rtl8139,macaddr=52:54:00:12:34:33 -net
tap,script=myifup76,ifname=tap76 -daemonize -m 1000 -vnc :99 -netdev
type=tap,id=guest0,script=myifup77,vhost=on,ifname=tap77 -device
virtio-net-pci,netdev=guest0,mac=52:54:00:12:34:32
sleep 50 # wait for VM boot
/etc/init.d/apache2 start # or any other webserver
ethtool -K tap77 tx off
curl 192.168.77.2 # this should work
ethtool -K tap77 tx on
curl 192.168.77.2 # this fails here reproducibly


The debug output showed
on host: tun csum_start=34 csum_offset=16 headroom=230
on VM:   skb_checksum_help csum_start=30 csum_offset=16 headroom=68
partial=1

suggesting that either skb->csum_start or skb_headroom is off by 4
within the VM

I am not knowledgeable enough in linux net code to further debug or
fix this, thus asking you experts here.
Please help.

Ciao
Bernhard M.
- --
cloud software developer at SUSE
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlOulXEACgkQSTYLOx37oWQx7QCg074/0i+mkJnLRzG42T8zBifh
tTsAnRFzNonYeBCCpag1ZqR4DcfPV/46
=BBOd
-----END PGP SIGNATURE-----
