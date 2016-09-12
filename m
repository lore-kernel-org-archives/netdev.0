From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
	more
Date: Mon, 12 Sep 2016 13:30:25 +0200
Message-ID: <20160912133025.5b35c25b@redhat.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
	<20160909032202.GA62966@ast-mbp.thefacebook.com>
	<20160909073652.351d76d7@redhat.com>
	<20160909063048.GA67375@ast-mbp.thefacebook.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160909063048.GA67375-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Sep 2016 23:30:50 -0700
Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Fri, Sep 09, 2016 at 07:36:52AM +0200, Jesper Dangaard Brouer wrote:
[...]
> > Imagine you have packets intermixed towards the stack and XDP_TX. 
> > Every time you call the stack code, then you flush your icache.  When
> > returning to the driver code, you will have to reload all the icache
> > associated with the XDP_TX, this is a costly operation.  
> 
[...]
> To make further progress in this discussion can we talk about
> the use case you have in mind instead? Then solution will
> be much clear, I hope.

The DDoS use-case _is_ affected by this "hidden" bulking design.

Lets say, I want to implement a DDoS facility. Instead of just
dropping the malicious packets, I want to see the bad packets.  I
implement this by rewriting the destination-MAC to be my monitor
machine and then XDP_TX the packet.

In the DDoS use-case, you have loaded your XDP/eBPF program, and 100%
of the traffic is delivered to the stack. (See note 1)

Once the DDoS attack starts, then the traffic pattern changes, and XDP
should (hopefully only) catch the malicious traffic (monitor machine can
help diagnose false positive).  Now, due to interleaving the DDoS
traffic with the clean traffic, then efficiency of XDP_TX is reduced due to
more icache misses...



Note(1): Notice I have already demonstrated that loading a XDP/eBPF
program with 100% delivery to the stack, actually slows down the
normal stack.  This is due to hitting a bottleneck in the page
allocator.  I'm working removing that bottleneck with page_pool, and
that solution is orthogonal to this problem.
 It is actually an excellent argument, for why you would want to run a
DDoS XDP filter only on a restricted number of RX queues.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
