From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] AF_RAW: Augment raw_send_hdrinc to expand skb to fit
	iphdr->ihl (v2)
Date: Wed, 28 Oct 2009 14:59:47 -0400
Message-ID: <20091028185947.GA12675@hmsreliant.think-freely.org>
References: <20091028173955.GB7422@hmsreliant.think-freely.org> <4AE889B5.4040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57137 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbZJ1S7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 14:59:51 -0400
Content-Disposition: inline
In-Reply-To: <4AE889B5.4040301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2009 at 07:13:09PM +0100, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > Augment raw_send_hdrinc to correct for incorrect ip header length v=
alues
> >=20
> > A series of oopses was reported to me recently.  Apparently when us=
ing AF_RAW
> > sockets to send data to peers that were reachable via ipsec encapsu=
lation,
> > people could panic or BUG halt their systems.
> >=20
> > I've tracked the problem down to user space sending an invalid ip h=
eader over an
> > AF_RAW socket with IP_HDRINCL set to 1.
> >=20
> > Basically what happens is that userspace sends down an ip frame tha=
t includes
> > only the header (no data), but sets the ip header ihl value to a la=
rge number,
> > one that is larger than the total amount of data passed to the send=
msg call.  In
> > raw_send_hdrincl, we allocate an skb based on the size of the data =
in the msghdr
> > that was passed in, but assume the data is all valid.  Later during=
 ipsec
> > encapsulation, xfrm4_tranport_output moves the entire frame back in=
 the skbuff
> > to provide headroom for the ipsec headers.  During this operation, =
the
> > skb->transport_header is repointed to a spot computed by
> > skb->network_header + the ip header length (ihl).  Since so little =
data was
> > passed in relative to the value of ihl provided by the raw socket, =
we point
> > transport header to an unknown location, resulting in various crash=
es.
> >=20
> > So, what to do about this?  My first thought was to simply return -=
EINVAL, and
> > let user space sort it out.  I'm still thinking that might be the b=
est way, but
> > I thought I'd try this first, just in case someone has reason to tr=
y to
> > send such a bogus frame through the kernel.  This solution simply c=
hecks the
> > value of ihl in raw_send_hdrinc and expands the skb to fit, filling=
 the new
> > space with  IPOPT_NOOP options.  I've confirmed that it fixes the c=
rashes that
> > were reported.
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
>=20
> Thanks a lot for this detailed info, I wish everything could be expla=
ined like this !
>=20
You're welcome, this was a fun one to track down :)

> I believe we should drop the request, since padding it is not what wa=
s expected by user.

Yeah, I had a feeling.  Ok, version 2, this time drop the invalid frame=
 and
report it to user space, instead of expanding it:


    Augment raw_send_hdrinc to correct for incorrect ip header length v=
alues
   =20
    A series of oopses was reported to me recently.  Apparently when us=
ing AF_RAW
    sockets to send data to peers that were reachable via ipsec encapsu=
lation,
    people could panic or BUG halt their systems.
   =20
    I've tracked the problem down to user space sending an invalid ip h=
eader over an
    AF_RAW socket with IP_HDRINCL set to 1.
   =20
    Basically what happens is that userspace sends down an ip frame tha=
t includes
    only the header (no data), but sets the ip header ihl value to a la=
rge number,
    one that is larger than the total amount of data passed to the send=
msg call.  In
    raw_send_hdrincl, we allocate an skb based on the size of the data =
in the msghdr
    that was passed in, but assume the data is all valid.  Later during=
 ipsec
    encapsulation, xfrm4_tranport_output moves the entire frame back in=
 the skbuff
    to provide headroom for the ipsec headers.  During this operation, =
the
    skb->transport_header is repointed to a spot computed by
    skb->network_header + the ip header length (ihl).  Since so little =
data was
    passed in relative to the value of ihl provided by the raw socket, =
we point
    transport header to an unknown location, resulting in various crash=
es.
   =20
    This fix for this is pretty straightforward, simply validate the va=
lue of of
    iph->ihl when sending over a raw socket.  If (iph->ihl*4U) > user d=
ata buffer
    size, drop the frame and return -EINVAL.  I just confirmed this fix=
es the
    reported crashes.
   =20
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

 raw.c |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)


diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 9ef8c08..4b15354 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -351,13 +351,24 @@ static int raw_send_hdrinc(struct sock *sk, void =
*from, size_t length,
 	skb->ip_summed =3D CHECKSUM_NONE;
=20
 	skb->transport_header =3D skb->network_header;
-	err =3D memcpy_fromiovecend((void *)iph, from, 0, length);
-	if (err)
-		goto error_fault;
+	err =3D -EFAULT;
+	if (memcpy_fromiovecend((void *)iph, from, 0, length))
+		goto error_free;
=20
-	/* We don't modify invalid header */
 	iphlen =3D iph->ihl * 4;
-	if (iphlen >=3D sizeof(*iph) && iphlen <=3D length) {
+
+	/*
+	 * We don't want to modify the ip header, but we do need to=20
+	 * be sure that it won't cause problems later along the network
+	 * stack.  Specifically we want to make sure that iph->ihl is a=20
+	 * sane value.  If ihl points beyond the length of the buffer passed
+	 * in, reject the frame as invalid
+	 */
+	err =3D -EINVAL;
+	if (iphlen > length)
+		goto error_free;=20
+=20
+	if (iphlen >=3D sizeof(*iph)) {
 		if (!iph->saddr)
 			iph->saddr =3D rt->rt_src;
 		iph->check   =3D 0;
@@ -380,8 +391,7 @@ static int raw_send_hdrinc(struct sock *sk, void *f=
rom, size_t length,
 out:
 	return 0;
=20
-error_fault:
-	err =3D -EFAULT;
+error_free:
 	kfree_skb(skb);
 error:
 	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
