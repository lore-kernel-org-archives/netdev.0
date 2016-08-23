From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Tue, 23 Aug 2016 02:54:09 -0700
Message-ID: <20160823095347.GA3070@ircssh.c.rugged-nimbus-611.internal>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <20160819162158.GA25083@salvia>
 <20160819170739.GF29430@pox.localdomain>
 <20160822160610.GA32723@salvia>
 <05bfd5c4-4095-37ff-b7a6-85b8dca8ec70@zonque.org>
 <20160822172040.GA22876@ircssh.c.rugged-nimbus-611.internal>
 <721182c4-7285-c169-d088-c45c81a5219e@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Thomas Graf <tgraf@suug.ch>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37390 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756656AbcHWJyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 05:54:12 -0400
Received: by mail-it0-f46.google.com with SMTP id f6so125757740ith.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 02:54:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <721182c4-7285-c169-d088-c45c81a5219e@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2016 at 10:27:28AM +0200, Daniel Mack wrote:
> On 08/22/2016 07:20 PM, Sargun Dhillon wrote:
> > On Mon, Aug 22, 2016 at 06:22:20PM +0200, Daniel Mack wrote:
> >> On 08/22/2016 06:06 PM, Pablo Neira Ayuso wrote:
> 
> >>> This patchset also needs an extra egress hook, not yet known where to
> >>> be placed, so two hooks in the network stacks in the end, 
> >>
> >> That should be solvable, I'm sure. I can as well leave egress out for
> >> the next version so it can be added later on.
> >>
> > Any idea where you might put that yet? Does dev_xmit seems like a reasonable 
> > place?
> 
> Ah, yes. Thanks for the pointer, that seems to work fine.
> 
Daniel pointed out to me that there's already a BPF program that's used there 
for tc matches. So, it should work fine. I would just verify you can call 
programs from IRQs, and rcu_bh plays well with it.

Alternatively, if you want to filter only IP traffic, ip_output, and ip6_output 
are fairly good places. I'm planning on putting some LSM hooks there soon. It's 
a bit simpler.

I also suggest you use verdicts rather than trimming for simplicity sake.

> > If someone uses the netprio, or the net classid controllers, skcd matches
> > no longer work.
> 
> Yes, sock_cgroup_ptr() will fall back to the v2 root in this case.
> 
> > Ideally, we should fix up these controllers to make them
> > more v2 friendly.
> 
> These controllers do not exist for v2, that's why sock_cgroup_ptr()
> behaves that way. What's your idea to fix that up?
I think that we should just add another pointer to the end of sock_cgroup_data 
while we're in this state of transition, and nudge people to disable 
CONFIG_CGROUP_NET_PRIO and CONFIG_CGROUP_NET_CLASSID over time.

Alternatively, we add these controllers for v2, and we have some kind of marker 
whether or not they're on v2 in the skcd. If they are, we can find the cgroup, 
and get the prioidx, and classid from the css. Although the comment in 
cgroup-defs.h suggests that v2 and classid should never be used concurrently, I 
can't help but to disagree, given there's legacy infrastructure that leverages 
classid.

> 
> 
> Thanks,
> Daniel
> 

Looking forward to seeing these patches,
-Sargun
