From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: nfp bpf offload add/replace
Date: Thu, 7 Sep 2017 14:44:12 +0100
Message-ID: <20170907144412.7a4a7cf7@cakuba.netronome.com>
References: <20170907091033.GD1967@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:10360 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754005AbdIGNoR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 09:44:17 -0400
In-Reply-To: <20170907091033.GD1967@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Sep 2017 11:10:33 +0200, Jiri Pirko wrote:
> Hi Kuba.
> 
> I'm looking into cls_bpf code and nfp_net_bpf_offload function in your
> driver. Why do you need TC_CLSBPF_ADD? Seems like TC_CLSBPF_REPLACE
> should be enough. It would make the cls_bpf code easier.
>
> Note that other cls just have replace/destroy (u32 too, as drivers
> handle NEW/REPLACE in one switch-case - will patch this).

Could we clarify what the REPLACE is actually supposed to do?  :)

In the flower code and the REPLACE looks a lot like ADD on the
surface...  If change is called it will invoke REPLACE with the new
filter and then if there was an old filter, it will do DELETE.  Is my
understanding correct?

If so I found this model of operation somehow confusing.  Plus the
management of flows may get slightly tricky if there is a possibility of
"replacing" a flow with an identical one.  Flower may make calls like
these:

add flower vlan_id 100 action ...
# REPLACE vid 100 ...
change ... flower vlan_id 100 action ...
# REPLACE vid 100 ...
# DELETE  vid 100 ...

Doesn't this force driver/HW to implement refcounting on the rules?

On why I need the replace - BPF unlike other classifiers usually
installs a single program, I think offloading multiple TC filters is
questionable (people will use tailcalls instead most likely).  I want to
be able to implement atomic replace of that single program (i.e. not ADD
followed by DELETE) because that simplifies the driver quite a bit.
