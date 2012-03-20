From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Kernel Panic with bonding + IPoIB on 3.2.9
Date: Mon, 19 Mar 2012 21:30:26 -0700
Message-ID: <5560.1332217826@death.nxdomain>
References: <CAOzFzEiufg40gKBH6D7zeB47SebfPvgzqOLxhF5eQqpYd-r4zQ@mail.gmail.com> <CAOzFzEi=UOnwiV+qVks7+RnYU3PFbaQ+3OaEE3YFG2HHuD5ydQ@mail.gmail.com> <CAL1RGDVAd-LiS0sy6RAFNzkUuXrcuGv829nADcnxUnC2tfx3bw@mail.gmail.com> <CAOzFzEgSWHqabw9yq6JxhD+CxQY61O+gqGwPMdbWPC=M+_oZAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland@purestorage.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joseph Glanville <joseph.glanville@orionvm.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <CAOzFzEgSWHqabw9yq6JxhD+CxQY61O+gqGwPMdbWPC=M+_oZAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joseph Glanville <joseph.glanville@orionvm.com.au> wrote:

>On 20 March 2012 06:05, Roland Dreier <roland@purestorage.com> wrote:
>> On Sun, Mar 18, 2012 at 1:21 PM, Joseph Glanville
>> <joseph.glanville@orionvm.com.au> wrote:
>>> [ =C2=A0422.047024] kernel BUG at net/core/dev.c:1896!
>>
>> So this line is
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(offset >=3D skb_headlen(skb));
>>
>> right? =C2=A0No paritcular idea how we hit this, though...
>
>Yep... I have looked through most of /drivers/net/bonding and I can't
>really see why it should be blowing up there.. it really should cause
>the BUG_ON under normal IPoIB if the MTU was the cause - yet I have
>not experienced this.
>The bonding code doesn't seem to do anything special with the MTU
>other than propagating changes to the slaves.

	For IPoIB, though, there is some extra initialization stuff in
bond_setup_by_slave(), and the hard_header_len will end up being set to
something different from the usual Ethernet value.

	In looking at ipoib_setup, I see that hard_header_len appears to
be set to 4 (IPOIB_ENCAP_LEN).  My recollection was that the IPoIB
hard_header_len was quite a bit larger than that; it looks like it
changed very recently from IPOIB_ENCAP_LEN + INFINIBAND_ALEN to what it
is now:

commit afd87adacb5de00768b2e54f0bd851278f2e6179
Author: Roland Dreier <roland@purestorage.com>
Date:   Tue Feb 7 14:51:21 2012 +0000

    IPoIB: Stop lying about hard_header_len and use skb->cb to stash LL=
 addresses
   =20
    [ Upstream commit 936d7de3d736e0737542641269436f4b5968e9ef ]
   =20
    Commit a0417fa3a18a ("net: Make qdisc_skb_cb upper size bound
    explicit.") made it possible for a netdev driver to use skb->cb
    between its header_ops.create method and its .ndo_start_xmit
    method.  Use this in ipoib_hard_header() to stash away the LL addre=
ss
    (GID + QPN), instead of the "ipoib_pseudoheader" hack.  This allows
    IPoIB to stop lying about its hard_header_len, which will let us fi=
x
    the L2 check for GRO.


	I don't know if this change could be causing the problem (it
appears to be new in 3.2.9), but the hard_header_len is one of the few
areas in the TX path of bonding that IPoIB ends up being different from
regular Ethernet.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
