From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Wed, 18 Feb 2004 17:24:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218172441.2eb117a7.davem@redhat.com>
References: <403066A2.30705@kolumbus.fi>
	<Xine.LNX.4.44.0402160843570.15855-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: mika.penttila@kolumbus.fi, laforge@netfilter.org, netdev@oss.sgi.com,
        sds@epoch.ncsc.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402160843570.15855-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 16 Feb 2004 08:45:47 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> On Mon, 16 Feb 2004, Mika Penttil=E4 wrote:
>=20
> > James Morris wrote:
> >=20
> > >No, it's not needed by all callers, and is just a does-one-thing hel=
per=20
> > >function.
> > >
> > >
> > It is needed for cloned skbs, so check for this should go in=20
> > skb_checksum_help().
>=20
> No, there is no need to bloat a simple helper function out with this=20
> (and then need to handle OOM internally etc.), and it is not appropriat=
e=20
> for all callers.

I think Mika is in a way correct James.

Nobody may mangle packet data contents without unsharing SKB on output pa=
th.

But things are not so simple.  Just mucking with the checksum works becau=
se
things which usually clone such packets (TCP retransmit queue) regenerate=
 all
headers and thus checksum fields upon each further use of such clones.

I am tempted just to punish nf_hook_slow()'s invocation of skb_checksum_h=
elp()
but that is not the right answer.

Let us look at some of the other users of skb_checksum_help().  The one i=
n dev_queue_xmit()
and the IPSEC encapsulator xfrm drivers are doing so just to plug up a sh=
ort lived race where
a route lookup points to a non-IPSEC checksumming hardware path, but we e=
nd up in the IPSEC
path or to a device which does not support hw checksumming.

One could argue that what we could do in this case is just drop the packe=
t and let the route
relookup on retransmit get things right.  This reminds me that we should =
audit and if necessary
fix handling of the ethtool operations that turn on/off checksumming supp=
ort, they would need
to flush all of the cached checksumming capability state if they not do s=
o already.

I'm as confused as when we began this thread :-)

I believe it is possible to replace all skb_checksum_help() calls with a =
packet drop, except
for the nf_hook_slow() case.  It may be possible to instead push the nf_h=
ook_slow() instance
simply deeper into the netfilter code so that the iterate/parse/match pha=
se need not invoke
such a heavy operation.  Only if netfilter will actually do something wit=
h the packet would
we skb_checksum_help() or whatever.  And I even believe that most cases w=
here the packet is
mangled do not need to keep from still letting the card checksum the pack=
et.
