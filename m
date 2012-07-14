From: Hillf Danton <dhillf@gmail.com>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 16:04:50 +0800
Message-ID: <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
References: <20120713171835.GA26052@vault.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willy Tarreau <w@1wt.eu>, Linux-Netdev <netdev@vger.kernel.org>
To: Johannes Truschnigg <johannes@truschnigg.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:32945 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab2GNIEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 04:04:51 -0400
In-Reply-To: <20120713171835.GA26052@vault.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 1:18 AM, Johannes Truschnigg
<johannes@truschnigg.info> wrote:
> Hello good people of linux-kernel.
>
> I've been bothered by silent data corruption from my personal fileserver - no
> matter the Layer 7 protocol used, huge transfers sporadically ended up damaged
> in-flight. I used Samba/CIFS, NFS(v4, via TCP), Apache httpd 2.2, thttpd,
> python and netcat to verify this.
>
> I think I managed to track down the culprit: as soon as I disable sendfile()
> for all programs that support such a configuration (netcat, afaik, won't ever
> use sendfile() to transmit data over a socket, so the problem was never
> reproducible there in the first place), everything reverts to perfect and
> proper working condition.
>
> I've been experiencing this problem with vanilla kernel releases from the 3.3
> up until 3.4.0 series. I do not know if it also occurs with earlier releases,
> but I can verify if that is useful. I set up the environment for a minimal
> kind of testcase (a large ISO image file available from the server's local
> filesystem, as well as from a mounted NFS export - once via lo, and once via
> br0/eth0), and proceeded to do the following:
>
> i=0; for i in {1..100}
> do
>   echo "pass $i:"; sync; echo 3 > /proc/sys/vm/drop_caches
>   cmp -b /mnt/nfs-test/lo/tmp/X15-65741.iso /srv/files/pub/tmp/X15-65741.iso
> done
>
> I then rotated the source of the data, and tested the network-mount against
> the loopback-mount, as well as the network-mount against the local filesystem.
>
> Computing the file's md5sum in a loop whilst dropping caches after each
> iteration by reading it directly from its location in the filesystem produces
> the very same hash every time - I therefore think it's safe to assume the
> corruption is introduced when traversing the networking stack. The hash also
> does not change if I repeadetly compute the md5sum of the file as transferred
> by, e. g., Apache httpd or smbd with sendfile explicitly disabled.
>
> Please take a look at the attachment to see the actual output of the above
> script. It does not matter if I do an actual transfer over the network from my
> server to one of its clients (I verified the problem with two different client
> machines, one even running Windows), or if the server is both source and
> destination of the transfer - as long as sendfile is involed, some of the data
> will always become garbled sooner or later. That also leads me to believe that
> my internetworking devices (my switch in particular) is working just fine;
> testing bulky transfers from one host to another confirms this insofar as thus
> all data makes it through unscathed.
>
> As soon as I switch off sendfile-support (in, e. g. Samba or Apache httpd), I
> can run a series of thousands and more transfers, and not experience any
> corruption at all. Whenever the data gets fubared, there is no hint at
> anything fishy going on in the debug ringbuffer - curruption takes place in
> total silence.
>
> The system in question has an Intel Pro/1000 PCI-e NIC for doing the networked
> file transfers, and is backed by a md RAID5-Array with LVM2 on top. The 4GB of
> system memory (ECC-enabled UDIMM) are operating in S4ECD4ED mode as reported
> by EDAC, and there are no reported errors. The CPU I have installed is an AMD
> Athlon II X2 245e on an ASUS M4A88TD-M/USB3 Motherboard. It's running Gentoo
> for amd64. The box can run prime96 in torture mode and linpack just fine for
> days - I'm therefore assuming the hardware to be working correctly.
>
> I have attached my kernel's config (from 3.4.0, as that's the image that I
> have running right now) attached for sake of completeness, as well as some
> information for you to see how I tested, and what these tests actually
> produced. If you need any other information to help track this down, please
> let me know.
>
> If you decide to answer please keep me CC'd, as I'm not subscribed to this
> list.
>
> Just in case the numerous attachments get scrubbed/removed, I've also uploaded
> them to http://johannes.truschnigg.info/tmp/sendfile_data_corruption/
>
> Thanks for reading, and have a nice weekend everyone :)
>

Is the above corruption related to the one below?


On Tue, Jul 3, 2012 at 8:02 AM, Willy Tarreau <w@1wt.eu> wrote:
>
> In fact it has been true zero copy in 2.6.25 until we faced a large
> amount of data corruption and the zero copy was disabled in 2.6.25.X.
> Since then it remained that way until you brought your patches to
> re-instantiate it.
