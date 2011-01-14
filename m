From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Fri, 14 Jan 2011 12:49:47 -0500
Message-ID: <AANLkTi=Z4mtV5SUqORivPKPxEGddsmQQ2sVdkeOAogeY@mail.gmail.com>
References: <20101215012430.120fd47f@xenia.leun.net>
	<20101215013431.GA21173@mcarlson.broadcom.com>
	<20101215081606.18e12fc9@xenia.leun.net>
	<AANLkTi=hGRW+DwoKQzxPAZao6-y_tvn6nNXS-tj_-Y6T@mail.gmail.com>
	<20110107032459.GA17959@mcarlson.broadcom.com>
	<AANLkTi=N6jFE7T1=W-WLo_eHYWeE=oB6n8C8zPGoBNQF@mail.gmail.com>
	<20110113012157.GA28147@mcarlson.broadcom.com>
	<AANLkTimz3Mw5itChtTgHTeGT4seJauy3+FVrpEJn1iez@mail.gmail.com>
	<20110113205056.GA29254@mcarlson.broadcom.com>
	<AANLkTimQ1T0erugwK17o0zuSwxVh-Ro4yCsBpOqCykyr@mail.gmail.com>
	<20110114011533.GA29723@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110114011533.GA29723@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2011 at 8:15 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> On Thu, Jan 13, 2011 at 01:58:40PM -0800, Jesse Gross wrote:
>> On Thu, Jan 13, 2011 at 3:50 PM, Matt Carlson <mcarlson@broadcom.com=
> wrote:
>> > On Thu, Jan 13, 2011 at 07:06:22AM -0800, Jesse Gross wrote:
>> >> On Wed, Jan 12, 2011 at 8:21 PM, Matt Carlson <mcarlson@broadcom.=
com> wrote:
>> >> > On Thu, Jan 06, 2011 at 08:36:27PM -0800, Jesse Gross wrote:
>> >> >> On Thu, Jan 6, 2011 at 10:24 PM, Matt Carlson <mcarlson@broadc=
om.com> wrote:
>> >> >> > On Sat, Dec 18, 2010 at 07:38:00PM -0800, Jesse Gross wrote:
>> >> >> >> On Tue, Dec 14, 2010 at 11:16 PM, Michael Leun
>> >> >> >> <lkml20101129@newton.leun.net> wrote:
>> >> >> >> > OK - all tests done on that DL320G5:
>> >> >> >> >
>> >> >> >> > For completeness, 2.6.37-rc5 unpatched:
>> >> >> >> >
>> >> >> >> > eth0, no vlan configured: totally broken - see double tag=
ged vlans
>> >> >> >> > without tag, single or untagged packets missing at all
>> >> >> >>
>> >> >> >> Random behavior? ?This one is somewhat hard to explain - ma=
ybe there
>> >> >> >> are some other factors. ?eth0 has ASF on, so it always stri=
ps tags. ?I
>> >> >> >> would expect it to behave like the vlan configured case.
>> >> >> >>
>> >> >> >> >
>> >> >> >> > eth0, vlan configured: see packets without vlan tag (see =
double tagged
>> >> >> >> > packets with one vlan tag)
>> >> >> >>
>> >> >> >> Both ASF and vlan group configured cause tag stripping to b=
e enabled.
>> >> >> >> Missing tag.
>> >> >> >>
>> >> >> >> >
>> >> >> >> > eth1 same as originally reported:
>> >> >> >> > without vlan configured see vlan tags (single and double =
tagged as
>> >> >> >> > expected)
>> >> >> >>
>> >> >> >> No ASF and no vlan group means tag stripping is disabled. ?=
Have tag.
>> >> >> >>
>> >> >> >> > with vlan configured: see packets without vlan tag (see d=
ouble tagged
>> >> >> >> > packets with one vlan tag)
>> >> >> >>
>> >> >> >> Configuring vlan group causes stripping to be enabled. ?Mis=
sing tag.
>> >> >> >>
>> >> >> >> >
>> >> >> >> >
>> >> >> >> > 2.6.37-rc5, your tg3 use new vlan-code patch:
>> >> >> >> >
>> >> >> >> > eth0, no vlan configured: ?see packets without vlan tag (=
see double
>> >> >> >> > tagged packets with one vlan tag)
>> >> >> >>
>> >> >> >> ASF enables tag stripping. ?Missing tag.
>> >> >> >>
>> >> >> >> > eth1, no vlan configured: see vlan tags (single and doubl=
e tagged as
>> >> >> >> > expected)
>> >> >> >>
>> >> >> >> No ASF, no vlan group means no stripping. ?Have tag.
>> >> >> >>
>> >> >> >> >
>> >> >> >> >
>> >> >> >> > eth0, vlan configured: as without vlan
>> >> >> >>
>> >> >> >> ASF enables stripping. ?Missing tag.
>> >> >> >>
>> >> >> >> > eth1, vlan configured: as without vlan
>> >> >> >>
>> >> >> >> With this patch vlan stripping is only enabled when ASF is =
on, so no
>> >> >> >> stripping. ?Have tag.
>> >> >> >>
>> >> >> >> >
>> >> >> >> > 2.6.37-rc5, your tg3 use new vlan-code patch with test pa=
tch ontop
>> >> >> >> >
>> >> >> >> > eth1 no vlan configured: see packets without vlan tag (se=
e double tagged
>> >> >> >> > packets with one vlan tag)
>> >> >> >>
>> >> >> >> With the second patch, vlan stripping is always enabled. ?M=
issing tag.
>> >> >> >>
>> >> >> >> > eth1 with vlan: the same
>> >> >> >>
>> >> >> >> Stripping still always enabled. ?Missing tag.
>> >> >> >>
>> >> >> >> The bottom line is whenever vlan stripping is enabled we're=
 missing
>> >> >> >> the outer tag. ?It might be worth adding some debugging in =
the area
>> >> >> >> before napi_gro_receive/vlan_gro_receive (depending on vers=
ion). ?My
>> >> >> >> guess is that (desc->type_flags & RXD_FLAG_VLAN) is false e=
ven for
>> >> >> >> vlan packets on this NIC.
>> >> >> >>
>> >> >> >> You said that everything works on the 5752? ?Matt, is it po=
ssible that
>> >> >> >> the 5714 either has a problem with vlan stripping or a diff=
erent way
>> >> >> >> of reporting it?
>> >> >> >
>> >> >> > I don't think this is a 5714 specific issue. ?I think the pr=
oblem is
>> >> >> > rooted in the fact that the VLAN tag stripping is enabled.
>> >> >>
>> >> >> It's definitely related to vlan stripping being enabled. ?Othe=
r cards
>> >> >> using tg3 seem to work fine with stripping though, which is wh=
y I
>> >> >> thought it might be specific to the 5714.
>> >> >
>> >> > I just tested this on a 5714S, using a net-next-2.6 snapshot ob=
tained
>> >> > today. ?It does the right thing in both cases (2nd tg3 patch om=
mited /
>> >> > applied). ?The tag is always visible in the packet stream as se=
en from
>> >> > tcpdump.
>> >> >
>> >> >> > Your RXD_FLAG_VLAN idea sounds unlikely to me, but it's wort=
h a check.
>> >> >> >
>> >> >> > The patch here is using __vlan_hwaccel_put_tag(), which info=
rms the
>> >> >> > stack a VLAN tag is present. ?If this is indeed a reporting =
problem, I'm
>> >> >> > not sure what else the driver should be doing.
>> >> >>
>> >> >> The code to hand off the tag to the stack looks OK to me. ?Mic=
hael was
>> >> >> seeing this on older versions of the kernel as well with this =
NIC,
>> >> >> which predates both this patch and the larger vlan changes so =
it
>> >> >> doesn't seem like a problem with passing the tag to the networ=
k stack.
>> >> >> ?It's hard to know exactly what is going on though without see=
ing what
>> >> >> the hardware is reporting.
>> >> >
>> >> > When RX_MODE_KEEP_VLAN_TAG is set, the RXD_FLAG_VLAN flag will =
not be set
>> >> > when receiving a packet. ?The driver skips the __vlan_hwaccel_p=
ut_tag()
>> >> > call.
>> >> >
>> >> > When RX_MODE_KEEP_VLAN_TAG is unset, the RXD_FLAG_VLAN flag is =
set, and
>> >> > __vlan_hwaccel_put_tag() is called to reinject the packet.
>> >>
>> >> OK, thanks for testing it out. ?I'm not sure that there's anythin=
g
>> >> more we can do without hearing from Michael.
>> >
>> > In the meantime, I think what we have should go upstream. ?Just to=
 be
>> > absolutely clear though, your position is that VLAN tags should al=
ways
>> > be stripped?
>>
>> That's what the other converted drivers do by default (though most o=
f
>> them also provide an ethtool set_flags() method to change this). =A0=
It's
>> generally the most efficient and is now safe to do in all cases. =A0=
It's
>> also the consistent with what was happening before, since stripping
>> was enabled when a vlan device was configured. =A0So, yes, normally =
I
>> think stripping should be enabled.
>>
>> I assumed that disabling stripping in most situations was just an
>> oversight. =A0Was there a reason why you feel it is better not to us=
e
>> it?
>
> Actually, the tg3 driver was trying to disable VLAN tag stripping
> when possible. =A0I believe this was primarily to support the raw pac=
ket
> interface.

Hmm, is this really true?

        if (!tp->vlgrp &&
            !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
                rx_mode |=3D RX_MODE_KEEP_VLAN_TAG;

So if a vlan device is registered or ASF is enabled we will use
stripping.  That seems like it is using stripping in the common case
when vlans are used.

Before 2.6.37 it was only possible to deliver stripped tags if a vlan
group was configured.  This means that if ASF was enabled and forced
stripping but no group was configured we would lose the tag.  In this
situation tg3 manually reinserts the tags so raw packet capture will
see them, as you say.  However, in the current tree this limitation no
longer exists and it is always possible to deliver stripped tags to
the networking core, which should do the right thing in all
situations.

So I believe the only reason to disable tag stripping is for debugging
or some other special purpose situation.
