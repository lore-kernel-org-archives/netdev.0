From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: nfp bpf offload add/replace
Date: Thu, 7 Sep 2017 17:52:24 +0100
Message-ID: <20170907175224.176b41e6@cakuba.netronome.com>
References: <20170907091033.GD1967@nanopsycho>
        <20170907144412.7a4a7cf7@cakuba.netronome.com>
        <20170907140503.GE1967@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:37083 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752689AbdIGQw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 12:52:29 -0400
In-Reply-To: <20170907140503.GE1967@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Sep 2017 16:05:03 +0200, Jiri Pirko wrote:
> Thu, Sep 07, 2017 at 03:44:12PM CEST, kubakici@wp.pl wrote:
> >On Thu, 7 Sep 2017 11:10:33 +0200, Jiri Pirko wrote:  
> >> Hi Kuba.
> >> 
> >> I'm looking into cls_bpf code and nfp_net_bpf_offload function in your
> >> driver. Why do you need TC_CLSBPF_ADD? Seems like TC_CLSBPF_REPLACE
> >> should be enough. It would make the cls_bpf code easier.
> >>
> >> Note that other cls just have replace/destroy (u32 too, as drivers
> >> handle NEW/REPLACE in one switch-case - will patch this).  
> >
> >Could we clarify what the REPLACE is actually supposed to do?  :)
> >
> >In the flower code and the REPLACE looks a lot like ADD on the
> >surface...  If change is called it will invoke REPLACE with the new
> >filter and then if there was an old filter, it will do DELETE.  Is my
> >understanding correct?  
> 
> Yes, correct.
> 
> >
> >If so I found this model of operation somehow confusing.  Plus the
> >management of flows may get slightly tricky if there is a possibility of
> >"replacing" a flow with an identical one.  Flower may make calls like
> >these:
> >
> >add flower vlan_id 100 action ...
> ># REPLACE vid 100 ...
> >change ... flower vlan_id 100 action ...
> ># REPLACE vid 100 ...
> ># DELETE  vid 100 ...  
> 
> Yes, that is the flow.
> 
> >
> >Doesn't this force driver/HW to implement refcounting on the rules?  
> 
> Why do you think so? There is a cookie that is passed from flower down
> and driver uses it to remove the entry.

Right, the key/mask combination doesn't have to be unique anyway...

> >On why I need the replace - BPF unlike other classifiers usually
> >installs a single program, I think offloading multiple TC filters is
> >questionable (people will use tailcalls instead most likely).  I want to
> >be able to implement atomic replace of that single program (i.e. not ADD
> >followed by DELETE) because that simplifies the driver quite a bit.  
> 
> Understood. So, looks like the REPLACE/DESTROY would be sufficient for
> bpf. ADD is not needed as it can be done by REPLACE-NULL, right?

Yes, or you could take it to the extreme ;)
 DESTROY == offload(old, NULL)
 ADD     == offload(NULL, new)
 REPLACE == offload(obj, new)

> On the other hand, the rest of the cls, namely flower, u32 and matchall
> need ADD/DESTROY as they don't really do no replacing.
> 
> Makes sense?

Ack, if you're unifying things, I don't mind how things are muxed as
long as atomic replace is possible.

FWIW cls_bpf doesn't pass old prog in REPLACE right now, but I have
patch to add it anyway since it simplifies the driver when maps are
involved.  I should probably stop looking at the .command completely,
just rely on new/old programs being populated.
