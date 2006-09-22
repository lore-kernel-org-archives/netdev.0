From: Phillip Susi <psusi@cfl.rr.com>
Subject: Re: [RFC 0/6] TCP socket splice
Date: Fri, 22 Sep 2006 13:45:37 -0400
Message-ID: <45142141.3010802@cfl.rr.com>
References: <20060920210711.17480.92354.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from iriserv.iradimed.com ([69.44.168.233]:47313 "EHLO iradimed.com")
	by vger.kernel.org with ESMTP id S964833AbWIVRpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 13:45:33 -0400
To: Ashwini Kulkarni <ashwini.kulkarni@intel.com>
In-Reply-To: <20060920210711.17480.92354.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How is this different than just having the application mmap() the file=20
and recv() into that buffer?

Ashwini Kulkarni wrote:
> My name is Ashwini Kulkarni and I have been working at Intel Corporat=
ion for
> the past 4 months as an engineering intern. I have been working on th=
e 'TCP
> socket splice' project with Chris Leech. This is a work-in-progress v=
ersion
> of the project with scope for further modifications.
>=20
> TCP socket splicing:
> It allows a TCP socket to be spliced to a file via a pipe buffer. Fir=
st, to
> splice data from a socket to a pipe buffer, upto 16 source pages(s) a=
re pulled
> into the pipe buffer. Then to splice data from the pipe buffer to a f=
ile,
> those pages are migrated into the address space of the target file. I=
t takes
> place entirely within the kernel and thus results in zero memory copi=
es. It is
> the receive side complement to sendfile() but unlike sendfile() it is
> possible to splice from a socket as well and not just to a socket.
>=20
> Current Method:
>                          + >  Application Buffer +
>                          |                       |
>         _________________|_______________________|_____________
>                          |                       |
>               Receive or |                       | Write
>               I/OAT DMA  |                       |
>                          |                       |
>                          |                       V
>                        Network              File System
>                        Buffer                  Buffer
>                          ^                       |
>                          |                       |
>         _________________|_______________________|_____________
>                      DMA |                       | DMA
>                          |                       |
>        Hardware          |                       |
>                          |                       V
>                         NIC                     SATA
>                                                                    =20
> In the current method, the packet is DMA=E2=80=99d from the NIC into =
the network buffer.
> There is a read on socket to the user space and the packet data is co=
pied from
> the network buffer to the application buffer. A write operation then =
moves the
> data from the application buffer to the file system buffer which is t=
hen DMA'd
> to the disk again. Thus, in the current method there will be one full=
 copy of
> all the data to the user space.
>=20
> Using TCP socket splice:
>=20
>                     Application Control
>                          |
>         _________________|__________________________________
>                          |
>                          |   TCP socket splice
>                          | +---------------------+
>                          | |     Direct path     |
>                          V |                     V
>                        Network              File System
>                        Buffer                  Buffer
>                          ^                       |
>                          |                       |
>         _________________|_______________________|__________
>                      DMA |                       | DMA
>                          |                       |
>        Hardware          |                       |
>                          |                       V
>                         NIC                     SATA
>                                                                    =20
> In this method, the objective is to use TCP socket splicing to create=
 a direct
> path in the kernel from the network buffer to the file system buffer =
via a pipe
> buffer. The pages will migrate from the network buffer (which is asso=
ciated
> with the socket) into the pipe buffer for an optimized path. From the=
 pipe
> buffer, the pages will then be migrated to the output file address sp=
ace page
> cache. This will enable to create a LAN to file-system API which will=
 avoid the
> memcpy operations in user space and thus create a fast path from the =
network
> buffer to the storage buffer.
>=20
> Open Issues (currently being addressed):
> There is a performance drop when transferring bigger files (usually l=
arger than
> 65536 bytes in size). Performance drop increases with the size of the=
 file.
> Work is in progress to identify the source of this issue.
>=20
> We encourage the community to review our TCP socket splice project. F=
eedback
> would be greatly appreciated.
>=20
> --
> Ashwini Kulkarni

