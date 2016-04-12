From: Ian Campbell <ian.campbell@docker.com>
Subject: Re: [RFC v5 0/5] Add virtio transport for AF_VSOCK
Date: Tue, 12 Apr 2016 17:37:54 +0100
Message-ID: <CAOc2ZU1Kaes-UVfFrKrE9QyLMWnAQ77+hkSAGJgD0gOuM8o_UQ@mail.gmail.com>
References: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
	<1460129705.1749.25.camel@docker.com>
	<20160411104548.GA12826@stefanha-x1.localdomain>
	<20160411154517-mutt-send-email-mst@redhat.com>
	<20160412135957.GB29405@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8060150057196769230=="
Cc: marius vlad <marius.vlad0@gmail.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, ijc@hellion.org.uk,
	virtualization@lists.linux-foundation.org,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Matt Benjamin <mbenjamin@redhat.com>, netdev@vger.kernel.org,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Christoffer Dall <christoffer.dall@linaro.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160412135957.GB29405@stefanha-x1.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============8060150057196769230==
Content-Type: multipart/alternative; boundary=001a1144400c6c719c05304c48c5

--001a1144400c6c719c05304c48c5
Content-Type: text/plain; charset=UTF-8

For some reason your mails in this thread only appear in the gmail web UI
and not on the IMAP version of my mailbox (my own and Michael's mails are
fine).

So I'm replying via the web interface, sorry for the inevitable formatting
mess :-/

I've CCd another mailbox in the hopes of getting your mails in that IMAP
folder instead/aswell so I can avoid this next time.

On 12 April 2016 at 14:59, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>
> > > > One wrinkle I came across, which I'm not sure if it is by design or a
> > > > problem is that I can see this sequence coming from the guest (with
> > > > other activity in between):
> > > >
> > > >     1) OP_SHUTDOWN w/ flags == SHUTDOWN_RX
> > > >     2) OP_SHUTDOWN w/ flags == SHUTDOWN_TX
> > > >     3) OP_SHUTDOWN w/ flags == SHUTDOWN_TX|SHUTDOWN_RX
>
> How did you trigger this sequence?  I'd like to reproduce it.
>

Nothing magic. I've written some logging into my backend and captured the
result for a simple backend initiated connection.

In the log "TX" and "RX" indicate the thread doing the processing (with
"TX" being the one which processes the guest's TX ring, i.e. data coming
from the guest to the host). "<=" indicates a buffer going from guest to
host and "=>" is from host to guest. NB that guest to host replies are
queued synchronously by the TX thread onto the RX ring which is why the
somewhat odd looking "TX: =>" combination can occur. A host initiated
connection also happens from the TX thread in the same way.

The trace is of a simple request response (which both fit in one buffer in
each direction), the lines without an "?X:" prefix are my
annotations/guesses as to what is going on:

TX: =>SRC:00000002.00010002 DST:00000003.00000948
TX:   LEN:00000000 TYPE:0001 OP:1=REQUEST
TX:  FLAGS:00000000 BUF_ALLOC:00008000 FWD_CNT:00000000

TX: <=SRC:00000003.00000948 DST:00000002.00010002
TX:   LEN:00000000 TYPE:0001 OP:2=RESPONSE
TX:  FLAGS:00000000 BUF_ALLOC:00040000 FWD_CNT:00000000

REQUEST + RESPONSE == Channel open successfully

RX: =>SRC:00000002.00010002 DST:00000003.00000948
RX:   LEN:0000005e TYPE:0001 OP:5=RW
RX:  FLAGS:00000000 BUF_ALLOC:00008000 FWD_CNT:00000000

Host sends a request to the guest

TX: <=SRC:00000003.00000948 DST:00000002.00010002
TX:   LEN:00000000 TYPE:0001 OP:6=CREDIT_UPDATE
TX:  FLAGS:00000000 BUF_ALLOC:00040000 FWD_CNT:0000005e

Guest replies with a credit update

TX: <=SRC:00000003.00000948 DST:00000002.00010002
TX:   LEN:00000091 TYPE:0001 OP:5=RW
TX:  FLAGS:00000000 BUF_ALLOC:00040000 FWD_CNT:0000005e

Guest replies with the answer to the request

RX: =>SRC:00000002.00010002 DST:00000003.00000948
RX:   LEN:00000000 TYPE:0001 OP:4=SHUTDOWN
RX:  FLAGS:00000002 BUF_ALLOC:00008000 FWD_CNT:00000091

Host has sent its only request, so host app must have done
shutdown(SHUT_WR) I suppose and host therefore sends SHUTDOWN_TX.

TX: <=SRC:00000003.00000948 DST:00000002.00010002
TX:   LEN:00000000 TYPE:0001 OP:4=SHUTDOWN
TX:  FLAGS:00000001 BUF_ALLOC:00040000 FWD_CNT:0000005e

Guest SHUTDOWN_RX. I'm not sure if this is a direct kernel response to the
SHUTDOWN_TX or if the application inside the guest saw an EOF when reading
the socket and did the corresponding shutdown(SHUT_RD).

TX: <=SRC:00000003.00000948 DST:00000002.00010002
TX:   LEN:00000000 TYPE:0001 OP:4=SHUTDOWN
TX:  FLAGS:00000002 BUF_ALLOC:00040000 FWD_CNT:0000005e

Guest SHUTDOWN_TX, I presume that having sent the only response it is going
to it then does shutdown(SHUT_WR).

TX: <=SRC:00000003.00000948 DST:00000002.00010002
TX:   LEN:00000000 TYPE:0001 OP:4=SHUTDOWN
TX:  FLAGS:00000003 BUF_ALLOC:00040000 FWD_CNT:0000005e

Guest shuts down both directions.

Perhaps the guest end is turning shutdown(foo) directly into a vsock
message without or-ing in the current state?

> > > I orignally had my backend close things down at #2, however this meant
> > > > that when #3 arrived it was for a non-existent socket (or, worse, an
> > > > active one if the ports got reused). I checked v5 of the spec
> > > > proposal[0] which says:
> > > >     If these bits are set and there are no more virtqueue buffers
> > > >     pending the socket is disconnected.
> > > >
> > > > but I'm not entirely sure if this behaviour contradicts this or not
> > > > (the bits have both been set at #2, but not at the same time).
> > > >
> > > > BTW, how does one tell if there are no more virtqueue buffers pending
> > > > or not while processing the op?
> > >
> > > #2 is odd.  The shutdown bits are sticky so they cannot be cleared once
> > > set.  I would have expected just #1 and #3.  The behavior you observe
> > > look like a bug.
> > >
> > > The spec text does not convey the meaning of OP_SHUTDOWN well.
> > > OP_SHUTDOWN SHUTDOWN_TX|SHUTDOWN_RX means no further rx/tx is possible
> > > for this connection.  "there are no more virtqueue buffers pending the
> > > socket" really means that this isn't an immediate close from the
> > > perspective of the application.  If the application still has unread rx
> > > buffers then the socket stays readable until the rx data has been fully
> > > read.
> >
> > Yes but you also wrote:
> >       If these bits are set and there are no more virtqueue buffers
> >       pending the socket is disconnected.
> >
> > how does remote know that there are no buffers pending and so it's safe
> > to reuse the same source/destination address now?  Maybe destination
> > should send RST at that point?
>
> You are right, the source/destination address could be reused while the
> remote still has the connection in their table.  Connection
> establishment would fail with a RST reply.
>
> I can think of two solutions:
>
> 1. Implementations must remove connections from their table as soon as
>    SHUTDOWN_TX|SHUTDOWN_RX is received.  This way the source/destination
>    address tuple can be reused immediately, i.e. new connections with
>    the same source/destination would be possible while an application is
>    still draining the receive buffers of an old connection.
>
> 2. Extend the connection lifecycle so that an A->B
>    SHUTDOWN_TX|SHUTDOWN_RX must be followed by a by a B->A RST to close
>    a connection.  This way the source/destination address is only in use
>    once at a time.
>
> Option #2 seems safer because there is no overlap in source/destination
> address usage.
>

I agree (I hadn't seen this when I replied to Michael similar suggestion).

Ian. (sorry again for the formatting)

--001a1144400c6c719c05304c48c5
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">For some reason your mails in this thread only appear in t=
he gmail web UI and not on the IMAP version of my mailbox (my own and Micha=
el&#39;s mails are fine).<div><br></div><div>So I&#39;m replying via the we=
b interface, sorry for the inevitable formatting mess :-/</div><div><br></d=
iv><div>I&#39;ve CCd another mailbox in the hopes of getting your mails in =
that IMAP folder instead/aswell so I can avoid this next time.<br><div clas=
s=3D"gmail_extra"><br><div class=3D"gmail_quote">On 12 April 2016 at 14:59,=
 Stefan Hajnoczi <span dir=3D"ltr">&lt;<a href=3D"mailto:stefanha@redhat.co=
m" target=3D"_blank">stefanha@redhat.com</a>&gt;</span> wrote:<blockquote c=
lass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1p=
x;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1=
ex"><span class=3D"">
&gt; &gt; &gt; One wrinkle I came across, which I&#39;m not sure if it is b=
y design or a<br>
&gt; &gt; &gt; problem is that I can see this sequence coming from the gues=
t (with<br>
&gt; &gt; &gt; other activity in between):<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; =C2=A0 =C2=A0 1) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_RX<br>
&gt; &gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A02) OP_SHUTDOWN w/ flags =3D=3D SHUTD=
OWN_TX<br>
&gt; &gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A03) OP_SHUTDOWN w/ flags =3D=3D SHUTD=
OWN_TX|SHUTDOWN_RX<br>
<br>
</span>How did you trigger this sequence?=C2=A0 I&#39;d like to reproduce i=
t.<br></blockquote><div><br></div><div>Nothing magic. I&#39;ve written some=
 logging into my backend and captured the result for a simple backend initi=
ated connection.</div><div><br></div><div>In the log &quot;TX&quot; and &qu=
ot;RX&quot; indicate the thread doing the processing (with &quot;TX&quot; b=
eing the one which processes the guest&#39;s TX ring, i.e. data coming from=
 the guest to the host). &quot;&lt;=3D&quot; indicates a buffer going from =
guest to host and &quot;=3D&gt;&quot; is from host to guest. NB that guest =
to host replies are queued synchronously by the TX thread onto the RX ring =
which is why the somewhat odd looking &quot;TX: =3D&gt;&quot; combination c=
an occur. A host initiated connection also happens from the TX thread in th=
e same way.</div><div><br></div><div>The trace is of a simple request respo=
nse (which both fit in one buffer in each direction), the lines without an =
&quot;?X:&quot; prefix are my annotations/guesses as to what is going on:</=
div><div><br></div><div><div>TX: =3D&gt;SRC:00000002.00010002 DST:00000003.=
00000948</div><div>TX: =C2=A0 LEN:00000000 TYPE:0001 OP:1=3DREQUEST</div><d=
iv>TX: =C2=A0FLAGS:00000000 BUF_ALLOC:00008000 FWD_CNT:00000000</div><div><=
br></div><div>TX: &lt;=3DSRC:00000003.00000948 DST:00000002.00010002</div><=
div>TX: =C2=A0 LEN:00000000 TYPE:0001 OP:2=3DRESPONSE</div><div>TX: =C2=A0F=
LAGS:00000000 BUF_ALLOC:00040000 FWD_CNT:00000000</div><div><br></div><div>=
REQUEST + RESPONSE =3D=3D Channel open successfully</div><div><br></div><di=
v>RX: =3D&gt;SRC:00000002.00010002 DST:00000003.00000948</div><div>RX: =C2=
=A0 LEN:0000005e TYPE:0001 OP:5=3DRW</div><div>RX: =C2=A0FLAGS:00000000 BUF=
_ALLOC:00008000 FWD_CNT:00000000</div><div><br></div><div>Host sends a requ=
est to the guest</div><div><br></div><div>TX: &lt;=3DSRC:00000003.00000948 =
DST:00000002.00010002</div><div>TX: =C2=A0 LEN:00000000 TYPE:0001 OP:6=3DCR=
EDIT_UPDATE</div><div>TX: =C2=A0FLAGS:00000000 BUF_ALLOC:00040000 FWD_CNT:0=
000005e</div><div><br></div><div>Guest replies with a credit update</div><d=
iv><br></div><div>TX: &lt;=3DSRC:00000003.00000948 DST:00000002.00010002</d=
iv><div>TX: =C2=A0 LEN:00000091 TYPE:0001 OP:5=3DRW</div><div>TX: =C2=A0FLA=
GS:00000000 BUF_ALLOC:00040000 FWD_CNT:0000005e</div><div><br></div><div>Gu=
est replies with the answer to the request</div><div><br></div><div>RX: =3D=
&gt;SRC:00000002.00010002 DST:00000003.00000948</div><div>RX: =C2=A0 LEN:00=
000000 TYPE:0001 OP:4=3DSHUTDOWN</div><div>RX: =C2=A0FLAGS:00000002 BUF_ALL=
OC:00008000 FWD_CNT:00000091</div><div><br></div><div>Host has sent its onl=
y request, so host app must have done shutdown(SHUT_WR) I suppose and host =
therefore sends SHUTDOWN_TX.</div><div><br></div><div>TX: &lt;=3DSRC:000000=
03.00000948 DST:00000002.00010002</div><div>TX: =C2=A0 LEN:00000000 TYPE:00=
01 OP:4=3DSHUTDOWN</div><div>TX: =C2=A0FLAGS:00000001 BUF_ALLOC:00040000 FW=
D_CNT:0000005e</div><div><br></div><div>Guest SHUTDOWN_RX. I&#39;m not sure=
 if this is a direct kernel response to the SHUTDOWN_TX or if the applicati=
on inside the guest saw an EOF when reading the socket and did the correspo=
nding shutdown(SHUT_RD).</div><div><br></div><div>TX: &lt;=3DSRC:00000003.0=
0000948 DST:00000002.00010002</div><div>TX: =C2=A0 LEN:00000000 TYPE:0001 O=
P:4=3DSHUTDOWN</div><div>TX: =C2=A0FLAGS:00000002 BUF_ALLOC:00040000 FWD_CN=
T:0000005e</div><div><br></div><div>Guest SHUTDOWN_TX, I presume that havin=
g sent the only response it is going to it then does shutdown(SHUT_WR).</di=
v><div><br></div><div>TX: &lt;=3DSRC:00000003.00000948 DST:00000002.0001000=
2</div><div>TX: =C2=A0 LEN:00000000 TYPE:0001 OP:4=3DSHUTDOWN</div><div>TX:=
 =C2=A0FLAGS:00000003 BUF_ALLOC:00040000 FWD_CNT:0000005e</div></div><div><=
br></div><div>Guest shuts down both directions.</div><div><br></div><div>Pe=
rhaps the guest end is turning shutdown(foo) directly into a vsock message =
without or-ing in the current state?</div><div><br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;bo=
rder-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1ex">=
<div><div class=3D"h5">
&gt; &gt; &gt; I orignally had my backend close things down at #2, however =
this meant<br>
&gt; &gt; &gt; that when #3 arrived it was for a non-existent socket (or, w=
orse, an<br>
&gt; &gt; &gt; active one if the ports got reused). I checked v5 of the spe=
c<br>
&gt; &gt; &gt; proposal[0] which says:<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0If these bits are set and there are no mo=
re virtqueue buffers<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0pending the socket is disconnected.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; but I&#39;m not entirely sure if this behaviour contradicts =
this or not<br>
&gt; &gt; &gt; (the bits have both been set at #2, but not at the same time=
).<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; BTW, how does one tell if there are no more virtqueue buffer=
s pending<br>
&gt; &gt; &gt; or not while processing the op?<br>
&gt; &gt;<br>
&gt; &gt; #2 is odd.=C2=A0 The shutdown bits are sticky so they cannot be c=
leared once<br>
&gt; &gt; set.=C2=A0 I would have expected just #1 and #3.=C2=A0 The behavi=
or you observe<br>
&gt; &gt; look like a bug.<br>
&gt; &gt;<br>
&gt; &gt; The spec text does not convey the meaning of OP_SHUTDOWN well.<br=
>
&gt; &gt; OP_SHUTDOWN SHUTDOWN_TX|SHUTDOWN_RX means no further rx/tx is pos=
sible<br>
&gt; &gt; for this connection.=C2=A0 &quot;there are no more virtqueue buff=
ers pending the<br>
&gt; &gt; socket&quot; really means that this isn&#39;t an immediate close =
from the<br>
&gt; &gt; perspective of the application.=C2=A0 If the application still ha=
s unread rx<br>
&gt; &gt; buffers then the socket stays readable until the rx data has been=
 fully<br>
&gt; &gt; read.<br>
&gt;<br>
&gt; Yes but you also wrote:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0If these bits are set and there are no more =
virtqueue buffers<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0pending the socket is disconnected.<br>
&gt;<br>
&gt; how does remote know that there are no buffers pending and so it&#39;s=
 safe<br>
&gt; to reuse the same source/destination address now?=C2=A0 Maybe destinat=
ion<br>
&gt; should send RST at that point?<br>
<br>
</div></div>You are right, the source/destination address could be reused w=
hile the<br>
remote still has the connection in their table.=C2=A0 Connection<br>
establishment would fail with a RST reply.<br>
<br>
I can think of two solutions:<br>
<br>
1. Implementations must remove connections from their table as soon as<br>
=C2=A0 =C2=A0SHUTDOWN_TX|SHUTDOWN_RX is received.=C2=A0 This way the source=
/destination<br>
=C2=A0 =C2=A0address tuple can be reused immediately, i.e. new connections =
with<br>
=C2=A0 =C2=A0the same source/destination would be possible while an applica=
tion is<br>
=C2=A0 =C2=A0still draining the receive buffers of an old connection.<br>
<br>
2. Extend the connection lifecycle so that an A-&gt;B<br>
=C2=A0 =C2=A0SHUTDOWN_TX|SHUTDOWN_RX must be followed by a by a B-&gt;A RST=
 to close<br>
=C2=A0 =C2=A0a connection.=C2=A0 This way the source/destination address is=
 only in use<br>
=C2=A0 =C2=A0once at a time.<br>
<br>
Option #2 seems safer because there is no overlap in source/destination<br>
address usage.<br>
</blockquote></div><br></div></div><div class=3D"gmail_extra">I agree (I ha=
dn&#39;t seen this when I replied to Michael similar suggestion).</div><div=
 class=3D"gmail_extra"><br></div><div class=3D"gmail_extra">Ian. (sorry aga=
in for the formatting)</div></div>

--001a1144400c6c719c05304c48c5--

--===============8060150057196769230==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8060150057196769230==--
