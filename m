From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Mon, 23 Nov 2015 14:27:30 -0500
Message-ID: <20151123192730.GB30089@oracle.com>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16921 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbbKWT1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 14:27:45 -0500
Content-Disposition: inline
In-Reply-To: <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/23/15 09:43), Dave Watson wrote:
> Currently gcm(aes) represents ~80% of our SSL connections.
> 
> Userspace interface:
> 
> 1) A transform and op socket are created using the userspace crypto interface
> 2) Setsockopt ALG_SET_AUTHSIZE is called
> 3) Setsockopt ALG_SET_KEY is called twice, since we need both send/recv keys
> 4) ALG_SET_IV cmsgs are sent twice, since we need both send/recv IVs.
>    To support userspace heartbeats, changeciphersuite, etc, we would also need
>    to get these back out, use them, then reset them via CMSG.
> 5) ALG_SET_OP cmsg is overloaded to mean FD to read/write from.

[from patch 0/2:]
> If a non application-data TLS record is seen, it is left on the TCP
> socket and an error is returned on the ALG socket, and the record is
> left for userspace to manage.

Interesting approach.

FWIW, I was hoping to discuss solutions for securing traffic tunnelled
over L3 at netdev 1.1, so hopefully we'll be able to go over the
trade-offs there. 

I'm trying to see how your approach would fit with the RDS-type of
use-case. RDS-TCP is mostly similar in concept to kcm,
except that rds has its own header for multiplexing, and has no 
dependancy on BPF for basic things like re-assembling the datagram. 
If I were to try to use this for RDS-TCP, the tls_tcp_read_sock() logic
would be merged into the recv_actor callback for RDS, right?  Thus tls
control-plane message could be seen in the middle of the
data-stream, so we really have to freeze the processing of the data
stream till the control-plane message is processed?

I'm concerned about the possiblilites for async that can happen when
we separate the data-plane from the control-plane (uspace tls
does not have to deal with this), but we now have control plane
separated from data-plane. (And IPsec/IKE has plenty of headaches
from this sort of thing already)

In the tls.c example that you have, the opfd is generated from
the accept() on the AF_ALG socket- how would this work if I wanted
my opfd to be a PF_RDS or a PF_KCM or similar?

One concern is that this patchset provides a solution for the "80%"
case but what about the other 20% (and the non x86 platforms)?
E.g., if I get a cipher-suite request outside the aes-ni, what would
happen (punt to uspace?)

--Sowmini
