From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Supporting 4 way connections in LKSCTP
Date: Wed, 27 Nov 2013 07:45:30 -0500
Message-ID: <20131127124530.GA23369@hmsreliant.think-freely.org>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>
 <5294BC01.7090605@gmail.com>
 <CAFXGftLsKm9a5bmXX4Fe+rnSvYVdBDOyYGwisRP7XMu+ky=DGw@mail.gmail.com>
 <CAFXGftLt1p6XpR2eGsMYKjEbbOHvch-LgcFw1sAXThcA2Rtjyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sun Paul <paulrbk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37715 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab3K0Mpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 07:45:38 -0500
Content-Disposition: inline
In-Reply-To: <CAFXGftLt1p6XpR2eGsMYKjEbbOHvch-LgcFw1sAXThcA2Rtjyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 27, 2013 at 07:10:49AM +0800, Sun Paul wrote:
> Hi Vlad
> 
> Thank for your reply. If it is based on the destination IP to find the
> best route, why the problem didn't happen on single-homing sample?
> 
Because You only ever use one address from NODE A (12.1.1.1)

> In the single-homing sample that provided in the original email, both
> of the interfaces (eth1 and eth2) are presented on NODE-B during the
> test. However, the LKSCTP library know to use the interface eth1 to
> respond to the SCTP request.
> 
Yes, because it does a route lookup to each of the two ip addresses to NODE B,
and in both lookups, the route indicates that only one source address should be
used (12.1.1.1).  If you issue a ip route show command, you'll see that routes
to both address on NODE B match on a rule that specifies the same src address
and interface be used.

Neil

> - PS
> 
> On Wed, Nov 27, 2013 at 7:09 AM, Sun Paul <paulrbk@gmail.com> wrote:
> > Hi Vlad
> >
> > Thank for your reply. If it is based on the destination IP to find the
> > best route, why the problem didn't happen on single-homing sample?
> >
> > In the single-homing sample that provided in the original email, both
> > of the interfaces (eth1 and eth2) are presented on NODE-B during the
> > test. However, the LKSCTP library know to use the interface eth1 to
> > respond to the SCTP request.
> >
> > - PS
> >
> > On Tue, Nov 26, 2013 at 11:19 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> >> On 11/25/2013 08:03 PM, Sun Paul wrote:
> >>> Hi
> >>>
> >>> we have a problem on using LKSCTP to form a 4 ways multi-homing network.
> >>>
> >>> Configuration
> >>> - Node-A has 2 IP addresses in different subnets, known as IP-A (eth1),
> >>> IP-B (eth2)
> >>> - Node-B has 2 IP addresses in different subnets, known as IP-X (eth1),
> >>> IP-Y (eth2)
> >>>
> >>
> >> First of all, this is not a 4 way multi-homed network.  As far as each
> >> SCTP association is concerned, it has only 2 destinations to send to
> >> so it has only 2 ways to get there.  The fact that you have multiple
> >> local addresses doesn't mean that every local address can and should
> >> be used to connect to the remote.
> >>
> >>> the four way paths are shown below.
> >>> 1. IP-A (11.1.1.1) to IP-X (11.1.1.11)
> >>> 2. IP-B (12.1.1.1) to IP-Y (12.1.1.11)
> >>> 3. IP-A (11.1.1.1) to IP-Y (12.1.1.11)
> >>> 4. IP-B (12.1.1.1) to IP-X (11.1.1.11)
> >>
> >> No, actually you only have 2 paths:  one to IPX and one to IP-Y.
> >> Which source address you choose is based on routing policy
> >> decisions and is outside the scope of SCTP.
> >>
> >>>
> >>> the HB/HB_ACK is normal for the paths " IP-A to IP-X" and "IP-B to
> >>> IP-Y", but it is not correct for the rest of two.
> >>
> >> Right, because linux is using a host addressing model, not an interface
> >> addressing model.  SCTP stack simply finds the best source address
> >> that can be used to reach IP-X and it happens to be IP-A.  So that
> >> is what it is going to use.
> >>
> >> The above explains why you are seeing what you describe below.
> >>
> >> In the end, linux SCTP implementation determines paths solely based
> >> on the destination address.
> >>
> >> -vlad
> >>
> >>>
> >>> First of all, we are using iproute2 to form 2 table such that when
> >>> IP-B arrives on IP-X, it will know how to route back to IP-B on the
> >>> same interface, i.e (eth1). Same logic for the path "IP-A to IP-X".
> >>>
> >>> What we observed here is that when 12.1.1.1 sends INIT to 11.1.1.11,
> >>> LKSCTP will send back the INIT_ACK to 12.1.1.1 using 12.1.1.11 but not
> >>> using the IP 11.1.1.11.
> >>>
> >>> The above operation makes the subsequence HB/HB_ACK in using wrong IP address.
> >>>
> >>> TCP trace on eth1
> >>> 18:02:41.058640 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [INIT]
> >>> [init tag: 19933036] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
> >>> 18:02:41.061634 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [COOKIE ECHO]
> >>> 18:02:41.062642 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:41.062846 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
> >>> 18:02:41.361811 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
> >>> 18:02:41.661791 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
> >>> 18:02:41.961791 IP 11.1.1.11.2905 > 11.1.1.1.2905: sctp (1) [HB ACK]
> >>>
> >>> TCP trace on eth2
> >>> 18:02:41.058755 IP 12.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [INIT ACK]
> >>> [init tag: 424726157] [rwnd: 131072] [OS: 5] [MIS: 5] [init TSN:
> >>> 3340756356]
> >>> 18:02:41.061696 IP 12.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [COOKIE ACK]
> >>> 18:02:41.062663 IP 12.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
> >>> 18:02:41.062791 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:41.361777 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:41.661772 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:41.961772 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:42.161771 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:42.461770 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:02:42.675770 IP 11.1.1.1.2905 > 12.1.1.11.2905: sctp (1) [HB REQ]
> >>>
> >>>
> >>> If we are using single homing, there is no problem on the SCTP
> >>> communication. Below is the TCP trace on eth1 using sctp_test
> >>>
> >>> 18:09:55.356727 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [INIT]
> >>> [init tag: 32516609] [rwnd: 102400] [OS: 16] [MIS: 16] [init TSN: 0]
> >>> 18:09:55.356811 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [INIT ACK]
> >>> [init tag: 3168861995] [rwnd: 131072] [OS: 10] [MIS: 16] [init TSN:
> >>> 1877695021]
> >>> 18:09:55.357727 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [COOKIE ECHO]
> >>> 18:09:55.357788 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [COOKIE ACK]
> >>> 18:09:55.358724 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:09:55.358740 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
> >>> 18:09:55.379715 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [DATA]
> >>> (B)(E) [TSN: 0] [SID: 0] [SSEQ 0] [PPID 0x3]
> >>> 18:09:55.379735 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [SACK]
> >>> [cum ack 0] [a_rwnd 131064] [#gap acks 0] [#dup tsns 0]
> >>> 18:09:55.657716 IP 12.1.1.1.2905 > 11.1.1.11.2905: sctp (1) [HB REQ]
> >>> 18:09:55.657732 IP 11.1.1.11.2905 > 12.1.1.1.2905: sctp (1) [HB ACK]
> >>>
> >>> From the observations, it seems that the LKSCTP library is not able to
> >>> use the original local address when multi-homing is being used. Is
> >>> there anyway can be resolved it?
> >>>
> >>> Thanks
> >>>
> >>> PS
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
