From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: AF_PACKET mmap() v4...
Date: Mon, 09 Nov 2015 11:54:02 +0100
Message-ID: <56407B4A.6020809@iogearbox.net>
References: <20151105.000414.1682124328670738318.davem@davemloft.net> <4931220.z2MFa8LzkQ@wuerfel> <563B23C3.5070406@iogearbox.net> <20151108021958.GA39441@ast-mbp.thefacebook.com> <563ECF1B.1000306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, horms@verge.net.au
To: John Fastabend <john.fastabend@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58613 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbKIKyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 05:54:10 -0500
In-Reply-To: <563ECF1B.1000306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2015 05:27 AM, John Fastabend wrote:
> On 15-11-07 06:19 PM, Alexei Starovoitov wrote:
>> On Thu, Nov 05, 2015 at 10:39:15AM +0100, Daniel Borkmann wrote:
>>> On 11/05/2015 10:07 AM, Arnd Bergmann wrote:
>>>> On Thursday 05 November 2015 00:04:14 David Miller wrote:
>>>>> As part of fixing y2038 problems, Arnd is going to have to make a new
>>>>> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
>>>>> the time values to 64-bit.
>>
>> would also be quite useful to add ability to attach metadata to packet
>> from bpf program.
>> Right now we can only trim the length. Would be great if program could
>> compute something and pass it along with packet as metadata.
>
> Also most modern NICs can generate metadata using packet filters
> it would be nice to allow these to populate any metadata fields as well.
> Ethtool already has a flow classifier feature that could be easily
> extended once the stack has support.

If I understand this correctly, that would be something independent from
packet sockets, right? Attaching metadata to the skb could be currently done
via mark, tc_index, tc_classid, priority, but I presume you mean something
else. ;)

Or, do you mean to push meta data into skb->data f.e. in front of the frame.
As in having some sort of a 'dynamic-sized', reserved scratch space or stack
at the head or tail of the skb (not visible to the network itself, but only
to the local NIC)?

It would be interesting if it could be used to interact with the NIC, as
John says, e.g. from incoming side to place a tag or additional meta data
there as a result of the NIC's flow classifier, which might then be read out
from an eBPF program to perform further actions on the skb.

If you even want to take this one step further for data center environments,
there was the idea floating around [1], where you encapsulate a restricted
set of instructions together with some scratch space between Ethernet header
and payload.

These "tiny packet programs" could then query switch meta data on the fly
that is being stored into the scratch space. Of course, this requires vendor
support, but this seems really powerful.

   [1] http://jvimal.github.io/tpp/
