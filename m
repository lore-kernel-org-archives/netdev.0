From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH stable<3.19] net: handle null iovec pointer in
 skb_copy_and_csum_datagram_iovec()
Date: Mon, 26 Oct 2015 11:25:42 +0000
Message-ID: <20151026112542.GB2953@ares>
References: <20151023084609.585AEA0C18@unicorn.suse.cz>
 <20151023092219.GA10782@bistromath.redhat.com>
 <20151023093946.GA9789@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Sasha Levin <sasha.levin@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>, Zefan Li <lizefan@huawei.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44033 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbbJZLZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 07:25:50 -0400
Content-Disposition: inline
In-Reply-To: <20151023093946.GA9789@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 11:39:46AM +0200, Michal Kubecek wrote:
> On Fri, Oct 23, 2015 at 11:22:19AM +0200, Sabrina Dubroca wrote:
> > Hello Michal,
> >=20
> > 2015-10-23, 10:46:09 +0200, Michal Kubecek wrote:
> > > Mainline commit 89c22d8c3b27 ("net: Fix skb csum races when peeki=
ng")
> > > backport into pre-3.19 stable kernels introduces a regression cau=
sing
> > > null pointer dererefence in skb_copy_and_csum_datagram_iovec().
> > >=20
> > > This commit only sets CHECKSUM_UNNECESSARY for non-shared skb, al=
lowing
> > > udp_recvmsg() to take the "else" branch of if (skb_csum_unnecessa=
ry(skb))
> > > when called with null iovec (and len=3D0, e.g. when peeking for d=
atagram
> > > size first). The problem is that unlike skb_copy_and_csum_datagra=
m_msg()
> > > called in this path since 3.19, skb_copy_and_csum_datagram_iovec(=
) does
> > > not handle null iov parameter and always dereferences iov->iov_le=
n. This
> > > is especially harmful when udp_recvmsg() is called in kernel cont=
ext,
> > > e.g. from kernel nfsd.
> > >=20
> > > Band-aid skb_copy_and_csum_datagram_iovec() by testing iov for nu=
ll and
> > > only checking the checksum in this case.
> > >=20
> > > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> > > ---
> >=20
> > I ran into this problem too and that was my initial solution to thi=
s
> > problem as well, but actually, we need a more complete fix, like th=
e
> > one I submitted a few days ago:
> >=20
> > http://patchwork.ozlabs.org/patch/530642/
> >=20
> > With your solution, userspace can still receive bogus EFAULT, or th=
e
> > kernel ends up writing data to an unwanted memory location.
>=20
> I must admit I wondered why skb_copy_and_csum_datagram_iovec() doesn'=
t
> get (and check) read length and why it cannot overfill the buffer. Bu=
t
> then I saw the comment "Caller _must_ check that skb will fit to this
> iovec", stopped thinking and assumed it's OK. I guess I should be les=
s
> trusting... :-(
>=20
> Thank you for the warning.
>=20
>                                                         Michal Kubece=
k

I can confirm that we had this issue reported in our kernels too
(https://bugs.launchpad.net/bugs/1508510).  I'll queue Sabrina's patch =
for
the next 3.16 stable kernel release.  Thanks a lot!


Cheers,
--
Lu=EDs
