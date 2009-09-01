From: Andrew Dickinson <andrew@whydna.net>
Subject: ipsec not forwarding (suspect SA issue)
Date: Tue, 1 Sep 2009 11:57:40 -0700
Message-ID: <606676310909011157g9ce5377gabc30a63da897049@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f195.google.com ([209.85.212.195]:33891 "EHLO
	mail-vw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbZIAS5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 14:57:38 -0400
Received: by vws33 with SMTP id 33so286925vws.33
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 11:57:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy netdev,

First, I'm not positive that this is the right list for this question,
so feel free to steer me in the right direction.  I'm trying to work
out an issue with ipsec not forwarding traffic from my LAN down my
tunnel.  I've walked through the troubleshooting-doc on the lartc site
and everything seems kosher...

Here's my setup.

I've got a linux-based router/firewall on the edge of my network with
two interfaces, $WAN and $LAN.  The router is MASQUERADING to the
internet.  My LAN is 10.0.0.0/24.  I'm trying to peer with a remote
network 10.254.0.0/23.  The remote network does not have internet
connectivity, so all non-10.254/23 traffic should traverse the VPN to
get to my router to go to the internet or my local LAN.

I'm using racoon and setkey to establish the VPN tunnel and BGP (via
quagga) to advertise routes into the remote network.  The routers are
using 169.254.255.0/30 for BGP.

The problem that I'm having is that traffic from my LAN to 10.254/23
is not going down the VPN tunnel; it just disappears.  I can see it
come in on the LAN interface, but I don't see it leave the WAN
interface as either unencrypted traffic or as esp traffic.  Traffic
from the router, however, works fine.

------ BEGIN racoon.conf ------
log info;

path pre_shared_key "/etc/racoon/psk.txt";


listen {
    adminsock "/var/run/racoon/racoon.sock" "root" "operator" 0660;
    isakmp <MY_IP>
}

timer {
    counter 5;
    interval 20 sec;
    persend 1;
    phase1 30 sec;
    phase2 15 sec;
}

remote anonymous {
    exchange_mode main,aggressive,base;
    lifetime time 28800 sec;
    proposal_check obey;
    dpd_delay 10;
    dpd_retry 10;
    dpd_maxfail 3;
    esp_frag 1396;
    proposal {
        encryption_algorithm aes;
        hash_algorithm sha1;
        authentication_method pre_shared_key;
        dh_group 2;
    }
}

sainfo anonymous {
    authentication_algorithm hmac_sha1;
    encryption_algorithm aes;
    lifetime time 3600 seconds;
    compression_algorithm deflate;
    pfs_group 2;
}

------- END racoon.conf -------

------ BEGIN setkey.conf -----
flush;
spdflush;


spdadd 169.254.255.1 169.254.255.2 any -P in ipsec
    esp/tunnel/REMOTE_IP-MY_IP/unique;
spdadd 169.254.255.2 169.254.255.1 any -P out ipsec
    esp/tunnel/MY_IP-REMOTE_IP/unique;

spdadd 10.254.0.0/23 0.0.0.0/0 any -P in ipsec
    esp/tunnel/REMOTE_IP-MY_IP/unique;
spdadd 0.0.0.0/0 10.254.0.0/23 any -P fwd ipsec
    esp/tunnel/MY_IP-REMOTE_IP/unique;
spdadd 0.0.0.0/0 10.254.0.0/23 any -P out ipsec
    esp/tunnel/MY_IP-REMOTE_IP/unique;

spdadd 0.0.0.0/0 0.0.0.0/0 254 -P in ipsec
    esp/tunnel/REMOTE_IP-MY_IP/unique;
spdadd 0.0.0.0/0 0.0.0.0/0 254 -P out ipsec
    esp/tunnel/MY_IP-REMOTE_IP/unique;

spdadd 0.0.0.0/0 0.0.0.0/0 tcp -P in none;
spdadd 0.0.0.0/0 0.0.0.0/0 tcp -P out none;
spdadd 0.0.0.0/0 0.0.0.0/0 udp -P in none;
spdadd 0.0.0.0/0 0.0.0.0/0 udp -P out none;

----- END setkey.conf ----

There's two things that are potentially funky with this config that
I'm not proud of (and which might potentially be part of my problem).
When racoon goes to phase2 negotiation, it looks for an SPD with 0/0 -
0/0 [any] .   I've installed an SPD of 0/0 - 0/0 [254] in order to
make racoon happy.  This isn't a problem for me as I don't have any
traffic using IP protocol #254 (obviously).  The other thing is that
I'm explicitly adding a fwd rule... that was my effort to try to fix
my problem (it didn't help).  Beyond that, the rest of the rules seem
fairly straight forward.

Further, when I initially connect the VPN, I see racoon do an SA
negotiation for the 0/0 rules.  When I start quagga, I see it do an SA
for the 169.254... rules.  If I ping a remote machine from the
routers, I see it do an SA for the 10.254.0.0/23 rules.  But if I ping
from something on my LAN there's no negotiation (this is true whether
I ping from the router first or not).

Here's what I've double checked:
1) iptables nat table has rules to ACCEPT 10.254.0.0/23 destined
traffic to prevent it from being MASQUERADE'd (which I see counters
for when I ping from the router)
2) iptables (main) table has FORWARD rules to ACCEPT 10.254.0.0/23
destined traffic (which I never see counters for)
3) IP forwarding is enabled (as this router is happily forwarding
other traffic to-from the LAN to the internet)

It seems like this is an issue with an SA not getting found for
forwarding traffic and the kernel silently dropping the packet.  How
do I debug this?

-A
