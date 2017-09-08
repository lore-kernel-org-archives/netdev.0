From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net] bpf: don't select potentially stale ri->map from
 buggy xdp progs
Date: Fri, 8 Sep 2017 15:07:46 +0200
Message-ID: <20170908150746.3f010b41@redhat.com>
References: <01d69254802986ad3a8b18a8650c45df3df95def.1504821825.git.daniel@iogearbox.net>
        <20170908070610.4b8e1df1@redhat.com>
        <59B27234.4050703@iogearbox.net>
        <20170908135242.55f99177@redhat.com>
        <59B28E45.40700@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, davem@davemloft.net, ast@fb.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58684 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755508AbdIHNHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 09:07:54 -0400
In-Reply-To: <59B28E45.40700@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Sep 2017 14:34:13 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 09/08/2017 01:52 PM, Jesper Dangaard Brouer wrote:
> > On Fri, 08 Sep 2017 12:34:28 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:  
> >> On 09/08/2017 07:06 AM, Jesper Dangaard Brouer wrote:  
> >>> On Fri,  8 Sep 2017 00:14:51 +0200
> >>> Daniel Borkmann <daniel@iogearbox.net> wrote:
> >>>  
> >>>> +	/* This is really only caused by a deliberately crappy
> >>>> +	 * BPF program, normally we would never hit that case,
> >>>> +	 * so no need to inform someone via tracepoints either,
> >>>> +	 * just bail out.
> >>>> +	 */
> >>>> +	if (unlikely(map_owner != xdp_prog))
> >>>> +		return -EINVAL;  
> >>>
> >>> IMHO we do need to call the tracepoint here.  It is not just crappy
> >>> BPF-progs that cause this situation, it is also drivers not implementing
> >>> XDP_REDIRECT yet (which is all but ixgbe).  Due to the level XDP
> >>> operates at, tracepoints are the only way users can runtime troubleshoot
> >>> their XDP programs.  
> >>
> >> Drivers not implementing XDP_REDIRECT don't even get there in
> >> the first place. What they will do is to hit the 'default' case
> >> when they check for the action code from the BPF program. Then
> >> call into bpf_warn_invalid_xdp_action(act), and fall-through
> >> to hit the tracepoint at trace_xdp_exception() which is also
> >> triggered by XDP_ABORTED usually. So when that happens we do
> >> complain loudly and call a tracepoint already. We should probably
> >> tweak the bpf_warn_invalid_xdp_action() message a little to make
> >> it clear that the action could also just be unsupported by the
> >> driver instead of being illegal.  
> >
> > Yes. drivers not implementing XDP_REDIRECT will cause a tracepoint
> > trace_xdp_exception() to be called for its _own_ packets.  
> 
> Yep, plus a big one time warning for the case a user doesn't
> look at tracepoints initially.
> 
> > But it will still setup and leave map and map_owner pointer dangling.
> > Another NIC can load an xdp_prog that return XDP_REDIRECT, which will hit
> > above if-statement, and its packets will disappear, without getting
> > recorded by a tracepoint (thus hard to debug!).  
> 
> If a user wants to reproduce this exact error, he would need
> to go and reload the program on the driver not supporting the
> XDP_REDIRECT in the first place, and then reload his buggy program
> on the other driver supporting XDP_REDIRECT but w/o having called
> bpf_xdp_redirect_map(), so exactly once on the switch from one
> driver to another with this misuse, any subsequent packets will
> trigger _trace_xdp_redirect_err(), same way as if the buggy
> program was loaded to the 2nd driver from the beginning since
> the map and ifindex etc will be zero, hence my comment on this.

We can agree that the second program that experience the side-effect is
also buggy, as just returning XDP_REDIRECT without calling
bpf_xdp_redirect_map() or bpf_xdp_redirect(), is a bug in the bpf
program.  Thus, the comment about a "deliberately crappy BPF program"
is not wrong.

You don't have to load and unload xdp programs.  My test is simply
having two XDP programs running.  1. xdp_redirect_map on mlx5 which
doesn't implement XDP_REDIRECT, and 2. a "deliberately crappy BPF
program" on ixgbe that just returns XDP_REDIRECT.

In below output I've used -EFAULT == -14 to capture this situation
happening:

     ksoftirqd/3    28 [003]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
         swapper     0 [005]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/0     7 [000]  3437.829882:        xdp:xdp_exception: prog_id=5 action=REDIRECT ifindex=7
     ksoftirqd/4    34 [004]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/2    22 [002]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/3    28 [003]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
         swapper     0 [005]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
         swapper     0 [005]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/3    28 [003]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/2    22 [002]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/4    34 [004]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/3    28 [003]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/2    22 [002]  3437.829882:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/0     7 [000]  3437.829882: xdp:xdp_redirect_map_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-14 map_id=5 map_index=0
         swapper     0 [005]  3437.829883:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22
     ksoftirqd/3    28 [003]  3437.829883:     xdp:xdp_redirect_err: prog_id=3 action=REDIRECT ifindex=2 to_ifindex=0 err=-22

And I can see I made a mistake and dereference the map_id ;-)

BTW, just to make it clear, I love the rest of the patch.  And I love
how you solved this.  Cool trick. You also closed a hole where someone
could set the map in one bpf_prog and cause the next bpf program to
forward using this map (this could be a policy violation).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
