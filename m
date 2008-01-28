From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2: tx hang on dual-port Yukon XL when rx csum disabled
Date: Mon, 28 Jan 2008 12:43:39 -0800
Message-ID: <20080128124339.4d013d71@deepthought>
References: <479E2247.8080109@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tony Battersby <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54809 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757782AbYA1Un4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 15:43:56 -0500
In-Reply-To: <479E2247.8080109@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jan 2008 13:43:19 -0500
Tony Battersby <tonyb@cybernetics.com> wrote:

> I am experiencing network tx hangs on a dual-port SK-9E22 with sky2 in
> 2.6.24.  The problem is triggered by both ports transmitting at high
> speed simultaneously.  This problem is 100% quickly reproducible.  Here
> is the setup:
> 
> PC #1 with Intel PRO/1000 NIC:
> e1000 IP address 192.168.1.1
> running iperf -s
> 
> PC #2 with Intel PRO/1000 NIC:
> e1000 IP address 192.168.2.1
> running iperf -s
> 
> PC #3 with SysKonnect SK-9E22 (dual-port copper PCI-express)
> sky2 IP address 192.168.1.2
> sky2 IP address 192.168.2.2
> 
> So basically, I have two PCs with Intel PRO/1000 NICs running "iperf
> -s".  Each of these Intel NICs is directly cabled to one of the two
> ports of the SysKonnect NIC.
> 
> When I run:
> (PC #3 tty1) iperf -c 192.168.1.1 -t 30
> (wait for a second or two)
> (PC #3 tty2) iperf -c 192.168.2.1 -t 30
> 
> "iperf -c 192.168.1.1" never finishes, but "iperf -c 192.168.2.1" does
> finish.  Press Ctrl-C to abort the hung iperf.  Ping 192.168.1.1 does
> not respond.  Ping 192.168.2.1 does respond, but each ping has almost
> exactly 1 second latency (the latency should be < 1 ms).
> 
> When I switch the order of the tests, whichever iperf -c was started
> _first_ is the one that locks up with no ping afterward, and whichever
> was started _second_ is the one that finishes, but with a 1-second ping
> latency afterward.  So the problem follows the ordering of the tests
> rather than a specific port.
> 
> Also, the trigger seems to be transmitting, not receiving.  If I run
> "iperf -s" on the SysKonnect PC and "iperf -c" on the two Intel PRO/1000
> PCs, then the tests pass.
> 
> When I do "ethtool -K eth0 rx on; ethtool -K eth1 rx on" to turn on rx
> checksumming on both ports of the SysKonnect NIC, both tests pass
> successfully.  Commit 8b31cfbcd1b54362ef06c85beb40e65a349169a2 "sky2:
> disable rx checksum on Yukon XL" disabled rx checksumming by default on
> this NIC to get rid of some "hw csum failure" messages
> (http://marc.info/?l=linux-netdev&m=119497815523843&w=4).  However, this
> seems to have exposed a different (and arguably worse) bug.
> 
> I also tried booting with "maxcpus=1 pci=nomsi", but that didn't affect
> the problem.
> 
> As a temporary workaround, I will use ethtool to turn on rx checksumming
> and live with the "hw csum failure" messages, since they are better than
> network lockups.
> 
> Let me know if I can be of any further assistance in tracking down this
> problem.
> 
> Tony Battersby
> Cybernetics

What bus and chipset is in use on the systems with sky2?
I have seen problems when using PCI-X on AMD systems (documented in AMD errata)
due to multiple outstanding transactions.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
