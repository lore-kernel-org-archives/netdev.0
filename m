From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Sat, 14 Oct 2017 17:58:01 -0700
Message-ID: <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com> <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:53439 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751032AbdJOA6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 20:58:03 -0400
Received: by mail-qt0-f174.google.com with SMTP id n61so25716426qte.10
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 17:58:02 -0700 (PDT)
In-Reply-To: <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pawel,

To clarify is that Dave Miller's tree or Linus's that you are talking
about? If it is Dave's tree how long ago was it you pulled it since I
think the fix was just pushed by Jeff Kirsher a few days ago.

The issue should be fixed in the following commit:
https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/driver=
s/net/ethernet/intel/i40e/i40e_txrx.c?id=3D2b9478ffc550f17c6cd8c69057234e91=
150f5972

Thanks.

- Alex

On Sat, Oct 14, 2017 at 3:03 PM, Pawe=C5=82 Staszewski <pstaszewski@itcare.=
pl> wrote:
> Forgot to add - this graphs are tested with Kernel 4.14-rc4-next
>
>
> W dniu 2017-10-15 o 00:00, Pawe=C5=82 Staszewski pisze:
>
> Same problem here
>
> Also only difference is change 82599 intel to x710 and have memleak
>
> mem with ixgbe driver over time - same config saame kernel
>
>
>
> changed NIC's to x710 i40e driver (this is the only change)
>
> And mem over time:
>
>
>
> There is no process that is eating memory - looks like there is some prob=
lem
> with i40e driver - but it not a surprise :) this driver is really buggy -
> with many things - most tickets on e1000e sourceforge that i openned have=
 no
> reply for year or more - or if somebody reply after year they are closing
> ticket after 1 day with info about no activity :)
>
>
>
> W dniu 2017-10-05 o 07:19, Anders K. Pedersen | Cohaesio pisze:
>
> On ons, 2017-10-04 at 08:32 -0700, Alexander Duyck wrote:
>
> On Wed, Oct 4, 2017 at 5:56 AM, Anders K. Pedersen | Cohaesio
> <akp@cohaesio.com> wrote:
>
> Hello,
>
> After updating one of our Linux based routers to kernel 4.13 it
> began
> leaking memory quite fast (about 1 GB every half hour). To narrow
> we
> tried various kernel versions and found that 4.11.12 is okay, while
> 4.12 also leaks, so we did a bisection between 4.11 and 4.12.
>
> The first bisection ended at
> "[6964e53f55837b0c49ed60d36656d2e0ee4fc27b] i40e: fix handling of
> HW
> ATR eviction", which fixes some flag handling that was broken by
> 47994c119a36 "i40e: remove hw_disabled_flags in favor of using
> separate
> flag bits", so I did a second bisection, where I added 6964e53f5583
> "i40e: fix handling of HW ATR eviction" to the steps that had
> 47994c119a36 "i40e: remove hw_disabled_flags in favor of using
> separate
> flag bits" in them.
>
> The second bisection ended at
> "[0e626ff7ccbfc43c6cc4aeea611c40b899682382] i40e: Fix support for
> flow
> director programming status", where I don't see any obvious
> problems,
> so I'm hoping for some assistance.
>
> The router is a PowerEdge R730 server (Haswell based) with three
> Intel
> NICs (all using the i40e driver):
>
> X710 quad port 10 GbE SFP+: eth0 eth1 eth2 eth3
> X710 quad port 10 GbE SFP+: eth4 eth5 eth6 eth7
> XL710 dual port 40 GbE QSFP+: eth8 eth9
>
> The NICs are aggregated with LACP with the team driver:
>
> team0: eth9 (40 GbE selected primary), and eth3, eth7 (10 GbE non-
> selected backups)
> team1: eth0, eth1, eth4, eth5 (all 10 GbE selected)
>
> team0 is used for internal networks and has one untagged and four
> tagged VLAN interfaces, while team1 has an external uplink
> connection
> without any VLANs.
>
> The router runs an eBGP session on team1 to one of our uplinks, and
> iBGP via team0 to our other border routers. It also runs OSPF on
> the
> internal VLANs on team0. One thing I've noticed is that when OSPF
> is
> not announcing a default gateway to the internal networks, so there
> is
> almost no traffic coming in on team0 and out on team1, but still
> plenty
> of traffic coming in on team1 and out via team0, there's no memory
> leak
> (or at least it is so small that we haven't detected it). But as
> soon
> as we configure OSPF to announce a default gateway to the internal
> VLANs, so we get traffic from team0 to team1 the leaking begins.
> Stopping the OSPF default gateway announcement again also stops the
> leaking, but does not release already leaked memory.
>
> So this leads to me suspect that the leaking is related to RX on
> team0
> (where XL710 eth9 is normally the only active interface) or TX on
> team1
> (X710 eth0, eth1, eth4, eth5). The first bad commit is related to
> RX
> cleaning, which suggests RX on team0. Since we're only seeing the
> leak
> for our outbound traffic, I suspect either a difference between the
> X710 vs. XL710 NICs, or that the inbound traffic is for relatively
> few
> destination addresses (only our own systems) while the outbound
> traffic
> is for many different addresses on the internet. But I'm just
> guessing
> here.
>
> I've tried kmemleak, but it only found a few kB of suspected memory
> leaks (several of which disappeared again after a while).
>
> Below I've included more details - git bisect logs, ethtool -i,
> dmesg,
> Kernel .config, and various memory related /proc files. Any help or
> suggestions would be much appreciated, and please let me know if
> more
> information is needed or there's something I should try.
>
> Regards,
> Anders K. Pedersen
>
> Hi Anders,
>
> I think I see the problem and should have a patch submitted shortly
> to
> address it. From what I can tell it looks like the issue is that we
> weren't properly recycling the pages associated with descriptors that
> contained an Rx programming status. For now the workaround would be
> to
> try disabling ATR via the "ethtool --set-priv-flags" command. I
> should
> have a patch out in the next hour or so that you can try testing to
> verify if it addresses the issue.
>
> Thanks.
>
> - Alex
>
> Thanks Alex,
>
> I will test the patch in our next service window on Tuesday morning.
>
> Regards,
> Anders
>
>
>
