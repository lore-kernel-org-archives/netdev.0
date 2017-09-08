From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net] bpf: don't select potentially stale ri->map from
 buggy xdp progs
Date: Fri, 8 Sep 2017 13:52:42 +0200
Message-ID: <20170908135242.55f99177@redhat.com>
References: <01d69254802986ad3a8b18a8650c45df3df95def.1504821825.git.daniel@iogearbox.net>
        <20170908070610.4b8e1df1@redhat.com>
        <59B27234.4050703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@fb.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33476 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751577AbdIHLwt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 07:52:49 -0400
In-Reply-To: <59B27234.4050703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Sep 2017 12:34:28 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 09/08/2017 07:06 AM, Jesper Dangaard Brouer wrote:
> > On Fri,  8 Sep 2017 00:14:51 +0200
> > Daniel Borkmann <daniel@iogearbox.net> wrote:
> >  
> >> +	/* This is really only caused by a deliberately crappy
> >> +	 * BPF program, normally we would never hit that case,
> >> +	 * so no need to inform someone via tracepoints either,
> >> +	 * just bail out.
> >> +	 */
> >> +	if (unlikely(map_owner != xdp_prog))
> >> +		return -EINVAL;  
> >
> > IMHO we do need to call the tracepoint here.  It is not just crappy
> > BPF-progs that cause this situation, it is also drivers not implementing
> > XDP_REDIRECT yet (which is all but ixgbe).  Due to the level XDP
> > operates at, tracepoints are the only way users can runtime troubleshoot
> > their XDP programs.  
> 
> Drivers not implementing XDP_REDIRECT don't even get there in
> the first place. What they will do is to hit the 'default' case
> when they check for the action code from the BPF program. Then
> call into bpf_warn_invalid_xdp_action(act), and fall-through
> to hit the tracepoint at trace_xdp_exception() which is also
> triggered by XDP_ABORTED usually. So when that happens we do
> complain loudly and call a tracepoint already. We should probably
> tweak the bpf_warn_invalid_xdp_action() message a little to make
> it clear that the action could also just be unsupported by the
> driver instead of being illegal.

Yes. drivers not implementing XDP_REDIRECT will cause a tracepoint
trace_xdp_exception() to be called for its _own_ packets.

But it will still setup and leave map and map_owner pointer dangling.
Another NIC can load an xdp_prog that return XDP_REDIRECT, which will hit
above if-statement, and its packets will disappear, without getting
recorded by a tracepoint (thus hard to debug!).

The fundamental point is that tracepoints is the way we choose to
handle debugging XDP programs.  Thus, we must trigger a tracepoint when
a packet gets dropped.  Even in this unlikely case.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
