From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] netlink: don't send NETLINK_URELEASE for unbound sockets
Date: Sat, 16 Apr 2016 23:42:27 +0200
Message-ID: <1460842947.2075.11.camel@sipsolutions.net>
References: <20160416063040.GA6380@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmitrijs.ivanovs-NO1NBkfNQUg@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160416063040.GA6380-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-04-16 at 14:30 +0800, Herbert Xu wrote:
> Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> >=20
> >=20
> > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > index 215fc08c02ab..330ebd600f25 100644
> > --- a/net/netlink/af_netlink.c
> > +++ b/net/netlink/af_netlink.c
> > @@ -688,7 +688,7 @@ static int netlink_release(struct socket *sock)
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0skb_queue_purge(&sk->sk_w=
rite_queue);
> >=20
> > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (nlk->portid) {
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (nlk->portid && nlk->=
bound) {
> Any reason why we're still testing portid at all? Isn't testing
> bound enough?

The reason is that while I felt confident in understanding the problem
and its solution, I didn't realize that bound follows portid, and that,
for example, a kernel socket can't get bound. :-)

But yeah - looking at the code after your comment does show that
testing portid is pointless now.

In fact, now that I look at it, I wonder how this situation came about?

In the current code, you can only trigger the problematic situation
through an error condition, afaict - you have to try to bind a socket
with the same portid as an already existing one, and __netlink_insert()
will then fail, but netlink_insert() won't reset the nlk_sk(sk)->portid=
=20
since your commit=C2=A0da314c9923fe ("netlink: Replace rhash_portid wit=
h
bound"), even though you had previously fixed precisely this issue
already - commit=C2=A0c0bb07df7d98 ("netlink: Reset portid after
netlink_insert failure"). You then close the socket, and since portid
is assigned, that will trigger NETLINK_URELEASE.

So before the rhash_portid -> bound change, this doesn't seem to have
been a problem, and I guess we didn't get the "stuck in limbo" problem
back because we now check bound everywhere relevant, for purposes of
calling netlink_autobind.

IOW - I'm now even more convinced that the patch is correct, and I'm
also convinced that until fairly recently (da314c9923fe) this wasn't
even a problem.

Maybe we can take the opportunity of removing the "portid" check to put
most of the above into a commit message, but I think you should review
it first.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
