From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next v3] af_unix: Fix use-after-free crashes
Date: Fri, 09 Sep 2011 03:41:29 -0700
Message-ID: <1315564889.2363.39.camel@schen9-mobl>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	 <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	 <1315406256.6287.7.camel@schen9-mobl> <4E680BF1.8000901@intel.com>
	 <1315429583.2361.3.camel@schen9-mobl>
	 <1315461572.2532.7.camel@edumazet-laptop> <4E685F19.6030407@intel.com>
	 <1315465919.2532.19.camel@edumazet-laptop> <4E686D71.30603@intel.com>
	 <1315467184.2532.22.camel@edumazet-laptop>
	 <CA+icZUWH8953m4qs74JLhNwrzJM0eMfE8aizJ1XtuVFFTtLKqg@mail.gmail.com>
	 <1315488103.2456.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315471065.2301.1.camel@schen9-mobl>
	 <1315551100.5410.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sedat.dilek@gmail.com, "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53051 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753566Ab1IIRlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Sep 2011 13:41:31 -0400
In-Reply-To: <1315551100.5410.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-09 at 08:51 +0200, Eric Dumazet wrote:
> Le jeudi 08 septembre 2011 =C3=A0 01:37 -0700, Tim Chen a =C3=A9crit =
:
> > On Thu, 2011-09-08 at 15:21 +0200, Eric Dumazet wrote:
> > > Le jeudi 08 septembre 2011 =C3=A0 11:59 +0200, Sedat Dilek a =C3=A9=
crit :
> > >=20
> > > > I have tested this fixup patch on i386.
> > > > Can we have a separate patch with corrected descriptive text?
> > > >=20
> > > > Thanks to all involved people.
> > >=20
> > > Here it is :
> > >=20
> > > [PATCH net-next v3] af_unix: Fix use-after-free crashes
> > >=20
> > > Commit 0856a30409 (Scm: Remove unnecessary pid & credential refer=
ences
> > > in Unix socket's send and receive path) introduced an use-after-f=
ree
> > > bug.
> > >=20
> > > We are allowed to steal the references to pid/cred only in the la=
st skb
> > > sent from unix_stream_sendmsg(), because first skbs might be cons=
umed by
> > > the receiver before we finish our sendmsg() call.
> > >=20
> > > Remove scm_release() helper, since its cleaner to clear pid/cred =
fields
> > > in unix_scm_to_skb() when we steal them.
> > >=20
> > > Based on prior patches from Yan Zheng and Tim Chen
> > >=20
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > Reported-by: Jiri Slaby <jirislaby@gmail.com>
> > > Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
> > > Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> > > ---
> >=20
> > Thanks.
> >=20
> > Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
> >=20
>=20
> Now we have to fix a bug in unix_stream_recvmsg() as well.
>=20

Thanks for your careful review to catch the bugs.  Wish I had thought
about the stream msg case more in my original patch.

> consume_skb() call actually releases pid/cred references, and we can =
use
> them after their eventual freeing.
>=20
> Keep also in mind that receiver can provides a too short user buffer,
> and skb can be put back to head of sk_receive_queue
>=20
> Tim, your 0856a304091b33 commit introduced a lot of bugs, I was right
> asking a revert.
>=20
> If we revert your patch, my litle patch (af_unix: dont send
> SCM_CREDENTIALS by default) is enough to solve performance problems.
>=20

But the regression where we do send SCM_CREDENTIALS is not addressed,
right?  I don't mind reverting my patch if there's a better solution.

Tim
