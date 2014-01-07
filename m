From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net v2 1/9] bridge: Fix the way to find old local fdb
 entries in br_fdb_changeaddr
Date: Tue, 07 Jan 2014 21:42:58 +0900
Message-ID: <1389098578.3768.12.camel@ubuntu-vm-makita>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1387281821-21342-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <52C70F63.4020604@redhat.com> <52C7218C.2000205@redhat.com>
	 <1388935578.1906.26.camel@localhost.localdomain>
	 <52CA9398.3090603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:39756 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbaAGMnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 07:43:08 -0500
In-Reply-To: <52CA9398.3090603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 06:29 -0500, Vlad Yasevich wrote:
> On 01/05/2014 10:26 AM, Toshiaki Makita wrote:
> > On Fri, 2014-01-03 at 15:46 -0500, Vlad Yasevich wrote:
> >> On 01/03/2014 02:28 PM, Vlad Yasevich wrote:
> >>> On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
> >>>> br_fdb_changeaddr() assumes that there is at most one local entry per port
> >>>> per vlan. It used to be true, but since commit 36fd2b63e3b4 ("bridge: allow
> >>>> creating/deleting fdb entries via netlink"), it has not been so.
> >>>> Therefore, the function might fail to search a correct previous address
> >>>> to be deleted and delete an arbitrary local entry if user has added local
> >>>> entries manually.
> >>>>
> >>>> Example of problematic case:
> >>>>   ip link set eth0 address ee:ff:12:34:56:78
> >>>>   brctl addif br0 eth0
> >>>>   bridge fdb add 12:34:56:78:90:ab dev eth0 master
> >>>>   ip link set eth0 address aa:bb:cc:dd:ee:ff
> >>>> Then, the address 12:34:56:78:90:ab might be deleted instead of
> >>>> ee:ff:12:34:56:78, the original mac address of eth0.
> >>>>
> >>>> Address this issue by introducing a new flag, added_by_user, to struct
> >>>> net_bridge_fdb_entry.
> >>>>
> >>>> Note that br_fdb_delete_by_port() has to set added_by_user to 0 in case
> >>>> like:
> >>>>   ip link set eth0 address 12:34:56:78:90:ab
> >>>>   ip link set eth1 address aa:bb:cc:dd:ee:ff
> >>>>   brctl addif br0 eth0
> >>>>   bridge fdb add aa:bb:cc:dd:ee:ff dev eth0 master
> >>>>   brctl addif br0 eth1
> >>>>   brctl delif br0 eth0
> >>>> In this case, kernel should delete the user-added entry aa:bb:cc:dd:ee:ff,
> >>>> but it also should have been added by "brctl addif br0 eth1" originally,
> >>>> so we don't delete it and treat it a new kernel-created entry.
> >>>>
> >>>
> >>> I was looking over my patch series that adds something similar to this
> >>> and noticed that you are not handing the NTF_USE case.  That case was
> >>> always troublesome for me as it allows for 2 different way to create
> >>> the same FDB: one through br_fdb_update() and one through fdb_add_entry().
> >>>
> >>> It is possible, though I haven't found any users yet, that NTF_USE
> >>> may be used and in that case, bridge will create a dynamic fdb and
> >>> disregard all NUD flags.  In case case, add_by_user will not be set
> >>> either.
> >>>
> >>> I think that the above is broken and plan to submit a fix shortly.
> >>
> >> Just looked again at my NTF_USE patch and while it seems ok, the whole
> >> NTF_USE usage is racy to begin with and I am really starting to question
> >> it's validity.
> >>
> >> Presently, br_fdb_update() will not update local fdb entries.   Instead
> >> it will log a misleading warning...  It will only let you update
> >> non-local entries.  This is fine for user-created entries, but any
> >> operation on dynamically created entries will only persist until
> >> the next packet.  It also races against the packet, so there is
> >> absolutely no guarantee that the values of fdb->dst and fdb->updated
> >> will be consistent..
> >>
> >> It seems to me that the update capability of NTF_USE would actually be
> >> of more value on local or user-created fdb entries.
> >>
> >> The fdb creation capability of NTF_USE should be disabled.
> >>
> >> Thoughts?
> > 
> > I ignored NTF_USE in this patch because I regard it as emulating kernel
> > creating entries after investigating git log.
> > 
> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=0c5c2d3089068d4aa378f7a40d2b5ad9d4f52ce8
> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=292d1398983f3514a0eab13b7606df7f4730b498
> > 
> > So I think NTF_USE shouldn't set added_by_user.
> > And to emulate kernel creating entries, simply calling br_fdb_update()
> > is the right way, isn't it?
> 
> You can create dynamic entries (emulating the kernel) without NTF_USE.
> Just set the NUD_REACHABLE.  Notice that arp cache only uses NTF_USE
> to trigger and arp notification.  The creation is still triggered via
> other netlink flags.
> 
> The more I look at this the more I think NTF_USE should not create
> an entry all by itself.

I haven't fully understood you yet.
Currently NTF_USE behaves as if the port receives a frame and it seems
to work, though the ability to create entries is different from neigh
subsystem.
Why do you want to change the behavior?
Are you worried about inconsistency of NLM-flags/NUD-state with NTF_USE
between neigh and bridge?

Thanks,
Toshiaki Makita
