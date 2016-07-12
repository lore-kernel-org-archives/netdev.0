From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v8 01/11] bpf: add XDP prog type for early driver filter
Date: Tue, 12 Jul 2016 07:52:53 -0700
Message-ID: <CALx6S36aPgB1PCsTg7Z=SNGQs_8REMm4qJdpp6JJ6ksVp_65VA@mail.gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-2-git-send-email-bblanco@plumgrid.com> <20160712151431.26cbac82@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38048 "EHLO
	mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbcGLOwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 10:52:54 -0400
Received: by mail-it0-f54.google.com with SMTP id h190so17674853ith.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 07:52:54 -0700 (PDT)
In-Reply-To: <20160712151431.26cbac82@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 6:14 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Tue, 12 Jul 2016 00:51:24 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:
>
>> Add a new bpf prog type that is intended to run in early stages of the
>> packet rx path. Only minimal packet metadata will be available, hence a
>> new context type, struct xdp_md, is exposed to userspace. So far only
>> expose the packet start and end pointers, and only in read mode.
>>
>> An XDP program must return one of the well known enum values, all other
>> return codes are reserved for future use. Unfortunately, this
>> restriction is hard to enforce at verification time, so take the
>> approach of warning at runtime when such programs are encountered. Out
>> of bounds return codes should alias to XDP_ABORTED.
>
> This is going to be a serious usability problem, when XDP gets extended
> with newer features.
>
> How can users know what XDP capabilities a given driver support?
>
We talked about this a the XDP summit and I have some slides on this
(hope to have slides posted shortly) . Drivers, more generally XDP
platforms, will provide a list APIs that they support. APIs would be
contained in a sort common specification files that and would have
some name like basic_xdp_api, adv_switch_api, etc. An XDP program is
written using one of the published APIs and the API it uses is
expressed as part of the program. At runtime (possibly compile time)
the API used by the program is checked against the list of APIs for
the target platform-- if the API is not in the set then the program is
not allowed to be loaded. To whatever extent possible we should also
try to verify that program adhere's to the API as load and compile
time. In the event that program violates the API it claims to be
using, such as return invalid return code for the API, that is an
error condition.

> If the user loads a XDP program using capabilities not avail in the
> driver, then all his traffic will be hard dropped.
>
>
> My proposal is to NOT allow XDP programs to be loaded if they want to use
> return-codes/features not supported by the driver.  Thus, eBPF programs
> register/annotate their needed capabilities upfront (I guess this could
> also help HW offload engines).
>
Exactly. We just need to define exactly how this is done ;-)

One open issue is whether XDP needs to be binary compatible across
platforms or source code compatible (also require recompile in latter
case for each platform). Personally I prefer source code compatible
since that might allow platforms to implement the API specifically for
their needs (like the ordering of fields in a meta data structure.

Tom

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
