From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Sat, 18 Dec 2010 19:38:00 -0800
Message-ID: <AANLkTi=hGRW+DwoKQzxPAZao6-y_tvn6nNXS-tj_-Y6T@mail.gmail.com>
References: <20101205114404.7c0cddc2@xenia.leun.net>
	<AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	<20101206203437.54b550e0@xenia.leun.net>
	<AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	<20101206222703.32fbe852@xenia.leun.net>
	<AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	<20101213224510.GB17400@mcarlson.broadcom.com>
	<AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	<20101214191500.GD19951@mcarlson.broadcom.com>
	<20101215012430.120fd47f@xenia.leun.net>
	<20101215013431.GA21173@mcarlson.broadcom.com>
	<20101215081606.18e12fc9@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Leun <lkml20101129@newton.leun.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101215081606.18e12fc9@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 11:16 PM, Michael Leun
<lkml20101129@newton.leun.net> wrote:
> OK - all tests done on that DL320G5:
>
> For completeness, 2.6.37-rc5 unpatched:
>
> eth0, no vlan configured: totally broken - see double tagged vlans
> without tag, single or untagged packets missing at all

Random behavior?  This one is somewhat hard to explain - maybe there
are some other factors.  eth0 has ASF on, so it always strips tags.  I
would expect it to behave like the vlan configured case.

>
> eth0, vlan configured: see packets without vlan tag (see double tagge=
d
> packets with one vlan tag)

Both ASF and vlan group configured cause tag stripping to be enabled.
Missing tag.

>
> eth1 same as originally reported:
> without vlan configured see vlan tags (single and double tagged as
> expected)

No ASF and no vlan group means tag stripping is disabled.  Have tag.

> with vlan configured: see packets without vlan tag (see double tagged
> packets with one vlan tag)

Configuring vlan group causes stripping to be enabled.  Missing tag.

>
>
> 2.6.37-rc5, your tg3 use new vlan-code patch:
>
> eth0, no vlan configured: =A0see packets without vlan tag (see double
> tagged packets with one vlan tag)

ASF enables tag stripping.  Missing tag.

> eth1, no vlan configured: see vlan tags (single and double tagged as
> expected)

No ASF, no vlan group means no stripping.  Have tag.

>
>
> eth0, vlan configured: as without vlan

ASF enables stripping.  Missing tag.

> eth1, vlan configured: as without vlan

With this patch vlan stripping is only enabled when ASF is on, so no
stripping.  Have tag.

>
> 2.6.37-rc5, your tg3 use new vlan-code patch with test patch ontop
>
> eth1 no vlan configured: see packets without vlan tag (see double tag=
ged
> packets with one vlan tag)

With the second patch, vlan stripping is always enabled.  Missing tag.

> eth1 with vlan: the same

Stripping still always enabled.  Missing tag.

The bottom line is whenever vlan stripping is enabled we're missing
the outer tag.  It might be worth adding some debugging in the area
before napi_gro_receive/vlan_gro_receive (depending on version).  My
guess is that (desc->type_flags & RXD_FLAG_VLAN) is false even for
vlan packets on this NIC.

You said that everything works on the 5752?  Matt, is it possible that
the 5714 either has a problem with vlan stripping or a different way
of reporting it?

Also, why does ASF require vlan stripping?
