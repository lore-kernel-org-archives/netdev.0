From: Tim Mattox <tmattox@engr.uky.edu>
Subject: Re: [PATCH 2.6] e100: use NAPI mode all the time
Date: Sun, 6 Jun 2004 21:51:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <2DF80C45-B825-11D8-9557-000393652100@engr.uky.edu>
References: <Pine.LNX.4.58.0406041727160.2662@sfeldma-ich5.jf.intel.com> <DC71FD1C-B80C-11D8-9557-000393652100@engr.uky.edu> <1086566591.3721.54.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net,
        Scott Feldman <scott.feldman@intel.com>, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1086566591.3721.54.camel@localhost.localdomain>
To: sfeldma@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please excuse the length of this e-mail.

I will attempt to explain the potential problem between NAPI and
bonding with an example below.  And the only reason I say "potential"
is that I have deliberately avoided building clusters with this
configuration and have not seen it "in the wild" personally.
I've read about this problem on the beowulf mailing list, usually
in conjunction with people trying to bond GigE NICs.
I will soon have a cluster that can be easily switched to various
modes on it's network, including simple bonding, and I should be able
to directly test this myself in my lab.

The problem is caused by the order packets are delivered to the TCP
stack on the receiving machine.  In normal round-robin bonding mode,
the packets are sent out one per NIC in the bond.  For simplicity
sake, lets say we have two NICs in a bond, eth0 and eth1.  When
sending packets, eth0 will handle all the even packets, and eth1 all
the odd packets.  Similarly when receiving, eth0 would get all
the even packets, and eth1 all the odd packets from a particular
TCP stream.

With NAPI (or other interrupt mitigation techniques) the
receiving machine will process multiple packets in a row from a
single NIC, before getting packets from another NIC.  In the
above example, eth0 would receive packets 0, 2, 4, 6, etc.
and pass them to the TCP layer.  Followed by eth1's
packets 1, 3, 5, 7, etc.  The specific number of out-of-order
packets received in a row would depend on many factors.

The TCP layer would need to reorder the packets from something
like 0, 2, 4, 6, 1, 3, 5, 7 or something
like 0, 2, 4, 1, 3, 5, 6, 7.  With many possible variations.

Before NAPI (and hardware interrupt mitigation schemes), bonding
would work without causing this re-ordering, since each packet
would arrive and be enqueued to the TCP stack in the order of
arrival, which in a well designed network would match the
transmission order.  Sure, if your network randomly delayed packets
then things would get out of order, but in the HPC community which
uses bonding, the two network paths would normally be made
identical, and possibly with only a single switch between source
and destination NICs.  If there was congestion delays in one path and
not in another, then the HPC network/program had more serious problems.

I don't want to slow the progress of Linux networking development.
I was objecting to the removal of a feature to e100 that already has
working code and that was, AFAIK, necessary for the performance
enhancement of bonding.

If the overhead of re-ordering the packets is not significant, and
if simply increasing the value of /proc/sys/net/ipv4/tcp_reordering
will allow TCP to "chill" and not send negative ACKs when it sees
packets this much out of order, than sure, remove the non-NAPI support.

I will attempt to re-locate the specific examples discussed on the
beowulf mailing list, but I don't have those URLs handy.

On Jun 6, 2004, at 8:03 PM, Scott Feldman wrote:
>> Have you considered how this interacts with multiple e100's bonded
>> together with Linux channel bonding?
>> I've CC'd the bonding developer mailing list to flush out any more
>> opinions on this.
>
> No.  But if there is an issue between NAPI and bonding, that's 
> something
> to solve between NAPI and bonding but not the nic driver.

There may yet need to be more bonding code put in the receive path
to deal with this re-ordering problem.  Or possibly a configuration
option to NAPI that works across various NIC drivers.  But I hope not.
Any bonding developers have ideas on how to mitigate this problem?

>> I have yet to set up a good test system, but my impression has been
>> that NAPI and channel bonding would lead to lots of packet re-ordering
>> load for the CPU that could outweigh the interrupt load savings.
>> Does anyone have experience with this?
>
> re-ordering or dropped?

This re-ordering problem will show up without any actual packet loss.

>> Also, depending on the setting of /proc/sys/net/ipv4/tcp_reordering
>> the TCP stack might do aggressive NACKs because of a false-positive on
>> dropped packets due to the large reordering that could occur with
>> NAPI and bonding combined.
>
> I guess I don't see the bonding angle.  How does inserting a SW FIFO
> between the nic HW and the softirq thread make things better for
> bonding?

I'm not sure I understand your question.  The tcp_reordering parameter
is supposed to control the amount of out-of-order packets the receiving
TCP stack sees before issuing pre-emptive negative ACKs to the sender.
(To avoid waiting for the TCP resend timer to expire.)  This was an
optimization that works well in most situations where packet re-ordering
was a strong indication of a dropped packet.  Such extra NACKs, and the
resulting unnecessary retransmits, would be quite detrimental to
performance in a bonded network setup that was not actually dropping
packets.

>> In short, unless there has been study on this, I would suggest not yet
>> removing support for non-NAPI mode on any network driver.
>
> fedora core 2's default is e100-NAPI, so we're getting good test
> coverage there without bonding.   tg3 has used NAPI only for some time,
> and I'm sure it's used with bonding.
>
> -scott

I have NO problems with NAPI itself, I think it's a wonderful 
development.
I would even advocate for making NAPI the default across the board.
But for bonding, until I see otherwise, I want to be able to not use 
NAPI.
As I indicated, I will have a new cluster that I can directly test this
NAPI vs Bonding issue very soon.
--
Tim Mattox - tmattox@engr.uky.edu - http://homepage.mac.com/tmattox/
     http://aggregate.org/KAOS/ - http://advogato.org/person/tmattox/
