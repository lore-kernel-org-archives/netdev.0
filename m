From: Ashwini Kulkarni <ashwini.kulkarni@intel.com>
Subject: [RFC 0/6] TCP socket splice
Date: Wed, 20 Sep 2006 14:07:11 -0700
Message-ID: <20060920210711.17480.92354.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:57357 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751058AbWITU7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 16:59:13 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My name is Ashwini Kulkarni and I have been working at Intel Corporatio=
n for
the past 4 months as an engineering intern. I have been working on the =
'TCP
socket splice' project with Chris Leech. This is a work-in-progress ver=
sion
of the project with scope for further modifications.

TCP socket splicing:
It allows a TCP socket to be spliced to a file via a pipe buffer. First=
, to
splice data from a socket to a pipe buffer, upto 16 source pages(s) are=
 pulled
into the pipe buffer. Then to splice data from the pipe buffer to a fil=
e,
those pages are migrated into the address space of the target file. It =
takes
place entirely within the kernel and thus results in zero memory copies=
=2E It is
the receive side complement to sendfile() but unlike sendfile() it is
possible to splice from a socket as well and not just to a socket.

Current Method:
                         + >  Application Buffer +
                         |                       |
        _________________|_______________________|_____________
                         |                       |
              Receive or |                       | Write
              I/OAT DMA  |                       |
                         |                       |
                         |                       V
                       Network              File System
                       Buffer                  Buffer
                         ^                       |
                         |                       |
        _________________|_______________________|_____________
                     DMA |                       | DMA
                         |                       |
       Hardware          |                       |
                         |                       V
                        NIC                     SATA
                                                                   =20
In the current method, the packet is DMA=E2=80=99d from the NIC into th=
e network buffer.
There is a read on socket to the user space and the packet data is copi=
ed from
the network buffer to the application buffer. A write operation then mo=
ves the
data from the application buffer to the file system buffer which is the=
n DMA'd
to the disk again. Thus, in the current method there will be one full c=
opy of
all the data to the user space.

Using TCP socket splice:

                    Application Control
                         |
        _________________|__________________________________
                         |
                         |   TCP socket splice
                         | +---------------------+
                         | |     Direct path     |
                         V |                     V
                       Network              File System
                       Buffer                  Buffer
                         ^                       |
                         |                       |
        _________________|_______________________|__________
                     DMA |                       | DMA
                         |                       |
       Hardware          |                       |
                         |                       V
                        NIC                     SATA
                                                                   =20
In this method, the objective is to use TCP socket splicing to create a=
 direct
path in the kernel from the network buffer to the file system buffer vi=
a a pipe
buffer. The pages will migrate from the network buffer (which is associ=
ated
with the socket) into the pipe buffer for an optimized path. From the p=
ipe
buffer, the pages will then be migrated to the output file address spac=
e page
cache. This will enable to create a LAN to file-system API which will a=
void the
memcpy operations in user space and thus create a fast path from the ne=
twork
buffer to the storage buffer.

Open Issues (currently being addressed):
There is a performance drop when transferring bigger files (usually lar=
ger than
65536 bytes in size). Performance drop increases with the size of the f=
ile.
Work is in progress to identify the source of this issue.

We encourage the community to review our TCP socket splice project. Fee=
dback
would be greatly appreciated.

--
Ashwini Kulkarni
