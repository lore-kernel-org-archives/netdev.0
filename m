From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: ipsec not forwarding (suspect SA issue)
Date: Wed, 2 Sep 2009 07:41:04 -0700
Message-ID: <606676310909020741n70d46b3ev1197b487feaedb19@mail.gmail.com>
References: <606676310909011157g9ce5377gabc30a63da897049@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f195.google.com ([209.85.212.195]:46560 "EHLO
	mail-vw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbZIBOlE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:41:04 -0400
Received: by vws33 with SMTP id 33so790013vws.33
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 07:41:05 -0700 (PDT)
In-Reply-To: <606676310909011157g9ce5377gabc30a63da897049@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to follow up on this... it was an SA issue, but due to my config
and not a kernel problem. :D

specifically, I changed the "uniques" to "requires" in the spdadd
lines and dropped the "fwd" entry that I'd manually added... that
straightened everything out :D

-A

On Tue, Sep 1, 2009 at 11:57 AM, Andrew Dickinson<andrew@whydna.net> wr=
ote:
> Howdy netdev,
>
> First, I'm not positive that this is the right list for this question=
,
> so feel free to steer me in the right direction. =A0I'm trying to wor=
k
> out an issue with ipsec not forwarding traffic from my LAN down my
> tunnel. =A0I've walked through the troubleshooting-doc on the lartc s=
ite
> and everything seems kosher...
>
> Here's my setup.
>
> I've got a linux-based router/firewall on the edge of my network with
> two interfaces, $WAN and $LAN. =A0The router is MASQUERADING to the
> internet. =A0My LAN is 10.0.0.0/24. =A0I'm trying to peer with a remo=
te
> network 10.254.0.0/23. =A0The remote network does not have internet
> connectivity, so all non-10.254/23 traffic should traverse the VPN to
> get to my router to go to the internet or my local LAN.
>
> I'm using racoon and setkey to establish the VPN tunnel and BGP (via
> quagga) to advertise routes into the remote network. =A0The routers a=
re
> using 169.254.255.0/30 for BGP.
>
> The problem that I'm having is that traffic from my LAN to 10.254/23
> is not going down the VPN tunnel; it just disappears. =A0I can see it
> come in on the LAN interface, but I don't see it leave the WAN
> interface as either unencrypted traffic or as esp traffic. =A0Traffic
> from the router, however, works fine.
>
> ------ BEGIN racoon.conf ------
> log info;
>
> path pre_shared_key "/etc/racoon/psk.txt";
>
>
> listen {
> =A0 =A0adminsock "/var/run/racoon/racoon.sock" "root" "operator" 0660=
;
> =A0 =A0isakmp <MY_IP>
> }
>
> timer {
> =A0 =A0counter 5;
> =A0 =A0interval 20 sec;
> =A0 =A0persend 1;
> =A0 =A0phase1 30 sec;
> =A0 =A0phase2 15 sec;
> }
>
> remote anonymous {
> =A0 =A0exchange_mode main,aggressive,base;
> =A0 =A0lifetime time 28800 sec;
> =A0 =A0proposal_check obey;
> =A0 =A0dpd_delay 10;
> =A0 =A0dpd_retry 10;
> =A0 =A0dpd_maxfail 3;
> =A0 =A0esp_frag 1396;
> =A0 =A0proposal {
> =A0 =A0 =A0 =A0encryption_algorithm aes;
> =A0 =A0 =A0 =A0hash_algorithm sha1;
> =A0 =A0 =A0 =A0authentication_method pre_shared_key;
> =A0 =A0 =A0 =A0dh_group 2;
> =A0 =A0}
> }
>
> sainfo anonymous {
> =A0 =A0authentication_algorithm hmac_sha1;
> =A0 =A0encryption_algorithm aes;
> =A0 =A0lifetime time 3600 seconds;
> =A0 =A0compression_algorithm deflate;
> =A0 =A0pfs_group 2;
> }
>
> ------- END racoon.conf -------
>
> ------ BEGIN setkey.conf -----
> flush;
> spdflush;
>
>
> spdadd 169.254.255.1 169.254.255.2 any -P in ipsec
> =A0 =A0esp/tunnel/REMOTE_IP-MY_IP/unique;
> spdadd 169.254.255.2 169.254.255.1 any -P out ipsec
> =A0 =A0esp/tunnel/MY_IP-REMOTE_IP/unique;
>
> spdadd 10.254.0.0/23 0.0.0.0/0 any -P in ipsec
> =A0 =A0esp/tunnel/REMOTE_IP-MY_IP/unique;
> spdadd 0.0.0.0/0 10.254.0.0/23 any -P fwd ipsec
> =A0 =A0esp/tunnel/MY_IP-REMOTE_IP/unique;
> spdadd 0.0.0.0/0 10.254.0.0/23 any -P out ipsec
> =A0 =A0esp/tunnel/MY_IP-REMOTE_IP/unique;
>
> spdadd 0.0.0.0/0 0.0.0.0/0 254 -P in ipsec
> =A0 =A0esp/tunnel/REMOTE_IP-MY_IP/unique;
> spdadd 0.0.0.0/0 0.0.0.0/0 254 -P out ipsec
> =A0 =A0esp/tunnel/MY_IP-REMOTE_IP/unique;
>
> spdadd 0.0.0.0/0 0.0.0.0/0 tcp -P in none;
> spdadd 0.0.0.0/0 0.0.0.0/0 tcp -P out none;
> spdadd 0.0.0.0/0 0.0.0.0/0 udp -P in none;
> spdadd 0.0.0.0/0 0.0.0.0/0 udp -P out none;
>
> ----- END setkey.conf ----
>
> There's two things that are potentially funky with this config that
> I'm not proud of (and which might potentially be part of my problem).
> When racoon goes to phase2 negotiation, it looks for an SPD with 0/0 =
-
> 0/0 [any] . =A0 I've installed an SPD of 0/0 - 0/0 [254] in order to
> make racoon happy. =A0This isn't a problem for me as I don't have any
> traffic using IP protocol #254 (obviously). =A0The other thing is tha=
t
> I'm explicitly adding a fwd rule... that was my effort to try to fix
> my problem (it didn't help). =A0Beyond that, the rest of the rules se=
em
> fairly straight forward.
>
> Further, when I initially connect the VPN, I see racoon do an SA
> negotiation for the 0/0 rules. =A0When I start quagga, I see it do an=
 SA
> for the 169.254... rules. =A0If I ping a remote machine from the
> routers, I see it do an SA for the 10.254.0.0/23 rules. =A0But if I p=
ing
> from something on my LAN there's no negotiation (this is true whether
> I ping from the router first or not).
>
> Here's what I've double checked:
> 1) iptables nat table has rules to ACCEPT 10.254.0.0/23 destined
> traffic to prevent it from being MASQUERADE'd (which I see counters
> for when I ping from the router)
> 2) iptables (main) table has FORWARD rules to ACCEPT 10.254.0.0/23
> destined traffic (which I never see counters for)
> 3) IP forwarding is enabled (as this router is happily forwarding
> other traffic to-from the LAN to the internet)
>
> It seems like this is an issue with an SA not getting found for
> forwarding traffic and the kernel silently dropping the packet. =A0Ho=
w
> do I debug this?
>
> -A
>
