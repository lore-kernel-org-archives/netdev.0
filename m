From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next V3 3/7] net/sched: Reflect HW offload status
Date: Wed, 15 Feb 2017 10:28:21 -0800
Message-ID: <20170215102821.12f419e7@cakuba.netronome.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
        <1487148757-24809-4-git-send-email-ogerlitz@mellanox.com>
        <CAJ3xEMg32qMp0Hh+BQbHdoMCKwX_ivvZVwo30njvXubR7ZQ8xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Roi Dayan <roid@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36636 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdBOS20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:28:26 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so33285504pfu.3
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 10:28:25 -0800 (PST)
In-Reply-To: <CAJ3xEMg32qMp0Hh+BQbHdoMCKwX_ivvZVwo30njvXubR7ZQ8xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Feb 2017 18:19:17 +0200, Or Gerlitz wrote:
> On Wed, Feb 15, 2017 at 10:52 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> > Currently there is no way of querying whether a filter is
> > offloaded to HW or not when using "both" policy (where none
> > of skip_sw or skip_hw flags are set by user-space).  
> 
> > Add two new flags, "in hw" and "not in hw" such that user
> > space can determine if a filter is actually offloaded to
> > hw or not. The "in hw" UAPI semantics was chosen so it's
> > similar to the "skip hw" flag logic.  
> 
> To make things a bit more clear, the semantics of the "in hw"
> thing relates to the time of dumping the rule.
> 
> Currently in all of the offloading drivers/cases, when the driver returns
> success for the ndo_setup_tc call, the flow is offloaded to hw.
> 
> But moving fwd that might change, a flow might be not offloaded to HW
> on some window of time.
> 
> The coming up example, is support for neigh updates w.r.t to IP tunnel
> encapsulation offloads in mlx5 SRIOV switchdev mode.
> 
> Today we offload tunnel encap flow only if the kernel has valid neigh
> to the tunnel destination. Under the works is a code to offload/un-offload
> the flow to/from HW when the neigh becomes valid/invalid or goes through
> hardware address change etc.
> 
> So what I basically suggest here is to enhance that future mlx5 series
> with patches
> under which the dump code of all the classifiers will invoke the
> tc_setup_ndo with
> a fourth sub command (today there are add/del/stats) which will return
> the actual
> "in hw" status.
> 
> This is aligned with the general architecture/approach in the kernel
> for switchdev and other
> offloads.
> 
> Note that this future change doesn't change the UAPI, it will still
> have two values, "in hw"
> and "not in hw". The values with this series are the actual values and
> later with that change,
> they will keep being the actual values, just the kernel method to
> retrieve them will be different.

Thanks for explaining this, I was actually hoping to take this in
slightly different direction.

What worries me is that the moment we started offloading packet
modification we run at the risk of modifying packets twice.  This used
to be a problem only for eBPF but now mlx5 can also offload things like
ttl decrement.  For filters which have no skip_* flags set and get
offloaded if packet doesn't get redirected or modified significantly it
will match the filter both in HW and on the host and therefore have the
actions applied twice.  And it will get counted twice.  (It seems nobody
ever raised this so perhaps I'm mistaken in thinking that this can
happen?)

Back to your patch set, I was hoping we will be able to use the new
IN_HW flag to skip filters in software even if they don't have skip_sw
set.  If we need to eject actions from HW based on external events, that
obviously complicates things.  Three trivial solutions to the problem
I could think of are:
 - pass a pointer to filter's flags down to the driver and let it do
   atomic bitops? on it to set/clear the IN_HW status;
 - add a way of driver calling back into TC;
 - use one of recently freed skb TC bits to mark packets which were
   supposed to be processed in HW by could not as needing software
   fallback (I think this could work for you without parsing the packet
   in the driver, you could replace the tunnel action with mark action
   and leave the matching rule in HW classifier/TCAM; for BPF I have a
   descriptor flag telling me if offloaded BPF completed successfully).

FWIW this patch set looks good to me!
