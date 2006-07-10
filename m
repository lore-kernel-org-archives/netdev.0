From: "Tien ChenLi" <cltien@gmail.com>
Subject: Re: [Bugme-new] [Bug 6802] New: pktgen cause kernel oops with transmit load balanced bonding
Date: Mon, 10 Jul 2006 10:52:58 -0400
Message-ID: <cc862f80607100752t4f575548uba3d54e7ceee400a@mail.gmail.com>
References: <200607071437.k67EbqZS022297@fire-2.osdl.org>
	 <20060707115019.ebeb6865.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:10253 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1422644AbWGJOxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 10:53:00 -0400
Received: by nf-out-0910.google.com with SMTP id a25so678068nfc
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 07:52:58 -0700 (PDT)
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060707115019.ebeb6865.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Output of kernel 2.6.17.4:

BUG: unable to handle kernel NULL pointer dereference at virtual
address 00000010
 printing eip:
e0988e2e
*pde = 00000000
Oops: 0000 [#1]
Modules linked in: pktgen bonding ip_tables x_tables microcode ata_piix libata
CPU:    0
EIP:    0060:[<e0988e2e>]    Not tainted VLI
EFLAGS: 00010213   (2.6.17.4 #1)
EIP is at bond_alb_xmit+0xb2/0x1c9 [bonding]
eax: 00000000   ebx: df526ba0   ecx: 00000005   edx: dd8f0ee8
esi: df53b6a3   edi: e098ad51   ebp: dca23f18   esp: dca23f00
ds: 007b   es: 007b   ss: 0068
Process pktgen/0 (pid: 2104, threadinfo=dca22000 task=ddd10520)
Stack: df53b6a2 00000001 df526cb8 df526940 dde8e16c df526940 dca23fe4 e097a324
       dd8f0ee8 df526940 5a5a5a5a 5a5a5a5a 5a5a5a5a 5a5a5a5a 5a5a5a5a 5a5a5a5a
       00000000 00000000 dca22000 5a5a5a5a 5a5a5a5a 5a5a5a5a 5a5a5a5a bc5e5016
Call Trace:
 <c0102a82> show_stack_log_lvl+0x87/0x8f  <c0102bd3> show_registers+0x112/0x17b
 <c0102d8e> die+0xda/0x19f  <c010b228> do_page_fault+0x467/0x551
 <c0102727> error_code+0x4f/0x54  <e097a324>
pktgen_thread_worker+0x3b1/0x790 [pktgen]
 <c0100d3d> kernel_thread_helper+0x5/0xb
Code: 74 69 81 fa dd 86 00 00 74 3f e9 b5 00 00 00 fc 8b 75 e8 bf 50
ad 98 e0 b9 06 00 00 00 f3 a6 0f 84 a3 00 00 00 8b 55 08 8b 42 20 <83>
78 10 ff 0f 84 93 00 00 00 80 78 09 02 0f 84 89 00 00 00 8d
EIP: [<e0988e2e>] bond_alb_xmit+0xb2/0x1c9 [bonding] SS:ESP 0068:dca23f00
 <0>Kernel panic - not syncing: Fatal exception in interrupt

The script I ran with kernel 2.6 is:

#! /bin/sh

modprobe pktgen

PGDEV=/proc/net/pktgen/bond0
PGCTL=/proc/net/pktgen/pgctrl

function pgset() {
    local result

    echo $1 > $PGDEV

    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
         cat $PGDEV | fgrep Result:
    fi
}

function pg() {
    echo start > $PGCTL
    cat $PGDEV
}

echo "add_device bond0" > /proc/net/pktgen/kpktgend_0
pgset "frags 5"         # packet will consist of 5 fragments
pgset "dst 192.168.0.1"

pgset "count 0"    # sets number of packets to send, set to zero
                        # for continious sends untill explicitly
                        # stopped.
pg

2006/7/7, Andrew Morton <akpm@osdl.org>:
> On Fri, 7 Jul 2006 07:37:52 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
>
> > http://bugzilla.kernel.org/show_bug.cgi?id=6802
> >
> >            Summary: pktgen cause kernel oops with transmit load balanced
> >                     bonding
> >     Kernel Version: 2.4.32, 2.6.17.2
> >             Status: NEW
> >           Severity: high
> >              Owner: acme@conectiva.com.br
> >          Submitter: cltien@gmail.com
> >
> >
> > Most recent kernel where this bug did not occur:
> > not found
> > Distribution:
> > Fedora Core 4
> >
> > Hardware Environment:
> > i386, ppc
> >
> > Software Environment:
> > gcc
> >
> > Problem Description:
> > If running the kernel packet generator (pktgen), and the output device is set
> > to bonding interface with mode balance-tlb or balance-alb, then there will be
> > kernel oops.
> >
> > I only set the odev, dst and count (as 0 for infinite test) for the pktgen. I
> > wonder if I made mistake for the pktgen parameters but it doesn't cause problem
> > if the odev set to physical device such as eth0, etc.
> >
> > My investigations shows that the problem happen when the bond_alb_xmit tries to
> > access the daddr fields of IP header in skb->nh.iph. If I did the same in round-
> > robin mode, it can generate oops too.
> >
> > Steps to reproduce:
> > 1. Build kernel with pktgen (CONFIG_NET_PKTGEN) and bonding driver
> > (CONFIG_BONDING).
> > 2. Setup bonding interface.
> > ifenslave bond0 eth0
> > 3. Create a script for starting packet generator,
> > the script I start packet generator for kernel 2.4 series is like following:
> > -----------cut here --------
> > #! /bin/sh
> >
> > modprobe pktgen
> >
> > PGDEV=/proc/net/pktgen/pg0
> >
> > function pgset() {
> >     local result
> >
> >     echo $1 > $PGDEV
> >
> >     result=`cat $PGDEV | fgrep "Result: OK:"`
> >     if [ "$result" = "" ]; then
> >          cat $PGDEV | fgrep Result:
> >     fi
> > }
> >
> > function pg() {
> >     echo inject > $PGDEV
> >     cat $PGDEV
> > }
> >
> > pgset "odev bond0"
> > pgset "dst 127.1.16.1"
> > pgset "count 0"
> > pg
> > -----------cut here --------
> >
> > 4. If the odev is set to eth0, the this script will not have problem, problem
> > only happen when it is set to bond0.
> >
>
> Please send (via an emailed reply-to-all) a copy of the oops output.
>
> Thanks.
>
