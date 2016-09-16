From: Michal Soltys <soltys@ziu.info>
Subject: drr scheduler [mis]configuration question
Date: Fri, 16 Sep 2016 15:51:38 +0200
Message-ID: <ea42bcea-2982-e34c-268e-41a2eb7a1e37@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:46012 "EHLO drutsystem.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756213AbcIPNwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 09:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have hit some weird (probably missing some detail) issue with drr.
Originally it was tested between two machines, then I quickly double
checked between namespaces (same behaviour) - the configuration follows:

# setup namespace

ip netns add drrtest
ip li add name left type veth peer name right
ip li set right netns drrtest

# setup 'left' interface with drr

tc qdisc add dev left handle 1:0 root drr
for x in {1..16}; do tc class add dev left classid 1:$x parent 1:0 drr; done
for x in {1..16}; do tc qdisc add dev left handle $((256+x)):0 parent 1:$x pfifo_fast; done
tc filter add dev left proto all pref 1 parent 1:0 handle 1 flow map key dst divisor 16 baseclass 1:1
ip add add 10.15.0.255/16 dev left
ip li set left up

The above creates simple drr setup with 16 classes, counted from 1:1 to 1:16
The flow filter should simply distribute it across those classes,
relevant piece of code would suggest everything is ok:

                if (f->divisor)
                        classid %= f->divisor;

                res->class   = 0;
                res->classid = TC_H_MAKE(f->baseclass, f->baseclass + classid);

So 'classid' should 0-15 and after TC_H_MAKE() 1:1-1:16

# setup 'right' interface

ip netns exec drrtest bash

ip add add 10.15.1.249/16 dev right
ip li set right up


But with this setup, any transfer from 'left' to 'right' is blackholed.
If I change ip address of 'right' to 10.15.1.248/16, everything works
again - which would suggest some issue with proper classification.

At this point I'm a bit lost what I'm doing wrong.
