From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Fri, 15 Jul 2016 21:09:52 +0200
Message-ID: <20160715210952.089a793e@redhat.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
	<1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
	<20160714092543.776f8d8c@redhat.com>
	<20160715033057.GA98180@ast-mbp.thefacebook.com>
	<CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
	<20160715164744.GA3693@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbcGOTKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 15:10:00 -0400
In-Reply-To: <20160715164744.GA3693@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 15 Jul 2016 09:47:46 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Fri, Jul 15, 2016 at 09:18:13AM -0700, Tom Herbert wrote:
[..]
> > > We don't need extra comlexity of figuring out number of rings and
> > > struggling with lack of atomicity.  
> > 
> > We already have this problem with other per ring configuration.  
> 
> not really. without atomicity of the program change, the user space
> daemon that controls it will struggle to adjust. Consider the case
> where we're pushing new update for loadbalancer. In such case we
> want to reuse the established bpf map, since we cannot atomically
> move it from old to new, but we want to swap the program that uses
> in one go, otherwise two different programs will be accessing
> the same map. Technically it's valid, but difference in the programs
> may cause issues. Lack of atomicity is not intractable problem,
> it just makes user space quite a bit more complex for no reason.

I don't think you have a problem with updating the program per queue
basis, as they will be updated atomically per RX queue (thus a CPU can
only see one program).
 Today, you already have to handle that multiple CPUs running the same
program, need to access the same map.

You mention that, there might be a problem, if the program differs too
much to share the map.  But that is the same problem as today.  If you
need to load a program that e.g. change the map layout, then you
obviously cannot allow it inherit the old map, but must feed the new
program a new map (with the new layout).


There is actually a performance advantage of knowing that a program is
only attached to a single RX queue. As only a single CPU can process a
RX ring. Thus, when e.g. accessing a map (or other lookup table) you can
avoid any locking.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
