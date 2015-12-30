From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 10:38:56 +0100
Message-ID: <5683A630.2070401@iogearbox.net>
References: <5681AF69.4040204@redhat.com> <5681B594.70304@iogearbox.net> <5681E154.7040101@redhat.com> <20151230034300.GA8670@ast-mbp.thefacebook.com> <5683531F.9000704@redhat.com> <20151230041611.GA9209@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45372 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbL3JjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 04:39:04 -0500
In-Reply-To: <20151230041611.GA9209@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2015 05:16 AM, Alexei Starovoitov wrote:
> On Tue, Dec 29, 2015 at 10:44:31PM -0500, Doug Ledford wrote:
>> On 12/29/2015 10:43 PM, Alexei Starovoitov wrote:
>>> On Mon, Dec 28, 2015 at 08:26:44PM -0500, Doug Ledford wrote:
>>>> On 12/28/2015 05:20 PM, Daniel Borkmann wrote:
>>>>> On 12/28/2015 10:53 PM, Doug Ledford wrote:
>>>>>> The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
>>>>>> interfaces are failing to obtain a dhcp address using dhclient.  I've
>>>>>> tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel, both
>>>>>> failed.  I've tried NetworkManager and the old SysV network service,
>>>>>> both fail.  I tried a working dhclient from rhel7 on the Fedora rawhide
>>>>>> install and it failed too.  Running tcpdump on the interface shows the
>>>>>> dhcp request going out, and a dhcp response coming back in.  Running
>>>>>> strace on dhclient shows that it writes the dhcp request, but it never
>>>>>> recvs a dhcp response.  If I manually bring the interface up with a
>>>>>> static IP address then I'm able to run typical IP traffic across the
>>>>>> link (aka, ping).  It would seem that when dhclient registers a packet
>>>>>> filter on the socket, that filter is preventing it from ever getting the
>>>>>> dhcp response.  The same dhclient works on any non-vlan interfaces in
>>>>>> the system, so the filter must work for non-vlan interfaces.  Aside from
>>>>>> the fact that the interface is a vlan, we also use a priority egress map
>>>>>> on the interface, and we use PFC flow control.  Let me know if you need
>>>>>> anymore to debug the issue, or email me off list and I can get you
>>>>>> logins to my reproducer machines.
>>>>>
>>>>> When you say 4.4-rc7 kernel is failing for you, what latest kernel version
>>>>> was working, where the socket filter was properly receiving the response on
>>>>> your vlan iface?
>>>>
>>>> v4.3 final works.  I haven't bisected where in the 4.4 series it quits
>>>> working.  I can do that tomorrow.
>>>
>>> I've tried to reproduce, but cannot seem to make dnsmasq work properly
>>> over vlan, so bisect would be great.
>>
>> Yeah, I've been working on it.  Issues with available machines that
>> reproduce combined with what hardware they have and whether or not that
>> hardware works at various steps in the bisection :-/
>
> I've looked through all bpf related commits between v4.3..HEAD and don't see
> anything suspicious. Could it be that your setup exploited a bug that was fixed by

Agreed, also went over the bpf history yesterday and didn't find anything
that could be related to this issue between the two tags.

The filter that dhclient seems to be using is (common/bpf.c):

struct bpf_insn dhcp_bpf_filter [] = {
	/* Make sure this is an IP packet... */
	BPF_STMT (BPF_LD + BPF_H + BPF_ABS, 12),
	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, ETHERTYPE_IP, 0, 8),

	/* Make sure it's a UDP packet... */
	BPF_STMT (BPF_LD + BPF_B + BPF_ABS, 23),
	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, IPPROTO_UDP, 0, 6),

	/* Make sure this isn't a fragment... */
	BPF_STMT(BPF_LD + BPF_H + BPF_ABS, 20),
	BPF_JUMP(BPF_JMP + BPF_JSET + BPF_K, 0x1fff, 4, 0),

	/* Get the IP header length... */
	BPF_STMT (BPF_LDX + BPF_B + BPF_MSH, 14),

	/* Make sure it's to the right port... */
	BPF_STMT (BPF_LD + BPF_H + BPF_IND, 16),
	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, 67, 0, 1),             /* patch */

	/* If we passed all the tests, ask for the whole packet. */
	BPF_STMT(BPF_RET+BPF_K, (u_int)-1),

	/* Otherwise, drop it. */
	BPF_STMT(BPF_RET+BPF_K, 0),
};

Given that this drop doesn't strictly need to be caused by filter code,
it would be nice if you could pin the location down where the packet gets
dropped exactly. Perhaps dropwatch or perf with '-e skb:kfree_skb -a -g
dhclient <iface>', etc could help to get a first overview to dig into
details then.

> 28f9ee22bcdd ("vlan: Do not put vlan headers back on bridge and macvlan ports")
>
> Could you also provide more details on vlan+dhcp setup to help narrow it
> down if bisect is taking too long.
