From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: nfp bpf offload add/replace
Date: Thu, 7 Sep 2017 16:05:03 +0200
Message-ID: <20170907140503.GE1967@nanopsycho>
References: <20170907091033.GD1967@nanopsycho>
 <20170907144412.7a4a7cf7@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:38008 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755053AbdIGOFG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:05:06 -0400
Received: by mail-wr0-f175.google.com with SMTP id 108so19604950wra.5
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 07:05:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170907144412.7a4a7cf7@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 07, 2017 at 03:44:12PM CEST, kubakici@wp.pl wrote:
>On Thu, 7 Sep 2017 11:10:33 +0200, Jiri Pirko wrote:
>> Hi Kuba.
>> 
>> I'm looking into cls_bpf code and nfp_net_bpf_offload function in your
>> driver. Why do you need TC_CLSBPF_ADD? Seems like TC_CLSBPF_REPLACE
>> should be enough. It would make the cls_bpf code easier.
>>
>> Note that other cls just have replace/destroy (u32 too, as drivers
>> handle NEW/REPLACE in one switch-case - will patch this).
>
>Could we clarify what the REPLACE is actually supposed to do?  :)
>
>In the flower code and the REPLACE looks a lot like ADD on the
>surface...  If change is called it will invoke REPLACE with the new
>filter and then if there was an old filter, it will do DELETE.  Is my
>understanding correct?

Yes, correct.


>
>If so I found this model of operation somehow confusing.  Plus the
>management of flows may get slightly tricky if there is a possibility of
>"replacing" a flow with an identical one.  Flower may make calls like
>these:
>
>add flower vlan_id 100 action ...
># REPLACE vid 100 ...
>change ... flower vlan_id 100 action ...
># REPLACE vid 100 ...
># DELETE  vid 100 ...

Yes, that is the flow.


>
>Doesn't this force driver/HW to implement refcounting on the rules?

Why do you think so? There is a cookie that is passed from flower down
and driver uses it to remove the entry.


>
>On why I need the replace - BPF unlike other classifiers usually
>installs a single program, I think offloading multiple TC filters is
>questionable (people will use tailcalls instead most likely).  I want to
>be able to implement atomic replace of that single program (i.e. not ADD
>followed by DELETE) because that simplifies the driver quite a bit.

Understood. So, looks like the REPLACE/DESTROY would be sufficient for
bpf. ADD is not needed as it can be done by REPLACE-NULL, right?

On the other hand, the rest of the cls, namely flower, u32 and matchall
need ADD/DESTROY as they don't really do no replacing.

Makes sense?
