From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Tue, 01 Nov 2016 16:43:19 +0100
Message-ID: <87a8djnr3c.fsf@redhat.com>
References: <CALx6S36r0gzZ7ndmivsygZD9vX+EEv2sVEP=rmhQVzGB46Rkdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <CALx6S36r0gzZ7ndmivsygZD9vX+EEv2sVEP=rmhQVzGB46Rkdg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 31, 2016 at 07:25 PM GMT, Tom Herbert wrote:
> On Sun, Oct 30, 2016 at 6:03 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
>> On Fri, Oct 28, 2016 at 02:25 PM GMT, Tom Herbert wrote:
>>>
>>> If this patch is being done to be compatible with IPv4 I guess that's
>>> okay, but it would be false advertisement to say this makes ICMP
>>> follow the same path as the flow being targeted in an error.
>>> Fortunately, I doubt anyone can have a dependency on this for ICMP.
>>
>> I wouldn't want to propose anything that would be useless. If you think
>> that this is the case here, I would very much like to understand what
>> and why cannot work in practice.
>>
> The normal hash for TCP or UDP using ECMP is over <protocol, srcIP,
> dstIP, srcPort, dstPort>. For an ICMP packet ECMP would most likely be
> done over <protocol, srcIP, dstIP>. There really is no way to ensure
> that an ICMP packet will follow the same path as TCP or any other
> protocol. Fortunately, this is really isn't so terrible. The Internet
> has worked this way ever since routers started using ports as input to
> ECMP and that hasn't caused any major meltdown.

Ahh, I see the problem now. Thank you for clearing it up for me.

You are right, for locally generated TCP/UDP traffic we are computing an
L4 hash (over the 5-tuple that you mentioned) that drives the multipath
routing. While when sending locally generated ICMP errors we are only
computing an L3 hash (over the mentioned 3-tuple).

I believe that is a problem affects both IPv6 and IPv4, and manifests
itself only when the offending packet that triggers the error is
destined for the ECMP router.

When an ECMP router is: (i) sending an ICMP error in reaction to a
packet that was to be forwarded, or (ii) forwarding an ICMP error,
everything works as expected. That is because when forwarding traffic we
limit ourselves to computing an L3 hash so that the IP fragments are
routed together. Right?

So, my understanding is that, with these changes, things are not perfect
but we are not worse than IPv4 right now.

Would you be okay with this series if I update the patch 4/5 description
to highlight the existing problem that you point out? A fix for this
IPv4/6 common issue could follow afterwards.

Thanks,
Jakub
