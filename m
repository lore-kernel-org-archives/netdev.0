From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: Question about Cisco's ISL
Date: Wed, 11 Aug 2004 02:11:44 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092156104.6767.60.camel@andromache>
References: <1089121054.22081.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joubert Berger <jberger@trustednetworktech.com>
In-Reply-To: <1089121054.22081.31.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-07-06 at 23:07, Joubert Berger wrote:
> I am writing some code to decode Cisco ISL frames.  I am having a
> difficult time figuring out how the FCS is calculated at the end of the
> frame.  Does anyone have any experience with Cisco ISL frames and
> possibly how to calculate the CRC at the end of the frame.

There are two FCSs in an ISL frame. Grab Document 17056 from the Cisco
web site for the ISL frame format and observe:

 - the encapsulated frame includes its FCS (and DA, SA, Type
   and Data).

 - the transmitted ISL frame uses a format that is capable
   of being forwarded by a non-ISL switch (MTU willing).
   So it has a DA, SA, Type and FCS which is acceptable to
   any ethernet switch.

In both cases the FCS is calculated as per 802.3.

Your thinking might be a bit clearer if you think about a switch taking
a received frame, wrapping it in a ISL encapsulation and forwarding it
down the VLAN trunk. The switch at the end of the trunk simply strips
the encapsulation and drops the unencapsulated frame directly onto the
wire.

If you are writing software then you need to manually calculate
the FCS of the encapsulated frame (this FCS is usually calculated by the
hardware of the ethernet controller). The FCS at the end of the ISL
frame will be calculated by the ethernet controller hardware.

Have a look at the Ethereal source code, it pulls apart ISL frames.

There are also two control protocols:

1) Cisco ISL runs 802.1D spanning tree but does so on every ISL VLAN,
whereas 802.1q runs spanning tree only on the default untagged VLAN.

2) Automated configuration uses Cisco's VLAN Trunking Protocol (VTP). I
don't know of a spec for this; it looks a bit of a dog's breakfast
(they're up to version 3 now); and deploying it could be dangerous (some
Cisco switches run only 32 VLANs and announcing more VLANs through VTP
can lead to a denial of service on those switches, so why would you
extend the trust required by VTP out to hosts?). ISL works fine without
VTP, you just need to manually configure the port as "trunk" rather than
"auto".

-- 
Glen Turner         Tel: (08) 8303 3936 or +61 8 8303 3936
Australian Academic & Research Network   www.aarnet.edu.au
