From: P@draigBrady.com
Subject: Re: [E1000-devel] e1000 jumbo problems
Date: Thu, 24 Jun 2004 11:36:24 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40DAAEA8.7050105@draigBrady.com>
References: <40D883C2.7010106@draigBrady.com> <40D9BF6B.4050807@draigBrady.com> <41b516cb040623114825a9c555@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Leech <chris.leech@gmail.com>
In-Reply-To: <41b516cb040623114825a9c555@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Leech wrote:
>>>Another related issue, is that the driver uses 4KiB buffers
>>>for MTUs in the 1500 -> 2000 range which seems a bit silly.
>>>Any particular reason for that?
>=20
>=20
> It is wasteful, but does anyone actually use an MTU in the range of
> 1501 - 2030?  It seems silly to me to go with a non-standard frame
> size, but not go up to something that might give you a performance
> benefit (9k).

I'm seeing it with MPLS in some configs.
MPLS labels are just prepended onto ethernet frames giving frames
up to 1546 bytes. Using 4KiB frames for this situation is wasteful
of memory but more importantly for my application it has a noticeable
impact on receive performance.

>>I changed the driver to use 2KiB buffers for frames in the
>>1518 -> 2048 range (BSEX=3D0, LPE=3D1). This breaks however
>>as packets are not dropped that are larger than the max specified?
>>Instead they're scribbled into memory causing a lockup after a while.
>=20
>=20
> That sounds right, if you actually got the RCTL register set
> correctly.  In e1000_setup_rctl the adapter->rx_buffer_len is used to
> set that register, and it's currently written to only set LPE if the
> buffer size is bigger than 2k (thus, why 4k buffers are used even when
> the MTU is in the 1501 - 2030 range).  To use 2k buffers for slightly
> large frames, you'd want some new flag in the adapter for LPE (or
> check netdev->mtu I guess) and do something like: rctl |=3D
> E1000_RCTL_SZ_2048 | E1000_RCTL_LPE

yep, that's what I did.

> e1000 devices don't have a programmable MTU for receive filtering,
> they drop anything larger than 1518 unless LPE (long packet enable) is
> set.  If LPE is set they accept anything that fits in the FIFO and has
> a valid FCS.

thanks for that. What I'm noticing now is the same thing
happens with the official driver (5.2.52 or 5.2.30.1).
I.E. set the MTU to 4000 for e.g., then send in frames
larger than 4096 and they're accepted? Doing this for
a while causes mem to get corrupted.

> An MTU setting needs to be valid across your ethernet, why is the
> e1000 receiving a frame larger than the MTU? (jabber should be rare)=20
> But, if the length of receive buffers matches what was set in RCTL,
> larger than expected valid frames will spill over to the next buffer
> and be dropped in the driver without corrupting memory.

Are the buffers in contiguous mem? What happens for the last buffer?

>>I noticed in e1000_change_mtu() that adapter->hw.max_frame_size
>>is only set after e1000_down();e1000_up(); Is that correct?
>=20
> There might be a slight race there (I'll think about it some more),
> but it's not something that would cause memory corruption.=20
> hw.max_frame_size is only used in a software workaround for 82543
> based copper gigabit cards (vendor:device 8086:1004) when paired with
> certain link partners.

fair enough.

>=20
>>Are there any anwsers for the general questions I had even?
>>
>>1. Is there a public dev tree available for the e1000 driver?
>=20
> No, the best source base to work from is what is in the 2.6 kernel
> tree (or Jeff's net-drivers tree).  We keep that as up to date as
> possible, and it's always fairly close to our internal development
> sources.
>=20
>>2. Are there programming docs for the various GigE chipsets?
>=20
> Not publicly available at this time.

thanks a million,
P=E1draig.
