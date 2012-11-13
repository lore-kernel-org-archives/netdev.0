From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Tue, 13 Nov 2012 14:42:47 -0800
Message-ID: <CAOxq_8NpxEuA+i_kYqg04dMoi4sfM9awX0_210hB3q0f0j_5yQ@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
	<CAF4SogYMyANyZ4-RYoVHf3TewPVQgR49m5HLDdwVMJ7sn8_XxQ@mail.gmail.com>
	<CAOxq_8N7mSY9rLTeSdUohV5ufU+QF7DtrjwZ3xnAbuP9mRm3jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Guy Harris <guy@alum.mit.edu>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Michael Richardson <mcr@sandelman.ca>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:53014 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab2KMWms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 17:42:48 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so1062328iay.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 14:42:47 -0800 (PST)
In-Reply-To: <CAOxq_8N7mSY9rLTeSdUohV5ufU+QF7DtrjwZ3xnAbuP9mRm3jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

I'm wondering if there has been any progress on this. Are there any
thoughts on what Bill wrote in his email?

Thanks

On Tue, Nov 13, 2012 at 2:41 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> Folks,
>
> I'm wondering if there has been any progress on this. Are there any thoughts
> on what Bill wrote in his email?
>
> Thanks
> ani
>
>
>
> On Fri, Nov 2, 2012 at 9:13 AM, Bill Fenner <fenner@gmail.com> wrote:
>>
>> On Wed, Oct 31, 2012 at 6:20 PM, Guy Harris <guy@alum.mit.edu> wrote:
>> >
>> > On Oct 31, 2012, at 2:50 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>> >
>> >> pcap files that already have the tags reinsrted should work with
>> >> current filter code. However for live traffic, one has to get the tags
>> >> from CMSG() and then reinsert it back to the packet for the current
>> >> filter to work.
>> >
>> > *Somebody* has to do that, at least to packets that pass the filter,
>> > before they're handed to a libpcap-based application, for programs that
>> > expect to see packets as they arrived from/were transmitted to the wire to
>> > work.
>> >
>> > I.e., the tags *should* be reinserted by libpcap, and, as I understand
>> > it, that's what the
>> >
>> >         #if defined(HAVE_PACKET_AUXDATA) &&
>> > defined(HAVE_LINUX_TPACKET_AUXDATA_TP_VLAN_TCI)
>> >                 ...
>> >         #endif
>> >
>> > blocks of code in pcap-linux.c in libpcap are doing.
>> >
>> > Now, if filtering is being done in the *kernel*, and the tags aren't
>> > being reinserted by the kernel, then filter code stuffed into the kernel
>> > would need to differ from filter code run in userland.  There's already
>> > precedent for that on Linux, with the "cooked mode" headers; those are
>> > synthesized by libpcap from the metadata returned for PF_PACKET sockets, and
>> > the code that attempts to hand the kernel a filter goes through the filter
>> > code, which was generated under the assumption that the packet begins with a
>> > "cooked mode" header, and modifies (a copy of) the code to, instead, use the
>> > special Linux-BPF-interpreter offsets to access the metadata.
>> >
>> > The right thing to do here would be to, if possible, do the same, so
>> > that the kernel doesn't have to reinsert VLAN tags for packets that aren't
>> > going to be handed to userland.
>>
>> In this case, it would be incredibly complicated to do this just
>> postprocessing a set of bpf instructions.  The problem is that when
>> running the filter in the kernel, the IP header, etc. are not offset,
>> so "off_macpl" and "off_linktype" would be zero, not 4, while
>> generating the rest of the expression.  We would also have to insert
>> code when comparing the ethertype to 0x8100 to instead load the
>> vlan-tagged metadata, so all jumps crossing that point would have to
>> be adjusted, and if the "if-false" instruction was also testing the
>> ethertype, then the ethertype would have to be reloaded (again
>> inserting another instruction).
>>
>> Basically, take a look at the output of "tcpdump -d tcp port 22 or
>> (vlan and tcp port 22)".  Are the IPv4 tcp ports at x+14/x+16, or at
>> x+18/x+20?  If we're filtering in the kernel, they're at x+14/x+16
>> whether the packet is vlan tagged or not.  If we're filtering on the
>> actual packet contents (from a savefile, for example), they're at
>> x+18/x+20 if the packet is vlan tagged.
>>
>> Also, an expression such as 'tcp port 22' would have to have some
>> instructions added at the beginning, for "vlan-tagged == false", or it
>> would match both tagged and untagged packets.
>>
>> This would be much more straightforward to deal with in the code
>> generation phase, except until now the code generation phase hasn't
>> known whether the filter is headed for the kernel or not.
>>
>>   Bill
>
>
