From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Thu, 3 Mar 2016 16:44:34 -0800
Message-ID: <CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
	<CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
	<CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
	<CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:32803 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbcCDAof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 19:44:35 -0500
Received: by mail-yw0-f169.google.com with SMTP id b72so30000774ywe.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 16:44:35 -0800 (PST)
In-Reply-To: <CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 3:21 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>
>
> On Thu, Mar 3, 2016 at 1:43 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>>
>> On Wed, Mar 2, 2016 at 8:45 PM, Cong Wang <xiyou.wangcong@gmail.com>
>> wrote:
>> >
>> > On Mon, Feb 29, 2016 at 2:08 PM, Mahesh Bandewar <mahesh@bandewar.net>
>> > wrote:
>> > > From: Mahesh Bandewar <maheshb@google.com>
>> > >
>> > > netif_receive_skb_core() dispatcher uses skb->dev device to send it
>> > > to the packet-handlers (e.g. ip_rcv, ipv6_rcv etc). These packet
>> > > handlers intern use the device passed to determine the net-ns to
>> > > further process these packets.  Now with the nomination logic, the
>> > > dispatcher will call netif_get_l3_dev() helper to select the device
>> > > to be used for this processing. Since l3_dev is initialized to self,
>> > > normal packet processing should not change.
>> > >
>> >
>> > So, if I understand your patches correctly, _logically_ the skb is still
>> > passed into the slave's netns via dev_forward_skb() but now goes over
>> > the iptable rules from the default netns by only changing the netns
>> > parameter to these hooks?
>> >
>> We are using different dev pointer for L3 processing than skb->dev. All
>> netns, routing etc, associated with this dev (l3_dev) should be used for
>> L3.
>>
>> > That is ugly... Logically, you should still need to continue to pass
>> > the skb upper to the stack in default netns until
>> > ip_local_deliver_finish().
>> >
>> >
>> > So, how about adding an iptable hook in ipvlan so that skb will
>> > continue traverse in the original stack and then moved into slave's
>> > netns? This might be harder since logically we need an L3 entrance
>> > to the stack.
>> >
>> > Thoughts?
>>
>> As you mentioned logically we should be able to pass the skb in master's
>> ns
>> until L3 processing is completed. This patch series attempts to do that by
>> disassociating this logic from skb->dev and adding it to l3_dev. This
>> should
>> include not just IPT but all that is done in L3 phase (IPT, routing etc.)
>> Also since dev->l3_dev is same as dev, this should not break any existing
>> logic.
>>
> Well, looking at the code I realized that I missed few places (especially
> routing
> logic) which continues using skb->dev in ingress path and should be
> corrected to
> use l3_dev. I'll correct those places and send the next version.


Look, even you yourself are missing something here. ;) This is exactly why
I suggest to consider another approach. Please don't introduce any code
that is hard to debug even for yourself. The struct net pointer is passed
around in kernel network subsystem almost everywhere, it is not easy to make
it bug-free by just switching skb->dev.


>> That's the generic implementation as far as the stack is concerned and
>> IPvlan
>> uses it to make the IPT hooks symmetric.
>>
>> Another IPT hook may be good enough (however I haven't
>> given much thought to it) for IPvlan, but this generic approach will be
>> for
>> whole of L3. Also currently this I have implemented for the ingress path
>> but that does not mean the same cannot be extended for the egress path
>> (in fact I'm thinking about that)
>

This is logically correct and easier to understand or debug, since IPT hook
is very common in network subsystem even ingress qdisc uses it.
