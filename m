From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 12:15:42 +0200
Message-ID: <578371CE.6090305@iogearbox.net>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-2-git-send-email-bblanco@plumgrid.com> <20160709101403.1ed7d021@redhat.com> <CALx6S36dnA_vXBJVpLTZc6WyZaDh_hnw4vpp57EC2jsfA0vHcQ@mail.gmail.com> <20160710153731.62d6773d@redhat.com> <20160710170922.GC6657@gmail.com> <CALx6S34623bJP=L2EVNV6Gfx4oF=io5TGsGXCDQ=WH3VnHweMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>
To: Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57273 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbcGKKPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 06:15:55 -0400
In-Reply-To: <CALx6S34623bJP=L2EVNV6Gfx4oF=io5TGsGXCDQ=WH3VnHweMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2016 10:30 PM, Tom Herbert wrote:
> On Sun, Jul 10, 2016 at 12:09 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
[...]
>> I would then argue to only support offloading of XDP programs with
>> verifiable return codes. We're not at that stage yet, and I think we can
>> choose different defaults for these two cases.

It's also not really verifiable in the sense that such verdict could be
part of a struct member coming from a policy map and such. You'd loose
this flexibility if you'd only allow return codes encoded into immediate
values.

>> We have conflicting examples here, which lead to different conclusions.
>> Reiterating an earlier argument that I made for others on the list to
>> consider:
>> """
>> Besides, I don't see how PASS is any more correct than DROP. Consider a
>> future program that is intended to rewrite a packet and forward it out
>> another port (with some TX_OTHER return code or whatever). If the driver
>> PASSes the packet, it will still not be interpreted by the stack, since
>> it may have been destined for some other machine.
>> """
>> So, IMHO there is not a clear right or wrong, and I still fall back to
>> the security argument to resolve the dilemma. The point there is not
>> drop/pass, but resource preservation.
>>
> Blind pass is a security risk, drop is always a correct action in that sense.

I agree here that drop would be better, if there's a good reason/use-case
to make the default configurable as in i) drop or ii) fall-back to stack,
then this could be another option to leave admin the choice, but not seeing
it thus far. But hitting the default case could certainly inc a per-cpu error
counter visible for ethtool and et al, to have some more insight.

Additionally, a WARN_ON_ONCE() should be fine telling that the program for
this given configuration is buggy. I'm not sure there will be much support
that you can take a XDP program tailored for a specific kernel and expect it
to run on a, say, 1 year old kernel with XDP there. To make it work properly
you need to have that much insight into the program anyway so you configure
the stack to make up for those non-functioning parts (iff possible) that you
could just as well rewrite/change the affected parts from the XDP program.

Otoh, it should be reasonable to assume that older XDP programs written in
the past for driver xyz can run fine on newer kernels for driver xyz as well,
so that part should be expected.
