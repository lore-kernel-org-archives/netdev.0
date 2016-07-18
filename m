From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Sun, 17 Jul 2016 21:01:23 -0700
Message-ID: <20160718040121.GA36111@ast-mbp.thefacebook.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
 <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
 <20160715164744.GA3693@ast-mbp.thefacebook.com>
 <20160715210952.089a793e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35820 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbcGREBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 00:01:30 -0400
Received: by mail-pf0-f177.google.com with SMTP id c2so59340467pfa.2
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 21:01:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160715210952.089a793e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 09:09:52PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Fri, 15 Jul 2016 09:47:46 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> > On Fri, Jul 15, 2016 at 09:18:13AM -0700, Tom Herbert wrote:
> [..]
> > > > We don't need extra comlexity of figuring out number of rings and
> > > > struggling with lack of atomicity.  
> > > 
> > > We already have this problem with other per ring configuration.  
> > 
> > not really. without atomicity of the program change, the user space
> > daemon that controls it will struggle to adjust. Consider the case
> > where we're pushing new update for loadbalancer. In such case we
> > want to reuse the established bpf map, since we cannot atomically
> > move it from old to new, but we want to swap the program that uses
> > in one go, otherwise two different programs will be accessing
> > the same map. Technically it's valid, but difference in the programs
> > may cause issues. Lack of atomicity is not intractable problem,
> > it just makes user space quite a bit more complex for no reason.
> 
> I don't think you have a problem with updating the program per queue
> basis, as they will be updated atomically per RX queue (thus a CPU can
> only see one program).
>  Today, you already have to handle that multiple CPUs running the same
> program, need to access the same map.
> 
> You mention that, there might be a problem, if the program differs too
> much to share the map.  But that is the same problem as today.  If you
> need to load a program that e.g. change the map layout, then you
> obviously cannot allow it inherit the old map, but must feed the new
> program a new map (with the new layout).
> 
> 
> There is actually a performance advantage of knowing that a program is
> only attached to a single RX queue. As only a single CPU can process a
> RX ring. Thus, when e.g. accessing a map (or other lookup table) you can
> avoid any locking.

rx queue is not always == cpu. We have different nics with different
number of queues. We'll try to keep dataplane and control plane as generic
as possible otherwise it's operational headache. That's why 'attach to all'
default makes the most sense.
I've been thinking more about atomicity and think we'll be able to
add 'prog per rx queue' while preserving atomicity.
We can do it by extra indirection 'struct bpf_prog **prog'. The xchg
will be swapping the single pointer while all rings will be pointing to it.
Anyway I think we need to table this discussion, since Jesper's email
is already bouncing with happy vacation message :) and Tom is traveling.
I'm pretty sure we'll be able to add support for 'prog per rx ring'
while preserving atomicity of prog swap that this patch does.
