From: "David S. Miller" <davem@redhat.com>
Subject: Fw: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR
Date: Wed, 8 Oct 2003 13:33:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008133345.49f71991.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Wed__8_Oct_2003_13_33_45_-0700_ojs+lkjOa6soFJIR"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Wed__8_Oct_2003_13_33_45_-0700_ojs+lkjOa6soFJIR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Arnaldo, I think this is another piece of fallout
from the struct sock splitup you did ages ago.

I think it's dereferencing inet_sk(sk) for a time-wait
socket, so we probably need a TCP_TIME_WAIT test plus
some additional logic here?  Better check tcp_ipv6.c too.

Begin forwarded message:

Date: Wed, 8 Oct 2003 16:04:09 -0400
From: Dan Merillat <dmerillat@sequiam.com>
To: linux-kernel@vger.kernel.org
Subject: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR



I can't provide a stacktrace because it hardlocks the system, but it's
trivial to reproduce.

Swap back and forth between apache2 and apache a few times, and it
hardlocks at bind.

>From what I copied down and backtraced we crash at tcp_v4_get_port +
0x378/390, which is in tcp_ipv4.c:194 (inline tcp_bind_conflict)

                struct inet_opt *inet2 = inet_sk(sk2);
                if (!inet2->rcv_saddr || !inet->rcv_saddr ||
                    inet2->rcv_saddr == inet->rcv_saddr)
                    break;

     468:       0f b6 40 49             movzbl 0x49(%eax),%eax
     46c:       83 e0 20                and    $0x20,%eax
     46f:       84 c0                   test   %al,%al

In fact, I believe the problem to be with SO_REUSEADDR.  It only
manifests if the port has gotten traffic and there's sockets in
TIME_WAIT.

I suppose a trivial test would be to bind to a port, connect to it,
disconnect, close the socket, create a socket with SO_REUSEADDR and
rebind to it.  Pow.

I can't get UML 2.6.0 working so I can't test very well, but it's a
helluva showstopper.

The strace of apache starting up when it crashed:

socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
fcntl64(3, F_DUPFD, 15)                 = 20
close(3)                                = 0
setsockopt(20, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
setsockopt(20, SOL_SOCKET, SO_KEEPALIVE, [1], 4

(oopsed in bind so strace never saw it)

--Dan


--Multipart=_Wed__8_Oct_2003_13_33_45_-0700_ojs+lkjOa6soFJIR
Content-Type: application/pgp-signature;
 name="00000002.mimetmp"
Content-Disposition: attachment;
 filename="00000002.mimetmp"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KCmlENERCUUUvaEcyNWt5Y1NjRXhSZ3NnUkF1
OGtBSmo1V1dodW5LRTE0dDhxeGdyTDVjOVRKeHJKQUtDRjd6dUMKM0VNZTZLNnNKQ0hzb3JmQ0NH
R2R0Zz09Cj1tUitpCi0tLS0tRU5EIFBHUCBTSUdOQVRVUkUtLS0tLQoK

--Multipart=_Wed__8_Oct_2003_13_33_45_-0700_ojs+lkjOa6soFJIR--
