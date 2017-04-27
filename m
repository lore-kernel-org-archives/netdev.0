From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Thu, 27 Apr 2017 15:04:50 +0200
Message-ID: <20170427130450.GL17172@lunn.ch>
References: <58F9FD64.80506@aoifes.com>
 <20170425082741.59428876@xeon-e3>
 <5901DE9F.1070005@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Rafa Corvillo <rafael.corvillo@aoifes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43290 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033141AbdD0NEx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 09:04:53 -0400
Content-Disposition: inline
In-Reply-To: <5901DE9F.1070005@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 02:05:51PM +0200, Rafa Corvillo wrote:
> On 25/04/17 17:27, Stephen Hemminger wrote:
> >On Fri, 21 Apr 2017 14:39:00 +0200
> >Rafa Corvillo <rafael.corvillo@aoifes.com> wrote:
> >
> >>We are working in an ARMv7 embedded system running kernel 4.9 (LEDE build).
> >>It is an imx6 board with 2 ethernet interfaces. One of them is connected to
> >>a Marvell switch.
> >>
> >>The schema of the system is the following:
> >>

Hi Rafa

Your ASCII art got messed up somewhere. Is this the correct
reconstruction?

   +-------------------+ eth0
   |                   +--+
   |                   |  |
   | Embedded system   +--+
   |                   |
   |      ARMv7        |
   |                   | Marvell 88E8057(sky2)     +-------------+
   |                   +--+                     +--+             +--+ eth1
   |                   |  +---------------------+  |             |  +------+
   |                   +--+      CPU port       +--+ mv88e6176   +--+
   +------+--+---------+                           |             |
emulated  |  |                                     |             |
GPIO      +--+                                  +--+             +--+ eth2
MDIO       +-----------------------------------+   |             |  +------+
                                MDIO            +--+             +--+
                                                   +-------------+

I assume you are using DSA? Since this is LEDE, it could be swconfig,
but the bridge configuration you mentioned would not make sense for
swconfig.

> >>If I connect the eth1/eth2, the link is up and I can do ping through it.
> >>But, once
> >>I start sending a heavy traffic load the link fails and the kernel sends the
> >>following messages:
> >>
> >>[   48.557140] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   48.564964] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   48.572110] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   48.579263] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   48.586417] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   48.593573] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   48.600718] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   54.877567] net_ratelimit: 6 callbacks suppressed
> >>[   54.882293] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >>[   61.413552] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
> >>length 1518
> >
> >The status error bits are in sky2.h
> >0x5f20010 is
> >      05f2 frame length => 1522
> >      0010 Too long err
> >
> >That means the packet was longer than the configured MTU.
> >You are probably getting packets with VLAN tag but have not configured
> >a VLAN.

Since you are using DSA, you will have DSA tags enabled on frames
to/from the switch. This adds an extra 8 byte header in the frame.  My
guess is, it is this header, not the VLAN tag which is causing you MTU
issues.

I think this is the first time i've seen sky2 used in a DSA
setup. mv643xx or mvneta is generally what is used, when using Marvell
chipsets. These drivers are more lenient about MTU, and are happy to
pass frames with additional headers.

> Thanks for the information. I have increased the MTU value to 1550
> (workaround) and it works if sends traffic (with iperf) from my
> computer to the unit. But, if I send traffic outside the unit, I get
> a new error message and link goes down:

Changing the MTU like this is not a good fix. It will allow you to
receive frames which are bigger, but it also means the local network
stack will generate bigger frames to be transmitted. You probably need
to modify the sky2 driver to allow it to receive frames bigger than
the interface MTU, by about 8 bytes.
 
> [ 4901.032989] sky2 0000:04:00.0 marvell: tx timeout
> [ 4904.722670] sky2 0000:04:00.0 marvell: Link is up at 1000 Mbps,
> full duplex, flow control both

Between the sky2 and the switch, do you have two back-to-back PHYs or
are you connecting the RGMII interfaces together?

    Andrew
