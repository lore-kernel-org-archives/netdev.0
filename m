From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Wed, 8 Aug 2012 08:23:15 +0300
Message-ID: <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	<1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com>
	<20120805185031.GA18640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:60729 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab2HHFXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 01:23:16 -0400
Received: by yhmm54 with SMTP id m54so383969yhm.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 22:23:15 -0700 (PDT)
In-Reply-To: <20120805185031.GA18640@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 5, 2012 at 9:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:

[...]
> So it seems that a sane solution would involve an extra level of
> indirection, with guest addresses being translated to host IB addresses.
> As long as you do this, maybe using an ethernet frame format makes sense.
[...]

Yep, that's among the points we're trying to make, the way you've put
it makes it clearer.

> So far the things that make sense. Here are some that don't, to me:

> - Is a pdf presentation all you have in terms of documentation?
>   We are talking communication protocols here - I would expect a
>   proper spec, and some effort to standardize, otherwise where's the
>   guarantee it won't change in an incompatible way?

To be precise, the solution uses 100% IPoIB wire-protocol, so we don't
see a need
for any spec change / standardization effort. This might go to the 1st
point you've
brought... improve the documentation, will do that. The pdf you looked
at was presented
in a conference.

>   Other things that I would expect to be addressed in such a spec is
>   interaction with other IPoIB features, such as connected
>   mode, checksum offloading etc, and IB features such as multipath etc.

For the eipoib interface, it doesn't really matters if the underlyind
ipoib clones used by it (we call them VIFs) use connected or datagram
mode, what does matter is the MTU and offload features supported by
these VIFs, for which the eipoib interface will have the min among all
these VIFs. Since for a given eipoib nic, all its VIFs must originated
from the same IPoIB PIF (e.g ib0) its easy admin job to make sure they
all have the same mtu / features which are needed for that eipoib nic,
e.g by using the same mode (connected/datagram for all of them), hope
this is clear.


> - The way you encode LID/QPN in the MAC seems questionable. IIRC there's
>   more to IB addressing than just the LID.  Since everyone on the subnet
>   need access to this translation, I think it makes sense to store it in
>   the SM. I think this would also obviate some IPv4 specific hacks in kernel.

The idead beyond the encoding was uniqueness, LID/QPN is unique per IB
HCA end-node. I wasn't sure to understand the comment re the IPv4 hacks.

> - IGMP/MAC snooping in a driver is just too hairy.

mmm, any rough idea/direction how to do that otherwise?

>   As you point out, bridge currently needs the uplink in promisc mode.
>   I don't think a driver should work around that limitation.
>   For some setups, it might be interesting to remove the
>   promisc mode requirement, failing that,
>   I think you could use macvtap passthrough.

That's in the plans, the current code doesn't assume that the eipoib
has bridge on top, for VM networking it works with bridge + tap,
bridge + macvtap, but it would easily work with passthrough when we
allow to create multiple eipoib interfaces on the same ipoib PIF (e.g
today for the ib0 PIF we create eipoib eth0, and then two VIFs ib0.1
and ib0.2 that are enslaved by eth0, but next we will create eth1 and
eth2 which will use ib0.1 and ib0.2
respectively.

> - Currently migration works without host kernel help, would be
>   preferable to keep it that way.

OK
