From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2] sctp: fully initialize the IPv6 address in
 sctp_v6_to_addr()
Date: Tue, 15 Aug 2017 12:05:57 -0300
Message-ID: <20170815150557.GC18688@localhost.localdomain>
References: <20170814184304.82747-1-glider@google.com>
 <CAPA1RqDzSs3LogN+z69Ba2yoE6=jniobC-tEGd3TTh3z=39qxg@mail.gmail.com>
 <20170815015814.GB18688@localhost.localdomain>
 <20170814.194051.1408830683580606508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: hideaki.yoshifuji@miraclelinux.com, glider@google.com,
        dvyukov@google.com, kcc@google.com, edumazet@google.com,
        lucien.xin@gmail.com, vyasevich@gmail.com,
        linux-kernel@vger.kernel.org, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170814.194051.1408830683580606508.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2017 at 07:40:51PM -0700, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Mon, 14 Aug 2017 22:58:14 -0300
>
> > On Tue, Aug 15, 2017 at 10:43:59AM +0900, 吉藤英明 wrote:
> >> > diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> >> > index 2a186b201ad2..a15d691829c6 100644
> >> > --- a/net/sctp/ipv6.c
> >> > +++ b/net/sctp/ipv6.c
> >> > @@ -513,6 +513,8 @@ static void sctp_v6_to_addr(union sctp_addr *addr, struct in6_addr *saddr,
> >> >         addr->sa.sa_family = AF_INET6;
> >> >         addr->v6.sin6_port = port;
> >> >         addr->v6.sin6_addr = *saddr;
> >> > +       addr->v6.sin6_flowinfo = 0;
> >> > +       addr->v6.sin6_scope_id = 0;
> >>
> >> Please set flowinfo between port and addr.
> >
> > Why?
>
> Store buffer compression.
>
> You want to always initialize structure member in the order
> they are in memory.

Thanks.

>
> No, the compiler won't do this automatically.

Ok, but I should see a difference in the generated code, right?

union sctp_addr is a union of sockaddr_in structs, for easy reference
ipv6 being:
struct sockaddr_in6 {
        short unsigned int         sin6_family;          /*     0     2 */
        __be16                     sin6_port;            /*     2     2 */
        __be32                     sin6_flowinfo;        /*     4     4 */
        struct in6_addr            sin6_addr;            /*     8    16 */
        __u32                      sin6_scope_id;        /*    24     4 */

Current code:
    12a1:       ba 0a 00 00 00          mov    $0xa,%edx
    12a6:       49 8b 5f 68             mov    0x68(%r15),%rbx
    12aa:       66 89 55 a0             mov    %dx,-0x60(%rbp)
                             union/struct start -----^
    12ae:       4d 8d 4f 68             lea    0x68(%r15),%r9
    12b2:       49 8b 55 40             mov    0x40(%r13),%rdx
    12b6:       66 c1 c0 08             rol    $0x8,%ax        (htons)
    12ba:       4c 39 cb                cmp    %r9,%rbx
    12bd:       48 89 55 b0             mov    %rdx,-0x50(%rbp)
                                     thus this     ---^
    12c1:       66 89 45 a2             mov    %ax,-0x5e(%rbp)
                                                     ^-------- port number
    12c5:       49 8b 45 38             mov    0x38(%r13),%rax
    12c9:       48 89 45 a8             mov    %rax,-0x58(%rbp)
                  and this are the ipv6 addr bytes ---^
    12cd:       74 30                   je     12ff <sctp_v6_get_dst+0x37f>

Alexander's:
    12a1:       ba 0a 00 00 00          mov    $0xa,%edx
    12a6:       49 8b 5f 68             mov    0x68(%r15),%rbx
    12aa:       66 89 55 a0             mov    %dx,-0x60(%rbp)
    12ae:       4d 8d 4f 68             lea    0x68(%r15),%r9
    12b2:       49 8b 55 40             mov    0x40(%r13),%rdx
    12b6:       c7 45 a4 00 00 00 00    movl   $0x0,-0x5c(%rbp)
    12bd:       c7 45 b8 00 00 00 00    movl   $0x0,-0x48(%rbp)
    12c4:       66 c1 c0 08             rol    $0x8,%ax
    12c8:       4c 39 cb                cmp    %r9,%rbx
    12cb:       48 89 55 b0             mov    %rdx,-0x50(%rbp)
    12cf:       66 89 45 a2             mov    %ax,-0x5e(%rbp)
    12d3:       49 8b 45 38             mov    0x38(%r13),%rax
    12d7:       48 89 45 a8             mov    %rax,-0x58(%rbp)
    12db:       74 30                   je     130d <sctp_v6_get_dst+0x38d>

Hideaki's:
    12a1:       ba 0a 00 00 00          mov    $0xa,%edx
    12a6:       49 8b 5f 68             mov    0x68(%r15),%rbx
    12aa:       66 89 55 a0             mov    %dx,-0x60(%rbp)
    12ae:       4d 8d 4f 68             lea    0x68(%r15),%r9
    12b2:       49 8b 55 40             mov    0x40(%r13),%rdx
    12b6:       c7 45 a4 00 00 00 00    movl   $0x0,-0x5c(%rbp)
    12bd:       c7 45 b8 00 00 00 00    movl   $0x0,-0x48(%rbp)
    12c4:       66 c1 c0 08             rol    $0x8,%ax
    12c8:       4c 39 cb                cmp    %r9,%rbx
    12cb:       48 89 55 b0             mov    %rdx,-0x50(%rbp)
    12cf:       66 89 45 a2             mov    %ax,-0x5e(%rbp)
    12d3:       49 8b 45 38             mov    0x38(%r13),%rax
    12d7:       48 89 45 a8             mov    %rax,-0x58(%rbp)
    12db:       74 30                   je     130d <sctp_v6_get_dst+0x38d>

They are the same, and messed up by the compiler breaking the copy of
the ipv6 addr (which was copied backwards) with the port number copy.

  Marcelo
