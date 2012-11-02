From: Bill Fenner <fenner@gmail.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Fri, 2 Nov 2012 12:13:18 -0400
Message-ID: <CAF4SogYMyANyZ4-RYoVHf3TewPVQgR49m5HLDdwVMJ7sn8_XxQ@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Michael Richardson <mcr@sandelman.ca>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:39960 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505Ab2KBQNT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 12:13:19 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1429606eaa.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 09:13:18 -0700 (PDT)
In-Reply-To: <5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 6:20 PM, Guy Harris <guy@alum.mit.edu> wrote:
>
> On Oct 31, 2012, at 2:50 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>
>> pcap files that already have the tags reinsrted should work with
>> current filter code. However for live traffic, one has to get the tags
>> from CMSG() and then reinsert it back to the packet for the current
>> filter to work.
>
> *Somebody* has to do that, at least to packets that pass the filter, before they're handed to a libpcap-based application, for programs that expect to see packets as they arrived from/were transmitted to the wire to work.
>
> I.e., the tags *should* be reinserted by libpcap, and, as I understand it, that's what the
>
>         #if defined(HAVE_PACKET_AUXDATA) && defined(HAVE_LINUX_TPACKET_AUXDATA_TP_VLAN_TCI)
>                 ...
>         #endif
>
> blocks of code in pcap-linux.c in libpcap are doing.
>
> Now, if filtering is being done in the *kernel*, and the tags aren't being reinserted by the kernel, then filter code stuffed into the kernel would need to differ from filter code run in userland.  There's already precedent for that on Linux, with the "cooked mode" headers; those are synthesized by libpcap from the metadata returned for PF_PACKET sockets, and the code that attempts to hand the kernel a filter goes through the filter code, which was generated under the assumption that the packet begins with a "cooked mode" header, and modifies (a copy of) the code to, instead, use the special Linux-BPF-interpreter offsets to access the metadata.
>
> The right thing to do here would be to, if possible, do the same, so that the kernel doesn't have to reinsert VLAN tags for packets that aren't going to be handed to userland.

In this case, it would be incredibly complicated to do this just
postprocessing a set of bpf instructions.  The problem is that when
running the filter in the kernel, the IP header, etc. are not offset,
so "off_macpl" and "off_linktype" would be zero, not 4, while
generating the rest of the expression.  We would also have to insert
code when comparing the ethertype to 0x8100 to instead load the
vlan-tagged metadata, so all jumps crossing that point would have to
be adjusted, and if the "if-false" instruction was also testing the
ethertype, then the ethertype would have to be reloaded (again
inserting another instruction).

Basically, take a look at the output of "tcpdump -d tcp port 22 or
(vlan and tcp port 22)".  Are the IPv4 tcp ports at x+14/x+16, or at
x+18/x+20?  If we're filtering in the kernel, they're at x+14/x+16
whether the packet is vlan tagged or not.  If we're filtering on the
actual packet contents (from a savefile, for example), they're at
x+18/x+20 if the packet is vlan tagged.

Also, an expression such as 'tcp port 22' would have to have some
instructions added at the beginning, for "vlan-tagged == false", or it
would match both tagged and untagged packets.

This would be much more straightforward to deal with in the code
generation phase, except until now the code generation phase hasn't
known whether the filter is headed for the kernel or not.

  Bill
