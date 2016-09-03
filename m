From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Centralizing support for TCAM?
Date: Sat, 3 Sep 2016 09:09:50 +0200
Message-ID: <20160903070950.GA1749@nanopsycho.orion>
References: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
 <b8323295-e3eb-48ca-7c82-ff40d222a743@gmail.com>
 <57C9C9BE.6040407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, idosh@mellanox.com, john.fastabend@intel.com,
        ast@kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        ecree@solarflare.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36023 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752463AbcICHKU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 03:10:20 -0400
Received: by mail-wm0-f51.google.com with SMTP id c133so56753209wmd.1
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2016 00:09:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57C9C9BE.6040407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 02, 2016 at 08:49:34PM CEST, john.fastabend@gmail.com wrote:
>On 16-09-02 10:18 AM, Florian Fainelli wrote:
>> Hi all,
>> 
>
>Hi Florian,
>
>> (apologies for the long CC list and the fact that I can't type correctly
>> email addresses)
>> 
>
>My favorite topic ;)
>
>> While working on adding support for the Broadcom Ethernet switches
>> Compact Field Processor (which is essentially a TCAM,
>> action/policer/rate meter RAMs, 256 entries), I started working with the
>> ethtool::rxnfc API which is actually kind of nice in that it fits nicely
>> with my use simple case of being able to insert rules at a given or
>> driver selected location and has a pretty good flow representation for
>> common things you may match: TCP/UDP v4/v6 (not so much for non-IP, or
>> L2 stuff though you can use the extension flow representation). It lacks
>> support for more complex actions other than redirect to a particular
>> port/queue.
>
>When I was doing this for one of the products I work on I decided that
>extending ethtool was likely not a good approach and building a netlink
>interface would be a better choice. My reasons were mainly extending
>ethtool is a bit painful to keep structure compatibility across versions
>and I also had use cases that wanted to get notifications both made
>easier when using netlink. However my netlink port+extensions were not
>accepted and were called a "kernel bypass" and the general opinion was
>that it was not going to be accepted upstream. Hence the 'tc' effort.

Ethtool should die peacefully. Don't poke in it in the process...


>
>> 
>> Now ethtool::rxnfc is one possible user, but tc and netfiler also are,
>> more powerful and extensible, but since this is a resource constrained
>> piece of hardware, and it would suck for people to have to implement
>> these 3 APIs if we could come up with a central one that satisfies the
>> superset offered by tc + netfilter. We can surely imagine an use case we
>
>My opinion is that tc and netfilter are sufficiently different that
>building a common layer is challenging and is actually more complex vs
>just implementing two interfaces. Always happy to review code though.

In february, Pablo did some work on finding the common intermediate
layer for classifier-action subsystem. It was rejected with the argument
of unnecessary overhead. Makes sense to me. After that, you introduced
u32 tc offload. Since that, couple more tc classifiers and actions were
offloaded.

I believe that for Florian's usecase, TC is a great fit. You can just use
cls_flower with couple of actions.

My colleagues are working hard on enabling cls_flower offload. You can
easily benefit that. In mlxsw we also plan to use that for our TCAM ACLs
offloading.


>
>There is also an already established packet flow through tc, netfilter,
>fdb, l3 in linux that folks want to maintain. At the moment I just don't
>see the need for a common layer IMO.
>
>Also adding another layer of abstraction so we end up doing multiple
>translations into and out of these layers adds overhead. Eventually
>I need to get reasonable operations per second on the TCAM tables.
>Reasonable for me being somewhere in the 50k to 100k add/del/update
>commands per second. I'm hesitant to create more abstractions then
>are actually needed.
>
>> centralize the whole matching + action into a Domain Specific Language
>> that we compiled into eBPF and then translate into whatever the HW
>> understands, although that raises the question of where do we put the
>> translation tool in user space or kernel space.
>
>The eBPF to HW translation I started to look at but gave up. The issue
>was the program space of eBPF is much larger than any traditional
>parser, table hardware implementation can support so most programs get
>rejected (obvious observation right?). I'm more inclined to build
>hardware that can support eBPF vs restricting eBPF to fit into a
>parser/table model.

+1
I have been thinging a lot about this and I believe that parsing bpf
program in drivers into some pre-defined tables is quite complex. I
think that bpf is just very unsuitable to offload, if you don't have a
hw which could directly interpret it.
I know that Alexei disagrees :)


>
>Surely something like P4 (DSL) -> ebpf -> HW can constrain the ebpf
>programs so they can be loaded without issues. This might be worth
>while but mapping it onto 'tc' classifiers like cls_{u32|flower} is a
>bit more straight forward.
>
>> 
>> So what's everybody's take on this?
>
>Seems a good time to bring up my other issue. When I have a pipeline
>with multiple TCAM tables I was trying to figure out how to abstract
>that in Linux. Something like the following
>
>    TCAM -> exact match -> TCAM -> exact match
>
>So for now I was thinking of lifting two netdevs into linux something
>like, ethx-frontend, ethx-backend. Where rules added to the frontend
>go into the front part of the pipeline and rules added to the backend
>go into the second half of the pipeline.
>
>It probably needs more thought.
>
>> 
>> Thanks!
>> 
>
>Not sure that helps but my suggestion is to see if the
>cls_u32/cls_flower implementation that exists today solves at least
>the TCAM entry problem. Note the "order" field in u32 allows you to
>place rules in user specific order.
>
>.John
