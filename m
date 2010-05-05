From: Bhaskar Dutta <bhaskie@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Wed, 5 May 2010 23:33:59 +0530
Message-ID: <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:62592 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab0EESED convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 14:04:03 -0400
Received: by pxi5 with SMTP id 5so1620064pxi.19
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 11:03:59 -0700 (PDT)
In-Reply-To: <20100504101301.5f4dd9c2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 4, 2010 at 10:43 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>
> On Tue, 4 May 2010 22:38:49 +0530
> Bhaskar Dutta <bhaskie@gmail.com> wrote:
>
> > On Tue, May 4, 2010 at 9:42 PM, Stephen Hemminger <shemminger@vyatt=
a.com> wrote:
> > > On Tue, 4 May 2010 19:58:32 +0530
> > > Bhaskar Dutta <bhaskie@gmail.com> wrote:
> > >
> > >> On Tue, May 4, 2010 at 5:02 PM, Ben Hutchings <bhutchings@solarf=
lare.com> wrote:
> > >> > On Tue, 2010-05-04 at 09:00 +0530, Bhaskar Dutta wrote:
> > >> >> Hi,
> > >> >>
> > >> >> I am observing intermittent TCP-MD5 checksum failures
> > >> >> (CONFIG_TCP_MD5SIG) =A0on kernel 2.6.31 while talking to a BG=
P router.
> > >> >>
> > >> >> The problem is only seen in multi-core 64 bit machines.
> > >> >> Is there any known bug in the per_cpu_ptr implementation (I a=
m aware
> > >> >> that the percpu allocator has been re-implemented in 2.6.33) =
that
> > >> >> might cause a corruption in 64 bit SMP machines?
> > >> >>
> > >> >> Any pointers would be appreciated.
> > >> >
> > >> > There was another recent report of incorrect MD5 signatures in
> > >> > <http://thread.gmane.org/gmane.linux.network/159556>, but with=
out any
> > >> > response.
> > >> >
> > >> > Ben.
> > >> >
> > >>
> > >> I found another thread posted back in Jan 2007 with a similar bu=
g
> > >> (x86_64 on 2.6.20) but no replies to that as well.
> > >> http://lkml.org/lkml/2007/1/20/56
> > >
> > > 2.6.20 had lots of other MD5 bugs. Your problem might be related =
to
> > > GRO. =A0MD5 may not handle multi-fragment packets.
> > > --
> >
> > I am getting the issue on 2.6.31 and 2.6.28 (gro infrastructure was
> > added in 2.6.29).
> > Also, both segmentation offloading as well as receive offloading
> > (gso/gro) are turned off.
> >
> > Moreover outgoing TCP packets are the ones with the corrupt checksu=
ms.
> > Both tcpdump on my local machine and the BGP router on the other si=
de
> > complain of the bad checksums with the same packet.
> >
> > I am trying to figure out if there is something in the per-cpu
> > implementation that might be causing a corruption (SMP and x86_64) =
but
> > I am not really getting anywhere.
>
> I seriously doubt the per-cpu stuff is the issue.
>
> > I am trying to reproduce the bad checksums with the latest kernel
> > sources since it has a new implementation of the percpu allocator.
>
> First turn off all offload settings on the device (TSO,GSO,SG,CSUM)
> then check that size of the bad packets. Are they fragmented or
> just simple linear packets?
>
> --

Hi,

TSO, GSO and SG are already turned off.
rx/tx checksumming is on, but that shouldn't matter, right?

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

The bad packets are very small in size, most have no data at all (<300 =
bytes).

After adding some logs to kernel 2.6.31-12, it seems that
tcp_v4_md5_hash_skb (function that calculates the md5 hash) is
(might?) getting corrupt.

The tcp4_pseudohdr (bp =3D &hp->md5_blk.ip4) structure's saddr, daddr
and len fields get modified to different values towards the end of the
tcp_v4_md5_hash_skb function whenever there is a checksum error.

The tcp4_pseudohdr (bp) is within the tcp_md5sig_pool (hp), which is
filled up by tcp_get_md5sig_pool (which calls per_cpu_ptr).

Using a local copy of the tcp4_pseudohdr in the same function
tcp_v4_md5_hash_skb (copied all fields from the original
tcp4_pseudohdr within the tcp_md5sig_pool) and calculating the md5
checksum with the local  tcp4_pseudohdr seems to solve the issue
(don't see bad packets for a hours in load tests, and without the
change I can see them instantaneously in the load tests).

I am still unable to figure out how this is happening. Please let me
know if you have any pointers.

Thanks a lot!
Bhaskar
