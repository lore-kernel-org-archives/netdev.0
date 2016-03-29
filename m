From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers of encapsulation.
Date: Mon, 28 Mar 2016 19:41:49 -0700
Message-ID: <CAKgT0UfGamfow7o0=w=VcYBPkUw-ZLxP80+jAcfdoYjtrj2F_Q@mail.gmail.com>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
	<1458405122-12565-3-git-send-email-jesse@kernel.org>
	<CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
	<CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
	<CALx6S35WiXiKDJL6s_nW4xWNx8M6atZVQYEgb8kO5ty2WhjFyQ@mail.gmail.com>
	<CAKgT0UdiqecAMihYP=gfmBYp7-Ko54EkO23=GWg4jEAuHocKJQ@mail.gmail.com>
	<CALx6S37RPHwsWJOpNJ+8t1bBbJJ=5PKNwFUrh-yhwwXN63RFOA@mail.gmail.com>
	<CAKgT0Uf-mPK3xQuR+BdB5owfuJdQkZPE6Z0MQs9R-y3NRrC_9g@mail.gmail.com>
	<CALx6S37eOhZ+9rS8vk6FG9qyxpZ_1i5-hw4d4rnFdvEnBde3kg@mail.gmail.com>
	<CAKgT0UdaEodsDwSfKBDJqjRG-7xHEdJGpKsAAmfmgLDL8cT4zQ@mail.gmail.com>
	<CALx6S37oooS6_0rQr59E3qkcDu14eGFDYP4CKvc_Zv64zP4NqA@mail.gmail.com>
	<CAEh+42grm7dH8VQ6MJGPjp2Cpti8NcptORk+-9hyGp0MgSVZbQ@mail.gmail.com>
	<CALx6S34VydaFDEVZD5Qv4ts7iGywx6PCGUy1oB4AkTF3Y+MB6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37828 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbcC2Clu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 22:41:50 -0400
Received: by mail-ig0-f174.google.com with SMTP id l20so4308630igf.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:41:50 -0700 (PDT)
In-Reply-To: <CALx6S34VydaFDEVZD5Qv4ts7iGywx6PCGUy1oB4AkTF3Y+MB6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 5:50 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Mar 28, 2016 at 4:34 PM, Jesse Gross <jesse@kernel.org> wrote:
>> * A packet is received that is encapsulated with two layers of GRE. It
>> looks like this: Eth|IP|GRE|IP|GRE|IP|TCP
>> * The packet is processed through GRO successfully. skb->encapsulation
>> bit is set and skb_shinfo(skb)->gso_type is set to SKB_GSO_GRE |
>> SKB_GSO_TCPV4.
>> * The packet is bridged to an output device and is prepared for
>> transmission. skb_gso_segment() is called to segment the packet.
>> * As we descent down the GSO code, we get to gre_gso_segment() for the
>> first GRE header. skb->encapsulation is cleared and we keep going to
>> the next header.
>> * We return to gre_gso_segment() again for the second GRE header.
>> There is a check for skb->encapsulation being set but it is now clear.
>> GSO processing is aborted.
>> * The packet is dropped.
>
> If multiple level of GRE GSO is the problem then you are welcome to
> fix it after FOU is fixed and when net-next opens (GSO partial should
> fix this this anyway). But this is not at all the same problem as
> saying all multiple levels of encapsulation are invalid so we need to
> disallow that in GRO for everyone regardless of whether the packet is
> is being forwarded or some driver can't understand a certain valid
> combination.

GSO partial is not magic.  It is not going to fix a great many of
these kind of issues.  All GSO partial gives us is a way for hardware
to segment frames if the headers can be replicated.  If GSO cannot
handle the frame in software then GSO partial still cannot handle it.

It looks like what we probably need to do is rewrite GSO in order to
support this as multiple tunnel levels are currently not supported.  I
figure it is something we can add once we have GSO partial in.  Maybe
call it GSO_STACKED.  I still have to figure out where we are going to
want the header pointers since there are obvious bits that wouldn't
work such as the part in UDP or GRE segmentation code where we assume
we can just reset the network header offset based off of the inner
network header offset.  If we have multiple levels of tunnels then
this is blatantly broken.  Maybe to get around it we might have to add
the tunnel header length as a value passed with UDP offloads.

> Testing GUE is really not hard. There is no reason why GUE, Geneve,
> and VXLAN should not be tested each time a change is made to any of
> the common UDP tunneling code.
>
> Configuring ipip-GUE can be done by:
>
> ./ip fou add port 6080 gue
> ./ip link add name tun1 type ipip remote 10.1.1.2 local 10.1.1.1 ttl
> 225 encap gue encap-sport auto encap-dport 6080 encap-csum
> encap-remcsum
> ifconfig tun1 192.168.1.1
> ip route add 192.168.1.0/24 dev tun1
>
> Configuring gre-GUE is just s/ipip/gre/ of above.
>
> ./netperf -H 192.168.1.2 -t TCP_STREAM -l 100

This is essentially the test case I ran to verify that the patch I
submitted fixed the issue.  I'm not sure we need to do too much
testing for the patch I submitted since the whole thing is pretty
straightforward.

> Is good for showing showing regression in a single flow. You should
> see GSO/GRO being effective on both sides and perf should show only a
> minute amount of time in csum_partial assuming that your device has
> checksum offload for outer UDP (which should be about all).
>
> ./super_netperf 200 -H 192.168.1.2 -j -l 1 -t TCP_RR -- -r 1,1 -o
> TRANSACTION_RATE,P50_LATENCY,P90_LATENCY,P99_LATENCY
>
> Is run to test pps. We're looking for no regression in tput, latency,
> or CPU utilization.
>
> Next time you make changes to anything that affects common paths in
> tunnels please run these tests and report the results in the commit
> log so we can avoid regressions like this. You should also be running
> an equivalent battery of VXLAN tests. The configuration I use is:
>
> ./ip link add vxlan0 type vxlan id 10 group 224.10.10.10 ttl 10 dev
> eth0  udpcsum remcsumtx remcsumrx
> ifconfig vxlan0 192.168.111.1
> ip route add 192.168.111.0/24 dev vxlan0
>
> Again we expect the same sort of results, GRO/GSO should be effective,
> csum_partial should not be getting significant tine, etc...

With my patch I can verify that GRO is working and coalescing frames
at least for the IPIP case as that was the only one I tested.

If there is something I missed I am willing to respin it and resubmit
it.  From what I can tell though it should restore the original
functionality for the FOU/GUE cases though since all it really does is
push the setting of the encap_mark back from the UDP header over to
the next level header which is the correct behavior (at least in my
opinion).

- Alex
