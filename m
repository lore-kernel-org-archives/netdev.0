From: "Ian! D. Allen" <idallen@idallen.ca>
Subject: rp_filter interaction with netfilter SNAT/un-SNAT
Date: Sat, 26 Feb 2005 18:37:07 -0500
Message-ID: <20050226233707.GA11802@elm.home.idallen.ca>
References: <20050226161836.GA15277@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050226161836.GA15277@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am using netfilter to mark packets that have a given session id
(--sid-owner).  I then SNAT the marked packets to have an eth2 source
address 66.11.175.98.  I use iproute2 to divert these fwmark marked
packets out eth2 instead of the default eth0.

Tcpdump confirms that the packets leave eth2 with the correct source
address.  Return packets come back with the correct eth2 destination
address.  Then, the 2.6.10 kernel rp_filter mysteriously rejects the
returning packets as martians with a bad source address.  For example:

    # ping google.ca
    PING google.ca (216.239.59.104) 56(84) bytes of data.
    --- google.ca ping statistics ---
    5 packets transmitted, 0 received, 100% packet loss, time 3999ms

The ping packets as seen by tcpdump going out/in on eth2 (66.11.175.98):

    15:46:46.058033 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], length:
       84) 66.11.175.98 > 216.239.59.104: icmp 64: echo request seq 1
    15:46:46.215603 IP (tos 0x0, ttl 239, id 0, offset 0, flags [DF], length:
       84) 216.239.59.104 > 66.11.175.98: icmp 64: echo reply seq 1
    15:46:47.057421 IP (tos 0x0, ttl  64, id 1, offset 0, flags [DF], length:
       84) 66.11.175.98 > 216.239.59.104: icmp 64: echo request seq 2
    15:46:47.223310 IP (tos 0x0, ttl 239, id 1, offset 0, flags [DF], length:
       84) 216.239.59.104 > 66.11.175.98: icmp 64: echo reply seq 2

What the kernel (2.6.10) objects to:

    Feb 23 15:46:46 elm kernel: martian source 192.168.9.250 from
       216.239.59.104, on dev eth2
    Feb 23 15:46:47 elm kernel: martian source 192.168.9.250 from
       216.239.59.104, on dev eth2

192.168.9.250 is the old pre-SNAT source address (eth0) of these packets.

The kernel is objecting to packets with the wrong source address on eth2;
but, they don't have the wrong source address because they were SNATd
specifically for eth2 and left and returned with the correct address.

If I set the source address at the application level in ping (no SNAT
needed on these), things work fine:

    # ping -I eth2 google.ca
    PING google.ca (216.239.39.104) from 66.11.175.98 eth2: 56(84) bytes
    64 bytes from 216.239.39.104: icmp_seq=1 ttl=243 time=53.2 ms
    64 bytes from 216.239.39.104: icmp_seq=2 ttl=243 time=54.7 ms
    64 bytes from 216.239.39.104: icmp_seq=3 ttl=243 time=55.1 ms

Here's what tcpdump sees for these packets going out/in eth2:

    16:05:22.446901 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], length:
       84) 66.11.175.98 > 216.239.39.104: icmp 64: echo request seq 1
    16:05:22.500097 IP (tos 0x0, ttl 243, id 0, offset 0, flags [DF], length:
       84) 216.239.39.104 > 66.11.175.98: icmp 64: echo reply seq 1
    16:05:23.448149 IP (tos 0x0, ttl  64, id 1, offset 0, flags [DF], length:
       84) 66.11.175.98 > 216.239.39.104: icmp 64: echo request seq 2
    16:05:23.502901 IP (tos 0x0, ttl 243, id 1, offset 0, flags [DF], length:
       84) 216.239.39.104 > 66.11.175.98: icmp 64: echo reply seq 2

These above "working" packets from the above session look no different to
tcpdump on eth2 than the non-working packets from the previous session.
The packets are leaving with the correct source address for eth2 and
are returing correctly.  Shouldn't both sets of packets be treated the
same way?

I think that rp_filter checks are a good thing; but, shouldn't the martian
check take place closer to the wire where the packets are coming in?
The kernel is apparently checking for martians *after* the corresponding
un-SNAT rule for the echo reply changes the incoming destination address
from 66.11.175.98 back to 192.168.9.250.

I think people use rp_filter to prevent spoofed packets coming in
over *the wire*, not to prevent SNAT rules from working.  The martian
check should be on the packets as received *over the wire* from eth2,
not after the un-SNAT rule internally mangles the packet destination.

If I'm looking for spoofed packets, I want to check the packets where
the danger is - out at the wire where the spoofed packets arrive -
not somewhere in the middle of the network stack mangling.

I could (must) disable source validation for all packets (rp_filter=0);
but, I'd rather have the kernel not complain about packets on eth2 that
really and truly did arrive with the correct eth2 address.

Am I misunderstanding the intent of rp_filter?  Is there a work-around
that doesn't involve disabling it entirely on the interface?

-- 
-IAN!  Ian! D. Allen   Ottawa, Ontario, Canada
       EMail: idallen@idallen.ca   WWW: http://www.idallen.com/
       College professor (Linux) via: http://teaching.idallen.com/
       Support free and open public digital rights:  http://eff.org/
