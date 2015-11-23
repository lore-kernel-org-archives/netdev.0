From: Dave Watson <davejwatson@fb.com>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Mon, 23 Nov 2015 13:43:12 -0800
Message-ID: <20151123214312.GA2319382@devbig217.prn1.facebook.com>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
 <20151123192730.GB30089@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Herbert <tom@herbertland.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Herbert Xu <herbert@gondor.apana.org.au>,
	<linux-crypto@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151123192730.GB30089@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/23/15 02:27 PM, Sowmini Varadhan wrote:
> On (11/23/15 09:43), Dave Watson wrote:
> > Currently gcm(aes) represents ~80% of our SSL connections.
> >
> > Userspace interface:
> >
> > 1) A transform and op socket are created using the userspace crypto interface
> > 2) Setsockopt ALG_SET_AUTHSIZE is called
> > 3) Setsockopt ALG_SET_KEY is called twice, since we need both send/recv keys
> > 4) ALG_SET_IV cmsgs are sent twice, since we need both send/recv IVs.
> >    To support userspace heartbeats, changeciphersuite, etc, we would also need
> >    to get these back out, use them, then reset them via CMSG.
> > 5) ALG_SET_OP cmsg is overloaded to mean FD to read/write from.
>
> [from patch 0/2:]
> > If a non application-data TLS record is seen, it is left on the TCP
> > socket and an error is returned on the ALG socket, and the record is
> > left for userspace to manage.
>
> I'm trying to see how your approach would fit with the RDS-type of
> use-case. RDS-TCP is mostly similar in concept to kcm,
> except that rds has its own header for multiplexing, and has no
> dependancy on BPF for basic things like re-assembling the datagram.
> If I were to try to use this for RDS-TCP, the tls_tcp_read_sock() logic
> would be merged into the recv_actor callback for RDS, right?  Thus tls
> control-plane message could be seen in the middle of the
> data-stream, so we really have to freeze the processing of the data
> stream till the control-plane message is processed?

Correct.

> In the tls.c example that you have, the opfd is generated from
> the accept() on the AF_ALG socket- how would this work if I wanted
> my opfd to be a PF_RDS or a PF_KCM or similar?

For kcm, opfd is the fd you would pass along in kcm_attach.

For rds, it looks like you'd want to use opfd as the sock instead of
the new one created by sock_create_kern in rds_tcp_conn_connect.

> One concern is that this patchset provides a solution for the "80%"
> case but what about the other 20% (and the non x86 platforms)?

Almost all the rest are aes sha.  The actual encrypt / decrypt code
would be similar to this previous patch:

http://marc.info/?l=linux-kernel&m=140662647602192&w=2

The software routines in gcm(aes) should work for all platforms
without aesni.

> E.g., if I get a cipher-suite request outside the aes-ni, what would
> happen (punt to uspace?)
>
> --Sowmini

Right, bind() would fail and you would fallback to uspace.
