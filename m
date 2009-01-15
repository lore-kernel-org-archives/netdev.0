From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Thu, 15 Jan 2009 12:47:22 +0100
Message-ID: <496F224A.9080100@cosmosbay.com>
References: <20090113123702.ad29cd13.akpm@linux-foundation.org>	<496D2078.9080302@cosmosbay.com>	<496D25F8.2080505@cosmosbay.com> <20090114.205839.20689555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, Volker.Lendecke@SerNet.DE,
	linux-kernel@vger.kernel.org, sfrench@us.ibm.com,
	jens.axboe@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48558 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbZAOLrn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 06:47:43 -0500
In-Reply-To: <20090114.205839.20689555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 14 Jan 2009 00:38:32 +0100
>=20
>> [PATCH] net: splice() from tcp to socket should take into account O_=
NONBLOCK
>>
>> Instead of using SPLICE_F_NONBLOCK to select a non blocking mode bot=
h on
>> source tcp socket and pipe destination, we use the underlying file f=
lag (O_NONBLOCK)
>> for selecting a non blocking socket.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> This needs at least some more thought.
>=20
> It seems, for one thing, that this change will interfere with the
> intentions of the code in splice_dirt_to_actor which goes:
>=20
> 	/*
> 	 * Don't block on output, we have to drain the direct pipe.
> 	 */
> 	sd->flags &=3D ~SPLICE_F_NONBLOCK;

Reading splice_direct_to_actor() I see nothing wrong with the patch

(Patch is about splice from socket to pipe, while the sd->flags you men=
tion
in splice_direct_to_actor() only applies to the splice from internal pi=
pe to
something else, as splice_direct_to_actor() allocates an internal pipe =
to perform
its work.

Also, the meaning of SPLICE_F_NONBLOCK, as explained in include/linux/s=
plice.h is :

#define SPLICE_F_NONBLOCK (0x02) /* don't block on the pipe splicing (b=
ut */
	/* we may still block on the fd we splice */
	/* from/to, of course */

If the comment is still correct, SPLICE_F_NONBLOCK only applies to the =
pipe implied in
splice() syscall.

=46or the other file, either its :
- A regular file : nonblocking mode is not available, like a normal rea=
d()/write() syscall

- A socket : We should be able to specify if its blocking or not, indep=
endantly from
             the SPLICE_F_NONBLOCK flag that only applies to the pipe. =
Normal way
             is using ioctl(FIONBIO) or other fcntl() call to change fi=
le->f_flags O_NONBLOCK


In order to be able to efficiently use splice() from a socket to a file=
, we need
to do a loop of :

{
splice(from blocking tcp socket to non blocking pipe, SPLICE_F_NONBLOCK=
); /* nonblocking pipe or risk deadlock */
splice(from pipe to file)
}


